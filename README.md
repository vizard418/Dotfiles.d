# System and Application Configuration
Repositorio con archivos de configuracion para distintas aplicaciones y componentes del sistema.
El objetivo es mantener un entorno de trabajo reproducible y centralizado mediante configuraciones versionadas.

Las configuraciones incluidas cubren distintos aspectos del sistema, como gestores de ventanas, barras de estado, launchers, terminales y configuraciones de aplicaciones.

El entorno de escritorio o gestor de ventanas puede variar segun el sistema donde se utilicen estos archivos.
Cada directorio contiene archivos de configuracion asociados a una aplicacion o componente especifico del sistema.


## Objetivo
Este repositorio sirve para:

* Versionar configuraciones del sistema
* Facilitar la reproduccion del entorno de trabajo
* Mantener una organizacion clara de los archivos de configuracion
* Compartir o migrar configuraciones entre distintas maquinas


## Instalacion y Setup
Antes de aplicar los dotfiles, es recomendable seguir los pasos de configuracion inicial del sistema operativo. Puedes encontrar las guias detalladas en el directorio `system/`:

* [Guia de post-instalacion para Debian 13](./system/post-install_debian13.md)


## Uso
Los archivos pueden copiarse o enlazarse a sus ubicaciones correspondientes dentro del sistema, normalmente bajo: `~/.config`
Dependiendo de la aplicacion o componente.

Por ejemplo:

```bash
cp nvim/init.lua ~/.config/nvim/init.lua
```

Tambien es posible utilizar herramientas de gestion de dotfiles como `stow`, `chezmoi` o **enlaces simbolicos** (recomendado).


## Notas
* Algunas configuraciones pueden depender de herramientas externas o scripts auxiliares.
* Los archivos pueden evolucionar con el tiempo segun cambie el entorno de trabajo o las aplicaciones utilizadas.


## Licencia
Uso libre para adaptacion personal.

