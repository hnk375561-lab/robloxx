# CLAUDE.md - Contexto del proyecto para Claude

Este archivo es la memoria del proyecto. Claude debe leerlo al empezar cada sesion y actualizarlo cuando se tomen decisiones nuevas.

## Sobre la persona
- Habla espanol (Argentina). Responder SIEMPRE en espanol, simple, sin asumir conocimientos de programacion ni de Roblox.
- Es principiante. Dar pasos de a uno, con comandos exactos para copiar y pegar en PowerShell (Windows 11), y decir que deberia ver en pantalla despues de cada paso.
- No quiere trabajar dentro de Roblox Studio. Studio es solo un visor. Tocarlo lo minimo posible.
- Si falta informacion: hacer UNA pregunta por vez y recomendar un camino, no dar muchas opciones.
- Objetivo de fondo: no gastar dinero y tener ingreso pasivo. Ser honesto: los ingresos dependen de que jueguen jugadores reales; DevEx tiene requisitos (edad, verificacion, minimo de Robux) que hay que verificar en la pagina oficial de Roblox, incluyendo como funciona desde Argentina.

## Flujo de trabajo
- Claude escribe el codigo Luau y dice en que archivo va cada cosa. La persona solo copia/pega, hace commit y push.
- Claude no puede hacer push al repo por si mismo.
- Rojo sincroniza src/ con Studio (la persona deja `rojo serve` abierto y aprieta Connect en el plugin).

## Stack
- Repo: https://github.com/hnk375561-lab/robloxx (rama main)
- Rokit (gestor de herramientas): Rojo 7.7.1, StyLua 2.6.0, Selene 0.32.0
- Lenguaje: Luau. Extension de archivos: .luau
- Sin Wally por ahora (solo si hace falta una libreria de terceros).
- GitHub Actions para chequeos; publicacion con Open Cloud a futuro (la primera publicacion se hace desde Studio).

## Estructura y convenciones
- Archivo de proyecto de Rojo: `default.project.json` (ese nombre exacto).
- `src/server/` -> ServerScriptService.Server. Scripts que corren en el servidor se llaman `Nombre.server.luau`.
- `src/client/` -> StarterPlayer.StarterPlayerScripts.Client. Scripts de cliente: `Nombre.client.luau`.
- `src/shared/` -> ReplicatedStorage.Shared. Modulos: `Nombre.luau`.
- Todo el contenido (bosque, paredes, UI) se genera por codigo. No construir nada a mano en Studio.
- Estilo: StyLua (`stylua src`) y Selene (`selene src`) antes de cada commit.
- Nombres en espanol o ingles simples, comentarios en espanol.
- La logica importante (monedas, items, dano) va SIEMPRE en el servidor. El cliente solo muestra cosas.

## Diseno del juego
- Ambientacion: bosque animado, pocos detalles (troncos, hojas y suelo con bloques simples), pero que se entienda que es un bosque.
- Los jugadores estan encerrados en un espacio de 4x4 (medidas exactas a definir).
- Hay que romper paredes para avanzar. Las paredes se desmoronan y sueltan items.
- Los items se cambian por monedas. Las monedas se gastan en fuerza, poder, armas, etc.
- Monetizacion: a definir mas adelante (game passes, boosts), sin gastar plata propia.

## Estado actual
- [x] Git, Rokit, Rojo, StyLua y Selene instalados
- [x] Repo clonado y estructura inicial creada
- [x] Rojo conectado con Studio y probado (cubo verde de prueba en src/server/Main.server.luau)
- [x] Primer commit subido a GitHub
- [ ] GitHub Actions (chequeos)
- [ ] Primera publicacion del juego desde Studio y Open Cloud
- [x] Prototipo: bosque de 4x4 habitaciones, paredes rompibles, items
- [x] Trueque (items -> monedas) y Herreria (monedas -> fuerza), HUD de fuerza
- [x] Mejora visual: Ambiente.luau (luz, niebla), arboles, flores, rocas, luciernagas, polvo al golpear paredes, titulo de entrada
- [ ] Sonidos y musica (requieren IDs de assets de Roblox, a elegir)
- [ ] Guardado de progreso (DataStore)
- [ ] Armas, mas mejoras y monetizacion

