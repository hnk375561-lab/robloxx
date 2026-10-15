-- El viento mueve suavemente las copas de los arboles y los arbustos (solo en PC).
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	return
end

local bosque = workspace:WaitForChild("Bosque", 30)
if not bosque then
	return
end

local partes = {}
local origenes = {}
local fases = {}
local amplitudes = {}

local function registrar(pieza)
	if not pieza:IsA("BasePart") then
		return
	end
	local amplitud = 0
	if pieza.Name == "Hojas" then
		amplitud = 0.45
	elseif pieza.Name == "Matas" then
		amplitud = 0.2
	end
	if amplitud > 0 then
		table.insert(partes, pieza)
		table.insert(origenes, pieza.CFrame)
		table.insert(fases, pieza.Position.X * 0.07 + pieza.Position.Z * 0.11)
		table.insert(amplitudes, amplitud)
	end
end

for _, pieza in bosque:GetChildren() do
	registrar(pieza)
end
bosque.ChildAdded:Connect(registrar)

local acumulado = 0
RunService.Heartbeat:Connect(function(dt)
	acumulado += dt
	if acumulado < 0.05 then
		return
	end
	acumulado = 0

	local t = os.clock()
	local nuevos = table.create(#partes)
	for i = 1, #partes do
		local fase = fases[i]
		local a = amplitudes[i]
		nuevos[i] = origenes[i]
			+ Vector3.new(
				math.sin(t * 0.8 + fase) * a,
				math.sin(t * 1.3 + fase * 1.7) * a * 0.3,
				math.cos(t * 0.7 + fase) * a
			)
	end
	pcall(function()
		workspace:BulkMoveTo(partes, nuevos, Enum.BulkMoveMode.FireCFrameChanged)
	end)
end)
