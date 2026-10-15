-- Luz, cielo, nubes, niebla y efectos de pantalla: bosque al atardecer (hora dorada).
local Lighting = game:GetService("Lighting")

local Ambiente = {}

local EFECTOS = {
	"Atmosphere",
	"BloomEffect",
	"ColorCorrectionEffect",
	"SunRaysEffect",
	"DepthOfFieldEffect",
	"Sky",
}

-- Si alguna propiedad no existe en tu version de Roblox, se ignora sin romper nada
local function ajustar(objeto, propiedad, valor)
	pcall(function()
		objeto[propiedad] = valor
	end)
end

local function limpiar()
	for _, hijo in Lighting:GetChildren() do
		for _, clase in EFECTOS do
			if hijo:IsA(clase) then
				hijo:Destroy()
				break
			end
		end
	end
	local viejas = workspace.Terrain:FindFirstChildOfClass("Clouds")
	if viejas then
		viejas:Destroy()
	end
end

local function crearLuz()
	ajustar(Lighting, "ClockTime", 17.2)
	ajustar(Lighting, "GeographicLatitude", 25)
	ajustar(Lighting, "Brightness", 3)
	ajustar(Lighting, "Ambient", Color3.fromRGB(60, 68, 70))
	ajustar(Lighting, "OutdoorAmbient", Color3.fromRGB(105, 112, 105))
	ajustar(Lighting, "ColorShift_Top", Color3.fromRGB(255, 200, 130))
	ajustar(Lighting, "GlobalShadows", true)
	ajustar(Lighting, "ShadowSoftness", 0.25)
	ajustar(Lighting, "EnvironmentDiffuseScale", 1)
	ajustar(Lighting, "EnvironmentSpecularScale", 1)
	ajustar(Lighting, "ExposureCompensation", 0.2)
end

local function crearCielo()
	local cielo = Instance.new("Sky")
	cielo.StarCount = 2500
	cielo.SunAngularSize = 14
	cielo.MoonAngularSize = 10
	cielo.Parent = Lighting

	local nubes = Instance.new("Clouds")
	nubes.Cover = 0.55
	nubes.Density = 0.6
	nubes.Color = Color3.fromRGB(255, 214, 180)
	nubes.Parent = workspace.Terrain

	-- El viento mueve el pasto del terreno y las particulas que lo usan
	ajustar(workspace, "GlobalWind", Vector3.new(6, 0, 3))
end

local function crearEfectos()
	local niebla = Instance.new("Atmosphere")
	niebla.Density = 0.34
	niebla.Offset = 0.25
	niebla.Color = Color3.fromRGB(200, 205, 185)
	niebla.Decay = Color3.fromRGB(120, 130, 90)
	niebla.Glare = 0.25
	niebla.Haze = 1.6
	niebla.Parent = Lighting

	local brillo = Instance.new("BloomEffect")
	brillo.Intensity = 0.5
	brillo.Size = 22
	brillo.Threshold = 1.1
	brillo.Parent = Lighting

	local color = Instance.new("ColorCorrectionEffect")
	color.Saturation = 0.3
	color.Contrast = 0.12
	color.TintColor = Color3.fromRGB(255, 244, 228)
	color.Parent = Lighting

	local rayos = Instance.new("SunRaysEffect")
	rayos.Intensity = 0.18
	rayos.Spread = 0.8
	rayos.Parent = Lighting

	local profundidad = Instance.new("DepthOfFieldEffect")
	profundidad.FarIntensity = 0.3
	profundidad.FocusDistance = 60
	profundidad.InFocusRadius = 40
	profundidad.NearIntensity = 0
	profundidad.Parent = Lighting
end

-- La hora se mueve muy despacio entre el sol bajo y el atardecer profundo
local function iniciarCiclo()
	task.spawn(function()
		local tiempo = 0
		while true do
			tiempo += 2
			Lighting.ClockTime = 17.2 + math.sin(tiempo / 95) * 0.9
			task.wait(2)
		end
	end)
end

function Ambiente.crear()
	limpiar()
	crearLuz()
	crearCielo()
	crearEfectos()
	iniciarCiclo()
end

return Ambiente
