-- Chispazos al romper cristales, destello al recoger fragmentos y una linterna suave.
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local jugador = Players.LocalPlayer
local camara = workspace.CurrentCamera
local esCelular = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local Sonidos = require(script.Parent:WaitForChild("Sonidos"))

local fragmentos = workspace:WaitForChild("Fragmentos")

local function ancla(posicion)
	local parte = Instance.new("Part")
	parte.Anchored = true
	parte.CanCollide = false
	parte.CanQuery = false
	parte.CanTouch = false
	parte.CastShadow = false
	parte.Transparency = 1
	parte.Size = Vector3.new(0.2, 0.2, 0.2)
	parte.Position = posicion
	parte.Parent = workspace
	return parte
end

-- ====== Cristal roto: chispas de su color y un flash de luz ======
local activos = 0

local function destelloCristal(posicion, color)
	if activos >= 10 then
		return
	end
	activos += 1
	task.delay(1.5, function()
		activos -= 1
	end)

	Sonidos.cristal()
	local punto = ancla(posicion)

	local emisor = Instance.new("ParticleEmitter")
	emisor.Color = ColorSequence.new(color)
	emisor.LightEmission = 1
	emisor.Size = NumberSequence.new(0.5, 0)
	emisor.Lifetime = NumberRange.new(0.5, 0.9)
	emisor.Speed = NumberRange.new(10, 20)
	emisor.SpreadAngle = Vector2.new(180, 180)
	emisor.Acceleration = Vector3.new(0, -25, 0)
	emisor.Rate = 0
	emisor.Parent = punto
	emisor:Emit(16)

	local luz = Instance.new("PointLight")
	luz.Color = color
	luz.Brightness = 3
	luz.Range = 14
	luz.Shadows = false
	luz.Parent = punto
	TweenService:Create(luz, TweenInfo.new(0.5), { Brightness = 0 }):Play()

	Debris:AddItem(punto, 1.5)
end

fragmentos.ChildAdded:Connect(function(parte)
	if parte:IsA("BasePart") and parte.Material == Enum.Material.Neon then
		destelloCristal(parte.Position, parte.Color)
	end
end)

-- ====== Recoger fragmentos: destello dorado ======
local puntoRecoger = ancla(Vector3.new(0, -100, 0))
local brilloRecoger = Instance.new("ParticleEmitter")
brilloRecoger.Color = ColorSequence.new(Color3.fromRGB(255, 235, 170))
brilloRecoger.LightEmission = 1
brilloRecoger.Size = NumberSequence.new(0.35, 0)
brilloRecoger.Lifetime = NumberRange.new(0.3, 0.5)
brilloRecoger.Speed = NumberRange.new(4, 8)
brilloRecoger.SpreadAngle = Vector2.new(180, 180)
brilloRecoger.Rate = 0
brilloRecoger.Parent = puntoRecoger

fragmentos.ChildRemoved:Connect(function(parte)
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	if raiz and parte:IsA("BasePart") and (raiz.Position - parte.Position).Magnitude < 6 then
		puntoRecoger.Position = parte.Position
		brilloRecoger:Emit(3)
		Sonidos.recoger()
	end
end)

-- ====== Sonidos de monedas y de mejora de fuerza ======
task.spawn(function()
	local stats = jugador:WaitForChild("leaderstats")
	local monedas = stats:WaitForChild("Monedas")
	local fuerza = stats:WaitForChild("Fuerza")
	local ultimasMonedas = monedas.Value
	local ultimaFuerza = fuerza.Value

	monedas.Changed:Connect(function(nuevo)
		if nuevo > ultimasMonedas then
			Sonidos.moneda()
		end
		ultimasMonedas = nuevo
	end)
	fuerza.Changed:Connect(function(nuevo)
		if nuevo > ultimaFuerza then
			Sonidos.mejora()
		end
		ultimaFuerza = nuevo
	end)
end)

-- ====== Linterna suave que sigue la camara (solo PC) ======
if not esCelular then
	local base = ancla(Vector3.new(0, 0, 0))
	base.Parent = camara

	local linterna = Instance.new("PointLight")
	linterna.Color = Color3.fromRGB(255, 226, 190)
	linterna.Brightness = 0.45
	linterna.Range = 22
	linterna.Shadows = false
	linterna.Parent = base

	RunService.RenderStepped:Connect(function()
		base.CFrame = camara.CFrame
	end)
end
