-- Luz, niebla y efectos de pantalla para que parezca un bosque al atardecer.
local Lighting = game:GetService("Lighting")

local Ambiente = {}

local EFECTOS = {
	"Atmosphere",
	"BloomEffect",
	"ColorCorrectionEffect",
	"SunRaysEffect",
	"DepthOfFieldEffect",
}

-- Si alguna propiedad no existe en tu version de Roblox, se ignora sin romper nada
local function ajustar(propiedad, valor)
	pcall(function()
		Lighting[propiedad] = valor
	end)
end

function Ambiente.crear()
	for _, hijo in Lighting:GetChildren() do
		for _, clase in EFECTOS do
			if hijo:IsA(clase) then
				hijo:Destroy()
				break
			end
		end
	end

	ajustar("ClockTime", 17)
	ajustar("Brightness", 2.6)
	ajustar("Ambient", Color3.fromRGB(55, 65, 58))
	ajustar("OutdoorAmbient", Color3.fromRGB(95, 105, 90))
	ajustar("ColorShift_Top", Color3.fromRGB(255, 205, 140))
	ajustar("GlobalShadows", true)
	ajustar("ShadowSoftness", 0.35)
	ajustar("EnvironmentDiffuseScale", 0.6)
	ajustar("EnvironmentSpecularScale", 0.4)
	ajustar("ExposureCompensation", 0.15)

	local niebla = Instance.new("Atmosphere")
	niebla.Density = 0.35
	niebla.Offset = 0.25
	niebla.Color = Color3.fromRGB(190, 205, 180)
	niebla.Decay = Color3.fromRGB(110, 130, 90)
	niebla.Glare = 0.2
	niebla.Haze = 1.5
	niebla.Parent = Lighting

	local brillo = Instance.new("BloomEffect")
	brillo.Intensity = 0.4
	brillo.Size = 24
	brillo.Threshold = 1.5
	brillo.Parent = Lighting

	local color = Instance.new("ColorCorrectionEffect")
	color.Saturation = 0.25
	color.Contrast = 0.1
	color.TintColor = Color3.fromRGB(255, 245, 225)
	color.Parent = Lighting

	local rayos = Instance.new("SunRaysEffect")
	rayos.Intensity = 0.15
	rayos.Spread = 0.8
	rayos.Parent = Lighting

	local profundidad = Instance.new("DepthOfFieldEffect")
	profundidad.FarIntensity = 0.25
	profundidad.FocusDistance = 70
	profundidad.InFocusRadius = 60
	profundidad.NearIntensity = 0
	profundidad.Parent = Lighting
end

return Ambiente
