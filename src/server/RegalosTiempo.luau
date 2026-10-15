-- Regalos por tiempo jugado: cuanto mas te quedas en la sesion, mas monedas recibis.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Jugadores = require(script.Parent.Jugadores)

local RegalosTiempo = {}

local function seguir(jugador)
	local entrada = os.time()
	for indice, regalo in Config.REGALOS do
		local momento = entrada + regalo.minutos * 60
		jugador:SetAttribute("RegaloIndice", indice)
		jugador:SetAttribute("RegaloEn", momento)

		while jugador.Parent and os.time() < momento do
			task.wait(1)
		end
		if not jugador.Parent then
			return
		end

		local stats = jugador:FindFirstChild("leaderstats")
		if stats then
			local monedas = math.floor(regalo.monedas * Jugadores.multiplicadorMonedas(jugador))
			stats.Monedas.Value += monedas
			Jugadores.avisar(
				jugador,
				string.format("Regalo por %d min jugados: +%d monedas", regalo.minutos, monedas)
			)
		end
	end
	jugador:SetAttribute("RegaloEn", 0)
end

function RegalosTiempo.iniciar()
	Players.PlayerAdded:Connect(function(jugador)
		task.spawn(seguir, jugador)
	end)
	for _, jugador in Players:GetPlayers() do
		task.spawn(seguir, jugador)
	end
end

return RegalosTiempo
