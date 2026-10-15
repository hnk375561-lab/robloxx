-- Cartel del proximo regalo por tiempo y banner del Evento Dorado.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local jugador = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "HUDRetencion"
gui.ResetOnSpawn = false
gui.Parent = jugador:WaitForChild("PlayerGui")

-- ====== Proximo regalo (debajo de la mision) ======
local regalo = Instance.new("TextLabel")
regalo.Position = UDim2.fromOffset(16, 356)
regalo.Size = UDim2.fromOffset(230, 34)
regalo.BackgroundColor3 = Color3.fromRGB(22, 30, 24)
regalo.BackgroundTransparency = 0.2
regalo.TextColor3 = Color3.fromRGB(255, 225, 140)
regalo.TextSize = 16
regalo.FontFace = Font.fromEnum(Enum.Font.GothamBold)
regalo.Parent = gui

local esquinasRegalo = Instance.new("UICorner")
esquinasRegalo.CornerRadius = UDim.new(0, 12)
esquinasRegalo.Parent = regalo

-- ====== Banner del evento dorado ======
local banner = Instance.new("TextLabel")
banner.AnchorPoint = Vector2.new(0.5, 0)
banner.Position = UDim2.new(0.5, 0, 0, 80)
banner.Size = UDim2.fromOffset(380, 44)
banner.BackgroundColor3 = Color3.fromRGB(70, 48, 8)
banner.BackgroundTransparency = 0.1
banner.TextColor3 = Color3.fromRGB(255, 220, 90)
banner.TextSize = 22
banner.FontFace = Font.fromEnum(Enum.Font.GothamBlack)
banner.Visible = false
banner.Parent = gui

local esquinasBanner = Instance.new("UICorner")
esquinasBanner.CornerRadius = UDim.new(0, 12)
esquinasBanner.Parent = banner

local borde = Instance.new("UIStroke")
borde.Color = Color3.fromRGB(255, 200, 60)
borde.Thickness = 2
borde.Parent = banner

TweenService:Create(
	borde,
	TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
	{ Transparency = 0.8 }
):Play()

local function formatear(segundos)
	segundos = math.max(0, segundos)
	return string.format("%d:%02d", segundos // 60, segundos % 60)
end

local function actualizar()
	local ahora = os.time()

	local momento = jugador:GetAttribute("RegaloEn") or 0
	local indice = jugador:GetAttribute("RegaloIndice") or 1
	if momento > 0 and Config.REGALOS[indice] then
		local premio = Config.REGALOS[indice].monedas
		regalo.Text = string.format("Regalo en %s  (+%d)", formatear(momento - ahora), premio)
	else
		regalo.Text = "Todos los regalos reclamados"
	end

	local evento = workspace:GetAttribute("EventoHasta") or 0
	if evento > ahora then
		banner.Visible = true
		banner.Text = string.format("EVENTO DORADO  x2  %ds", evento - ahora)
	else
		banner.Visible = false
	end
end

actualizar()
task.spawn(function()
	while gui.Parent do
		actualizar()
		task.wait(1)
	end
end)
