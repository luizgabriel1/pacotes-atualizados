#!/bin/bash
echo "Atualizando chaves do pacman"
sudo pacman-key --init
sudo pacman-key --populate archlinux
echo "Feito."

echo "Instalando LDAP"
cd LDAP/
sudo pacman -U *.tar.xz --needed --noconfirm
cd ..
echo "Feito."

echo "Instalando LightDM"
cd lightdm/
sudo pacman -U *.tar.xz --needed --noconfirm
cd ..
echo "LightDM Instalado."

echo "Instalando PHP e PHP-SSH"
cd php-ssh/
sudo pacman -U *.tar.xz --needed --noconfirm
cd ..
echo "Feito."

echo "Instalando Restante do Ambiente PHP"
cd ambiente-php/
sudo pacman -U *.tar.xz --needed --noconfirm
cd ..
echo "Ambiente PHP instalado e configurado."

echo "Configurando a hora"
sh hora.sh
echo "Feito."

echo "Instalando Sublime"
cd sublime/
sudo pacman -U *.tar.xz --needed --noconfirm
cd ..
echo "Sublime-text instalado."

echo "Instalando o Sanity"
cd sanity/
sudo pacman -U *.tar.xz --needed --noconfirm
cd ..
echo "Feito."

echo "Instalando e configurando o Login Unico"
cd login-unico-dcomp/
sudo pacman -U *.tar.xz --needed --noconfirm
cd ..
echo "Feito."

echo "Configurando o layout do teclado"
cd layout-teclado/
sh scriptUsuarioLocalETeclado.sh
cd ..
echo "Feito."

echo "Instalando programas principais do Repo Oficial"
cd principais/
sh principal.ssp.sh
cd ..
echo "Feito."

echo "Configurando o repositorio do AdminDCOMP ao Pacman"
cd dcomp-cfg/
sudo pacman -U *.tar.xz --needed --noconfirm
cd ..
echo "Repositorio configurado."

#sudo pacman -Syy --needed --noconfirm
sudo pacman -S openldap ldap-client-config nss-pam-ldapd sanity --needed --noconfirm

echo "Programas principais instalados."
