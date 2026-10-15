-- Cartel con tu arma actual, tu dano y lo que cuesta la siguiente.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local jugador = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "HUDArma"
gui.ResetOnSpawn = false
gui.Parent = jugador:WaitForChild("PlayerGui")

local cuadro = Instance.new("Frame")
cuadro.Position = UDim2.fromOffset(16, 224)
cuadro.Size = UDim2.fromOffset(230, 52)
cuadro.BackgroundColor3 = Color3.fromRGB(22, 30, 24)
cuadro.BackgroundTransparency = 0.2
cuadro.Parent = gui

local esquinas = Instance.new("UICorner")
esquinas.CornerRadius = UDim.new(0, 12)
esquinas.Parent = cuadro

local function linea(posicionY, tamano, color)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Position = UDim2.new(0, 8, posicionY, 0)
	t.Size = UDim2.new(1, -16, 0.5, 0)
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.TextSize = tamano
	t.TextColor3 = color
	t.FontFace = Font.fromEnum(Enum.Font.GothamBold)
	t.Parent = cuadro
	return t
end

local lineaArma = linea(0, 18, Color3.fromRGB(255, 190, 150))
local lineaSiguiente = linea(0.5, 15, Color3.fromRGB(220, 225, 215))

local function actualizar()
	local indice = math.clamp(jugador:GetAttribute("Arma") or 1, 1, #Config.ARMAS)
	local dano = jugador:GetAttribute("Dano") or 1
	lineaArma.Text = string.format("%s  (dano %.1f)", Config.ARMAS[indice].nombre, dano)
	local siguiente = Config.ARMAS[indice + 1]
	if siguiente then
		lineaSiguiente.Text =
			string.format("Proxima: %s - %d monedas", siguiente.nombre, siguiente.precio)
	else
		lineaSiguiente.Text = "Arma maxima!"
	end
end

actualizar()
for _, nombre in { "Arma", "Dano" } do
	jugador:GetAttributeChangedSignal(nombre):Connect(actualizar)
end
