-- Punto de entrada del servidor.
local Ambiente = require(script.Parent.Ambiente)
local Bosque = require(script.Parent.Bosque)
local Jugadores = require(script.Parent.Jugadores)
local Tienda = require(script.Parent.Tienda)

Ambiente.crear()
Bosque.generar()
Tienda.crear()
Jugadores.iniciar()
print("Bosque generado")
