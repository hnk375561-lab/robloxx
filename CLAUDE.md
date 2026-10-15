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
- [ ] Prototipo del juego: cuarto, paredes rompibles, items

## Decisiones tomadas
- Se usa Rojo + Rokit en lugar de trabajar dentro de Studio.
- Se descarta Wally por ahora para mantener todo simple.