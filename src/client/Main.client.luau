-- Interfaz del jugador: panel de estadisticas, titulo de entrada y avisos "+N".
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local jugador = Players.LocalPlayer

-- Ocultamos la lista de jugadores de Roblox (usamos nuestro panel)
task.spawn(function()
	for _ = 1, 10 do
		local ok = pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		end)
		if ok then
			break
		end
		task.wait(0.5)
	end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "HUD"
gui.ResetOnSpawn = false
gui.Parent = jugador:WaitForChild("PlayerGui")

-- ====== Panel arriba a la izquierda ======
local panel = Instance.new("Frame")
panel.Position = UDim2.fromOffset(16, 16)
panel.Size = UDim2.fromOffset(230, 140)
panel.BackgroundColor3 = Color3.fromRGB(22, 30, 24)
panel.BackgroundTransparency = 0.2
panel.Parent = gui

local esquinasPanel = Instance.new("UICorner")
esquinasPanel.CornerRadius = UDim.new(0, 12)
esquinasPanel.Parent = panel

local borde = Instance.new("UIStroke")
borde.Color = Color3.fromRGB(230, 190, 90)
borde.Thickness = 2
borde.Transparency = 0.2
borde.Parent = panel

local relleno = Instance.new("UIPadding")
relleno.PaddingTop = UDim.new(0, 10)
relleno.PaddingBottom = UDim.new(0, 10)
relleno.PaddingLeft = UDim.new(0, 12)
relleno.PaddingRight = UDim.new(0, 12)
relleno.Parent = panel

local lista = Instance.new("UIListLayout")
lista.Padding = UDim.new(0, 4)
lista.SortOrder = Enum.SortOrder.LayoutOrder
lista.Parent = panel

local function crearFila(orden, nombre, colorValor)
	local fila = Instance.new("Frame")
	fila.LayoutOrder = orden
	fila.Size = UDim2.new(1, 0, 0, 34)
	fila.BackgroundTransparency = 1
	fila.Parent = panel

	local etiqueta = Instance.new("TextLabel")
	etiqueta.Size = UDim2.fromScale(0.55, 1)
	etiqueta.BackgroundTransparency = 1
	etiqueta.Text = nombre
	etiqueta.TextXAlignment = Enum.TextXAlignment.Left
	etiqueta.TextColor3 = Color3.fromRGB(220, 225, 215)
	etiqueta.TextSize = 20
	etiqueta.FontFace = Font.fromEnum(Enum.Font.GothamMedium)
	etiqueta.Parent = fila

	local valor = Instance.new("TextLabel")
	valor.AnchorPoint = Vector2.new(1, 0)
	valor.Position = UDim2.fromScale(1, 0)
	valor.Size = UDim2.fromScale(0.45, 1)
	valor.BackgroundTransparency = 1
	valor.Text = "0"
	valor.TextXAlignment = Enum.TextXAlignment.Right
	valor.TextColor3 = colorValor
	valor.TextSize = 24
	valor.FontFace = Font.fromEnum(Enum.Font.GothamBlack)
	valor.Parent = fila

	local escala = Instance.new("UIScale")
	escala.Parent = valor
	return valor, escala
end

local valorItems, escalaItems = crearFila(1, "Items", Color3.fromRGB(235, 175, 100))
local valorMonedas, escalaMonedas = crearFila(2, "Monedas", Color3.fromRGB(255, 215, 90))
local valorFuerza, escalaFuerza = crearFila(3, "Fuerza", Color3.fromRGB(255, 120, 100))

-- Aviso "+N" que sube desde el centro de la pantalla
local function emerger(texto, color)
	local x = 0.5 + math.random(-5, 5) / 100
	local aviso = Instance.new("TextLabel")
	aviso.AnchorPoint = Vector2.new(0.5, 0.5)
	aviso.Position = UDim2.fromScale(x, 0.6)
	aviso.Size = UDim2.fromOffset(220, 36)
	aviso.BackgroundTransparency = 1
	aviso.Text = texto
	aviso.TextSize = 26
	aviso.FontFace = Font.fromEnum(Enum.Font.GothamBlack)
	aviso.TextColor3 = color
	aviso.TextStrokeTransparency = 0
	aviso.Parent = gui

	TweenService:Create(
		aviso,
		TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = UDim2.fromScale(x, 0.52), TextTransparency = 1, TextStrokeTransparency = 1 }
	):Play()
	task.delay(1, function()
		aviso:Destroy()
	end)
end

local function vincular(nombreStat, etiquetaValor, escala, avisoTexto, colorAviso)
	task.spawn(function()
		local stats = jugador:WaitForChild("leaderstats")
		local valor = stats:WaitForChild(nombreStat)
		local anterior = valor.Value
		etiquetaValor.Text = tostring(anterior)

		valor.Changed:Connect(function(nuevo)
			etiquetaValor.Text = tostring(nuevo)
			if nuevo > anterior then
				escala.Scale = 1.35
				TweenService:Create(
					escala,
					TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Scale = 1 }
				):Play()
				if avisoTexto then
					emerger("+" .. (nuevo - anterior) .. " " .. avisoTexto, colorAviso)
				end
			end
			anterior = nuevo
		end)
	end)
end

vincular("Items", valorItems, escalaItems, "item", Color3.fromRGB(255, 200, 130))
vincular("Monedas", valorMonedas, escalaMonedas, "monedas", Color3.fromRGB(255, 225, 100))
vincular("Fuerza", valorFuerza, escalaFuerza, nil, Color3.new(1, 1, 1))

-- ====== Barra de abajo: costo de la proxima mejora ======
local barra = Instance.new("TextLabel")
barra.AnchorPoint = Vector2.new(0.5, 1)
barra.Position = UDim2.new(0.5, 0, 1, -20)
barra.Size = UDim2.fromOffset(420, 36)
barra.BackgroundColor3 = Color3.new(0, 0, 0)
barra.BackgroundTransparency = 0.4
barra.TextColor3 = Color3.new(1, 1, 1)
barra.TextSize = 20
barra.FontFace = Font.fromEnum(Enum.Font.GothamBold)
barra.Parent = gui

local esquinasBarra = Instance.new("UICorner")
esquinasBarra.CornerRadius = UDim.new(0, 10)
esquinasBarra.Parent = barra

local function actualizar()
	local costo = jugador:GetAttribute("CostoFuerza") or 0
	barra.Text = string.format("Mejorar fuerza cuesta %d monedas", costo)
end
actualizar()
jugador:GetAttributeChangedSignal("CostoFuerza"):Connect(actualizar)

local ayuda = Instance.new("TextLabel")
ayuda.AnchorPoint = Vector2.new(0, 1)
ayuda.Position = UDim2.new(0, 16, 1, -16)
ayuda.Size = UDim2.fromOffset(560, 24)
ayuda.BackgroundTransparency = 1
ayuda.Text = "Clic: golpear  |  E (mantener): puestos  |  G: graficos  |  M: sonido"
ayuda.TextXAlignment = Enum.TextXAlignment.Left
ayuda.TextColor3 = Color3.fromRGB(235, 235, 225)
ayuda.TextSize = 16
ayuda.TextStrokeTransparency = 0.5
ayuda.FontFace = Font.fromEnum(Enum.Font.GothamMedium)
ayuda.Parent = gui

-- ====== Titulo que aparece al entrar y se desvanece ======
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
	TweenService
		:Create(titulo, TweenInfo.new(1.5), { TextTransparency = 1, TextStrokeTransparency = 1 })
		:Play()
end)
