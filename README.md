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

Los archivos pueden copiarse o enlazarse a sus ubicaciones correspondientes dentro del sistema, normalmente bajo `~/.config` o en el directorio home segun corresponda.


### Neovim

La configuracion de Neovim esta modularizada en archivos individuales dentro de `nvim/lua/` y no utiliza gestores de plugins externos.

1. Asegurate de respaldar tu configuracion anterior si existe.

2. Copia o enlaza el contenido del directorio `nvim/` a tu ruta de configuracion de Neovim:

```bash
mkdir -p ~/.config/nvim
cp -r nvim/* ~/.config/nvim/
```

3. Asegurate de tener disponible `sqlcmd` en el `PATH` del sistema.

4. Configura las variables de entorno necesarias para conectarte a SQL Server y define el alias utilizado por la configuracion de Neovim:

```bash
export PATH="/opt/sqlcmd:$PATH"

export MSSQL_USER="[SQLSERVER_USER_LOGIN]"
export MSSQL_PASSWORD="[SQLSERVER_USER_PASSWD]"

alias SQLCMD_CONNECT="sqlcmd -S tcp:127.0.0.1,1433 -U $MSSQL_USER -P $MSSQL_PASSWORD -v SQLCMDFORMAT=ascii -W"
```

El alias `SQLCMD_CONNECT` es utilizado tanto para ejecutar consultas desde Neovim como para alimentar el explorador MSSQL.

Se puede colocar esta configuracion en el archivo de inicio del shell, por ejemplo:

```text
~/.bashrc
~/.bash_profile
~/.zshrc
```

Despues de modificarlo, recarga la configuracion del shell o abre una nueva terminal.


### Ejecucion de consultas T-SQL

La configuracion reconoce archivos con extension `.sql` y `.tsql`.

Para ejecutar una consulta:

1. Abre un archivo `.sql` o `.tsql`.
2. Selecciona el codigo en modo visual usando `Shift+V`.
3. Ejecuta la consulta utilizando cualquiera de estas opciones:

```vim
:SQLCMD
```

o:

```text
Alt+Enter
```

`Alt+Enter` ejecuta el mismo comando `:SQLCMD` sobre el bloque seleccionado.

El resultado se mostrara en una terminal dividida dentro de Neovim.

Dentro del panel de resultados:

* `j` / `k` permiten navegar entre las lineas.
* Las flechas permiten navegar entre las lineas.
* `q` cierra el panel y vuelve al editor.
* `Esc` permite salir del modo de insercion de la terminal.


## Explorador MSSQL

Neovim incluye un explorador de SQL Server implementado de forma nativa en `lua/explorer_mssql.lua`.

No requiere plugins externos ni gestores de plugins.

El explorador permite navegar por:

```text
SQL Server
└─ Databases
   ├─ database
   │  ├─ Tables
   │  │  └─ schema.table
   │  │     ├─ column : type
   │  │     └─ column : type
   │  ├─ Views
   │  ├─ Stored Procedures
   │  └─ Functions
```

### Requisitos

El explorador necesita:

* Neovim
* SQL Server accesible desde el equipo
* `sqlcmd` instalado
* `sqlcmd` disponible en el `PATH`
* Variables de entorno `MSSQL_USER` y `MSSQL_PASSWORD`
* Alias `SQLCMD_CONNECT`
* Permisos suficientes en SQL Server para consultar metadatos

El explorador obtiene la informacion directamente desde las vistas de sistema de SQL Server, como:

```text
sys.databases
sys.tables
sys.views
sys.procedures
sys.objects
sys.columns
sys.schemas
sys.types
```


### Abrir el explorador

Desde Neovim ejecuta:

```vim
:ExploreMSSQL
```

El explorador se abrira como un panel vertical en el lado izquierdo de la ventana.

El editor permanece disponible a la derecha.


### Navegacion

Dentro del explorador:

| Tecla | Accion |
|---|---|
| `Enter` | Expandir o contraer el nodo seleccionado |
| `o` | Abrir el objeto seleccionado en el editor |
| `r` | Actualizar el contenido del explorador |
| `q` | Ocultar el panel |
| `Shift+>` | Aumentar el ancho del panel |
| `Shift+<` | Reducir el ancho del panel |
| `Ctrl+l` | Ir del explorador al editor |
| `Ctrl+h` | Ir del editor al explorador |
| `g?` | Mostrar ayuda |

El panel comienza con un ancho de 45 columnas.

El ancho puede modificarse utilizando `Shift+>` y `Shift+<`.


### Abrir tablas

Al seleccionar una tabla y presionar:

```text
o
```

Neovim abre un buffer SQL en el area del editor con una consulta similar a:

```sql
USE [database];
SELECT TOP 100 *
FROM [schema].[table];
```

Esto permite inspeccionar rapidamente los datos de una tabla sin modificar el buffer del explorador.


### Abrir procedimientos, vistas y funciones

Al seleccionar un procedimiento, vista o funcion y presionar:

```text
o
```

Neovim abre un buffer SQL con una consulta utilizando `sp_helptext` para consultar la definicion del objeto.

El resultado puede ejecutarse posteriormente utilizando el flujo normal de `SQLCMD`.


### Expandir tablas

Las tablas pueden expandirse utilizando:

```text
Enter
```

Al expandir una tabla se muestran sus columnas, incluyendo:

* Nombre
* Tipo de dato
* Nullable

Por ejemplo:

```text
├─▾ dbo.Users
│  ├─· Id : int
│  ├─· Name : nvarchar
│  └─· Email : varchar ?
```


### Actualizar el explorador

Para volver a consultar la informacion de SQL Server:

```text
r
```

Esto actualiza la lista de bases de datos y mantiene el explorador disponible.


### Ocultar y volver a abrir el panel

Presionando:

```text
q
```

el panel se oculta sin eliminar su buffer ni su estado interno.

Para volver a abrirlo:

```vim
:ExploreMSSQL
```

El explorador volvera a aparecer en el lado izquierdo.


### Navegacion entre explorador y editor

Desde el explorador:

```text
Ctrl+l
```

mueve el foco al editor.

Desde el editor:

```text
Ctrl+h
```

mueve el foco al explorador cuando el panel esta abierto.


## Windows Terminal (wt)

El repositorio incluye un esquema de colores personalizado con temática Gruvbox para Windows Terminal (`wt/windows_terminal-gruvbox.json`).

1. Localiza el archivo de configuracion de Windows Terminal en tu maquina Windows (usualmente ubicado en `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`).

2. Abre el archivo de configuracion con un editor de texto.

3. Copia el contenido de `wt/windows_terminal-gruvbox.json` e ingresalo dentro del arreglo `schemes` en tu `settings.json` de Windows Terminal:

```json
{
  "schemes": [
    {
      "name": "Gruvbox",
      ...
    }
  ]
}
```

4. Asigna el esquema como predeterminado en el perfil de Windows Terminal añadiendo:

```json
"colorScheme": "Gruvbox"
```

dentro de la seccion del perfil preferido.


## Licencia

Uso libre para adaptacion personal.