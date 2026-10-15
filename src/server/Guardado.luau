-- Guardado del progreso (items, monedas y fuerza) con DataStore.
-- En Studio hace falta: Game Settings > Security > "Enable Studio Access to API Services"
-- y haber publicado el juego al menos una vez. Si falla, el juego sigue andando igual.
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local Guardado = {}

local NOMBRE = "RobloxxProgreso_v1"
local CADA_CUANTO = 120

local almacen = nil
pcall(function()
	almacen = DataStoreService:GetDataStore(NOMBRE)
end)

local enCurso = {}
local avisado = false

local function avisar(texto)
	if not avisado then
		avisado = true
		warn("Guardado: " .. tostring(texto))
	end
end

local function clave(jugador)
	return "j_" .. jugador.UserId
end

local function conReintentos(funcion)
	local ultimoError = nil
	for intento = 1, 3 do
		local ok, resultado = pcall(funcion)
		if ok then
			return true, resultado
		end
		ultimoError = resultado
		task.wait(intento)
	end
	return false, ultimoError
end

local function numeroSeguro(valor, minimo, maximo, defecto)
	if type(valor) ~= "number" or valor ~= valor then
		return defecto
	end
	return math.clamp(math.floor(valor), minimo, maximo)
end

local function cargar(jugador)
	local stats = jugador:WaitForChild("leaderstats", 15)
	if not stats or not almacen then
		return
	end

	local ok, datos = conReintentos(function()
		return almacen:GetAsync(clave(jugador))
	end)
	if jugador.Parent ~= Players then
		return
	end
	if not ok then
		-- Si no pudimos leer, no marcamos como cargado: asi no pisamos el progreso guardado
		avisar(datos)
		return
	end

	if type(datos) == "table" then
		stats.Items.Value = numeroSeguro(datos.items, 0, 1000000000, 0)
		stats.Monedas.Value = numeroSeguro(datos.monedas, 0, 1000000000, 0)
		jugador:SetAttribute("Fuerza", numeroSeguro(datos.fuerza, 1, 100000, 1))
	end
	jugador:SetAttribute("DatosCargados", true)
end

local function guardar(jugador)
	if not almacen or not jugador:GetAttribute("DatosCargados") then
		return
	end
	if enCurso[jugador] then
		while enCurso[jugador] do
			task.wait(0.1)
		end
		return
	end
	local stats = jugador:FindFirstChild("leaderstats")
	if not stats then
		return
	end

	enCurso[jugador] = true
	local datos = {
		items = stats.Items.Value,
		monedas = stats.Monedas.Value,
		fuerza = jugador:GetAttribute("Fuerza") or 1,
	}
	local ok, errorTexto = conReintentos(function()
		almacen:SetAsync(clave(jugador), datos)
	end)
	if not ok then
		avisar(errorTexto)
	end
	enCurso[jugador] = nil
end

function Guardado.iniciar()
	Players.PlayerAdded:Connect(function(jugador)
		task.spawn(cargar, jugador)
	end)
	for _, jugador in Players:GetPlayers() do
		task.spawn(cargar, jugador)
	end

	Players.PlayerRemoving:Connect(guardar)

	game:BindToClose(function()
		local pendientes = 0
		for _, jugador in Players:GetPlayers() do
			pendientes += 1
			task.spawn(function()
				guardar(jugador)
				pendientes -= 1
			end)
		end
		local limite = os.clock() + 25
		while pendientes > 0 and os.clock() < limite do
			task.wait(0.2)
		end
	end)

	task.spawn(function()
		while true do
			task.wait(CADA_CUANTO)
			for _, jugador in Players:GetPlayers() do
				task.spawn(guardar, jugador)
			end
		end
	end)
end

return Guardado
