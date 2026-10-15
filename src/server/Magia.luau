-- Detalles magicos: hongos y flores que brillan, cristales en las paredes,
-- rayos de luz con polvo flotando y hojas que caen. Todo con codigo, sin assets.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Paredes = require(script.Parent.Paredes)

local Magia = {}

local T = Config.TAMANO_HABITACION
local N = Config.GRILLA

local COLORES_MAGICOS = {
	Color3.fromRGB(70, 230, 200),
	Color3.fromRGB(160, 110, 255),
	Color3.fromRGB(255, 100, 190),
	Color3.fromRGB(90, 190, 255),
}
local COLORES_HOJAS_CAYENDO = {
	Color3.fromRGB(230, 150, 55),
	Color3.fromRGB(180, 90, 40),
	Color3.fromRGB(150, 175, 60),
}

local function invisible(nombre, tamano, posicion, carpeta)
	local parte = Instance.new("Part")
	parte.Name = nombre
	parte.Size = tamano
	parte.Position = posicion
	parte.Anchored = true
	parte.Transparency = 1
	parte.CanCollide = false
	parte.CanQuery = false
	parte.CanTouch = false
	parte.CastShadow = false
	parte.Parent = carpeta
	return parte
end

-- Hongos brillantes: gorro de neon, mancha de luz en el piso y, cada tanto, una luz real
local function encenderHongos(carpeta, azar)
	local cuenta = 0
	for _, pieza in carpeta:GetChildren() do
		if pieza.Name == "SombreroHongo" and pieza:IsA("BasePart") then
			cuenta += 1
			local color = COLORES_MAGICOS[azar:NextInteger(1, #COLORES_MAGICOS)]
			pieza.Material = Enum.Material.Neon
			pieza.Color = color

			local mancha = Instance.new("Part")
			mancha.Name = "ManchaDeLuz"
			mancha.Shape = Enum.PartType.Cylinder
			mancha.Size = Vector3.new(0.08, 5, 5)
			mancha.CFrame = CFrame.new(pieza.Position.X, 0.06, pieza.Position.Z)
				* CFrame.Angles(0, 0, math.rad(90))
			mancha.Anchored = true
			mancha.CanCollide = false
			mancha.CanQuery = false
			mancha.CanTouch = false
			mancha.CastShadow = false
			mancha.Material = Enum.Material.Neon
			mancha.Color = color
			mancha.Transparency = 0.82
			mancha.Parent = carpeta

			if cuenta % 3 == 0 then
				local luz = Instance.new("PointLight")
				luz.Color = color
				luz.Brightness = 1.4
				luz.Range = 12
				luz.Shadows = false
				luz.Parent = pieza
			end
		end
	end
end

-- La mitad de las flores brillan un poquito
local function encenderFlores(carpeta, azar)
	for _, pieza in carpeta:GetChildren() do
		if pieza.Name == "Flor" and pieza:IsA("BasePart") and azar:NextNumber() < 0.5 then
			pieza.Material = Enum.Material.Neon
		end
	end
end

-- Algunos cubitos de las paredes son cristales que brillan (valen un poco mas)
local function crearCristales(azar)
	for _, voxel in Paredes.carpeta():GetChildren() do
		if voxel:IsA("BasePart") and voxel.Material == Enum.Material.Slate then
			if azar:NextNumber() < 0.06 then
				local color = COLORES_MAGICOS[azar:NextInteger(1, #COLORES_MAGICOS)]
				voxel.Material = Enum.Material.Neon
				voxel.Color = color
				voxel:SetAttribute("ColorBase", color)
				voxel:SetAttribute("Valor", (voxel:GetAttribute("Valor") or 1) + 1)
			end
		end
	end
end

-- Un rayo de luz que baja entre los arboles, con polvito flotando adentro
local function crearRayo(centro, carpeta, azar)
	local x = centro.X + azar:NextNumber(-12, 12)
	local z = centro.Z + azar:NextNumber(-12, 12)
	local parte = invisible("RayoDeLuz", Vector3.new(9, 24, 9), Vector3.new(x, 13, z), carpeta)

	local arriba = Instance.new("Attachment")
	arriba.Position = Vector3.new(8, 13, -6)
	arriba.Parent = parte
	local abajo = Instance.new("Attachment")
	abajo.Position = Vector3.new(0, -12.8, 0)
	abajo.Parent = parte

	local rayo = Instance.new("Beam")
	rayo.Attachment0 = arriba
	rayo.Attachment1 = abajo
	rayo.FaceCamera = true
	rayo.Width0 = 5
	rayo.Width1 = 9
	rayo.Segments = 1
	rayo.LightEmission = 1
	rayo.LightInfluence = 0
	rayo.Color = ColorSequence.new(Color3.fromRGB(255, 225, 160))
	rayo.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.25, 0.9),
		NumberSequenceKeypoint.new(1, 0.82),
	})
	rayo.Parent = parte

	local polvo = Instance.new("ParticleEmitter")
	polvo.Shape = Enum.ParticleEmitterShape.Box
	polvo.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	polvo.Color = ColorSequence.new(Color3.fromRGB(255, 235, 190))
	polvo.LightEmission = 0.8
	polvo.Size = NumberSequence.new(0.14)
	polvo.Lifetime = NumberRange.new(6, 9)
	polvo.Rate = 6
	polvo.Speed = NumberRange.new(0.2, 0.6)
	polvo.SpreadAngle = Vector2.new(180, 180)
	polvo.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0.2),
		NumberSequenceKeypoint.new(0.8, 0.2),
		NumberSequenceKeypoint.new(1, 1),
	})
	polvo.Parent = parte
