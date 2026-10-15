-- Detalle en el piso: tierra alrededor de cada arbol y parches de tierra, barro y musgo.
local Suelo = {}

local MATERIALES_PARCHES = {
	Enum.Material.Ground,
	Enum.Material.Mud,
	Enum.Material.LeafyGrass,
	Enum.Material.Ground,
}

-- Cubre exactamente la capa superior del terreno (de Y = -4 a Y = 0)
local function parche(terreno, x, z, radio, material)
	pcall(function()
		terreno:FillCylinder(CFrame.new(x, -2, z), 4, radio, material)
	end)
end

function Suelo.crear()
	local bosque = workspace:FindFirstChild("Bosque")
	if not bosque then
		warn("Suelo: no encontre la carpeta Bosque")
		return
	end
	local terreno = workspace.Terrain
	local azar = Random.new(77)

	-- Tierra y barro bajo cada arbol (la pieza "Base" mide 3.6 de ancho por cada escala)
	for _, pieza in bosque:GetChildren() do
		if pieza.Name == "Base" and pieza:IsA("BasePart") then
			local x = pieza.Position.X
			local z = pieza.Position.Z
			parche(terreno, x, z, pieza.Size.Y * 1.15, Enum.Material.Ground)
			parche(terreno, x, z, pieza.Size.Y * 0.7, Enum.Material.Mud)
		end
	end

	-- Parches sueltos dentro de cada habitacion
	local lado = 40
	for i = 1, 4 do
		for j = 1, 4 do
			local cx = (i - 1) * lado
			local cz = (j - 1) * lado
			for _ = 1, 7 do
				local x = cx + azar:NextNumber(-17, 17)
				local z = cz + azar:NextNumber(-17, 17)
				local material = MATERIALES_PARCHES[azar:NextInteger(1, #MATERIALES_PARCHES)]
				parche(terreno, x, z, azar:NextNumber(2.5, 5.5), material)
			end
		end
	end
end

return Suelo
