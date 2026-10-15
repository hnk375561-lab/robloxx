-- Game Passes y Developer Products. Los IDs se ponen en Config.luau (mientras sean 0, no hacen nada).
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Guardado = require(script.Parent.Guardado)
local Jugadores = require(script.Parent.Jugadores)

local Monetizacion = {}

local recibos = nil
pcall(function()
	recibos = DataStoreService:GetDataStore("RobloxxRecibos_v1")
end)

local function darPase(jugador, idPase)
	if idPase == Config.PASE_X2_MONEDAS and idPase ~= 0 then
		jugador:SetAttribute("PaseX2", true)
		Jugadores.avisar(jugador, "Gracias! Monedas x2 para siempre")
	elseif idPase == Config.PASE_DANO_X2 and idPase ~= 0 then
		jugador:SetAttribute("PaseDano", true)
		Jugadores.avisar(jugador, "Gracias! Tu dano es x2 para siempre")
	elseif idPase == Config.PASE_IMAN_GRANDE and idPase ~= 0 then
		jugador:SetAttribute("PaseIman", true)
		Jugadores.avisar(jugador, "Gracias! Iman con el doble de alcance")
	end
end

local function revisarPases(jugador)
	for _, idPase in { Config.PASE_X2_MONEDAS, Config.PASE_IMAN_GRANDE, Config.PASE_DANO_X2 } do
		if idPase ~= 0 then
			local ok, lo_tiene = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(jugador.UserId, idPase)
			end)
			if ok and lo_tiene then
				darPase(jugador, idPase)
			end
		end
	end
end

-- Entrega lo comprado. Devuelve true si se entrego.
local function entregar(jugador, idProducto)
	local stats = jugador:FindFirstChild("leaderstats")
	if not stats or not jugador:GetAttribute("DatosCargados") then
		return false
	end

	if idProducto == Config.PRODUCTO_BOOST_30MIN and idProducto ~= 0 then
		local desde = math.max(os.time(), jugador:GetAttribute("BoostHasta") or 0)
		jugador:SetAttribute("BoostHasta", desde + Config.MINUTOS_BOOST * 60)
		Jugadores.avisar(jugador, "Boost x2 activado por " .. Config.MINUTOS_BOOST .. " minutos")
		return true
	elseif idProducto == Config.PRODUCTO_PACK_MONEDAS and idProducto ~= 0 then
		stats.Monedas.Value += Config.MONEDAS_PACK
		Jugadores.avisar(jugador, "+" .. Config.MONEDAS_PACK .. " monedas")
		return true
	end
	return false
end

function Monetizacion.iniciar()
	Players.PlayerAdded:Connect(function(jugador)
		task.spawn(revisarPases, jugador)
	end)
	for _, jugador in Players:GetPlayers() do
		task.spawn(revisarPases, jugador)
	end

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(jugador, idPase, compro)
		if compro then
			darPase(jugador, idPase)
		end
	end)

	-- Roblox puede repetir un recibo: guardamos cada PurchaseId para no entregar dos veces.
	MarketplaceService.ProcessReceipt = function(info)
		local jugador = Players:GetPlayerByUserId(info.PlayerId)
		if not jugador or not recibos then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local clave = "r_" .. info.PurchaseId
		local ok, yaEntregado = pcall(function()
			return recibos:GetAsync(clave)
		end)
		if not ok then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		if yaEntregado then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		if not entregar(jugador, info.ProductId) then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local guardo = pcall(function()
			recibos:SetAsync(clave, true)
		end)
		if not guardo then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		Guardado.guardarYa(jugador)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

return Monetizacion