end

-- Hojas doradas y verdes que bajan despacito sobre toda la habitacion
local function crearHojas(centro, carpeta, azar)
	local techo =
		invisible("HojasCayendo", Vector3.new(34, 1, 34), centro + Vector3.new(0, 24, 0), carpeta)
	for k = 1, 2 do
		local hojas = Instance.new("ParticleEmitter")
		hojas.Shape = Enum.ParticleEmitterShape.Box
		hojas.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
		hojas.EmissionDirection = Enum.NormalId.Bottom
		hojas.Color =
			ColorSequence.new(COLORES_HOJAS_CAYENDO[azar:NextInteger(1, #COLORES_HOJAS_CAYENDO)])
		hojas.Size = NumberSequence.new(0.5)
		hojas.Lifetime = NumberRange.new(11, 14)
		hojas.Rate = 1.2
		hojas.Speed = NumberRange.new(1, 2)
		hojas.Acceleration = Vector3.new(0.5 * k, 0, 0.3)
		hojas.Rotation = NumberRange.new(0, 360)
		hojas.RotSpeed = NumberRange.new(-70, 70)
		hojas.SpreadAngle = Vector2.new(25, 25)
		hojas.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.1, 0),
			NumberSequenceKeypoint.new(0.9, 0),
			NumberSequenceKeypoint.new(1, 1),
		})
		pcall(function()
			hojas.WindAffectsDrag = true
			hojas.Drag = 1
		end)
		hojas.Parent = techo
	end
end

function Magia.crear()
	local azar = Random.new(2026)
	local bosque = workspace:FindFirstChild("Bosque")
	if not bosque then
		warn("Magia: no encontre la carpeta Bosque")
		return
	end

	-- Las zonas invisibles de luciernagas no deben tapar los golpes
	for _, pieza in bosque:GetChildren() do
		if pieza.Name == "Luciernagas" and pieza:IsA("BasePart") then
			pieza.CanQuery = false
			pieza.CastShadow = false
		end
	end

	encenderHongos(bosque, azar)
	encenderFlores(bosque, azar)
	crearCristales(azar)

	local carpeta = Instance.new("Folder")
	carpeta.Name = "Magia"
	carpeta.Parent = workspace

	for i = 1, N do
		for j = 1, N do
			local centro = Vector3.new((i - 1) * T, 0, (j - 1) * T)
			crearRayo(centro, carpeta, azar)
			crearHojas(centro, carpeta, azar)
		end
	end
end

return Magia
