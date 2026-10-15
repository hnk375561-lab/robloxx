-- Datos de cada jugador: contadores arriba a la derecha y fuerza.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Jugadores = {}

-- Cuanto cuesta pasar de la fuerza actual a la siguiente
function Jugadores.costoDeFuerza(fuerza)
	return Config.COSTO_BASE_FUERZA * fuerza * fuerza
end

local function alEntrar(jugador)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"

	local items = Instance.new("IntValue")
	items.Name = "Items"
	items.Parent = stats

	local monedas = Instance.new("IntValue")
	monedas.Name = "Monedas"
	monedas.Parent = stats

	local fuerza = Instance.new("IntValue")
	fuerza.Name = "Fuerza"
	fuerza.Value = 1
	fuerza.Parent = stats

	stats.Parent = jugador

	-- La fuerza "de verdad" es el atributo. Lo usan las paredes y la tienda.
	jugador:SetAttribute("Fuerza", 1)
	jugador:SetAttribute("CostoFuerza", Jugadores.costoDeFuerza(1))
	jugador:GetAttributeChangedSignal("Fuerza"):Connect(function()
		local actual = jugador:GetAttribute("Fuerza") or 1
		fuerza.Value = actual
		jugador:SetAttribute("CostoFuerza", Jugadores.costoDeFuerza(actual))
	end)
end

function Jugadores.iniciar()
	Players.PlayerAdded:Connect(alEntrar)
	for _, jugador in Players:GetPlayers() do
		alEntrar(jugador)
	end
end

return Jugadores
