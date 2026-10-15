-- Datos de cada jugador: contadores arriba a la derecha y fuerza.
local Players = game:GetService("Players")

local Jugadores = {}

local function alEntrar(jugador)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"

	local items = Instance.new("IntValue")
	items.Name = "Items"
	items.Parent = stats

	local monedas = Instance.new("IntValue")
	monedas.Name = "Monedas"
	monedas.Parent = stats

	stats.Parent = jugador
	jugador:SetAttribute("Fuerza", 1)
end

function Jugadores.iniciar()
	Players.PlayerAdded:Connect(alEntrar)
	for _, jugador in Players:GetPlayers() do
		alEntrar(jugador)
	end
end

return Jugadores
