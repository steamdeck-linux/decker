#! /bin/bash

# Decker, (c) Moxvallix 2022
# This program is licensed under the GNU GPL v3
# The full license can be viewed at: https://www.gnu.org/licenses/gpl-3.0.html

PKGLIST=~/.local/share/decker/packages.csv
GITPATH=~/.cache/decker/git
PKGPATH=~/.cache/decker/pkg
DBPATH=~/.local/share/decker/db
PACDBPATH=/var/lib/pacman/local
PACCACHEPATH=/var/cache/pacman/pkg
YAYCACHEPATH=~/.cache/yay

function init () {
  sudo touch /dev/null
  if [ $? != 0 ]
  then
    echo "You will need to configure your password:"
    passwd
  fi
  echo "Now readonly will be disabled:"
  sudo steamos-readonly disable
  echo "Populating the package keys"
  sudo pacman-key --init
  sudo pacman-key --populate archlinux
}

function setup () {
  mkdir -p $GITPATH
  mkdir -p $DBPATH
  mkdir -p $PKGPATH
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

function cache_package () {
  get_package_info $1
  PKGFILE=$PACCACHEPATH/$(ls $PACCACHEPATH | grep $PKG-$PKGVER | grep -v .sig)
  if [ $? != 0 ]
  then
    PKGFILE=$YAYCACHEPATH/$(ls $YAYCACHEPATH/$PKG | grep $PKG-$PKGVER | grep -v .tar.gz)
  fi
  sudo cp $PKGFILE $PKGPATH
}

function aur_setup () {
  sudo pacman -S git base-devel
  cd $GITPATH
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg
  PKG=$(ls | grep pkg.tar.zst)
  sudo pacman -U $PKG
  register_package "yay"
  register_package "git"
  register_package "base-devel"
}

function restore_package () {
  get_package_info $1
  sudo cp -r $DBPATH/$PKG-$PKGVER $PACDBPATH/
}

function restore_all_packages () {
  cat $PKGLIST | while read LINE
  do
    PKG=$(echo $LINE | awk -F "," '{ print $1}')
    restore_package $PKG
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

function remove_package () {
  PKG=$1
  yay -R $PKG
  if [ $? == 0 ]
  then
    unregister_package $PKG
  fi
}

if [[ $1 == "init" ]]
then
  echo "This command should only need to be run once."
  setup
  init
  aur_setup
elif [[ $1 == "restore" ]]
then
  init
  restore_all_packages
  aur_setup
elif [[ $1 == "install" ]]
then
  install_package $2
elif [[ $1 == "remove" ]]
then
  remove_package $2
else
  printf "Decker, Steam Deck Package Helper Script by Moxvallix\nhelp -- Display this message\ninit -- Setup your SteamDeck for Decker\nrestore -- Restore installed packages to Pacman\ninstall <package> -- Install a program and register it to Decker\nremove <package> -- Remove a program, and remove it from Decker\n"
fi
