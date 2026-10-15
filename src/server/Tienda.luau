-- Puestos del Trueque (items -> monedas) y la Herreria (monedas -> fuerza).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Jugadores = require(script.Parent.Jugadores)

local Tienda = {}

local function crearPuesto(nombre, posicion, color, textoAccion, accion)
	local base = Instance.new("Part")
	base.Name = nombre
	base.Size = Vector3.new(6, 5, 4)
	base.Position = posicion + Vector3.new(0, 2.5, 0)
	base.Anchored = true
	base.Color = color
	base.Material = Enum.Material.WoodPlanks
	base.Parent = workspace

	local cartel = Instance.new("BillboardGui")
	cartel.Size = UDim2.fromOffset(200, 50)
	cartel.StudsOffset = Vector3.new(0, 4, 0)
	cartel.AlwaysOnTop = true
	cartel.Parent = base

	local texto = Instance.new("TextLabel")
	texto.Size = UDim2.fromScale(1, 1)
	texto.BackgroundTransparency = 1
	texto.Text = nombre
	texto.TextScaled = true
	texto.FontFace = Font.fromEnum(Enum.Font.GothamBold)
	texto.TextColor3 = Color3.new(1, 1, 1)
	texto.TextStrokeTransparency = 0
	texto.Parent = cartel

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = textoAccion
	prompt.ObjectText = nombre
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = base
	prompt.Triggered:Connect(accion)
end

local function venderItems(jugador)
	local stats = jugador:FindFirstChild("leaderstats")
	if not stats then
		return
	end
	local cantidad = stats.Items.Value
	if cantidad <= 0 then
		return
	end
	stats.Items.Value = 0
	stats.Monedas.Value += cantidad * Config.PRECIO_ITEM
end

local function mejorarFuerza(jugador)
	local stats = jugador:FindFirstChild("leaderstats")
	if not stats then
		return
	end
	local fuerza = jugador:GetAttribute("Fuerza") or 1
	local costo = Jugadores.costoDeFuerza(fuerza)
	if stats.Monedas.Value < costo then
		return
	end
	stats.Monedas.Value -= costo
	jugador:SetAttribute("Fuerza", fuerza + 1)
end

function Tienda.crear()
	crearPuesto(
		"Trueque",
		Vector3.new(-12, 0, 0),
		Color3.fromRGB(200, 160, 60),
		"Vender items",
		venderItems
	)
	crearPuesto(
		"Herreria",
		Vector3.new(0, 0, -12),
		Color3.fromRGB(110, 110, 120),
		"Mejorar fuerza",
		mejorarFuerza
	)
end

return Tienda
