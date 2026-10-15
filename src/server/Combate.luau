-- Recibe los golpes de los jugadores y los valida antes de danar paredes.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Paredes = require(script.Parent.Paredes)

local Combate = {}

local ultimoGolpe = {}

function Combate.iniciar()
	local remoto = Instance.new("RemoteEvent")
	remoto.Name = "Golpear"
	remoto.Parent = ReplicatedStorage

	local filtro = OverlapParams.new()
	filtro.FilterType = Enum.RaycastFilterType.Include
	filtro.FilterDescendantsInstances = { Paredes.carpeta() }

	remoto.OnServerEvent:Connect(function(jugador, parte)
		-- Nunca confiamos en lo que manda el cliente
		if typeof(parte) ~= "Instance" or not parte:IsA("BasePart") then
			return
		end
		if not CollectionService:HasTag(parte, "Voxel") then
			return
		end

		local ahora = os.clock()
		if ahora - (ultimoGolpe[jugador] or 0) < Config.ENFRIAMIENTO * 0.8 then
			return
		end
		ultimoGolpe[jugador] = ahora

		local personaje = jugador.Character
		local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
		if not raiz then
			return
		end
		if (raiz.Position - parte.Position).Magnitude > Config.ALCANCE + 8 then
			return
		end

		local fuerza = jugador:GetAttribute("Fuerza")
		if type(fuerza) ~= "number" then
			fuerza = 1
		end
		local radio = math.min(Config.RADIO_AREA + 0.35 * (fuerza - 1), 6)

		for _, vecino in workspace:GetPartBoundsInRadius(parte.Position, radio, filtro) do
			if CollectionService:HasTag(vecino, "Voxel") then
				Paredes.danar(vecino, fuerza)
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(jugador)
		ultimoGolpe[jugador] = nil
	end)
end

return Combate
