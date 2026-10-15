-- Genera el bosque: pisos, arboles, bordes y paredes entre habitaciones.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Paredes = require(script.Parent.Paredes)

local Bosque = {}

local T = Config.TAMANO_HABITACION
local N = Config.GRILLA
local ALTO = Config.ALTO_PARED
local GROSOR = Config.GROSOR_PARED
local PUERTA = Config.ANCHO_PUERTA

local COLOR_PASTO = Color3.fromRGB(86, 140, 60)
local COLOR_TRONCO = Color3.fromRGB(105, 75, 45)
local COLOR_ARBUSTO = Color3.fromRGB(40, 90, 40)
local COLOR_HOJAS = Color3.fromRGB(60, 120, 50)
local COLOR_PARED = Color3.fromRGB(170, 120, 70)

local function crearParte(nombre, tamano, posicion, color, material, carpeta)
	local parte = Instance.new("Part")
	parte.Name = nombre
	parte.Size = tamano
	parte.Position = posicion
	parte.Anchored = true
	parte.Color = color
	parte.Material = material
	parte.TopSurface = Enum.SurfaceType.Smooth
	parte.BottomSurface = Enum.SurfaceType.Smooth
	parte.Parent = carpeta
	return parte
end

-- Centro de la habitacion (i, j). La habitacion (1, 1) esta en el origen.
local function centroHabitacion(i, j)
	return Vector3.new((i - 1) * T, 0, (j - 1) * T)
end

local function signoAlAzar(azar)
	if azar:NextNumber() < 0.5 then
		return -1
	end
	return 1
end

local function crearArbol(posicion, carpeta)
	local altoTronco = 8
	crearParte(
		"Tronco",
		Vector3.new(2, altoTronco, 2),
		posicion + Vector3.new(0, altoTronco / 2, 0),
		COLOR_TRONCO,
		Enum.Material.Wood,
		carpeta
	)
	local hojas = crearParte(
		"Hojas",
		Vector3.new(9, 9, 9),
		posicion + Vector3.new(0, altoTronco + 3, 0),
		COLOR_HOJAS,
		Enum.Material.Grass,
		carpeta
	)
	hojas.Shape = Enum.PartType.Ball
end

local function crearHabitacion(i, j, carpeta, azar)
	local centro = centroHabitacion(i, j)
	crearParte(
		"Piso",
		Vector3.new(T, 1, T),
		centro + Vector3.new(0, -0.5, 0),
		COLOR_PASTO,
		Enum.Material.Grass,
		carpeta
	)
	-- 3 arboles por habitacion, siempre lejos de las puertas del centro
	for _ = 1, 3 do
		local dx = azar:NextInteger(8, 16) * signoAlAzar(azar)
		local dz = azar:NextInteger(8, 16) * signoAlAzar(azar)
		crearArbol(centro + Vector3.new(dx, 0, dz), carpeta)
	end
end

local function crearBordes(carpeta)
	local largo = N * T + GROSOR
	local medio = (N - 1) * T / 2
	local minimo = -T / 2
	local maximo = (N - 1) * T + T / 2

	for _, x in { minimo, maximo } do
		crearParte(
			"Borde",
			Vector3.new(GROSOR, ALTO, largo),
			Vector3.new(x, ALTO / 2, medio),
			COLOR_ARBUSTO,
			Enum.Material.Grass,
			carpeta
		)
	end
	for _, z in { minimo, maximo } do
		crearParte(
			"Borde",
			Vector3.new(largo, ALTO, GROSOR),
			Vector3.new(medio, ALTO / 2, z),
			COLOR_ARBUSTO,
			Enum.Material.Grass,
			carpeta
		)
	end
end

-- Pared entre dos habitaciones: dos tramos de arbustos fijos y una puerta rompible al medio.
-- divideEnX = true: la pared separa habitaciones en el eje X (se extiende a lo largo de Z).
local function crearDivision(carpeta, centro, divideEnX, profundidad)
	local lado = (T - PUERTA) / 2
	local desplazamiento = PUERTA / 2 + lado / 2

	for _, signo in { -1, 1 } do
		local tamano = Vector3.new(lado, ALTO, GROSOR)
		local offset = Vector3.new(signo * desplazamiento, 0, 0)
		if divideEnX then
			tamano = Vector3.new(GROSOR, ALTO, lado)
			offset = Vector3.new(0, 0, signo * desplazamiento)
		end
		crearParte(
			"Arbustos",
			tamano,
			centro + offset + Vector3.new(0, ALTO / 2, 0),
			COLOR_ARBUSTO,
			Enum.Material.Grass,
			carpeta
		)
	end

	local tamanoPuerta = Vector3.new(PUERTA, ALTO, GROSOR)
	if divideEnX then
		tamanoPuerta = Vector3.new(GROSOR, ALTO, PUERTA)
	end
	local puerta = crearParte(
		"ParedRompible",
		tamanoPuerta,
		centro + Vector3.new(0, ALTO / 2, 0),
		COLOR_PARED,
		Enum.Material.WoodPlanks,
		carpeta
	)
	Paredes.prepararPared(puerta, profundidad)
end

function Bosque.generar()
	-- Sacamos lo que viene de fabrica en la plantilla Baseplate
	local base = workspace:FindFirstChild("Baseplate")
	if base then
		base:Destroy()
	end
	local spawnViejo = workspace:FindFirstChild("SpawnLocation")
	if spawnViejo then
		spawnViejo:Destroy()
	end

	local carpeta = Instance.new("Folder")
	carpeta.Name = "Bosque"
	carpeta.Parent = workspace

	local azar = Random.new(42)
	crearBordes(carpeta)

	for i = 1, N do
		for j = 1, N do
			local centro = centroHabitacion(i, j)
			crearHabitacion(i, j, carpeta, azar)
			if i < N then
				crearDivision(carpeta, centro + Vector3.new(T / 2, 0, 0), true, i + j - 1)
			end
			if j < N then
				crearDivision(carpeta, centro + Vector3.new(0, 0, T / 2), false, i + j - 1)
			end
		end
	end

	-- Punto de aparicion: centro de la habitacion (1, 1)
	local inicio = Instance.new("SpawnLocation")
	inicio.Anchored = true
	inicio.Size = Vector3.new(6, 1, 6)
	inicio.Position = Vector3.new(0, 0.5, 0)
	inicio.Transparency = 1
	inicio.CanCollide = false
	inicio.Neutral = true
	inicio.Parent = workspace
end

return Bosque
