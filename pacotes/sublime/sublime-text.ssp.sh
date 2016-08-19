#!/bin/bash

dir=$(pwd)

echo "[1/4] Pegando ultimo release do repositorio padrao do sublime-text"
git clone https://aur.archlinux.org/sublime-text-dev.git/
echo "Feito."

echo "[2/4] Compilando Pacote"
cd sublime-text-dev
makepkg
echo "Feito."

echo "[3/4] Instalando Pacote"
cp sublime-text-*.pkg.tar.xz $dir
sudo pacman -U sublime-text-*.pkg.tar.xz --noconfirm
echo "Feito"

echo "[4/4] Removendo arquivos restantes"
cd ..
#sudo rm -R sublime-text
echo "Feito."