# Decker
## A Package Restore Helper for the Steam Deck
Decker is an upcoming "Package Manager" (wrapper around [Paru](https://github.com/morganamilo/paru)), that aims to restore user installed packages to the system, after a system upgrade.

Decker will be distributed as an AppImage, allowing it to run easily, without installing any packages.

Decker will save package files downloaded to the cache, as well as pacman database entries, to it's own folders in the home directory (~/.local/share/decker and ~/.cache/decker), as well it will also save any dependencies of an installed package that are not already installed on the device. Decker, when the restore command is run, then restores first the database entries of the packages, then installs them once more, from the cached package file.

## Decker Early Testing Bash Script
### !!This program has had little testing. Use only if you know what you are doing!!

## Usage:
Run `./decker.sh init` to set up your SteamDeck with Decker.
To install a program, run `./decker.sh install <program>`.
To restore package information to the Pacman database after a system update, run `./decker restore`.

## Commands
help -- Display this message  
init -- Setup your SteamDeck for Decker  
restore -- Restore installed packages to Pacman  
install <package\> -- Install a program and register it to Decker  
remove <package\> -- Remove a program, and remove it from Decker  
update -- Updates packages installed with Decker  
patch <file\> -- Register a file to be restorable. Good for config files  
