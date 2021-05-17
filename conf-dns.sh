#Menu

echo "Escolha uma opção abaixo:"

echo "1 - Criar novo domino"
echo "2 - Configurar apontamento no servidor DNS para o site"
echo "3 - remover um apontamento de um site no servidor DNS"
echo ""
echo "Press Enter para sair"
read menu_resposta

case $menu_resposta in

#-----------------------------------------------------------------

        1)
        echo "1 - Criar novo domino"
        sleep 1

        echo "Digite o nome do dominio"
        read nome_dominio

        #valida se o arquivo existe
        if [ -e "/var/named/"$nome_dominio".db" ]
        then
                echo "Dominio já existe"
        else
        
        #Criando arquivo do dominio dentro de /var/named/
        > /var/named/"$nome_dominio".db

        #Adiciona conteudo dentro do arquivo criado 
        echo "
\$TTL 3H
@       IN SOA  @ root."$nome_dominio". (
                                        1       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum

@                       IN      NS      ns1."$nome_dominio".
ns1                     IN      A       192.168.1.10
@                       IN      A       192.168.1.4
www                     IN      A       192.168.1.4" >> /var/named/"$nome_dominio".db

#Configura a zona autoritativa do DNS
echo "
zone \""$nome_dominio"\" IN {
        type master;
        file \"/var/named/"$nome_dominio".db\";
};" >> /etc/named.conf

        #Reinicia o reserviço do DNS para reler os arquivos de configuração
        rndc flush
        rndc reload
        echo "Dominio adicionado com sucesso"
fi

exit
        ;;

        2)
        echo "2 - Configurar apontamento no servidor DNS para o site"
        sleep 1

                echo "Qual o nome do dominio que você deseja adicionar?"
                read dominio_site

                #valida se o arquivo existe
                if [ -e "/var/named/"$dominio_site".db" ]
                then
                
                echo "Digite o nome do site que quer adicionar oa dominio $dominio_site"
                read nome_site

                #Adicionando site dentro do dominio escolhido 
                echo "$nome_site                        IN      A       192.168.1.4" >> /var/named/"$dominio_site".db

                #Reinicia o reserviço do DNS para reler os arquivos de configuração
                rndc flush
                rndc reload
                else

                echo "O arquivo /var/named/$add_site não exite "

                fi
        ;;

        3)
        echo "3 - remover um apontamento de um site no servidor DNS"
        sleep 1

                echo "Digite o nome de dominio que quer editar?"
                read nome_domin_remove

                #valida se o arquivo existe
                if [ -e "/var/named/"$nome_domin_remove".db" ]
                then

                #Lista os sites do dominio
                echo "Sites presentes neste dominio"

                cat /var/named/"$nome_domin_remove".db | tail -n +13
                echo ""

                echo "Digite o nome do site que quer remover"
                read site_to_remove

                sed -i '/'$site_to_remove'/d' /var/named/"$nome_domin_remove".db


                #Reinicia o reserviço do DNS para reler os arquivos de configuração
                rndc flush
                rndc reload
                else

                echo "O arquivo /var/named/$nome_domin_remove não exite "

                fi



        ;;

        *)
        echo "Script Encerrado"
        ;;
esac
