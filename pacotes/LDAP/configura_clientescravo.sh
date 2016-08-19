#/bin/bash
#Author: Elias Rabelo Matos,João Manoel Pimentel Corrreia e Thiago Fontes dos Santos
pacman-key --init
pacman-key --populate archlinux
pacman -Sy
pacman -S openldap nss-pam-ldapd --needed --noconfirm
echo "Criando o certificado"
#nesta parte o certificado deverá ser criado
echo "BR
SE
Sao Cristovao
DCOMP
UFS
$HOSTNAME

"> geracert.txt
openssl ecparam -out server.key -name prime256v1 -genkey
openssl req -new -x509 -days 1095 -key server.key -out server.crt -nodes < geracert.txt
mkdir /etc/openldap/ssl
cp server.key /etc/openldap/ssl/server.key
cp server.crt /etc/openldap/ssl/server.crt
chmod -R 755 /etc/openldap/ssl/
chmod 400 /etc/openldap/ssl/server.key
chmod 444 /etc/openldap/ssl/server.crt
chown ldap /etc/openldap/ssl/server.key
rm server.key
rm server.crt
rm geracert.txt
rm -rf /var/lib/openldap/openldap/*
echo "Configurando o slapd.conf"
cp /etc/openldap/slapd.conf  /etc/openldap/slapd.conf.old
echo -e "#
include     /etc/openldap/schema/core.schema
include     /etc/openldap/schema/cosine.schema
include     /etc/openldap/schema/inetorgperson.schema
include     /etc/openldap/schema/nis.schema

pidfile		/run/openldap/slapd.pid
argsfile	/run/openldap/slapd.args

# Load dynamic backend modules:
modulepath	/usr/lib/openldap
# moduleload	back_bdb.la
# moduleload	back_hdb.la
# moduleload	back_ldap.la
moduleload  back_bdb
moduleload syncprov

backend bdb

database	bdb
suffix		"\"dc=computacao,dc=ufs,dc=br\""
rootdn		"\"cn=root,dc=computacao,dc=ufs,dc=br\""
directory	/var/lib/openldap/openldap-data

index	objectClass	eq
lastmod on
checkpoint 512 30
syncrepl rid=001
   provider=ldaps://10.27.100.2
   type=refreshAndPersist
   retry="\"30 10 600 20\""
   schemachecking=off
   tls_reqcert=never
   bindmethod=simple
   searchbase="\"dc=computacao,dc=ufs,dc=br\""
   binddn="\"uid=syncrepl,ou=pessoas,dc=computacao,dc=ufs,dc=br\""
   credentials=orz3NSYYNEqpJkwcDzbPzoAtcRO7NzTI
mirrormode on
updateref ldaps://10.27.100.2


access to attrs=userPassword
	by dn=cn=root,dc=computacao,dc=ufs,dc=br write
	by group.exact=cn=adm,ou=grupos,dc=computacao,dc=ufs,dc=br write
	by anonymous auth
	by self write
	by * none

#todos podem ler a lista de usuários, administradores podem escrever
access to dn.base=ou=pessoas,dc=computacao,dc=ufs,dc=br
	by group.exact=cn=adm,ou=grupos,dc=computacao,dc=ufs,dc=br write
	by self read

#somente o root e os admnistradores tem acesso a todo o diretório podendo escrever tudo
access to dn.base=
	by group.exact=cn=adm,ou=grupos,dc=computacao,dc=ufs,dc=br write
	by dn=cn=root,dc=computacao,dc=ufs,dc=br write
	by * none

#root pode escrever tudo
#os demais podem ler tudo
access to *
	by group.exact=cn=adm,ou=grupos,dc=computacao,dc=ufs,dc=br write
	by dn=cn=root,dc=computacao,dc=ufs,dc=br write
	by users read
	by * read
# Certificate/SSL Section
TLSCipherSuite DEFAULT
TLSCertificateFile /etc/openldap/ssl/server.crt
TLSCertificateKeyFile /etc/openldap/ssl/server.key" > /etc/openldap/slapd.conf
echo "Configurando do daemon do ldap para ldaps"
cp /usr/lib/systemd/system/slapd.service /usr/lib/systemd/system/slapd.service.old
echo -e "[Unit]
Description=OpenLDAP server daemon

[Service]
Type=forking
ExecStart=/usr/bin/slapd -u ldap -g ldap -h "\"ldaps:///\""

[Install]
WantedBy=multi-user.target"> /usr/lib/systemd/system/slapd.service
systemctl daemon-reload
echo "Executando configurações do Ldap"
cp /etc/openldap/DB_CONFIG.example /var/lib/openldap/openldap-data/DB_CONFIG
chown ldap:ldap /var/lib/openldap/openldap-data/DB_CONFIG
echo "* Removing old entries"
rm -rf /etc/openldap/slapd.d/*
systemctl start slapd
systemctl stop slapd
echo
echo "* Testing slapd.conf"
slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d/
echo
echo "* Giving OpenLdap file permissions"
chown -R ldap:ldap /etc/openldap/slapd.d
slapindex
chown ldap:ldap /var/lib/openldap/openldap-data/*
echo "Configurando cliente" &&
#cp /etc/openldap/ldap.conf /etc/openldap/ldap.conf.old &&

echo "BASE    dc=computacao,dc=ufs,dc=br
URI     ldaps://localhost

SIZELIMIT       12
TIMELIMIT       15

TLS_REQCERT allow
sudoers_base ou=sudoers,dc=AFOLA">/etc/openldap/ldap.conf &&

echo "nsswitch.conf"
cp /etc/nsswitch.conf  /etc/nsswitch.conf.old &&
echo "# Begin /etc/nsswitch.conf

passwd: files ldap
group: files ldap
shadow: files ldap

publickey: files

hosts: files dns myhostname
networks: files

protocols: files
services: files
ethers: files
rpc: files

netgroup: files

# End /etc/nsswitch.conf">/etc/nsswitch.conf


echo "nslcd.conf"
cp /etc/nslcd.conf /etc/nslcd.conf.old

echo "# The user and group nslcd should run as.
uid nslcd
gid nslcd

# The uri pointing to the LDAP server to use for name lookups.
# Multiple entries may be specified. The address that is used
# here should be resolvable without using LDAP (obviously).
uri ldaps://localhost/

# The LDAP version to use (defaults to 3
# if supported by client library)
ldap_version 3

# The distinguished name of the search base.
base dc=computacao,dc=ufs,dc=br

# Bind/connect timelimit.
bind_timelimit 30


# Use StartTLS without verifying the server certificate.
#ssl start_tls
tls_reqcert never">/etc/nslcd.conf

echo "system-auth"
cp /etc/pam.d/system-auth /etc/pam.d/system-auth.old
echo "auth      sufficient pam_ldap.so	minimum_uid=600000
auth      required  pam_unix.so		try_first_pass nullok
auth      optional  pam_permit.so
auth      required  pam_env.so

account   sufficient pam_ldap.so	minimum_uid=600000
account   required  pam_unix.so
account   optional  pam_permit.so
account   required  pam_time.so

password  sufficient pam_ldap.so	minimum_uid=600000
password  required  pam_unix.so		try_first_pass nullok sha512 shadow
password  optional  pam_permit.so

session   required  pam_limits.so
session   required  pam_unix.so
session   optional  pam_ldap.so		minimum_uid=600000
session   optional  pam_permit.so">/etc/pam.d/system-auth

echo "su | su-l"
cp /etc/pam.d/su /etc/pam.d/su.old
cp /etc/pam.d/su-l /etc/pam.d/su-l.old

echo "#%PAM-1.0
auth      sufficient    pam_ldap.so
auth      sufficient    pam_rootok.so
# Uncomment the following line to implicitly trust users in the \"wheel\" group.
#auth     sufficient    pam_wheel.so trust use_uid
# Uncomment the following line to require a user to be in the \"wheel\" group.
#auth     required      pam_wheel.so use_uid
auth      required	pam_unix.so use_first_pass
account   sufficient    pam_ldap.so
account   required	pam_unix.so
session         required        pam_mkhomedir.so skel=/etc/skel umask=0022
session   sufficient    pam_ldap.so
session   required	pam_unix.so">/etc/pam.d/su
echo "#%PAM-1.0
auth      sufficient    pam_ldap.so
auth      sufficient    pam_rootok.so
# Uncomment the following line to implicitly trust users in the \"wheel\" group.
#auth     sufficient    pam_wheel.so trust use_uid
# Uncomment the following line to require a user to be in the \"wheel\" group.
#auth     required      pam_wheel.so use_uid
auth      required	pam_unix.so use_first_pass
account   sufficient    pam_ldap.so
account   required	pam_unix.so
session         required        pam_mkhomedir.so skel=/etc/skel umask=0022
session   sufficient    pam_ldap.so
session   required	pam_unix.so">/etc/pam.d/su-l

echo "passwd"
cp /etc/pam.d/passwd /etc/pam.d/passwd.old
echo "#%PAM-1.0
password        sufficient      pam_ldap.so
#password       required        pam_cracklib.so difok=2 minlen=8 dcredit=2 ocredit=2 retry=3
#password       required        pam_unix.so sha512 shadow use_authtok
password        required        pam_unix.so sha512 shadow nullok">/etc/pam.d/passwd

echo "system-login"
cp /etc/pam.d/system-login /etc/pam.d/system-login.old
echo "#%PAM-1.0

auth       required   pam_tally.so         onerr=succeed file=/var/log/faillog
auth       required   pam_shells.so
auth       requisite  pam_nologin.so
auth       include    system-auth

account    required   pam_access.so
account    required   pam_nologin.so
account    include    system-auth

password   include    system-auth

session    optional   pam_loginuid.so
session    include    system-auth
session    optional   pam_motd.so          motd=/etc/motd
session    optional   pam_mail.so          dir=/var/spool/mail standard quiet
-session   optional   pam_systemd.so
session    required   pam_env.so
session    required   pam_mkhomedir.so skel=/etc/skel umask=0022">/etc/pam.d/system-login

echo "sudo"
cp /etc/pam.d/sudo /etc/pam.d/sudo.old
echo "#%PAM-1.0
auth      	sufficient    	pam_ldap.so
auth      	required      	pam_unix.so  try_first_pass
auth      	required	pam_nologin.so
auth		include		system-auth
account		include		system-auth
session		include		system-auth">/etc/pam.d/sudo
echo "sudoers"
cp /etc/sudoers /etc/sudoers.old
echo "## sudoers file.
##
## This file MUST be edited with the 'visudo' command as root.
## Failure to use 'visudo' may result in syntax or file permission errors
## that prevent sudo from running.
##
## See the sudoers man page for the details on how to write a sudoers file.
##

##
## Host alias specification
##
## Groups of machines. These may include host names (optionally with wildcards),
## IP addresses, network numbers or netgroups.
# Host_Alias	WEBSERVERS = www1, www2, www3

##
## User alias specification
##
## Groups of users.  These may consist of user names, uids, Unix groups,
## or netgroups.
# User_Alias	ADMINS = millert, dowdy, mikef

##
## Cmnd alias specification
##
## Groups of commands.  Often used to group related commands together.
# Cmnd_Alias	PROCESSES = /usr/bin/nice, /bin/kill, /usr/bin/renice, \
# 			    /usr/bin/pkill, /usr/bin/top
# Cmnd_Alias	REBOOT = /sbin/halt, /sbin/reboot, /sbin/poweroff

##
## Defaults specification
##
## You may wish to keep some of the following environment variables
## when running commands via sudo.
##
## Locale settings
# Defaults env_keep += \"LANG LANGUAGE LINGUAS LC_* _XKB_CHARSET\"
##
## Run X applications through sudo; HOME is used to find the
## .Xauthority file.  Note that other programs use HOME to find   
## configuration files and this may lead to privilege escalation!
# Defaults env_keep += \"HOME\"
##
## X11 resource path settings
# Defaults env_keep += \"XAPPLRESDIR XFILESEARCHPATH XUSERFILESEARCHPATH\"
##
## Desktop path settings
# Defaults env_keep += \"QTDIR KDEDIR\"
##
## Allow sudo-run commands to inherit the callers' ConsoleKit session
# Defaults env_keep += \"XDG_SESSION_COOKIE\"
##
## Uncomment to enable special input methods.  Care should be taken as
## this may allow users to subvert the command being run via sudo.
# Defaults env_keep += \"XMODIFIERS GTK_IM_MODULE QT_IM_MODULE QT_IM_SWITCHER\"
##
## Uncomment to use a hard-coded PATH instead of the user's to find commands
# Defaults secure_path=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"
##
## Uncomment to send mail if the user does not enter the correct password.
# Defaults mail_badpass
##
## Uncomment to enable logging of a command's output, except for
## sudoreplay and reboot.  Use sudoreplay to play back logged sessions.
# Defaults log_output
# Defaults!/usr/bin/sudoreplay !log_output
# Defaults!/usr/local/bin/sudoreplay !log_output
# Defaults!REBOOT !log_output

##
## Runas alias specification
##

##
## User privilege specification
##
root ALL=(ALL) ALL

## Uncomment to allow members of group wheel to execute any command
%wheel ALL=(ALL) ALL

## Same thing without a password
# %wheel ALL=(ALL) NOPASSWD: ALL

## Uncomment to allow members of group sudo to execute any command
# %sudo	ALL=(ALL) ALL

## Uncomment to allow any user to run sudo if they know the password
## of the user they are running the command as (root by default).
# Defaults targetpw  # Ask for the password of the target user
# ALL ALL=(ALL) ALL  # WARNING: only use this together with 'Defaults targetpw'

## Read drop-in files from /etc/sudoers.d
## (the '#' here does not indicate a comment)
#includedir /etc/sudoers.d
" > /etc/sudoers
echo "** Configuração finalizada"
echo "Configuração Pronta"
echo "Configurando o Ldap no boot"
systemctl enable slapd nslcd
echo "Iniciando o Ldap"
systemctl start slapd nslcd
echo "Pronto!!!"
