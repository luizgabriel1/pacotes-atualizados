#!/bin/bash

dir=$(pwd)

sudo pacman -S openssh php git --noconfirm --needed

echo "[1/3] Obtendo PKGBUILD dos repositorios da AUR"
git clone https://aur.archlinux.org/php-ssh.git
echo "Feito."

echo "[2/3] Entrando montando o Pacote"
cd php-ssh/
makepkg
echo "Feito."

echo "[3/3] Copiando Pacote e removendo arquivos desnecessários"
cp php-ssh-*.tar.xz $dir/
cd ..
sudo rm -R php-ssh/
echo "Feito"