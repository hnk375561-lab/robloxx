-- Sonidos con archivos que ya vienen dentro de Roblox (no hacen falta IDs ni permisos).
-- Si alguno no existe en tu version de Roblox, simplemente no suena y no rompe nada.
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local Sonidos = {}

local EVENTOS = {
	golpe = {
		archivos = { "rbxasset://sounds/swordslash.wav", "rbxasset://sounds/unsheath.wav" },
		volumen = 0.3,
		tono = { 0.8, 1.0 },
		espera = 0.1,
	},
	impacto = {
		archivos = {
			"rbxasset://sounds/collide.wav",
			"rbxasset://sounds/bass.wav",
			"rbxasset://sounds/snap.mp3",
		},
		volumen = 0.5,
		tono = { 0.6, 0.85 },
		espera = 0.08,
	},
	cristal = {
		archivos = {
			"rbxasset://sounds/electronicpingshort.wav",
			"rbxasset://sounds/clickfast.wav",
		},
		volumen = 0.5,
		tono = { 1.3, 1.8 },
		espera = 0.1,
	},
	recoger = {
		archivos = {
			"rbxasset://sounds/clickfast.wav",
			"rbxasset://sounds/button.wav",
			"rbxasset://sounds/snap.mp3",
		},
		volumen = 0.25,
		tono = { 1.2, 1.7 },
		espera = 0.06,
	},
	moneda = {
		archivos = { "rbxasset://sounds/button.wav", "rbxasset://sounds/clickfast.wav" },
		volumen = 0.35,
		tono = { 1.4, 1.6 },
		espera = 0.1,
	},
	mejora = {
		archivos = { "rbxasset://sounds/victory.wav", "rbxasset://sounds/electronicpingshort.wav" },
		volumen = 0.5,
		tono = { 1, 1 },
		espera = 0.5,
	},
}

local azar = Random.new()
local elegidos = {}
local ultimo = {}

-- Prueba cada archivo candidato y se queda con el primero que existe
local function preparar(nombre, datos)
	for _, ruta in datos.archivos do
		local sonido = Instance.new("Sound")
		sonido.SoundId = ruta
		sonido.Volume = datos.volumen
		sonido.Parent = SoundService
		pcall(function()
			ContentProvider:PreloadAsync({ sonido })
		end)
		if sonido.TimeLength > 0 then
			elegidos[nombre] = sonido
			return
		end
		sonido:Destroy()
	end
end

for nombre, datos in EVENTOS do
	task.spawn(preparar, nombre, datos)
end

local function reproducir(nombre)
	local base = elegidos[nombre]
	if not base then
		return
	end
	local datos = EVENTOS[nombre]
	local ahora = os.clock()
	if ahora - (ultimo[nombre] or 0) < datos.espera then
		return
	end
	ultimo[nombre] = ahora

	local copia = base:Clone()
	copia.PlaybackSpeed = azar:NextNumber(datos.tono[1], datos.tono[2])
	copia.Parent = SoundService
	copia:Play()
	Debris:AddItem(copia, copia.TimeLength / copia.PlaybackSpeed + 0.5)
end

function Sonidos.golpe()
	reproducir("golpe")
end

function Sonidos.impacto()
	reproducir("impacto")
end

function Sonidos.cristal()
	reproducir("cristal")
end

function Sonidos.recoger()
	reproducir("recoger")
end

function Sonidos.moneda()
	reproducir("moneda")
end

function Sonidos.mejora()
	reproducir("mejora")
end

return Sonidos
