-- Medidas y precios del juego. Si queres cambiar valores, se hace aca.
return {
	TAMANO_HABITACION = 40,
	GRILLA = 4,
	ALTO_PARED = 14,
	GROSOR_PARED = 4,
	ANCHO_PUERTA = 10,

	-- Voxeles (cubitos de las paredes)
	VOXEL = 2, -- lado de cada cubito en studs
	VIDA_BASE = 2, -- vida de un cubito = VIDA_BASE + profundidad de la pared

	-- Combate
	ALCANCE = 16, -- hasta donde llega el golpe (studs)
	ENFRIAMIENTO = 0.22, -- segundos entre golpes
	RADIO_AREA = 1.2, -- radio del golpe; crece con la fuerza
	RADIO_IMAN = 12, -- a que distancia los fragmentos vuelan hacia vos
	MAX_FRAGMENTOS = 300,
	VIDA_FRAGMENTO = 90, -- segundos antes de que un fragmento suelto desaparezca

	-- Economia
	PRECIO_ITEM = 1, -- monedas que paga el Trueque por cada item
	COSTO_BASE_FUERZA = 25, -- la mejora cuesta: base * fuerza * fuerza
}
