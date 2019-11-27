# Correção eduCAPES para versão 0.1

1. Instalar o AVAPolos normalmente.
2. Executar os seguintes comandos em ordem.

    `sudo su`

    `cd /opt/AVAPolos`

    `bash stop.sh`

    `nano docker-compose.yml`
 
3. Quando o editor de texto nano abrir, insira os seguintes comandos

    `Control + \`

Digitar "brendowdf/dspace-postgres-educapes:latest" sem aspas, apertar Enter.
Digitar "avapolos/dspacedb:latest" sem aspas, inserir

    Control + T
    Control + \

Digitar "brendowdf/dspace-educapes:latest" sem aspas, apertar Enter.
Digitar "avapolos/dspace:latest" sem aspas, após, inserir

    Control + T
    Control + o + Enter
    Control + x

4. No terminal, insira:

    `bash start.sh`

5. Acesse o endereço "educapes.avapolos/jspui", tente baixar um conteúdo.

## Se funcionar

* Nada precisará ser feito, a correção já está aplicada.

## Se não funcionar:

* Insira os seguintes comandos:

    `docker exec educapes /dspace/bin/dspace index-discovery -c -f`

    `docker exec educapes /dspace/bin/dspace index-discovery -f`

  Note que o último comando pode demorar 40 minutos!

