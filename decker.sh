#! /bin/bash

# Decker, (c) Moxvallix 2022
# This program is licensed under the GNU GPL v3
# The full license can be viewed at: https://www.gnu.org/licenses/gpl-3.0.html
# This is the legacy bash script, initially used for testing Decker's basic concepts
# Please use the Ruby based AppImage instead, as this script is far from stable.

PKGLIST="$HOME.local/share/decker/packages.csv"
GITPATH="$HOME.cache/decker/git"
PKGPATH="$HOME.cache/decker/pkg"
DBPATH="$HOME.local/share/decker/db"
PACDBPATH=/var/lib/pacman/local
PATCHPATH="$HOME.local/share/decker/patch"
PACCACHEPATH=/var/cache/pacman/pkg
YAYCACHEPATH="$HOME.cache/yay"

function init () {
  sudo touch /dev/null
  if [ $? != 0 ]
  then
    echo "You will need to configure your password:"
    passwd
  fi
  echo "Now readonly will be disabled"
  sudo steamos-readonly disable
  echo "Populating the package keys"
  sudo pacman-key --init
  sudo pacman-key --populate archlinux
}

function setup () {
  mkdir -p $GITPATH
  mkdir -p $DBPATH
  mkdir -p $PKGPATH
  mkdir -p $PATCHPATH
  touch $PKGLIST
}

function register_package () {
  PKG=$1
  PKGVER=$(pacman -Q $1 | awk -F " " '{ print $2}')
  cp -r $PACDBPATH/$PKG-$PKGVER/ $DBPATH
  cat $PKGLIST | grep $PKG, > /dev/null
  if [ $? == 0 ]
  then
    LINE=$(cat $PKGLIST | grep -n $PKG, | cut -d : -f 1)
    NEWLINE=$PKG,$PKGVER
    sed -i "${LINE}s/.*/${NEWLINE}/" $PKGLIST
  else
    echo "$PKG,$PKGVER" >> $PKGLIST
  fi
  cache_package $PKG
}

function get_package_info () {
  PKG=$1
  PKGVER=$(cat $PKGLIST | grep $PKG, | awk -F "," '{ print $2}')
}

function unregister_package () {
  get_package_info $1
  rm -f $DBPATH/$PKG-$PKGVER
  LINE=$PKG,$PKGVER
  sed -i /$LINE/d $PKGLIST
}

function register_patch () {
  FILEPATH=$(readlink -f "$1")
  FILE=$(basename $FILEPATH)
  PATCH=$PATCHPATH/$(date +"%Y-%m-%d-%H%M%S")-$FILE.patch
  EXISTINGPATCH=$(grep -r $FILEPATH $PATCHPATH | awk -F ":" '{ print $1 }')
  if [ $? == 0 ]
  then
    if [[ $(date -r $FILEPATH) > $(date -r $EXISTINGPATCH) ]]
    then
      rm $EXISTINGPATCH
      echo $FILEPATH > $PATCH
      echo "---" >> $PATCH
      cat $FILEPATH >> $PATCH
    else
      echo "Registered patch newer than \"$FILE\". If this is a mistake, delete the file at: \"$EXISTINGPATCH\""
    fi
  else
    echo $FILEPATH > $PATCH
    echo "---" >> $PATCH
    cat $FILEPATH >> $PATCH
  fi
}

function cache_package () {
  get_package_info $1
  PKGFILE=$(ls | grep $PKG-$PKGVER)
  if [ $? != 0 ]
  then
    PKGFILE=$PACCACHEPATH/$(ls $PACCACHEPATH | grep $PKG-$PKGVER | grep -v .sig)
  fi
  if [ $? != 0 ]
  then
    PKGFILE=$YAYCACHEPATH/$PKG/$(ls $YAYCACHEPATH/$PKG | grep $PKG-$PKGVER | grep -v .tar.gz)
  fi
  sudo cp $PKGFILE $PKGPATH
}

function base_utils_setup () {
  sudo pacman -S git base-devel
  register_package "git"
  register_base_utils
}

function aur_setup () {
  cd $GITPATH
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg
  PKG=$(ls | grep pkg.tar.zst)
  sudo pacman -U $PKG
  register_package "yay-bin"
}

function restore_package () {
  get_package_info $1
  sudo cp -r $DBPATH/$PKG-$PKGVER $PACDBPATH/
  PKGFILE=$(ls $PKGPATH | grep $PKG-$PKGVER)
  sudo pacman -U $PKGPATH/$PKGFILE --noconfirm
}

function restore_patch () {
  PATCH=$1
  PATCHPATH=$(head -n 1 $PATCH)
  sudo tail -n +3 $PATCH > $PATCHPATH
}

function restore_all_packages () {
  cat $PKGLIST | while read LINE
  do
    PKG=$(echo $LINE | awk -F "," '{ print $1}')
    restore_package $PKG
  done
}

function restore_all_patches () {
  for PATCH in $PATCHPATH/*.patch
  do
    restore_patch $(readlink -f $PATCH)
  done
}

function install_package () {
  PKG=$1
  yay -S $PKG
  if [ $? == 0 ]
  then
    register_package $PKG
  fi
}

function check_registered_package () {
  cat $PKGLIST | grep $PKG, > /dev/null
  return $?
}

function update_package () {
  get_package_info $1
  OLDVER=$PKGVER
  install_package $PKG
  OLDPKGFILE=$(ls $PKGPATH | grep $PKG-$PKGVER)
  sudo rm $PKGPATH/$OLDPKGFILE
}

function update_all_packages () {
  cat $PKGLIST | while read LINE
  do
    PKG=$(echo $LINE | awk -F "," '{ print $1}')
    update_package $PKG
  done
}

function remove_package () {
  PKG=$1
  yay -Rs $PKG
  if [ $? == 0 ]
  then
    unregister_package $PKG
  fi
}

function register_base_utils () {
  register_package "grep"
  register_package "findutils"
  register_package "git"
  register_package "gawk"
  register_package "m4"
  register_package "autoconf"
  register_package "automake"
  register_package "binutils"
  register_package "gettext"
  register_package "bison"
  register_package "sed"
  register_package "file"
  register_package "fakeroot"
  register_package "flex"
  register_package "gcc"
  register_package "groff"
  register_package "gzip"
  register_package "libtool"
  register_package "texinfo"
  register_package "make"
  register_package "patch"
  register_package "pkgconf"
  register_package "which"
}

if [[ $1 == "init" ]]
then
  echo "This command should only need to be run once."
  setup
  init
  base_utils_setup
  aur_setup
elif [[ $1 == "restore" ]]
then
  init
  restore_all_packages
  restore_all_patches
elif [[ $1 == "install" ]]
then
  setup
  install_package $2
elif [[ $1 == "remove" ]]
then
  setup
  check_registered_package $2
  if [ $? == 0 ]
  then
    remove_package $2
  else
    echo "$2 Does not seem to be registered in Decker."
  fi
elif [[ $1 == "update" ]]
then
  setup
  update_all_packages
elif [[ $1 == "patch" ]]
then
  register_patch $2
else
  printf "Decker, Steam Deck Package Helper Script by Moxvallix\nhelp -- Display this message\ninit -- Setup your SteamDeck for Decker\nrestore -- Restore installed packages and patches\ninstall <package> -- Install a program and register it to Decker\nremove <package> -- Remove a program, and remove it from Decker\nupdate -- Updates packages installed with Decker\npatch <file> -- Register a file to be restorable. Good for config files\n"
fi
