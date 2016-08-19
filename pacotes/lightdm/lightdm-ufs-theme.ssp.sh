#!/bin/bash
echo "[1/6] Instalando lightdm, dependencias necessarias e habilitando lightdm.service"
sudo pacman -S lightdm accountsservice gnome-common gobject-introspection intltool --noconfirm --needed
sudo systemctl enable lightdm.service
echo "Feito."

echo "[2/6] Extraindo Arquivos Necessarios"
tar -xvf lightdm-theme.tar
echo "Feito."

echo "[3/6]Instalando another-gtk-greeter"
cd lightdm-another-gtk-greeter/
makepkg
sudo pacman -U lightdm-another-gtk-greeter-*.pkg.tar.xz --noconfirm
cd ..
echo "Feito."

echo "[4/6] Instalando lightdm-another-gtk-greeter-themes"
cd lightdm-another-gtk-greeter-themes/
makepkg
sudo pacman -U lightdm-another-gtk-greeter-themes-*.pkg.tar.xz --noconfirm
cd ..
echo "Feito."

echo "[5/6] Instalando Tema do DCOMP no lightdm"
cd tema-ufs-dcomp/
makepkg
sudo pacman -U temas-ufs-dcomp-*.pkg.tar.xz --noconfirm
sudo sh css.sh
sudo sh lightdm-conf.sh
sudo sh lightdm-another-gtk-greeter-conf.sh
sudo cp nuvem_2.jpg /usr/share/backgrounds/nuvem_2.jpg
cd ..
echo "Feito."

echo "[6/6] Removendo arquivos arquivos desnecessarios..."
sudo rm -R lightdm-another-gtk-greeter/
sudo rm -R lightdm-another-gtk-greeter-themes/
sudo rm -R tema-ufs-dcomp/
echo "Feito."

echo "Configuracao Finalizada!"