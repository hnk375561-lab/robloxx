-- Sonidos con archivos que ya vienen dentro de Roblox (no hacen falta IDs ni permisos).
-- Todos pasan por un grupo con volumen general, ecualizador y limitador de picos.
-- Tecla M: silenciar / activar.
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local Sonidos = {}

-- Grupo general: aca se controla que tan fuerte suena todo
local grupo = Instance.new("SoundGroup")
grupo.Name = "Efectos"
grupo.Volume = Config.VOLUMEN_GENERAL
grupo.Parent = SoundService

-- Ecualizador: saca lo agudo y lo mas "filoso" de los sonidos
local ecualizador = Instance.new("EqualizerSoundEffect")
ecualizador.LowGain = 0
ecualizador.MidGain = -3
ecualizador.HighGain = -12
ecualizador.Parent = grupo

-- Limitador: los picos fuertes se aplastan para que nada suene a gritos
local limitador = Instance.new("CompressorSoundEffect")
limitador.Threshold = -26
limitador.Ratio = 10
limitador.Attack = 0.005
limitador.Release = 0.12
limitador.Parent = grupo

local EVENTOS = {
	golpe = {
		archivos = { "rbxasset://sounds/swordslash.wav", "rbxasset://sounds/unsheath.wav" },
		volumen = 0.12,
		tono = { 0.9, 1.1 },
		espera = 0.1,
	},
	impacto = {
		archivos = {
			"rbxasset://sounds/collide.wav",
			"rbxasset://sounds/snap.mp3",
		},
		volumen = 0.16,
		tono = { 0.7, 0.95 },
		espera = 0.12,
	},
	cristal = {
		archivos = {
			"rbxasset://sounds/electronicpingshort.wav",
			"rbxasset://sounds/clickfast.wav",
		},
		volumen = 0.2,
		tono = { 1.3, 1.8 },
		espera = 0.1,
	},
	recoger = {
		archivos = {
			"rbxasset://sounds/clickfast.wav",
			"rbxasset://sounds/button.wav",
			"rbxasset://sounds/snap.mp3",
		},
		volumen = 0.08,
		tono = { 1.2, 1.7 },
		espera = 0.08,
	},
	moneda = {
		archivos = { "rbxasset://sounds/button.wav", "rbxasset://sounds/clickfast.wav" },
		volumen = 0.14,
		tono = { 1.4, 1.6 },
		espera = 0.1,
	},
	mejora = {
		archivos = { "rbxasset://sounds/victory.wav", "rbxasset://sounds/electronicpingshort.wav" },
		volumen = 0.22,
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
		sonido.SoundGroup = grupo
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
	copia.SoundGroup = grupo
	copia.Parent = SoundService
	copia:Play()
	Debris:AddItem(copia, copia.TimeLength / copia.PlaybackSpeed + 0.5)
end

-- Tecla M: silenciar o volver a activar el sonido
local silenciado = false
UserInputService.InputBegan:Connect(function(entrada, procesado)
	if procesado then
		return
	end
	if entrada.KeyCode == Enum.KeyCode.M then
		silenciado = not silenciado
		grupo.Volume = if silenciado then 0 else Config.VOLUMEN_GENERAL
	end
end)

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
