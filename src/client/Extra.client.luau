-- Interfaz extra: multiplicador, renacimientos, avisos, y boton de Tienda (Game Passes y productos).
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local jugador = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "HUD2"
gui.ResetOnSpawn = false
gui.Parent = jugador:WaitForChild("PlayerGui")

local function redondear(objeto, radio)
	local esquinas = Instance.new("UICorner")
	esquinas.CornerRadius = UDim.new(0, radio)
	esquinas.Parent = objeto
end

local function texto(padre, tam, color, fuente)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.TextColor3 = color
	t.TextSize = tam
	t.FontFace = Font.fromEnum(fuente)
	t.Parent = padre
	return t
end

-- ====== Multiplicador y renacimientos (debajo del panel principal) ======
local info = Instance.new("Frame")
info.Position = UDim2.fromOffset(16, 164)
info.Size = UDim2.fromOffset(230, 52)
info.BackgroundColor3 = Color3.fromRGB(22, 30, 24)
info.BackgroundTransparency = 0.2
info.Parent = gui
redondear(info, 12)

local lineaMultiplicador = texto(info, 18, Color3.fromRGB(190, 255, 150), Enum.Font.GothamBold)
lineaMultiplicador.Size = UDim2.new(1, -16, 0.5, 0)
lineaMultiplicador.Position = UDim2.fromOffset(8, 0)
lineaMultiplicador.TextXAlignment = Enum.TextXAlignment.Left

local lineaRenacer = texto(info, 16, Color3.fromRGB(200, 160, 255), Enum.Font.GothamMedium)
lineaRenacer.Size = UDim2.new(1, -16, 0.5, 0)
lineaRenacer.Position = UDim2.new(0, 8, 0.5, 0)
lineaRenacer.TextXAlignment = Enum.TextXAlignment.Left

local function actualizarInfo()
	local mult = jugador:GetAttribute("Multiplicador") or 1
	local renac = jugador:GetAttribute("Renacimientos") or 0
	local boost = jugador:GetAttribute("BoostHasta") or 0
	local extra = ""
	if boost > os.time() then
		extra = string.format(" (boost %d min)", math.ceil((boost - os.time()) / 60))
	end
	lineaMultiplicador.Text = string.format("Monedas x%.1f%s", mult, extra)
	lineaRenacer.Text = string.format("Renacer: %d  (fuerza %d)", renac, Config.FUERZA_PARA_RENACER)
end
actualizarInfo()
for _, nombre in { "Multiplicador", "Renacimientos", "BoostHasta" } do
	jugador:GetAttributeChangedSignal(nombre):Connect(actualizarInfo)
end
task.spawn(function()
	while gui.Parent do
		task.wait(15)
		actualizarInfo()
	end
end)

-- ====== Avisos grandes (recompensa diaria, compras, renacer) ======
local aviso = ReplicatedStorage:WaitForChild("Aviso")
aviso.OnClientEvent:Connect(function(mensaje)
	local cartel = Instance.new("TextLabel")
	cartel.AnchorPoint = Vector2.new(0.5, 0)
	cartel.Position = UDim2.new(0.5, 0, 0, -60)
	cartel.Size = UDim2.fromOffset(460, 48)
	cartel.BackgroundColor3 = Color3.fromRGB(30, 22, 44)
	cartel.BackgroundTransparency = 0.1
	cartel.Text = tostring(mensaje)
	cartel.TextColor3 = Color3.fromRGB(255, 235, 170)
	cartel.TextSize = 22
	cartel.FontFace = Font.fromEnum(Enum.Font.GothamBold)
	cartel.Parent = gui
	redondear(cartel, 12)

	local entrada = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(cartel, entrada, { Position = UDim2.new(0.5, 0, 0, 20) }):Play()
	task.delay(4, function()
		local salida = TweenService:Create(cartel, TweenInfo.new(0.5), {
			Position = UDim2.new(0.5, 0, 0, -60),
			BackgroundTransparency = 1,
			TextTransparency = 1,
		})
		salida:Play()
		salida.Completed:Wait()
		cartel:Destroy()
	end)
end)

-- ====== Tienda (solo muestra lo que tiene un ID configurado) ======
local OFERTAS = {
	{ id = Config.PASE_X2_MONEDAS, pase = true, nombre = "Monedas x2 (para siempre)" },
	{ id = Config.PASE_IMAN_GRANDE, pase = true, nombre = "Iman de doble alcance" },
	{ id = Config.PRODUCTO_BOOST_30MIN, pase = false, nombre = "Boost x2 por 30 minutos" },
	{
		id = Config.PRODUCTO_PACK_MONEDAS,
		pase = false,
		nombre = "Pack de " .. Config.MONEDAS_PACK .. " monedas",
	},
}

local ofertasActivas = {}
for _, oferta in OFERTAS do
	if oferta.id ~= 0 then
		table.insert(ofertasActivas, oferta)
	end
end

if #ofertasActivas > 0 then
	local boton = Instance.new("TextButton")
	boton.AnchorPoint = Vector2.new(1, 0)
	boton.Position = UDim2.new(1, -16, 0, 16)
	boton.Size = UDim2.fromOffset(130, 44)
	boton.BackgroundColor3 = Color3.fromRGB(235, 175, 60)
	boton.Text = "TIENDA"
	boton.TextColor3 = Color3.fromRGB(40, 26, 10)
	boton.TextSize = 22
	boton.FontFace = Font.fromEnum(Enum.Font.GothamBlack)
	boton.Parent = gui
	redondear(boton, 12)

	local ventana = Instance.new("Frame")
	ventana.AnchorPoint = Vector2.new(0.5, 0.5)
	ventana.Position = UDim2.fromScale(0.5, 0.5)
	ventana.Size = UDim2.fromOffset(380, 70 + #ofertasActivas * 56)
	ventana.BackgroundColor3 = Color3.fromRGB(22, 30, 24)
	ventana.Visible = false
	ventana.Parent = gui
	redondear(ventana, 14)

	local titulo = texto(ventana, 24, Color3.fromRGB(255, 235, 170), Enum.Font.GothamBlack)
	titulo.Size = UDim2.new(1, 0, 0, 50)
	titulo.Text = "TIENDA"

	for k, oferta in ofertasActivas do
		local compra = Instance.new("TextButton")
		compra.Position = UDim2.new(0, 14, 0, 50 + (k - 1) * 56)
		compra.Size = UDim2.new(1, -28, 0, 48)
		compra.BackgroundColor3 = Color3.fromRGB(60, 110, 70)
		compra.Text = oferta.nombre
		compra.TextColor3 = Color3.new(1, 1, 1)
		compra.TextSize = 20
		compra.FontFace = Font.fromEnum(Enum.Font.GothamBold)
		compra.Parent = ventana
		redondear(compra, 10)
		compra.Activated:Connect(function()
			if oferta.pase then
				MarketplaceService:PromptGamePassPurchase(jugador, oferta.id)
			else
				MarketplaceService:PromptProductPurchase(jugador, oferta.id)
			end
		end)
	end

	boton.Activated:Connect(function()
		ventana.Visible = not ventana.Visible
	end)
end
