-- Pulido de pantalla: vineta suave, enfoque automatico y modo liviano para celulares.
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local jugador = Players.LocalPlayer
local camara = workspace.CurrentCamera

local esCelular = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ====== Vineta (bordes un poco oscuros, estilo cine) ======
local pantalla = Instance.new("ScreenGui")
pantalla.Name = "Vineta"
pantalla.IgnoreGuiInset = true
pantalla.ResetOnSpawn = false
pantalla.DisplayOrder = -1
pantalla.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pantalla.Parent = jugador:WaitForChild("PlayerGui")

local function borde(posicion, tamano, giro)
	local marco = Instance.new("Frame")
	marco.BackgroundColor3 = Color3.new(0, 0, 0)
	marco.BorderSizePixel = 0
	marco.Position = posicion
	marco.Size = tamano
	marco.Active = false

	local degradado = Instance.new("UIGradient")
	degradado.Rotation = giro
	degradado.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.82),
		NumberSequenceKeypoint.new(1, 1),
	})
	degradado.Parent = marco
	marco.Parent = pantalla
end

borde(UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.12), 90)
borde(UDim2.fromScale(0, 0.88), UDim2.fromScale(1, 0.12), -90)
borde(UDim2.fromScale(0, 0), UDim2.fromScale(0.1, 1), 0)
borde(UDim2.fromScale(0.9, 0), UDim2.fromScale(0.1, 1), 180)

-- ====== Modo liviano en celulares ======
if esCelular then
	for _, efecto in Lighting:GetChildren() do
		if efecto:IsA("SunRaysEffect") or efecto:IsA("DepthOfFieldEffect") then
			efecto.Enabled = false
		elseif efecto:IsA("BloomEffect") then
			efecto.Size = 14
		end
	end
	return
end

-- ====== Enfoque automatico: lo que miras queda nitido, lo lejano se desenfoca ======
local profundidad = Lighting:WaitForChild("DepthOfFieldEffect", 15)
if not profundidad then
	return
end

local filtro = RaycastParams.new()
filtro.FilterType = Enum.RaycastFilterType.Exclude
local foco = 60

RunService:BindToRenderStep("Enfoque", Enum.RenderPriority.Camera.Value + 2, function(dt)
	local excluidos = { camara }
	if jugador.Character then
		table.insert(excluidos, jugador.Character)
	end
	filtro.FilterDescendantsInstances = excluidos

	local tamano = camara.ViewportSize
	local rayo = camara:ViewportPointToRay(tamano.X / 2, tamano.Y / 2)
	local resultado = workspace:Raycast(rayo.Origin, rayo.Direction * 120, filtro)
	local distancia = 120
	if resultado then
		distancia = resultado.Distance
	end

	foco += (math.clamp(distancia, 12, 120) - foco) * math.min(dt * 4, 1)
	profundidad.FocusDistance = foco
end)
