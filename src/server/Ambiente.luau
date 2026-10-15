-- Luz, niebla y efectos de pantalla para que parezca un bosque al atardecer.
local Lighting = game:GetService("Lighting")

local Ambiente = {}

function Ambiente.crear()
	-- Limpiamos efectos viejos para no duplicarlos
	for _, hijo in Lighting:GetChildren() do
		if
			hijo:IsA("Atmosphere")
			or hijo:IsA("BloomEffect")
			or hijo:IsA("ColorCorrectionEffect")
			or hijo:IsA("SunRaysEffect")
		then
			hijo:Destroy()
		end
	end

	Lighting.ClockTime = 17.2
	Lighting.Brightness = 2.5
	Lighting.Ambient = Color3.fromRGB(60, 70, 60)
	Lighting.OutdoorAmbient = Color3.fromRGB(90, 100, 85)
	Lighting.GlobalShadows = true

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
end

return Ambiente
