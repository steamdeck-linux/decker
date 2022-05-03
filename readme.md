# Decker
## A Package Restore Helper for the Steam Deck
### !!This program has had little testing. Use only if you know what you are doing!!

## Usage:
Run `./decker.sh init` to set up your SteamDeck with Decker.
To install a program, run `./decker.sh install <program>`.
To restore package information to the Pacman database after a system update, run `./decker restore`.

## Commands
help -- Display this message  
init -- Setup your SteamDeck for Decker  
restore -- Restore installed packages to Pacman  
install <package> -- Install a program and register it to Decker  
remove <package> -- Remove a program, and remove it from Decker  
