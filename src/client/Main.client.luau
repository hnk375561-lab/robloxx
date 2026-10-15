-- Interfaz del jugador: titulo de entrada, fuerza y costo de la proxima mejora.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local jugador = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "HUD"
gui.ResetOnSpawn = false
gui.Parent = jugador:WaitForChild("PlayerGui")

local etiqueta = Instance.new("TextLabel")
etiqueta.AnchorPoint = Vector2.new(0.5, 1)
etiqueta.Position = UDim2.new(0.5, 0, 1, -20)
etiqueta.Size = UDim2.fromOffset(440, 40)
etiqueta.BackgroundColor3 = Color3.new(0, 0, 0)
etiqueta.BackgroundTransparency = 0.4
etiqueta.TextColor3 = Color3.new(1, 1, 1)
etiqueta.TextScaled = true
etiqueta.FontFace = Font.fromEnum(Enum.Font.GothamBold)
etiqueta.Parent = gui

local esquinas = Instance.new("UICorner")
esquinas.CornerRadius = UDim.new(0, 10)
esquinas.Parent = etiqueta

local function actualizar()
	local fuerza = jugador:GetAttribute("Fuerza") or 1
	local costo = jugador:GetAttribute("CostoFuerza") or 0
	etiqueta.Text = string.format("Fuerza: %d  |  Mejorar cuesta: %d monedas", fuerza, costo)
end

actualizar()
jugador:GetAttributeChangedSignal("Fuerza"):Connect(actualizar)
jugador:GetAttributeChangedSignal("CostoFuerza"):Connect(actualizar)

-- Titulo que aparece al entrar y se desvanece
local titulo = Instance.new("TextLabel")
titulo.AnchorPoint = Vector2.new(0.5, 0.5)
titulo.Position = UDim2.fromScale(0.5, 0.25)
titulo.Size = UDim2.fromOffset(600, 80)
titulo.BackgroundTransparency = 1
titulo.Text = "Encerrados en el bosque"
titulo.TextScaled = true
titulo.FontFace = Font.fromEnum(Enum.Font.GothamBold)
titulo.TextColor3 = Color3.fromRGB(255, 240, 200)
titulo.TextStrokeTransparency = 0
titulo.Parent = gui

task.delay(3, function()
	local desvanecer = TweenService:Create(
		titulo,
		TweenInfo.new(1.5),
		{ TextTransparency = 1, TextStrokeTransparency = 1 }
	)
	desvanecer:Play()
end)
