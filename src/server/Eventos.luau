-- Evento Dorado: cada tanto, todo el servidor gana monedas x2 por un rato. Crea momentos compartidos.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Jugadores = require(script.Parent.Jugadores)

local Eventos = {}

local function refrescarTodos()
	for _, jugador in Players:GetPlayers() do
		Jugadores.refrescar(jugador)
	end
end

function Eventos.iniciar()
	task.spawn(function()
		task.wait(Config.EVENTO_PRIMERO)
		while true do
			workspace:SetAttribute("EventoHasta", os.time() + Config.EVENTO_DURACION)
			refrescarTodos()
			for _, jugador in Players:GetPlayers() do
				Jugadores.avisar(
					jugador,
					"EVENTO DORADO! Monedas x2 por " .. Config.EVENTO_DURACION .. " segundos"
				)
			end

			task.wait(Config.EVENTO_DURACION + 1)
			refrescarTodos()
			task.wait(Config.EVENTO_CADA)
		end
	end)
end

return Eventos
