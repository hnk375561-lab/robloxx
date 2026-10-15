-- Altar de renacer (prestigio): reinicia items, monedas y fuerza, pero suma un bonus permanente de monedas.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Jugadores = require(script.Parent.Jugadores)

local Renacer = {}

local PIEDRA = Color3.fromRGB(70, 72, 84)
local VIOLETA = Color3.fromRGB(170, 110, 255)

local function parte(modelo, tamano, cf, color, material)
	local p = Instance.new("Part")
	p.Size = tamano
	p.CFrame = cf
	p.Anchored = true
	p.Color = color
	p.Material = material
	p.Parent = modelo
	return p
end

local function renacerJugador(jugador)
	local stats = jugador:FindFirstChild("leaderstats")
	if not stats then
		return false
	end
	local fuerza = jugador:GetAttribute("Fuerza") or 1
	if fuerza < Config.FUERZA_PARA_RENACER then
		Jugadores.avisar(
			jugador,
			"Necesitas fuerza " .. Config.FUERZA_PARA_RENACER .. " para renacer"
		)
		return false
	end

	stats.Items.Value = 0
	stats.Monedas.Value = 0
	jugador:SetAttribute("Fuerza", 1)
	local nuevos = (jugador:GetAttribute("Renacimientos") or 0) + 1
	jugador:SetAttribute("Renacimientos", nuevos)
	Jugadores.avisar(
		jugador,
		string.format(
			"Renaciste! Monedas x%.1f para siempre",
			Jugadores.multiplicadorMonedas(jugador)
		)
	)
	return true
end

function Renacer.crear()
	local posicion = Vector3.new(12, 0, 0)
	local base = CFrame.lookAt(posicion, posicion + Vector3.new(-1, 0, 0))

	local modelo = Instance.new("Model")
	modelo.Name = "Altar"
	modelo.Parent = workspace

	parte(modelo, Vector3.new(6, 1, 6), base * CFrame.new(0, 0.5, 0), PIEDRA, Enum.Material.Slate)
	parte(modelo, Vector3.new(3, 3, 3), base * CFrame.new(0, 2.5, 0), PIEDRA, Enum.Material.Slate)

	local cristal = parte(
		modelo,
		Vector3.new(2, 3, 2),
		base * CFrame.new(0, 6, 0) * CFrame.Angles(math.rad(45), math.rad(45), 0),
		VIOLETA,
		Enum.Material.Neon
	)
	local luz = Instance.new("PointLight")
	luz.Color = VIOLETA
	luz.Range = 24
	luz.Brightness = 3
	luz.Parent = cristal

	local destello = Instance.new("ParticleEmitter")
	destello.Color = ColorSequence.new(VIOLETA)
	destello.LightEmission = 1
	destello.Size = NumberSequence.new(0.6, 0)
	destello.Lifetime = NumberRange.new(0.8, 1.6)
	destello.Speed = NumberRange.new(4, 10)
	destello.SpreadAngle = Vector2.new(180, 180)
	destello.Rate = 8
	destello.Parent = cristal

	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = "Altar (renacer)"
	prompt.ActionText = "Renacer"
	prompt.HoldDuration = 1.5
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = cristal
	prompt.Triggered:Connect(function(jugador)
		if renacerJugador(jugador) then
			destello:Emit(60)
		end
	end)
end

return Renacer
