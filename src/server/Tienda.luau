-- Puestos: Trueque (items -> monedas) y Herreria (monedas -> fuerza).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Jugadores = require(script.Parent.Jugadores)

local Tienda = {}

local MADERA = Color3.fromRGB(120, 82, 50)
local MADERA_OSCURA = Color3.fromRGB(86, 58, 36)

-- Crea una pieza anclada. Las posiciones son relativas al puesto (cf).
local function parte(modelo, nombre, tamano, cf, color, material)
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tamano
	p.CFrame = cf
	p.Anchored = true
	p.Color = color
	p.Material = material
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = modelo
	return p
end

local function cilindroParado(modelo, nombre, largo, diametro, cf, color, material)
	local p = parte(modelo, nombre, Vector3.new(largo, diametro, diametro), cf, color, material)
	p.Shape = Enum.PartType.Cylinder
	p.CFrame = cf * CFrame.Angles(0, 0, math.rad(90))
	return p
end

local function cartel(modelo, tamano, cf, texto)
	local tabla = parte(modelo, "Cartel", tamano, cf, MADERA_OSCURA, Enum.Material.WoodPlanks)
	local superficie = Instance.new("SurfaceGui")
	superficie.Face = Enum.NormalId.Front
	superficie.PixelsPerStud = 50
	superficie.Parent = tabla

	local letras = Instance.new("TextLabel")
	letras.Size = UDim2.fromScale(1, 1)
	letras.BackgroundTransparency = 1
	letras.Text = texto
	letras.TextScaled = true
	letras.FontFace = Font.fromEnum(Enum.Font.GothamBlack)
	letras.TextColor3 = Color3.fromRGB(245, 225, 180)
	letras.TextStrokeTransparency = 0.3
	letras.Parent = superficie
end

local function crearDestello(padre, color)
	local emisor = Instance.new("ParticleEmitter")
	emisor.Color = ColorSequence.new(color)
	emisor.LightEmission = 1
	emisor.Size = NumberSequence.new(0.6, 0)
	emisor.Lifetime = NumberRange.new(0.6, 1.2)
	emisor.Speed = NumberRange.new(12, 22)
	emisor.SpreadAngle = Vector2.new(60, 60)
	emisor.Acceleration = Vector3.new(0, -30, 0)
	emisor.Rate = 0
	emisor.Parent = padre
	return emisor
end

local function crearPrompt(padre, objeto, accion)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = accion
	prompt.ObjectText = objeto
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = padre
	return prompt
end

-- ====== Trueque: puesto de mercado ======
local function construirTrueque(posicion, frente, accion)
	local base = CFrame.lookAt(posicion, posicion + frente)
	local modelo = Instance.new("Model")
	modelo.Name = "Trueque"
	modelo.Parent = workspace

	local mostrador = parte(
		modelo,
		"Mostrador",
		Vector3.new(8, 3.5, 3),
		base * CFrame.new(0, 1.75, 0),
		MADERA,
		Enum.Material.WoodPlanks
	)
	parte(
		modelo,
		"Tapa",
		Vector3.new(8.6, 0.3, 3.6),
		base * CFrame.new(0, 3.65, 0),
		MADERA_OSCURA,
		Enum.Material.Wood
	)
	for _, x in { -4, 4 } do
		for _, z in { -1.5, 1.5 } do
			parte(
				modelo,
				"Poste",
				Vector3.new(0.5, 9, 0.5),
				base * CFrame.new(x, 4.5, z),
				MADERA_OSCURA,
				Enum.Material.Wood
			)
		end
	end

	-- Toldo a rayas
	for k = 1, 6 do
		local color = Color3.fromRGB(190, 60, 50)
		if k % 2 == 0 then
			color = Color3.fromRGB(235, 225, 200)
		end
		parte(
			modelo,
			"Toldo",
			Vector3.new(1.5, 0.3, 5),
			base * CFrame.new(-3.75 + (k - 1) * 1.5, 9.3, 0) * CFrame.Angles(math.rad(-10), 0, 0),
			color,
			Enum.Material.Fabric
		)
	end
	cartel(
		modelo,
		Vector3.new(6, 1.6, 0.4),
		base * CFrame.new(0, 10.9, -1.7) * CFrame.Angles(math.rad(-10), 0, 0),
		"TRUEQUE"
	)

	-- Cajas
	parte(
		modelo,
		"Caja",
		Vector3.new(2.4, 2.4, 2.4),
		base * CFrame.new(5.8, 1.2, 0.5),
		MADERA,
		Enum.Material.WoodPlanks
	)
	parte(
		modelo,
		"Caja",
		Vector3.new(1.8, 1.8, 1.8),
		base * CFrame.new(5.6, 3.3, 0.5) * CFrame.Angles(0, math.rad(20), 0),
		MADERA_OSCURA,
		Enum.Material.WoodPlanks
	)

	-- Monedas apiladas e items sobre el mostrador
	for k = 1, 4 do
		cilindroParado(
			modelo,
			"Moneda",
			0.25,
			1.2,
			base * CFrame.new(-2.5, 3.95 + (k - 1) * 0.26, -0.3),
			Color3.fromRGB(235, 190, 60),
			Enum.Material.Metal
		)
	end
	for k = 0, 3 do
		parte(
			modelo,
			"ItemDeExhibicion",
			Vector3.new(1.1, 1.1, 1.1),
			base * CFrame.new(0.8 + k * 1.3, 4.3, 0.2) * CFrame.Angles(0, math.rad(k * 17), 0),
			Color3.fromRGB(190, 130, 60),
			Enum.Material.Wood
		)
	end

	-- Farol
	local farol = parte(
		modelo,
		"Farol",
		Vector3.new(1, 1, 1),
		base * CFrame.new(-4, 7.4, -1.9),
		Color3.fromRGB(255, 210, 120),
		Enum.Material.Neon
	)
	farol.Shape = Enum.PartType.Ball
	local luz = Instance.new("PointLight")
	luz.Color = Color3.fromRGB(255, 200, 130)
	luz.Range = 18
	luz.Brightness = 2
	luz.Parent = farol

	local destello = crearDestello(mostrador, Color3.fromRGB(255, 215, 90))
	local prompt = crearPrompt(mostrador, "Trueque", "Vender items")
	prompt.Triggered:Connect(function(jugador)
		if accion(jugador) then
			destello:Emit(25)
		end
	end)
