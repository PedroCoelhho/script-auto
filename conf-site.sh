#!/bin/bash

#Menu
echo "Escolha uma das opções abaixo:"

echo "1 - Adicinar um novo site" #ok
echo "2 - Remover configurações de um site" #ok
echo "3 - Remover o conteudo de um site" #ok
echo "4 - Relatório de diretorios hospedados /var/www/html/" #ok
echo "5 - Relatório de Virtual Hosts habilitados" #ok
echo ""
echo "Press Enter para sair"
read menu_resposta

case $menu_resposta in

#---------------------------------------------------------------------------------      

        1)

        echo "Adicionar um Virtual Host"
        sleep 1
                echo "Digite o nome do dominio:"
                read dominio

                #echo "digite o nome do primeiro site"
                #read site

                #echo "O dominio:$dominio e site:$site estão corretos? (y/n)"
                echo "O dominio:$dominio está correto? (y/n)"
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

#Adicionando o Virtual Host no apache  
echo "
<VirtualHost *:80>

        ServerName "$dominio"
        ServerAlias www."$dominio"
        DocumentRoot /var/www/html/$dominio
        ErrorLog /var/log/httpd/$dominio-error.log
        CustomLog /var/log/httpd/$dominio-access.log combined

</VirtualHost>" >> /etc/httpd/conf.d/dominios.conf

#Criando arquivo de teste para o dominio
echo "<h1>$dominio<h1>" > /var/www/html/$dominio/index.html

#Adicionando permição do apache para ler o diretorio criado
chown -R apache. /var/www/html/$dominio

echo "reiniciando serviço do apache"
#Restart no serviço do apache, relendo os asrquivos de configuração
systemctl restart httpd

echo "Site adicionado com sucesso"
fi

else 
        #Dominio ou site estão incorretos 
        echo "Reinicie o script inserindo informações corretas"
fi


exit
        ;;

#---------------------------------------------------------------------------------      

        2)
        echo "2 - Remover configurações de um site"
        sleep 1

        echo "Digite o nome do dominio:"
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
        echo "3 - Remover o conteudo de um site"
        sleep 1

        echo "Digite o nome do dominio:"
        read dir_to_remove

        #valida se o diretorio existe
        if [ -e "/var/www/html/$dir_to_remove" ]
        then
                echo "Você tem certeza que deseja remover o diretorio $dir_to_remove? (y/n)"
                read resp_dir_to_remove

                if [ $resp_dir_to_remove == y ]
                then
                        echo "Removendo o dominio $dir_to_remove da hospedagem..."
                        sleep 1
                        rm -rf /var/www/html/$dir_to_remove

                        #restart no serviço do apache para reler os diretorios
                        systemctl restart httpd
                        echo "Dominio removido com sucesso!!!"
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
        echo "4 - Relatório de diretorios hospedados /var/www/html/"
        sleep 1

        ls -l /var/www/html/ | awk -F' ' '{print $9}'

        ;;

#---------------------------------------------------------------------------------      
        5)
        echo "5 - Relatório de virtual hosts habilitados"
        sleep 1
        #Realiza a leitura do arquivo dos dominios com um parsing e exibe na tela
        cat /etc/httpd/conf.d/dominios.conf | grep ServerName |awk '{print $2}'
        ;;
#---------------------------------------------------------------------------------      

        *)
                echo "Script encerrado"
                ;;
esac

