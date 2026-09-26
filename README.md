# System and Application Configuration

Repositorio con archivos de configuracion para distintas aplicaciones y componentes del sistema. El objetivo es mantener un entorno de trabajo reproducible y centralizado mediante configuraciones versionadas.
Las configuraciones incluidas cubren distintos aspectos del sistema, como gestores de ventanas, barras de estado, launchers, terminales y configuraciones de aplicaciones.
El entorno de escritorio o gestor de ventanas puede variar segun el sistema donde se utilicen estos archivos. Cada directorio contiene archivos de configuracion asociados a una aplicacion o componente especifico del sistema.


## Objetivo

Este repositorio sirve para:

* Versionar configuraciones del sistema
* Facilitar la reproduccion del entorno de trabajo
* Mantener una organizacion clara de los archivos de configuracion
* Compartir o migrar configuraciones entre distintas maquinas


## Instalacion y Setup

Los archivos pueden copiarse o enlazarse a sus ubicaciones correspondientes dentro del sistema, normalmente bajo ~/.config o en el directorio home segun corresponda.


### Neovim

La configuracion de Neovim esta modularizada en archivos individuales dentro de nvim/lua/ y no utiliza gestores de plugins externos.

1. Asegurate de respaldar tu configuracion anterior si existe.
2. Copia o enlaza el contenido del directorio nvim/ a tu ruta de configuracion de Neovim ejecutando en tu terminal:

   mkdir -p ~/.config/nvim
   cp -r nvim/* ~/.config/nvim/

3. Asegurate de tener definido tu alias de conexion en tu perfil de shell (por ejemplo, en ~/.bash_profile o ~/.bashrc):
```bash
export PATH="/opt/sqlcmd:$PATH"

export MSSQL_USER="[SQLSERVER_USER_LOGIN]"
export MSSQL_PASSWORD="[SQLSERVER_USER_PASSWD]"

alias sqlcmd_connect="sqlcmd -S tcp:127.0.0.1,1433 -U \$MSSQL_USER -P \$MSSQL_PASSWORD -v SQLCMDFORMAT=ascii -W"
```

4. Abre Neovim con un archivo .sql o .tsql, selecciona un bloque de codigo en modo visual (Shift + v), escribe :SQLCMD y presiona Enter para ejecutar consultas T-SQL directamente. Para cerrar el panel de resultados de la terminal, simplemente presiona q.

### Windows Terminal (wt)

El repositorio incluye un esquema de colores personalizado con temática Gruvbox para Windows Terminal (`wt/windows_terminal-gruvbox.json`).

1. Localiza el archivo de configuración de Windows Terminal en tu máquina Windows (usualmente ubicado en `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`).
2. Abre el archivo de configuración con un editor de texto.
3. Copia el contenido de `wt/windows_terminal-gruvbox.json` e ingrésalo dentro del arreglo `schemes` en tu `settings.json` de Windows Terminal:

   {
     "schemes": [
       {
         "name": "Gruvbox",
         ...
       }
     ]
   }

4. Asigna el esquema como predeterminado en tu perfil de Windows Terminal añadiendo `"colorScheme": "Gruvbox"` dentro de la sección de tu perfil preferido.


## Licencia

Uso libre para adaptacion personal.
