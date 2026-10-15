-- Recompensa diaria con racha: volver todos los dias da mas monedas (clave para retener jugadores).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Jugadores = require(script.Parent.Jugadores)

local Recompensa = {}

-- Se llama cuando los datos del jugador ya estan cargados.
function Recompensa.revisar(jugador)
	local stats = jugador:FindFirstChild("leaderstats")
	if not stats then
		return
	end

	local ahora = os.time()
	local ultima = jugador:GetAttribute("UltimaRecompensa") or 0
	local pasado = ahora - ultima
	local espera = Config.HORAS_RECOMPENSA * 3600
	if pasado < espera then
		return
	end

	local racha = jugador:GetAttribute("Racha") or 0
	if pasado > espera * 2.4 then
		racha = 0 -- falto mas de un dia: se pierde la racha
	end
	racha = math.min(racha + 1, Config.RACHA_MAXIMA)

	local monedas = Config.RECOMPENSA_BASE * racha
	stats.Monedas.Value += monedas
	jugador:SetAttribute("Racha", racha)
	jugador:SetAttribute("UltimaRecompensa", ahora)
	Jugadores.avisar(
		jugador,
		string.format("Recompensa diaria dia %d: +%d monedas", racha, monedas)
	)
end

return Recompensa
