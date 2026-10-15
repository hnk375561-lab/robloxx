-- Armeria: se compran armas en orden con monedas. Cada arma multiplica el dano de los golpes.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Jugadores = require(script.Parent.Jugadores)

local Armeria = {}

local MADERA = Color3.fromRGB(120, 82, 50)
local MADERA_OSCURA = Color3.fromRGB(86, 58, 36)
local METAL = Color3.fromRGB(150, 155, 165)

local function parte(modelo, nombre, tamano, cf, color, material)
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tamano
	p.CFrame = cf
	p.Anchored = true
	p.Color = color
	p.Material = material
	p.Parent = modelo
	return p
end

local function comprar(jugador)
	local stats = jugador:FindFirstChild("leaderstats")
	if not stats then
		return false
	end
	local actual = jugador:GetAttribute("Arma") or 1
	local siguiente = Config.ARMAS[actual + 1]
	if not siguiente then
		Jugadores.avisar(jugador, "Ya tenes la mejor arma!")
		return false
	end
	if stats.Monedas.Value < siguiente.precio then
		Jugadores.avisar(
			jugador,
			string.format("%s cuesta %d monedas", siguiente.nombre, siguiente.precio)
		)
		return false
	end
	stats.Monedas.Value -= siguiente.precio
	jugador:SetAttribute("Arma", actual + 1)
	Jugadores.avisar(
		jugador,
		string.format("Nueva arma: %s (dano x%.1f)", siguiente.nombre, siguiente.dano)
	)
	return true
end

function Armeria.crear()
	local posicion = Vector3.new(0, 0, 12)
	local base = CFrame.lookAt(posicion, posicion + Vector3.new(0, 0, -1))

	local modelo = Instance.new("Model")
	modelo.Name = "Armeria"
	modelo.Parent = workspace

	-- Mesa y estante con armas de adorno
	local mesa = parte(
		modelo,
		"Mesa",
		Vector3.new(9, 3, 3),
		base * CFrame.new(0, 1.5, 0),
		MADERA,
		Enum.Material.WoodPlanks
	)
	parte(
		modelo,
		"Tapa",
		Vector3.new(9.6, 0.3, 3.6),
		base * CFrame.new(0, 3.15, 0),
		MADERA_OSCURA,
		Enum.Material.Wood
	)
	for _, x in { -4.4, 4.4 } do
		parte(
			modelo,
			"Poste",
			Vector3.new(0.5, 9, 0.5),
			base * CFrame.new(x, 4.5, 1.2),
			MADERA_OSCURA,
			Enum.Material.Wood
		)
	end
	parte(
		modelo,
		"Estante",
		Vector3.new(9.4, 0.4, 1.2),
		base * CFrame.new(0, 7.5, 1.2),
		MADERA_OSCURA,
		Enum.Material.Wood
	)
	for k = 0, 3 do
		local x = -3.3 + k * 2.2
		parte(
			modelo,
			"Mango",
			Vector3.new(0.35, 3.2, 0.35),
			base * CFrame.new(x, 9.3, 1.2),
			MADERA,
			Enum.Material.Wood
		)
		parte(
			modelo,
			"Cabeza",
			Vector3.new(1.6, 0.8, 0.5),
			base * CFrame.new(x, 11.1, 1.2),
			METAL,
			Enum.Material.Metal
		)
	end

	local cartel = parte(
		modelo,
		"Cartel",
		Vector3.new(6, 1.4, 0.4),
		base * CFrame.new(0, 5.6, -1.2),
		MADERA_OSCURA,
		Enum.Material.WoodPlanks
	)
	local superficie = Instance.new("SurfaceGui")
	superficie.Face = Enum.NormalId.Front
	superficie.PixelsPerStud = 50
	superficie.Parent = cartel
	local letras = Instance.new("TextLabel")
	letras.Size = UDim2.fromScale(1, 1)
	letras.BackgroundTransparency = 1
	letras.Text = "ARMERIA"
	letras.TextScaled = true
	letras.FontFace = Font.fromEnum(Enum.Font.GothamBlack)
	letras.TextColor3 = Color3.fromRGB(245, 225, 180)
	letras.Parent = superficie

	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = "Armeria"
	prompt.ActionText = "Comprar siguiente arma"
	prompt.HoldDuration = 0.3
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = mesa
	prompt.Triggered:Connect(comprar)
end

return Armeria
