-- Primera persona y mira en el centro de la pantalla.
local Players = game:GetService("Players")

local jugador = Players.LocalPlayer
jugador.CameraMode = Enum.CameraMode.LockFirstPerson

local gui = Instance.new("ScreenGui")
gui.Name = "Mira"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = jugador:WaitForChild("PlayerGui")

local punto = Instance.new("Frame")
punto.AnchorPoint = Vector2.new(0.5, 0.5)
punto.Position = UDim2.fromScale(0.5, 0.5)
punto.Size = UDim2.fromOffset(6, 6)
punto.BackgroundColor3 = Color3.new(1, 1, 1)
punto.Parent = gui

local redondo = Instance.new("UICorner")
redondo.CornerRadius = UDim.new(1, 0)
redondo.Parent = punto

local borde = Instance.new("UIStroke")
borde.Color = Color3.new(0, 0, 0)
borde.Thickness = 1
borde.Parent = punto
