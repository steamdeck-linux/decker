# Decker
## A Package Restore Helper for the Steam Deck
Decker is a "Package Manager" (wrapper around [Paru](https://github.com/morganamilo/paru)), that aims to restore user installed packages to the system, after a system upgrade.

Decker is distributed as an AppImage, allowing it to run easily, without installing any packages.

Decker saves package files downloaded to the cache, as well as pacman database entries, to it's own folders in the home directory (~/.local/share/decker and ~/.cache/decker), as well it also saves any dependencies of an installed package that are not already installed on the device. Decker, when the restore command is run, then restores first the database entries of the packages, then installs them once more, from the cached package file.

## Getting Decker
Download the AppImage from the [Github Releases](https://github.com/steamdeck-linux/decker/releases), and mark it as executable.
```
chmod a+x Decker*.AppImage
```

## Commands
```
  decker.rb help [COMMAND]     # Describe available commands or one specific command
  decker.rb install [PACKAGE]  # installs PACKAGE and registers it to Decker
  decker.rb patch [FILEPATH]   # registers file at FILEPATH to Decker, so it can be restored
  decker.rb remove [PACKAGE]   # removes PACKAGE and it's unique dependencies, from the system and from Decker
  decker.rb restore            # restores all packages and patches to the system
  decker.rb update             # updates packages registered to Decker
```