## Decisiones tomadas
- Se usa Rojo + Rokit en lugar de trabajar dentro de Studio.
- Se descarta Wally por ahora para mantener todo simple.
## Sistema de paredes y combate (voxeles, primera persona)
- Camara en primera persona (Camara.client.luau), mira en el centro.
- Las puertas entre habitaciones se generan como grilla de cubitos (Paredes.luau). Bosque.luau llama a Paredes.prepararPared y esa funcion reemplaza la pieza por voxeles. Cada voxel tiene atributos Vida, VidaMax, ColorBase, Valor y el tag "Voxel".
- El cliente (Golpe.client.luau) apunta con raycast desde el centro de la pantalla y manda el voxel al servidor por el RemoteEvent "Golpear". El servidor (Combate.luau) valida tag, distancia y velocidad de golpes, y danya los voxeles dentro de un radio que crece con la Fuerza.
- Al romperse, el voxel pasa a Workspace.Fragmentos (con fisica). Fragmentos.luau los atrae hacia el jugador (iman automatico) y los convierte en Items. Maximo 300 fragmentos, desaparecen a los 90 s.
- Numeros de balance viven en src/shared/Config.luau.
- Pendiente: sonidos (necesitan IDs del Creator Store), grietas con texturas (necesitan IDs), manos con arte mejor, guardado de progreso.
## Decision sobre el arte (assets)
- Se intento cargar modelos del Creator Store con InsertService:LoadAsset y dio "User is not authorized to access Asset": la cuenta tiene que "obtener" el asset primero. Claude no puede ver la pagina del Creator Store (carga con JavaScript) ni inventar IDs.
- Por ahora TODO el arte es procedural (codigo): terreno de Roblox, arboles, hongos, rocas, puestos, brazos del viewmodel, HUD. No hay sonidos ni musica todavia (requieren IDs de audio que la cuenta pueda usar).
- Si mas adelante se consiguen IDs validos, se integran desde un modulo nuevo (por ejemplo src/server/Assets.luau).
- Para leer errores sin la ventana Output de Studio, se lee el registro en %LOCALAPPDATA%\Roblox\logs (ultimo archivo *Studio*.log).
- Mejora visual 2: terreno real (Terrain), bosque denso fuera de la arena, forja con fuego y Trueque con toldo, brazos con nudillos/manga, numeros de dano flotantes, HUD con panel.

## Mejora visual 3 (direccion elegida: estilizado limpio + brillo magico, liviano para celulares)
- Ambiente.luau reescrito: Sky, Clouds, GlobalWind, hora dorada con ciclo lento, color mas rico.
- Magia.luau (servidor): hongos y flores que brillan (Neon + algunas PointLight), cristales Neon en 6% de los voxeles (valen +1), rayos de luz (Beam) con polvo, hojas cayendo. CanQuery=false en las zonas invisibles de luciernagas para no tapar golpes.
- Pulido.client.luau: vineta con 4 bordes en degradado, enfoque automatico (DepthOfField), modo liviano en celulares (sin SunRays ni DoF).
- default.project.json: Lighting.Technology = Future. Si Rojo no lo aplica en vivo, ponerlo una vez a mano en Studio (Lighting > Technology).
- Sigue sin haber sonidos ni modelos del Creator Store (hay que elegir IDs de audio de creador Roblox y 'Obtener' los modelos con la cuenta).


## Mejora visual 4
- Suelo.luau (servidor): tierra y barro bajo cada arbol, parches de tierra/barro/musgo en cada habitacion (FillCylinder sobre la capa superior del terreno).
- Viento.client.luau: las copas (Hojas) y arbustos (Matas) se mecen con BulkMoveTo a 20 veces por segundo, solo en PC.
- Efectos.client.luau: chispas y flash al romper cristales Neon, destello dorado al recoger fragmentos, linterna suave pegada a la camara (solo PC).