end

-- ====== Herreria: forja con fuego ======
local function construirHerreria(posicion, frente, accion)
	local base = CFrame.lookAt(posicion, posicion + frente)
	local modelo = Instance.new("Model")
	modelo.Name = "Herreria"
	modelo.Parent = workspace

	local piedra = Color3.fromRGB(96, 96, 102)
	local metal = Color3.fromRGB(58, 60, 66)

	local forja = parte(
		modelo,
		"Forja",
		Vector3.new(7, 4, 5),
		base * CFrame.new(0, 2, 0),
		piedra,
		Enum.Material.Slate
	)
	parte(
		modelo,
		"Chimenea",
		Vector3.new(2.6, 8, 2.6),
		base * CFrame.new(0, 8, 1.2),
		piedra,
		Enum.Material.Slate
	)
	local remate = parte(
		modelo,
		"Remate",
		Vector3.new(3.4, 0.6, 3.4),
		base * CFrame.new(0, 12.3, 1.2),
		metal,
		Enum.Material.Slate
	)

	-- Boca del horno y fuego
	parte(
		modelo,
		"Boca",
		Vector3.new(3.6, 2.2, 0.4),
		base * CFrame.new(0, 2.2, -2.55),
		Color3.fromRGB(25, 20, 20),
		Enum.Material.Slate
	)
	local brasas = parte(
		modelo,
		"Brasas",
		Vector3.new(3, 0.4, 0.2),
		base * CFrame.new(0, 1.4, -2.8),
		Color3.fromRGB(255, 110, 30),
		Enum.Material.Neon
	)
	brasas.CanCollide = false

	local fuegoParte = parte(
		modelo,
		"Fuego",
		Vector3.new(2.6, 0.6, 0.6),
		base * CFrame.new(0, 1.8, -2.9),
		Color3.new(1, 1, 1),
		Enum.Material.SmoothPlastic
	)
	fuegoParte.Transparency = 1
	fuegoParte.CanCollide = false

	local fuego = Instance.new("ParticleEmitter")
	fuego.Color = ColorSequence.new(Color3.fromRGB(255, 170, 60), Color3.fromRGB(220, 60, 20))
	fuego.LightEmission = 1
	fuego.Size = NumberSequence.new(1.4, 0)
	fuego.Transparency = NumberSequence.new(0.2, 1)
	fuego.Lifetime = NumberRange.new(0.6, 1.1)
	fuego.Speed = NumberRange.new(2, 4)
	fuego.Acceleration = Vector3.new(0, 6, 0)
	fuego.SpreadAngle = Vector2.new(15, 15)
	fuego.Rate = 25
	fuego.Parent = fuegoParte

	local luz = Instance.new("PointLight")
	luz.Color = Color3.fromRGB(255, 150, 70)
	luz.Range = 22
	luz.Brightness = 3
	luz.Parent = fuegoParte
	task.spawn(function()
		while luz.Parent do
			luz.Brightness = 2.5 + math.random() * 1.3
			task.wait(0.12)
		end
	end)

	-- Humo de la chimenea
	local humo = Instance.new("ParticleEmitter")
	humo.Color = ColorSequence.new(Color3.fromRGB(110, 110, 110))
	humo.Size = NumberSequence.new(2, 6)
	humo.Transparency = NumberSequence.new(0.5, 1)
	humo.Lifetime = NumberRange.new(3, 5)
	humo.Speed = NumberRange.new(3, 5)
	humo.SpreadAngle = Vector2.new(12, 12)
	humo.Rate = 6
	humo.Parent = remate

	-- Yunque sobre un tocon
	parte(
		modelo,
		"Tocon",
		Vector3.new(2.4, 2, 2.4),
		base * CFrame.new(6, 1, -1),
		MADERA,
		Enum.Material.WoodPlanks
	)
	parte(
		modelo,
		"YunqueBase",
		Vector3.new(2.6, 0.6, 2),
		base * CFrame.new(6, 2.3, -1),
		metal,
		Enum.Material.Metal
	)
	parte(
		modelo,
		"YunqueCintura",
		Vector3.new(1.6, 0.8, 1.2),
		base * CFrame.new(6, 3, -1),
		metal,
		Enum.Material.Metal
	)
	parte(
		modelo,
		"YunqueTapa",
		Vector3.new(3.8, 0.7, 1.7),
		base * CFrame.new(6, 3.75, -1),
		Color3.fromRGB(75, 78, 86),
		Enum.Material.Metal
	)
	parte(
		modelo,
		"YunqueCuerno",
		Vector3.new(1.2, 0.5, 1.2),
		base * CFrame.new(8.3, 3.75, -1),
		Color3.fromRGB(75, 78, 86),
		Enum.Material.Metal
	)

	-- Martillo
	parte(
		modelo,
		"MangoMartillo",
		Vector3.new(2.4, 0.25, 0.25),
		base * CFrame.new(5.5, 4.2, -1.3),
		MADERA,
		Enum.Material.Wood
	)
	parte(
		modelo,
		"CabezaMartillo",
		Vector3.new(0.6, 0.9, 0.9),
		base * CFrame.new(6.7, 4.35, -1.3),
		Color3.fromRGB(70, 72, 80),
		Enum.Material.Metal
	)

	-- Barril de agua
	cilindroParado(
		modelo,
		"Barril",
		2.6,
		2.2,
		base * CFrame.new(-5.5, 1.3, -0.5),
		MADERA,
		Enum.Material.WoodPlanks
	)
	cilindroParado(
		modelo,
		"AroBarril",
		0.2,
		2.35,
		base * CFrame.new(-5.5, 2, -0.5),
		metal,
		Enum.Material.Metal
	)

	cartel(modelo, Vector3.new(5.2, 1.4, 0.35), base * CFrame.new(0, 4.7, -1.9), "HERRERIA")

	local destello = crearDestello(forja, Color3.fromRGB(255, 170, 70))
	local prompt = crearPrompt(forja, "Herreria", "Mejorar fuerza")
	prompt.Triggered:Connect(function(jugador)
		if accion(jugador) then
			destello:Emit(30)
		end
	end)
end

local function venderItems(jugador)
	local stats = jugador:FindFirstChild("leaderstats")
	if not stats then
		return false
	end
	local cantidad = stats.Items.Value
	if cantidad <= 0 then
		return false
	end
	stats.Items.Value = 0
	stats.Monedas.Value += math.floor(
		cantidad * Config.PRECIO_ITEM * Jugadores.multiplicadorMonedas(jugador)
	)
	return true
end

local function mejorarFuerza(jugador)
	local stats = jugador:FindFirstChild("leaderstats")
	if not stats then
		return false
	end
	local fuerza = jugador:GetAttribute("Fuerza") or 1
	local costo = Jugadores.costoDeFuerza(fuerza)
	if stats.Monedas.Value < costo then
		return false
	end
	stats.Monedas.Value -= costo
	jugador:SetAttribute("Fuerza", fuerza + 1)
	return true
end

function Tienda.crear()
	-- "frente" apunta hacia donde aparecen los jugadores
	construirTrueque(Vector3.new(-12, 0, 0), Vector3.new(1, 0, 0), venderItems)
	construirHerreria(Vector3.new(0, 0, -12), Vector3.new(0, 0, 1), mejorarFuerza)
end

return Tienda
