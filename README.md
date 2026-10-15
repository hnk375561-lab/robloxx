# Robloxx

Juego de Roblox: estamos encerrados en un bosque animado, dentro de un lugar de 4x4. Hay que romper paredes para avanzar. Las paredes se desmoronan y sueltan items, los items se cambian por monedas, y las monedas por fuerza, poder y armas.

Todo el juego vive como archivos de codigo (Luau) en este repositorio. Roblox Studio se usa solo como visor, sincronizado con Rojo.

## Estructura

- `src/server/` : scripts del servidor (ServerScriptService/Server)
- `src/client/` : scripts del cliente (StarterPlayerScripts/Client)
- `src/shared/` : modulos compartidos (ReplicatedStorage/Shared)
- `default.project.json` : mapa que le dice a Rojo donde va cada carpeta
- `rokit.toml` : herramientas del proyecto (Rojo, StyLua, Selene)

## Como trabajar

1. Abrir PowerShell, ir a la carpeta del proyecto y ejecutar `rojo serve` (dejarlo abierto).
2. Abrir Roblox Studio y, en Plugins > Rojo, apretar Connect.
3. Los cambios en los archivos aparecen solos en Studio.
4. Para guardar: `git add .`, `git commit -m "mensaje"`, `git push`.

## Herramientas

- Rojo: sincroniza archivos con Studio
- StyLua: formatea el codigo (`stylua src`)
- Selene: revisa errores (`selene src`)