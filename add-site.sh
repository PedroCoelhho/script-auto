#!/bin/bash

#Menu
echo "Oque deseja fazer? escolha um número"

echo "1 - Adicionar um Virtual Rost + criar diretorio do site" #ok
echo "2 - Remover um virtual Host" #ok
echo "3 - Remover o diretorio de um site dentro de /var/www/html/" #ok
echo "4 - Relatório de diretorios hospedados /var/www/html/site" #ok
echo "5 - Relatório de virtual hosts habilitados" #ok
echo ""
echo "Press Enter para sair"
read menu_resposta

case $menu_resposta in

#---------------------------------------------------------------------------------      

        1)

        echo "Adicionar um Virtual Rost"
        sleep 1
                echo "Digite o nome do dominio:"
                read dominio

                echo "digite o nome do primeiro site"
                read site

                echo "O dominio:$dominio e site:$site estão corretos? (y/n)"
                read resposta

                        if [ $resposta == y ]
                        then 
                                echo "Iniciando a configuração do apache"
                                sleep 1

                        #Validando se o diretorio existe 
                        if [ -e "/var/www/html/$dominio" ]
                                then
                                        echo "O diretorio já existe em /var/www/html/$dominio - operação não concluída"
                        else
                                echo "Criando o diretorio /var/www/html/$dominio"
                                sleep 1
                                #Cria o diretorio do dominio
                                mkdir /var/www/html/$dominio

#Adicionando a conf ao webhost no apache  
echo "
<VirtualHost *:80>

        ServerName www."$site"."$dominio".com.br
        ServerAlias "$site"."$dominio".com.br
        DocumentRoot /var/www/html/$dominio
        ErrorLog /var/www/html/$dominio/error.log
        CustomLog /var/www/html/$dominio/access.log combined

</VirtualHost>" >> /etc/httpd/conf.d/dominios.conf

#Criando arquivo de teste para o dominio
echo "<h1>$dominio<h1>" > /var/www/html/$dominio/index.html

#Adicionando permição do apache para ler o diretorio criado
chown -R apache. /var/www/html/$dominio

#Restart no serviço do apache, relendo os asrquivos de configuração
systemctl restart httpd

fi

else 
        #Dominio ou site estão incorretos 
        echo "Reinicie o script inserindo informações corretas"
fi


exit
        ;;

#---------------------------------------------------------------------------------      

        2)
        echo "4 - Remover um virtual Host"
        sleep 1

        echo "Digite o nome do Virtual Host que deseja excluir"
        read nome_host
        sleep 1 

        echo "Excluindo o virtual host em /etc/httpd/conf.d/dominios.conf"

        #Exclui as linhas referente ao virtual host escolhido
        sed -i '/'$nome_host'/d' /etc/httpd/conf.d/dominios.conf

        echo "Reiniciando serviço do apache"
        systemctl restart httpd        
        ;;

#---------------------------------------------------------------------------------      

        3)
        echo "5 - Remover o diretorio de um site dentro de /var/www/html/site"
        sleep 1

        echo "Qual diretorio deseja remover?"
        read dir_to_remove

        #valida se o diretorio existe
        if [ -e "/var/www/html/$dir_to_remove" ]
        then
                echo "Você tem certeza que deseja remover o diretorio $dir_to_remove? (y/n)"
                read resp_dir_to_remove

                if [ $resp_dir_to_remove == y ]
                then
                        echo "Removendo o Diretorio de hospedagem em /var/www/html/"
                        sleep 1
                        rm -rf /var/www/html/$dir_to_remove

                        #restart no serviço do apache para reler os diretorios
                        systemctl restart httpd
                else
                        echo "Não foi possível remover o diretório"
                        sleep 1
                        
                fi
        else
                echo "Diretorio não existe" 
        fi
        ;;
#---------------------------------------------------------------------------------      

        4)
        echo "8 - Relatório de diretorios hospedados /var/www/html/site"
        sleep 1

        ls -l /var/www/html/ | awk -F' ' '{print $9}'

        ;;

#---------------------------------------------------------------------------------      
        5)
        echo "9 - Relatório de virtual hosts habilitados"
        sleep 1
        #Realiza a leitura do arquivo dos dominios com um parsing e exibe na tela
       cat /etc/httpd/conf.d/dominios.conf | grep -E "www.*.*.com.br" | sed 's/\t//g' | sed 's/ServerName //g' 

        ;;
#---------------------------------------------------------------------------------      

        *)
                echo "Script encerrado"
                ;;
esac
