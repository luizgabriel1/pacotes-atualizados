#!/bin/bash

echo "SCRIPT INSTALACAO DE PACOTES-UFS"

# Configurando o servidor da data e a hora
echo "# Please consider joining the pool:
#
#     http://www.pool.ntp.org/join.html
#
# For additional information see:
# - https://wiki.archlinux.org/index.php/Network_Time_Protocol_daemon
# - http://support.ntp.org/bin/view/Support/GettingStarted
# - the ntp.conf man page

# Associate to Arch's NTP pool
server 0.br.pool.ntp.org iburst
server 1.br.pool.ntp.org iburst
server 2.br.pool.ntp.org iburst
server 3.br.pool.ntp.org iburst

# By default, the server allows:
# - all queries from the local host
# - only time queries from remote hosts, protected by rate limiting and kod
restrict default kod limited nomodify nopeer noquery notrap
restrict 127.0.0.1
restrict ::1

# Location of drift file
driftfile /var/lib/ntp/ntp.drift" > /etc/ntp.conf

systemctl start ntpd
systemctl enable ntpd

echo "Servidor de data e hora configurado para BR:"
# Copiando configurações de GUI para todos os users
cp /root/.config /etc/skel -R
echo "Feito."

