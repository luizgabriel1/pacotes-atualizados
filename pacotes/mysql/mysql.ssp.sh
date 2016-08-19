#!/bin/bash
echo "Instalando MYSQL"
sudo pacman -S mariadb --noconfirm --needed

echo "Iniciando MySQL"
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl start mysqld.service
sudo systemctl enable mysqld.service


echo "Para setar a senha root, entre com sudo mysql_secure_installation"
echo "Finalizado!"
#sudo mysql_secure_installation