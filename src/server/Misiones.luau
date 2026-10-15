-- Misiones infinitas: romper cubitos da progreso; al completar, premio en monedas y mision mas grande.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Jugadores = require(script.Parent.Jugadores)

local Misiones = {}

function Misiones.meta(numero)
	return Config.MISION_META * numero
end

function Misiones.premio(numero)
	return Config.MISION_PREMIO * numero
end

-- Suma progreso a la mision actual (se llama cada vez que el jugador rompe un cubito)
function Misiones.sumar(jugador, cantidad)
	local stats = jugador:FindFirstChild("leaderstats")
	if not stats then
		return
	end

	local numero = jugador:GetAttribute("Mision") or 1
	local progreso = (jugador:GetAttribute("MisionProgreso") or 0) + cantidad
	local meta = Misiones.meta(numero)

	while progreso >= meta do
		progreso -= meta
		local monedas =
			math.floor(Misiones.premio(numero) * Jugadores.multiplicadorMonedas(jugador))
		stats.Monedas.Value += monedas
		Jugadores.avisar(
			jugador,
			string.format("Mision %d completada: +%d monedas", numero, monedas)
		)
		numero += 1
		meta = Misiones.meta(numero)
	end

	jugador:SetAttribute("Mision", numero)
	jugador:SetAttribute("MisionProgreso", progreso)
end

return Misiones
