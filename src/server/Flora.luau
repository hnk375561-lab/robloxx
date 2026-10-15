-- Mas vida en cada habitacion: helechos, tocones y hojas caidas.
-- Ademas, los adornos chicos dejan de tapar el rayo de los golpes.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Flora = {}

local T = Config.TAMANO_HABITACION
local N = Config.GRILLA

local COLOR_TRONCO = Color3.fromRGB(98, 70, 44)
local COLORES_HOJA_CAIDA = {
	Color3.fromRGB(230, 150, 55),
	Color3.fromRGB(180, 90, 40),
	Color3.fromRGB(150, 175, 60),
	Color3.fromRGB(120, 70, 40),
}

-- Estos adornos no bloquean el rayo con el que apuntas a las paredes
local NO_BLOQUEAN = {
	Flor = true,
	Tallo = true,
	TalloHongo = true,
	SombreroHongo = true,
	Hojas = true,
	Matas = true,
	Musgo = true,
	ManchaDeLuz = true,
}

local function signo(azar)
	if azar:NextNumber() < 0.5 then
		return -1
	end
	return 1
end

-- Los puestos del Trueque y la Herreria estan en la habitacion (1, 1)
local function cercaDePuesto(posicion)
	local puestos = { Vector3.new(-12, 0, 0), Vector3.new(0, 0, -12) }
	for _, puesto in puestos do
		local diferencia = Vector3.new(posicion.X - puesto.X, 0, posicion.Z - puesto.Z)
		if diferencia.Magnitude < 9 then
			return true
		end
	end
	return false
end

local function decorado(parte)
	parte.Anchored = true
	parte.CanQuery = false
	parte.CanTouch = false
	parte.TopSurface = Enum.SurfaceType.Smooth
	parte.BottomSurface = Enum.SurfaceType.Smooth
	return parte
end

local function crearHelecho(posicion, carpeta, azar)
	local color = Color3.fromRGB(
		azar:NextInteger(40, 70),
		azar:NextInteger(110, 150),
		azar:NextInteger(40, 70)
	)
	local hojas = 6
	for k = 1, hojas do
		local angulo = (k / hojas) * math.pi * 2 + azar:NextNumber(-0.2, 0.2)
		local largo = azar:NextNumber(1.8, 2.6)
		local giro = CFrame.Angles(0, -angulo - math.pi / 2, 0) * CFrame.Angles(math.rad(35), 0, 0)

		local hoja = decorado(Instance.new("Part"))
		hoja.Name = "Helecho"
		hoja.Size = Vector3.new(0.35, 0.08, largo)
		hoja.Material = Enum.Material.Grass
		hoja.Color = color
		hoja.CanCollide = false
		hoja.CastShadow = false
		hoja.CFrame = CFrame.new(posicion + Vector3.new(0, 0.05, 0) + giro.LookVector * (largo / 2))
			* giro
		hoja.Parent = carpeta
	end
end

local function crearTocon(posicion, carpeta, azar)
	local alto = azar:NextNumber(0.9, 1.6)
	local diametro = azar:NextNumber(1.8, 2.8)

	local function disco(nombre, grosor, ancho, y, color)
		local parte = decorado(Instance.new("Part"))
		parte.Name = nombre
		parte.Shape = Enum.PartType.Cylinder
		parte.Size = Vector3.new(grosor, ancho, ancho)
		parte.CFrame = CFrame.new(posicion + Vector3.new(0, y, 0))
			* CFrame.Angles(0, 0, math.rad(90))
		parte.Material = Enum.Material.Wood
		parte.Color = color
		parte.Parent = carpeta
		return parte
	end

	local tronco = disco("Tocon", alto, diametro, alto / 2, COLOR_TRONCO)
	tronco.CanQuery = true
	local tapa =
		disco("ToconTapa", 0.1, diametro * 0.92, alto + 0.03, Color3.fromRGB(190, 150, 100))
	tapa.CanCollide = false
	local centro =
		disco("ToconAnillo", 0.1, diametro * 0.5, alto + 0.06, Color3.fromRGB(160, 118, 76))
	centro.CanCollide = false
end

local function crearHojaCaida(posicion, carpeta, azar)
	local hoja = decorado(Instance.new("Part"))
	hoja.Name = "HojaCaida"
	hoja.Size = Vector3.new(0.8, 0.05, 0.6)
	hoja.CFrame = CFrame.new(posicion + Vector3.new(0, 0.05, 0))
		* CFrame.Angles(0, math.rad(azar:NextInteger(0, 359)), 0)
	hoja.Material = Enum.Material.Grass
	hoja.Color = COLORES_HOJA_CAIDA[azar:NextInteger(1, #COLORES_HOJA_CAIDA)]
	hoja.CanCollide = false
	hoja.CastShadow = false
	hoja.Parent = carpeta
end

function Flora.crear()
	local bosque = workspace:FindFirstChild("Bosque")
	if not bosque then
		warn("Flora: no encontre la carpeta Bosque")
		return
	end
	local azar = Random.new(555)

	for _, pieza in bosque:GetChildren() do
		if NO_BLOQUEAN[pieza.Name] and pieza:IsA("BasePart") then
			pieza.CanQuery = false
		end
	end

	local carpeta = Instance.new("Folder")
	carpeta.Name = "Flora"
	carpeta.Parent = workspace

	for i = 1, N do
		for j = 1, N do
			local centro = Vector3.new((i - 1) * T, 0, (j - 1) * T)

			for _ = 1, 8 do
				local lugar = centro
					+ Vector3.new(
						azar:NextInteger(6, 17) * signo(azar),
						0,
						azar:NextInteger(6, 17) * signo(azar)
					)
				if not cercaDePuesto(lugar) then
					crearHelecho(lugar, carpeta, azar)
				end
			end
			for _ = 1, 2 do
				local lugar = centro
					+ Vector3.new(
						azar:NextInteger(7, 16) * signo(azar),
						0,
						azar:NextInteger(7, 16) * signo(azar)
					)
				if not cercaDePuesto(lugar) then
					crearTocon(lugar, carpeta, azar)
				end
			end
			for _ = 1, 10 do
				crearHojaCaida(
					centro + Vector3.new(azar:NextNumber(-17, 17), 0, azar:NextNumber(-17, 17)),
					carpeta,
					azar
				)
			end
		end
	end
end

return Flora
