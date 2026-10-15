-- Genera el bosque: pisos, arboles, flores, rocas, luciernagas, bordes y paredes.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Paredes = require(script.Parent.Paredes)

local Bosque = {}

local T = Config.TAMANO_HABITACION
local N = Config.GRILLA
local ALTO = Config.ALTO_PARED
local GROSOR = Config.GROSOR_PARED
local PUERTA = Config.ANCHO_PUERTA

local COLOR_TRONCO = Color3.fromRGB(105, 75, 45)
local COLOR_ARBUSTO = Color3.fromRGB(40, 90, 40)
local COLOR_PARED = Color3.fromRGB(170, 120, 70)
local COLORES_HOJAS = {
	Color3.fromRGB(60, 120, 50),
	Color3.fromRGB(80, 140, 55),
	Color3.fromRGB(45, 105, 60),
}
local COLORES_FLORES = {
	Color3.fromRGB(255, 220, 80),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(240, 120, 180),
	Color3.fromRGB(150, 170, 255),
}

local function elegir(lista, azar)
	return lista[azar:NextInteger(1, #lista)]
end

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

-- Esfera decorativa (no bloquea el paso)
local function crearBola(nombre, diametro, posicion, color, material, carpeta)
	local bola = crearParte(
		nombre,
		Vector3.new(diametro, diametro, diametro),
		posicion,
		color,
		material,
		carpeta
	)
	bola.Shape = Enum.PartType.Ball
	bola.CanCollide = false
	return bola
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

-- El pasto se oscurece a medida que te alejas del inicio
local function colorPiso(profundidad)
	local oscuro = (profundidad - 1) / (2 * N - 2)
	return Color3.fromRGB(95, 150, 65):Lerp(Color3.fromRGB(45, 90, 40), oscuro)
end

local function crearArbol(posicion, carpeta, azar)
	local alto = azar:NextInteger(7, 11)
	crearParte(
		"Tronco",
		Vector3.new(2, alto, 2),
		posicion + Vector3.new(0, alto / 2, 0),
		COLOR_TRONCO,
		Enum.Material.Wood,
		carpeta
	)
	local color = elegir(COLORES_HOJAS, azar)
	local tamanos = { 10, 8, 6 }
	for k, tamano in tamanos do
		local desvio = Vector3.new(azar:NextInteger(-1, 1), (k - 1) * 3.5, azar:NextInteger(-1, 1))
		crearBola(
			"Hojas",
			tamano,
			posicion + Vector3.new(0, alto, 0) + desvio,
			color,
			Enum.Material.Grass,
			carpeta
		)
	end
end

local function crearFlor(posicion, carpeta, azar)
	crearParte(
		"Tallo",
		Vector3.new(0.2, 1, 0.2),
		posicion + Vector3.new(0, 0.5, 0),
		Color3.fromRGB(50, 110, 40),
		Enum.Material.Grass,
		carpeta
	).CanCollide =
		false
	crearBola(
		"Flor",
		0.9,
		posicion + Vector3.new(0, 1.1, 0),
		elegir(COLORES_FLORES, azar),
		Enum.Material.SmoothPlastic,
		carpeta
	)
end

local function crearRoca(posicion, carpeta, azar)
	local tamano = azar:NextNumber(1.5, 3.5)
	local roca = crearParte(
		"Roca",
		Vector3.new(tamano, tamano * 0.7, tamano * 1.2),
		posicion + Vector3.new(0, tamano * 0.3, 0),
		Color3.fromRGB(110, 110, 115),
		Enum.Material.Slate,
		carpeta
	)
	roca.CFrame = roca.CFrame * CFrame.Angles(0, math.rad(azar:NextInteger(0, 180)), 0)
end

-- Una zona invisible que suelta puntitos de luz amarilla flotando
local function crearLuciernagas(posicion, carpeta)
	local zona = crearParte(
		"Luciernagas",
		Vector3.new(30, 8, 30),
		posicion,
		Color3.new(1, 1, 1),
		Enum.Material.SmoothPlastic,
		carpeta
	)
	zona.Transparency = 1
	zona.CanCollide = false

	local emisor = Instance.new("ParticleEmitter")
	emisor.Shape = Enum.ParticleEmitterShape.Box
	emisor.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	emisor.Color = ColorSequence.new(Color3.fromRGB(255, 240, 130))
	emisor.LightEmission = 1
	emisor.Size = NumberSequence.new(0.35)
	emisor.Lifetime = NumberRange.new(3, 5)
	emisor.Rate = 4
	emisor.Speed = NumberRange.new(0.5, 1.5)
	emisor.SpreadAngle = Vector2.new(180, 180)
	emisor.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0),
		NumberSequenceKeypoint.new(0.8, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	emisor.Parent = zona
end

local function crearHabitacion(i, j, carpeta, azar)
	local centro = centroHabitacion(i, j)
	crearParte(
		"Piso",
		Vector3.new(T, 1, T),
		centro + Vector3.new(0, -0.5, 0),
		colorPiso(i + j - 1),
		Enum.Material.Grass,
		carpeta
	)

	-- Arboles lejos de las puertas del centro
	for _ = 1, 4 do
		local dx = azar:NextInteger(8, 15) * signoAlAzar(azar)
		local dz = azar:NextInteger(8, 15) * signoAlAzar(azar)
		crearArbol(centro + Vector3.new(dx, 0, dz), carpeta, azar)
	end
	for _ = 1, 10 do
		local dx = azar:NextNumber(-17, 17)
		local dz = azar:NextNumber(-17, 17)
		crearFlor(centro + Vector3.new(dx, 0, dz), carpeta, azar)
	end
	for _ = 1, 2 do
		local dx = azar:NextInteger(6, 16) * signoAlAzar(azar)
		local dz = azar:NextInteger(6, 16) * signoAlAzar(azar)
		crearRoca(centro + Vector3.new(dx, 0, dz), carpeta, azar)
	end
	crearLuciernagas(centro + Vector3.new(0, 6, 0), carpeta)
end

-- Pared de arbustos: un bloque con bultos redondeados arriba
local function crearArbusto(tamano, posicion, carpeta, azar)
	crearParte("Arbustos", tamano, posicion, COLOR_ARBUSTO, Enum.Material.Grass, carpeta)

	local alineadoEnX = tamano.X > tamano.Z
	local largo = tamano.Z
	if alineadoEnX then
		largo = tamano.X
	end

	local cantidad = math.max(1, math.floor(largo / 6))
	local altura = posicion.Y + ALTO / 2 - 1
	for k = 1, cantidad do
		local desvio = (k - 0.5) / cantidad * largo - largo / 2
		local lugar = Vector3.new(posicion.X, altura, posicion.Z + desvio)
		if alineadoEnX then
			lugar = Vector3.new(posicion.X + desvio, altura, posicion.Z)
		end
		crearBola(
			"Matas",
			ALTO * 0.55 + azar:NextNumber(-1, 1),
			lugar,
			elegir(COLORES_HOJAS, azar),
			Enum.Material.Grass,
			carpeta
		)
	end
end

local function crearBordes(carpeta, azar)
	local largo = N * T + GROSOR
	local medio = (N - 1) * T / 2
	local minimo = -T / 2
	local maximo = (N - 1) * T + T / 2

	for _, x in { minimo, maximo } do
		crearArbusto(
			Vector3.new(GROSOR, ALTO, largo),
			Vector3.new(x, ALTO / 2, medio),
			carpeta,
			azar
		)
	end
	for _, z in { minimo, maximo } do
		crearArbusto(
			Vector3.new(largo, ALTO, GROSOR),
			Vector3.new(medio, ALTO / 2, z),
			carpeta,
			azar
		)
	end
end

-- Pared entre dos habitaciones: dos tramos de arbustos fijos y una puerta rompible al medio.
-- divideEnX = true: la pared separa habitaciones en el eje X (se extiende a lo largo de Z).
local function crearDivision(carpeta, centro, divideEnX, profundidad, azar)
	local lado = (T - PUERTA) / 2
	local desplazamiento = PUERTA / 2 + lado / 2

	for _, signo in { -1, 1 } do
		local tamano = Vector3.new(lado, ALTO, GROSOR)
		local offset = Vector3.new(signo * desplazamiento, 0, 0)
		if divideEnX then
			tamano = Vector3.new(GROSOR, ALTO, lado)
			offset = Vector3.new(0, 0, signo * desplazamiento)
		end
		crearArbusto(tamano, centro + offset + Vector3.new(0, ALTO / 2, 0), carpeta, azar)
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
	crearBordes(carpeta, azar)

	for i = 1, N do
		for j = 1, N do
			local centro = centroHabitacion(i, j)
			crearHabitacion(i, j, carpeta, azar)
			if i < N then
				crearDivision(carpeta, centro + Vector3.new(T / 2, 0, 0), true, i + j - 1, azar)
			end
			if j < N then
				crearDivision(carpeta, centro + Vector3.new(0, 0, T / 2), false, i + j - 1, azar)
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
