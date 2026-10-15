-- Cubitos rotos que quedan sueltos: el imán los atrae hacia el jugador y se convierten en items.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)

local Fragmentos = {}

local lista = {}

function Fragmentos.agregar(parte, valor)
	table.insert(lista, { parte = parte, valor = valor, nace = os.clock() })
	if #lista > Config.MAX_FRAGMENTOS then
		local viejo = table.remove(lista, 1)
		viejo.parte:Destroy()
	end
end

-- El Game Pass del iman duplica el alcance
local function radioIman(jugador)
	if jugador:GetAttribute("PaseIman") then
		return Config.RADIO_IMAN * 2
	end
	return Config.RADIO_IMAN
end

local function posicionesDeJugadores()
	local resultado = {}
	for _, jugador in Players:GetPlayers() do
		local personaje = jugador.Character
		local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
		if raiz then
			table.insert(resultado, { jugador = jugador, posicion = raiz.Position })
		end
	end
	return resultado
end

function Fragmentos.iniciar()
	local acumulado = 0
	RunService.Heartbeat:Connect(function(dt)
		acumulado += dt
		if acumulado < 0.1 then
			return
		end
		acumulado = 0

		local jugadores = posicionesDeJugadores()
		local ahora = os.clock()

		for i = #lista, 1, -1 do
			local fragmento = lista[i]
			local parte = fragmento.parte
			local edad = ahora - fragmento.nace

			if not parte.Parent or edad > Config.VIDA_FRAGMENTO or parte.Position.Y < -50 then
				parte:Destroy()
				table.remove(lista, i)
			else
				local mejor = nil
				local mejorDistancia = math.huge
				for _, dato in jugadores do
					local distancia = (dato.posicion - parte.Position).Magnitude
					if distancia < mejorDistancia then
						mejor = dato
						mejorDistancia = distancia
					end
				end

				if mejor and mejorDistancia < 4 and edad > 0.5 then
					local stats = mejor.jugador:FindFirstChild("leaderstats")
					if stats then
						stats.Items.Value += fragmento.valor
					end
					parte:Destroy()
					table.remove(lista, i)
				elseif mejor and mejorDistancia < radioIman(mejor.jugador) and edad > 0.6 then
					local direccion = (mejor.posicion - parte.Position).Unit
					parte.AssemblyLinearVelocity = direccion * 60
				end
			end
		end
	end)
end

return Fragmentos
