#!/bin/bash
# Este script apaga usuários locais não mais necessários e configura o teclado pt-br
# como padrão da LightDM
echo -e "Deletando contas locais aluno, aluno-obi e prodap (Favor checar se há mais alguma)\n"
userdel -r aluno
userdel -r aluno-obi
userdel -r prodap
echo -e "Criando arquivos de configuração do teclado.\n"
# cp environment /etc
echo -e "LANG=pt_BR.utf8\n" > /etc/environment
cp 20-keyboard.conf /etc/X11/xorg.conf.d/
#echo -e "Section \"InputClass\" \n        Identifier \"keyboard\"\n        MatchIsKeyboard \"yes\"\n        Option \"XkbLayout\" \"br\"\n        Option \"XkbVariant\" \"abnt2\"\nEndSection" > /etc/X11/xorg.conf.d/20-keyboard.conf
echo -e "Pronto.\n"
