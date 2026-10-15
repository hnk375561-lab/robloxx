-- Cartel de la mision actual con barra de progreso.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local jugador = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "HUDMision"
gui.ResetOnSpawn = false
gui.Parent = jugador:WaitForChild("PlayerGui")

local cuadro = Instance.new("Frame")
cuadro.Position = UDim2.fromOffset(16, 284)
cuadro.Size = UDim2.fromOffset(230, 64)
cuadro.BackgroundColor3 = Color3.fromRGB(22, 30, 24)
cuadro.BackgroundTransparency = 0.2
cuadro.Parent = gui

local esquinas = Instance.new("UICorner")
esquinas.CornerRadius = UDim.new(0, 12)
esquinas.Parent = cuadro

local titulo = Instance.new("TextLabel")
titulo.BackgroundTransparency = 1
titulo.Position = UDim2.fromOffset(8, 4)
titulo.Size = UDim2.new(1, -16, 0, 24)
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.TextSize = 16
titulo.TextColor3 = Color3.fromRGB(160, 220, 255)
titulo.FontFace = Font.fromEnum(Enum.Font.GothamBold)
titulo.Parent = cuadro

local fondoBarra = Instance.new("Frame")
fondoBarra.Position = UDim2.fromOffset(8, 32)
fondoBarra.Size = UDim2.new(1, -16, 0, 14)
fondoBarra.BackgroundColor3 = Color3.fromRGB(10, 14, 12)
fondoBarra.Parent = cuadro

local esquinasFondo = Instance.new("UICorner")
esquinasFondo.CornerRadius = UDim.new(0, 7)
esquinasFondo.Parent = fondoBarra

local relleno = Instance.new("Frame")
relleno.Size = UDim2.fromScale(0, 1)
relleno.BackgroundColor3 = Color3.fromRGB(110, 200, 255)
relleno.Parent = fondoBarra

local esquinasRelleno = Instance.new("UICorner")
esquinasRelleno.CornerRadius = UDim.new(0, 7)
esquinasRelleno.Parent = relleno

local detalle = Instance.new("TextLabel")
detalle.BackgroundTransparency = 1
detalle.Position = UDim2.fromOffset(8, 46)
detalle.Size = UDim2.new(1, -16, 0, 16)
detalle.TextXAlignment = Enum.TextXAlignment.Left
detalle.TextSize = 13
detalle.TextColor3 = Color3.fromRGB(220, 225, 215)
detalle.FontFace = Font.fromEnum(Enum.Font.GothamMedium)
detalle.Parent = cuadro

local function actualizar()
	local numero = jugador:GetAttribute("Mision") or 1
	local progreso = jugador:GetAttribute("MisionProgreso") or 0
	local meta = Config.MISION_META * numero
	local premio = Config.MISION_PREMIO * numero

	titulo.Text = string.format("Mision %d: rompe %d cubitos", numero, meta)
	detalle.Text = string.format("%d / %d   (premio %d monedas)", progreso, meta, premio)
	TweenService:Create(
		relleno,
		TweenInfo.new(0.2),
		{ Size = UDim2.fromScale(math.clamp(progreso / meta, 0, 1), 1) }
	):Play()
end

actualizar()
for _, nombre in { "Mision", "MisionProgreso" } do
	jugador:GetAttributeChangedSignal(nombre):Connect(actualizar)
end
