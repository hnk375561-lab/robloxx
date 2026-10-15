-- Brazos en primera persona, golpes con click, efectos y numeros de dano.
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local remoto = ReplicatedStorage:WaitForChild("Golpear")

local jugador = Players.LocalPlayer
local camara = workspace.CurrentCamera

local COLOR_PIEL = Color3.fromRGB(226, 172, 134)
local COLOR_PIEL_CLARA = Color3.fromRGB(240, 192, 156)
local COLOR_MANGA = Color3.fromRGB(54, 74, 58)
local COLOR_PUNO_MANGA = Color3.fromRGB(34, 46, 36)
local FOV_BASE = 72
local GIRO_Z = CFrame.Angles(0, math.rad(90), 0)

-- ====== Brazos (viewmodel) ======
local modelo = Instance.new("Folder")
modelo.Name = "Brazos"
modelo.Parent = camara

local function nuevaParte(tamano, color)
	local pieza = Instance.new("Part")
	pieza.Size = tamano
	pieza.Color = color
	pieza.Material = Enum.Material.SmoothPlastic
	pieza.Anchored = true
	pieza.CanCollide = false
	pieza.CanQuery = false
	pieza.CanTouch = false
	pieza.CastShadow = false
	pieza.Parent = modelo
	return pieza
end

local function esfera(tamano, color)
	local pieza = nuevaParte(tamano, color)
	local malla = Instance.new("SpecialMesh")
	malla.MeshType = Enum.MeshType.Sphere
	malla.Parent = pieza
	return pieza
end

local function cilindro(largo, diametro, color)
	local pieza = nuevaParte(Vector3.new(largo, diametro, diametro), color)
	pieza.Shape = Enum.PartType.Cylinder
	return pieza
end

local function crearMano(lado)
	local piezas = {}
	local function agregar(pieza, offset)
		table.insert(piezas, { pieza = pieza, offset = offset })
	end

	-- puño
	agregar(esfera(Vector3.new(1.15, 1.0, 1.25), COLOR_PIEL), CFrame.new(0, 0, 0))
	-- nudillos
	for k = 0, 3 do
		agregar(
			esfera(Vector3.new(0.34, 0.34, 0.34), COLOR_PIEL_CLARA),
			CFrame.new(-0.4 + k * 0.265, 0.18, -0.58)
		)
	end
	-- pulgar
	agregar(
		esfera(Vector3.new(0.38, 0.38, 0.8), COLOR_PIEL),
		CFrame.new(-lado * 0.52, 0.12, -0.15) * CFrame.Angles(0, math.rad(lado * 10), 0)
	)
	-- muñeca, puño de manga y manga
	agregar(cilindro(1.0, 0.75, COLOR_PIEL), CFrame.new(0, -0.05, 0.95) * GIRO_Z)
	agregar(cilindro(0.4, 1.15, COLOR_PUNO_MANGA), CFrame.new(0, -0.08, 1.5) * GIRO_Z)
	agregar(cilindro(2.6, 1.05, COLOR_MANGA), CFrame.new(0, -0.12, 2.9) * GIRO_Z)

	return { lado = lado, golpe = 0, piezas = piezas }
end

local manos = { crearMano(1), crearMano(-1) }

-- ====== Estado ======
local manteniendo = false
local ultimoGolpe = 0
local proximaMano = 1
local sacudida = 0
local fovExtra = 0
local tiempo = 0
local swayX = 0
local swayY = 0

local resalte = Instance.new("Highlight")
resalte.FillColor = Color3.new(1, 1, 1)
resalte.FillTransparency = 0.85
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

local function numeroFlotante(posicion, texto)
	local ancla = Instance.new("Part")
	ancla.Anchored = true
	ancla.CanCollide = false
	ancla.CanQuery = false
	ancla.CanTouch = false
	ancla.Transparency = 1
	ancla.Size = Vector3.new(0.2, 0.2, 0.2)
	ancla.Position = posicion
		+ Vector3.new(math.random(-10, 10) / 10, 0.5, math.random(-10, 10) / 10)
	ancla.Parent = workspace

	local cartel = Instance.new("BillboardGui")
	cartel.Size = UDim2.fromOffset(100, 40)
	cartel.AlwaysOnTop = true
	cartel.Parent = ancla

	local letras = Instance.new("TextLabel")
	letras.Size = UDim2.fromScale(1, 1)
	letras.BackgroundTransparency = 1
	letras.Text = texto
	letras.TextScaled = true
	letras.FontFace = Font.fromEnum(Enum.Font.GothamBlack)
	letras.TextColor3 = Color3.fromRGB(255, 235, 170)
	letras.TextStrokeTransparency = 0
	letras.Parent = cartel

	local info = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(cartel, info, { StudsOffset = Vector3.new(0, 3.5, 0) }):Play()
	TweenService:Create(letras, info, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()

	Debris:AddItem(ancla, 0.9)
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
		numeroFlotante(resultado.Position, "-" .. tostring(jugador:GetAttribute("Fuerza") or 1))
		fovExtra = 3.5
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

	-- Temblor de camara y pequeno zoom al golpear
	if sacudida > 0 then
		local rx = math.rad((math.random() - 0.5) * sacudida)
		local ry = math.rad((math.random() - 0.5) * sacudida)
		camara.CFrame = camara.CFrame * CFrame.Angles(rx, ry, 0)
		sacudida = math.max(0, sacudida - dt * 6)
	end
	fovExtra = fovExtra * (1 - math.min(dt * 14, 1))
	camara.FieldOfView = FOV_BASE + fovExtra

	-- Los brazos se retrasan un poco respecto al mouse
	local giro = UserInputService:GetMouseDelta()
	local suavizado = math.min(dt * 10, 1)
	swayX = swayX + (math.clamp(-giro.X * 0.004, -0.5, 0.5) - swayX) * suavizado
	swayY = swayY + (math.clamp(giro.Y * 0.004, -0.4, 0.4) - swayY) * suavizado

	-- Balanceo al caminar
	local velocidad = 0
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	if raiz then
		local v = raiz.AssemblyLinearVelocity
		velocidad = Vector3.new(v.X, 0, v.Z).Magnitude
	end
	local intensidad = math.min(velocidad / 16, 1)
	local balanceoX = math.cos(tiempo * 9) * 0.05 * intensidad
	local balanceoY = math.sin(tiempo * 18) * 0.04 * intensidad

	for _, mano in manos do
		mano.golpe = math.max(0, mano.golpe - dt * 5)
		local avance = math.sin((1 - mano.golpe) * math.pi)

		local base = camara.CFrame
			* CFrame.new(
				mano.lado * (1.05 - avance * 0.55) + balanceoX + swayX,
				-1.0 + balanceoY + swayY - avance * 0.15,
				-1.9 - avance * 1.9
			)
			* CFrame.Angles(
				math.rad(10 - avance * 14),
				math.rad(-mano.lado * (8 - avance * 12)),
				math.rad(mano.lado * (4 + avance * 18))
			)

		for _, dato in mano.piezas do
			dato.pieza.CFrame = base * dato.offset
		end
	end
end)
