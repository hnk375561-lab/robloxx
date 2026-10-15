-- Datos de cada jugador: contadores arriba a la derecha, fuerza, renacimientos y multiplicadores.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Jugadores = {}

local avisoRemoto = nil

-- Cuanto cuesta pasar de la fuerza actual a la siguiente
function Jugadores.costoDeFuerza(fuerza)
	return Config.COSTO_BASE_FUERZA * fuerza * fuerza
end

-- Multiplicador total de monedas (renacimientos x pase x boost temporal)
function Jugadores.multiplicadorMonedas(jugador)
	local renacimientos = jugador:GetAttribute("Renacimientos") or 0
	local total = 1 + Config.BONUS_POR_RENACER * renacimientos
	if jugador:GetAttribute("PaseX2") then
		total *= 2
	end
	local boostHasta = jugador:GetAttribute("BoostHasta") or 0
	if boostHasta > os.time() then
		total *= 2
	end
	return total
end

-- Multiplicador de dano (arma x pase)
function Jugadores.multiplicadorDano(jugador)
	local indice = math.clamp(jugador:GetAttribute("Arma") or 1, 1, #Config.ARMAS)
	local total = Config.ARMAS[indice].dano
	if jugador:GetAttribute("PaseDano") then
		total *= 2
	end
	return total
end

-- Manda un cartelito a la pantalla del jugador
function Jugadores.avisar(jugador, texto)
	-- Esperamos un poco para que la pantalla del jugador ya este lista para mostrarlo
	task.delay(2, function()
		if avisoRemoto and jugador.Parent then
			avisoRemoto:FireClient(jugador, texto)
		end
	end)
end

local function actualizarMultiplicador(jugador)
	jugador:SetAttribute("Multiplicador", Jugadores.multiplicadorMonedas(jugador))
end

local function actualizarDano(jugador)
	local fuerza = jugador:GetAttribute("Fuerza") or 1
	jugador:SetAttribute("Dano", fuerza * Jugadores.multiplicadorDano(jugador))
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

	local renacer = Instance.new("IntValue")
	renacer.Name = "Renacer"
	renacer.Parent = stats

	stats.Parent = jugador

	-- La fuerza "de verdad" es el atributo. Lo usan las paredes y la tienda.
	jugador:SetAttribute("Fuerza", 1)
	jugador:SetAttribute("Renacimientos", 0)
	jugador:SetAttribute("Arma", 1)
	jugador:SetAttribute("CostoFuerza", Jugadores.costoDeFuerza(1))
	jugador:GetAttributeChangedSignal("Fuerza"):Connect(function()
		local actual = jugador:GetAttribute("Fuerza") or 1
		fuerza.Value = actual
		jugador:SetAttribute("CostoFuerza", Jugadores.costoDeFuerza(actual))
	end)
	jugador:GetAttributeChangedSignal("Renacimientos"):Connect(function()
		renacer.Value = jugador:GetAttribute("Renacimientos") or 0
		actualizarMultiplicador(jugador)
	end)
	jugador:GetAttributeChangedSignal("PaseX2"):Connect(function()
		actualizarMultiplicador(jugador)
	end)
	jugador:GetAttributeChangedSignal("BoostHasta"):Connect(function()
		actualizarMultiplicador(jugador)
		-- el multiplicador tiene que volver a bajar cuando se acaba el boost
		local hasta = jugador:GetAttribute("BoostHasta") or 0
		task.delay(math.max(0, hasta - os.time()) + 1, function()
			if jugador.Parent then
				actualizarMultiplicador(jugador)
			end
		end)
	end)
	for _, nombre in { "Fuerza", "Arma", "PaseDano" } do
		jugador:GetAttributeChangedSignal(nombre):Connect(function()
			actualizarDano(jugador)
		end)
	end
	actualizarDano(jugador)
	actualizarMultiplicador(jugador)
end

function Jugadores.iniciar()
	avisoRemoto = Instance.new("RemoteEvent")
	avisoRemoto.Name = "Aviso"
	avisoRemoto.Parent = ReplicatedStorage

	Players.PlayerAdded:Connect(alEntrar)
	for _, jugador in Players:GetPlayers() do
		alEntrar(jugador)
	end
end

return Jugadores
