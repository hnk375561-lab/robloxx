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

	-- Armas: cada una multiplica el dano. precio = monedas para comprarla (en orden).
	ARMAS = {
		{ nombre = "Manos", precio = 0, dano = 1 },
		{ nombre = "Palo", precio = 150, dano = 1.5 },
		{ nombre = "Hacha de piedra", precio = 800, dano = 2.2 },
		{ nombre = "Pico de hierro", precio = 3500, dano = 3.5 },
		{ nombre = "Martillo de forja", precio = 12000, dano = 5.5 },
		{ nombre = "Maza de cristal", precio = 40000, dano = 9 },
	},

	-- Misiones infinitas: la mision N pide MISION_META * N cubitos y paga MISION_PREMIO * N monedas
	MISION_META = 40,
	MISION_PREMIO = 150,

	-- Renacer (prestigio): reinicia todo pero da un multiplicador de monedas para siempre
	FUERZA_PARA_RENACER = 10,
	BONUS_POR_RENACER = 0.5, -- cada renacer suma +50% de monedas

	-- Recompensa diaria
	HORAS_RECOMPENSA = 20,
	RECOMPENSA_BASE = 100, -- monedas del dia 1; cada dia de racha suma otro tanto (maximo 7)
	RACHA_MAXIMA = 7,

	-- Monetizacion. Pone aca los IDs que te da Roblox (Creator Hub > tu juego > Monetizacion).
	-- Mientras valgan 0, ese producto no se muestra y el juego anda igual.
	PASE_X2_MONEDAS = 0, -- Game Pass: monedas x2 para siempre
	PASE_IMAN_GRANDE = 0, -- Game Pass: el iman junta desde el doble de lejos
	PASE_DANO_X2 = 0, -- Game Pass: el dano de tus golpes x2 para siempre
	PRODUCTO_BOOST_30MIN = 0, -- Developer Product: monedas x2 durante 30 minutos
	PRODUCTO_PACK_MONEDAS = 0, -- Developer Product: pack de monedas
	MINUTOS_BOOST = 30,
	MONEDAS_PACK = 2000,
}
