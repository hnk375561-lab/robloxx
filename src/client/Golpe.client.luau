-- Puños en primera persona, golpes con click y efectos.
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local remoto = ReplicatedStorage:WaitForChild("Golpear")

local jugador = Players.LocalPlayer
local camara = workspace.CurrentCamera

local COLOR_PIEL = Color3.fromRGB(234, 184, 146)
local COLOR_MANGA = Color3.fromRGB(60, 80, 60)

-- ====== Puños (viewmodel) ======
local modelo = Instance.new("Folder")
modelo.Name = "Punos"
modelo.Parent = camara

local function crearParte(tamano, color)
	local parte = Instance.new("Part")
	parte.Size = tamano
	parte.Color = color
	parte.Material = Enum.Material.SmoothPlastic
	parte.Anchored = true
	parte.CanCollide = false
	parte.CanQuery = false
	parte.CanTouch = false
	parte.CastShadow = false
	parte.Parent = modelo
	return parte
end

local manos = {
	{
		lado = 1,
		puno = crearParte(Vector3.new(1.1, 1.1, 1.1), COLOR_PIEL),
		brazo = crearParte(Vector3.new(0.9, 0.9, 2.6), COLOR_MANGA),
		golpe = 0,
	},
	{
		lado = -1,
		puno = crearParte(Vector3.new(1.1, 1.1, 1.1), COLOR_PIEL),
		brazo = crearParte(Vector3.new(0.9, 0.9, 2.6), COLOR_MANGA),
		golpe = 0,
	},
}

-- ====== Estado ======
local manteniendo = false
local ultimoGolpe = 0
local proximaMano = 1
local sacudida = 0
local tiempo = 0

local resalte = Instance.new("Highlight")
resalte.FillTransparency = 1
resalte.OutlineColor = Color3.fromRGB(255, 140, 60)
resalte.OutlineTransparency = 0
resalte.Enabled = false
resalte.Parent = workspace

local filtro = RaycastParams.new()
filtro.FilterType = Enum.RaycastFilterType.Exclude

local function objetivo()
	local excluidos = { modelo }
	if jugador.Character then
		table.insert(excluidos, jugador.Character)
	end
	filtro.FilterDescendantsInstances = excluidos

	local pantalla = camara.ViewportSize
	local rayo = camara:ViewportPointToRay(pantalla.X / 2, pantalla.Y / 2)
	local resultado = workspace:Raycast(rayo.Origin, rayo.Direction * Config.ALCANCE, filtro)
	if resultado and CollectionService:HasTag(resultado.Instance, "Voxel") then
		return resultado
	end
	return nil
end

local function chispas(posicion, color)
	local ancla = Instance.new("Part")
	ancla.Anchored = true
	ancla.CanCollide = false
	ancla.CanQuery = false
	ancla.CanTouch = false
	ancla.Transparency = 1
	ancla.Size = Vector3.new(0.2, 0.2, 0.2)
	ancla.Position = posicion
	ancla.Parent = workspace

	local emisor = Instance.new("ParticleEmitter")
	emisor.Color = ColorSequence.new(color)
	emisor.Size = NumberSequence.new(0.4, 0)
	emisor.Lifetime = NumberRange.new(0.4, 0.8)
	emisor.Speed = NumberRange.new(8, 16)
	emisor.SpreadAngle = Vector2.new(180, 180)
	emisor.Acceleration = Vector3.new(0, -40, 0)
	emisor.Rate = 0
	emisor.Parent = ancla
	emisor:Emit(8)

	Debris:AddItem(ancla, 1.5)
end

local function golpear()
	local ahora = os.clock()
	if ahora - ultimoGolpe < Config.ENFRIAMIENTO then
		return
	end
	ultimoGolpe = ahora

	manos[proximaMano].golpe = 1
	proximaMano = if proximaMano == 1 then 2 else 1
	sacudida = 1.5

	local resultado = objetivo()
	if resultado then
		remoto:FireServer(resultado.Instance)
		chispas(resultado.Position, resultado.Instance.Color)
	end
end

-- ====== Entrada (PC y celular) ======
local function esGolpe(entrada)
	return entrada.UserInputType == Enum.UserInputType.MouseButton1
		or entrada.UserInputType == Enum.UserInputType.Touch
end

UserInputService.InputBegan:Connect(function(entrada, procesado)
	if not procesado and esGolpe(entrada) then
		manteniendo = true
	end
end)

UserInputService.InputEnded:Connect(function(entrada)
	if esGolpe(entrada) then
		manteniendo = false
	end
end)

-- ====== Cada cuadro ======
RunService:BindToRenderStep("Golpes", Enum.RenderPriority.Camera.Value + 1, function(dt)
	tiempo += dt

	if manteniendo then
		golpear()
	end

	-- Contorno sobre el cubito apuntado
	local mirado = objetivo()
	if mirado then
		resalte.Adornee = mirado.Instance
		resalte.Enabled = true
	else
		resalte.Enabled = false
	end

	-- Temblor de camara
	if sacudida > 0 then
		local rx = math.rad((math.random() - 0.5) * sacudida)
		local ry = math.rad((math.random() - 0.5) * sacudida)
		camara.CFrame = camara.CFrame * CFrame.Angles(rx, ry, 0)
		sacudida = math.max(0, sacudida - dt * 6)
	end

	-- Balanceo al caminar
	local velocidad = 0
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	if raiz then
		local v = raiz.AssemblyLinearVelocity
		velocidad = Vector3.new(v.X, 0, v.Z).Magnitude
	end
	local balanceo = math.sin(tiempo * 9) * 0.05 * math.min(velocidad / 16, 1)

	for _, mano in manos do
		mano.golpe = math.max(0, mano.golpe - dt * 5)
		local avance = math.sin((1 - mano.golpe) * math.pi)

		local base = camara.CFrame
			* CFrame.new(mano.lado * 1.0, -0.95 + balanceo, -1.9 - avance * 1.8)
			* CFrame.Angles(math.rad(-8), math.rad(-mano.lado * 6), 0)
		mano.puno.CFrame = base
		mano.brazo.CFrame = base
			* CFrame.new(mano.lado * 0.15, -0.3, 1.9)
			* CFrame.Angles(math.rad(-6), 0, 0)
	end
end)
