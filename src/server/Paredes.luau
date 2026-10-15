-- Logica de las paredes rompibles y de los items que sueltan.
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Paredes = {}

local function soltarItems(posicion, cantidad)
	for _ = 1, cantidad do
		local item = Instance.new("Part")
		item.Name = "Item"
		item.Size = Vector3.new(1.5, 1.5, 1.5)
		item.Color = Color3.fromRGB(150, 100, 50)
		item.Material = Enum.Material.Wood
		item.Position = posicion + Vector3.new(math.random(-3, 3), 4, math.random(-3, 3))
		item.Parent = workspace

		local recogido = false
		item.Touched:Connect(function(otro)
			if recogido then
				return
			end
			local personaje = otro:FindFirstAncestorOfClass("Model")
			local jugador = personaje and Players:GetPlayerFromCharacter(personaje)
			if not jugador then
				return
			end
			recogido = true
			local stats = jugador:FindFirstChild("leaderstats")
			if stats then
				stats.Items.Value += 1
			end
			item:Destroy()
		end)

		Debris:AddItem(item, 120)
	end
end

local function desmoronar(pared, profundidad)
	local posicion = pared.Position
	for _ = 1, 10 do
		local pedazo = Instance.new("Part")
		pedazo.Name = "Escombro"
		pedazo.Size = Vector3.new(2, 2, 2)
		pedazo.Color = pared.Color
		pedazo.Material = pared.Material
		pedazo.Position = posicion
			+ Vector3.new(math.random(-4, 4), math.random(-4, 4), math.random(-4, 4))
		pedazo.Parent = workspace
		Debris:AddItem(pedazo, 4)
	end

	soltarItems(Vector3.new(posicion.X, 2, posicion.Z), 2 + profundidad)
	pared:Destroy()
end

-- Le agrega vida y el boton "Golpear" a una pared.
-- profundidad: 1 = cerca del inicio, mas alto = mas lejos (mas vida y mas items)
function Paredes.prepararPared(pared, profundidad)
	local vidaMaxima = 4 * profundidad
	local vida = vidaMaxima
	local destruida = false

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Golpear"
	prompt.ObjectText = "Pared"
	prompt.HoldDuration = 0.3
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = pared

	prompt.Triggered:Connect(function(jugador)
		if destruida then
			return
		end
		local dano = jugador:GetAttribute("Fuerza") or 1
		vida -= dano
		if vida <= 0 then
			destruida = true
			prompt.Enabled = false
			desmoronar(pared, profundidad)
		else
			-- A medida que recibe golpes se va poniendo mas transparente
			pared.Transparency = (1 - vida / vidaMaxima) * 0.6
		end
	end)
end

return Paredes
