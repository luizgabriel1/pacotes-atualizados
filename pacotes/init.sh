#!/bin/bash

echo "Começando Padronização .... "

sleep 2

proxima=0
##############################################################################

while : ; do
    case "$proxima" in
        0)  	
			menu=$( dialog --stdout --menu 'Menu de Padronizacao:' 0 0 0 1 'Alterar Hostname (apenas como root)' 2 'Configurar GRUB (não esquecer de configurar grub.cfg)' 3 'sair' )
            
            
            proxima=$menu
                        ;;
        
        1)	ip=$( dialog --stdout --inputbox 'Insira o novo Hostname :' 0 0 )
            hostnamectl set-hostname $ip 
            
          
            dialog                                            \
   			--title 'Info'                             \
   			--msgbox 'Hostname atualizado.'  \
   			6 40
           proxima=0
           ;;
			


        2) sh ./define_grub.sh
                     proxima=0

          ;;
         


        *)
           
            
            exit
    esac

done
















