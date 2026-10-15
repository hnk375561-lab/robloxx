-- Calidad grafica: tecla G cambia entre Alta, Media y Baja (para que ande fluido en cualquier equipo).
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local jugador = Players.LocalPlayer
local esCelular = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local NOMBRES = { "Alta", "Media", "Baja" }
local nivel = if esCelular then 2 else 1

local gui = Instance.new("ScreenGui")
gui.Name = "Calidad"
gui.ResetOnSpawn = false
gui.Parent = jugador:WaitForChild("PlayerGui")

local cartel = Instance.new("TextLabel")
cartel.AnchorPoint = Vector2.new(0.5, 1)
cartel.Position = UDim2.new(0.5, 0, 1, -70)
cartel.Size = UDim2.fromOffset(280, 34)
cartel.BackgroundColor3 = Color3.new(0, 0, 0)
cartel.BackgroundTransparency = 1
cartel.TextTransparency = 1
cartel.TextColor3 = Color3.new(1, 1, 1)
cartel.TextSize = 18
cartel.FontFace = Font.fromEnum(Enum.Font.GothamBold)
cartel.Parent = gui

local esquinas = Instance.new("UICorner")
esquinas.CornerRadius = UDim.new(0, 10)
esquinas.Parent = cartel

local function aplicar()
	for _, efecto in Lighting:GetChildren() do
		if efecto:IsA("DepthOfFieldEffect") or efecto:IsA("SunRaysEffect") then
			efecto.Enabled = nivel == 1
		elseif efecto:IsA("BloomEffect") then
			efecto.Enabled = nivel <= 2
		end
	end
	Lighting.GlobalShadows = nivel < 3
end

local function avisar()
	cartel.Text = "Graficos: " .. NOMBRES[nivel] .. "  (tecla G)"
	cartel.BackgroundTransparency = 0.35
	cartel.TextTransparency = 0
	TweenService
		:Create(cartel, TweenInfo.new(1.2), { BackgroundTransparency = 1, TextTransparency = 1 })
		:Play()
end

UserInputService.InputBegan:Connect(function(entrada, procesado)
	if procesado or entrada.KeyCode ~= Enum.KeyCode.G then
		return
	end
	nivel = nivel % #NOMBRES + 1
	aplicar()
	avisar()
end)

-- Aviso util si el juego no esta usando la iluminacion Future (se ve mucho mas plano)
task.delay(3, function()
	local ok, tecnologia = pcall(function()
		return Lighting.Technology
	end)
	if ok and tecnologia ~= Enum.Technology.Future then
		warn("Iluminacion: ponela en Future (Studio > Lighting > Technology) para que se vea mejor")
	end
end)

task.delay(2, aplicar)
