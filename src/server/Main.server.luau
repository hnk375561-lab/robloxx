-- Punto de entrada del servidor.
local Bosque = require(script.Parent.Bosque)
local Jugadores = require(script.Parent.Jugadores)

Bosque.generar()
Jugadores.iniciar()
print("Bosque generado")
