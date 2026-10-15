-- Paredes hechas de cubitos (voxeles). Cada cubito tiene vida y se rompe por separado.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Fragmentos = require(script.Parent.Fragmentos)

local Paredes = {}

local carpetaVoxeles = Instance.new("Folder")
carpetaVoxeles.Name = "Voxeles"
carpetaVoxeles.Parent = workspace

local carpetaFragmentos = Instance.new("Folder")
carpetaFragmentos.Name = "Fragmentos"
carpetaFragmentos.Parent = workspace

local PALETA = {
	Color3.fromRGB(140, 134, 122),
	Color3.fromRGB(122, 117, 107),
	Color3.fromRGB(152, 126, 96),
	Color3.fromRGB(110, 114, 102),
}
local COLOR_MUSGO = Color3.fromRGB(98, 144, 68)

function Paredes.carpeta()
	return carpetaVoxeles
end

local function romper(voxel)
	CollectionService:RemoveTag(voxel, "Voxel")
	voxel:SetAttribute("Vida", nil)
	voxel.Parent = carpetaFragmentos
	voxel.Size = voxel.Size * 0.75
	voxel.Color = voxel:GetAttribute("ColorBase")
	voxel.Anchored = false
	voxel.CanCollide = true
	voxel.AssemblyLinearVelocity =
		Vector3.new(math.random(-14, 14), math.random(8, 16), math.random(-14, 14))
	voxel.AssemblyAngularVelocity =
		Vector3.new(math.random(-8, 8), math.random(-8, 8), math.random(-8, 8))
	pcall(function()
		voxel:SetNetworkOwner(nil)
	end)
	Fragmentos.agregar(voxel, voxel:GetAttribute("Valor") or 1)
end

-- Le resta vida a un cubito. Si llega a 0, se rompe y queda suelto.
function Paredes.danar(voxel, dano)
	local vida = voxel:GetAttribute("Vida")
	if not vida then
		return
	end
	vida -= dano
	if vida <= 0 then
		romper(voxel)
		return true
	end
	voxel:SetAttribute("Vida", vida)
	local vidaMax = voxel:GetAttribute("VidaMax")
	local base = voxel:GetAttribute("ColorBase")
	voxel.Color = base:Lerp(Color3.new(0, 0, 0), (1 - vida / vidaMax) * 0.55)
end

-- Reemplaza la pared de una pieza por una grilla de cubitos.
-- profundidad: 1 = cerca del inicio, mas alto = mas lejos (mas vida y mas valor)
function Paredes.prepararPared(pared, profundidad)
	local lado = Config.VOXEL
	local tamano = pared.Size
	local nx = math.max(1, math.round(tamano.X / lado))
	local ny = math.max(1, math.round(tamano.Y / lado))
	local nz = math.max(1, math.round(tamano.Z / lado))

	local origen = pared.Position
		- Vector3.new(nx * lado, ny * lado, nz * lado) / 2
		+ Vector3.new(lado, lado, lado) / 2

	local vidaMax = Config.VIDA_BASE + profundidad
	local valor = 1 + math.floor((profundidad - 1) / 2)
	local azar = Random.new()

	for x = 0, nx - 1 do
		for y = 0, ny - 1 do
			for z = 0, nz - 1 do
				local voxel = Instance.new("Part")
				voxel.Name = "Voxel"
				voxel.Size = Vector3.new(lado - 0.06, lado - 0.06, lado - 0.06)
				voxel.Position = origen + Vector3.new(x * lado, y * lado, z * lado)
				voxel.Anchored = true

				local color = PALETA[azar:NextInteger(1, #PALETA)]
				if y == ny - 1 then
					color = COLOR_MUSGO
					voxel.Material = Enum.Material.Grass
				else
					voxel.Material = Enum.Material.Slate
				end
				voxel.Color = color

				voxel:SetAttribute("Vida", vidaMax)
				voxel:SetAttribute("VidaMax", vidaMax)
				voxel:SetAttribute("ColorBase", color)
				voxel:SetAttribute("Valor", valor)
				CollectionService:AddTag(voxel, "Voxel")
				voxel.Parent = carpetaVoxeles
			end
		end
	end

	pared:Destroy()
end

return Paredes
