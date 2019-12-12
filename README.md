# AVAPolos 0.2
Repositório da solução AVAPolos versão 0.2

## Notas para testadores.

A operação recomendada é a utilização de 2 máquinas como instalação IES e POLO e uma máquina somente para compilação, pois o processo de compilação é mais rápido depois da primeira utilização.

A compilação pode ser agilizada utilizando a opção --template como último argumento do script compilar.sh:

`bash compilar.sh --template`

O template "moodle-dev" é mais leve para testes somente com o Moodle.

### Após a primeira compilação.

Se não foram feitas mudanças na solução, as opções --no-update e --no-build-data podem ajudar muito na velocidade de compilação:

`bash compilar.sh --no-update --no-build-data`

# Instalação
Para instalar a solução, basta executar os seguintes comandos:

Para uma versão estável:
`git clone https://github.com/C3FURG/AVAPolos avapolos`

Para uma versão de testes:
`git clone https://github.com/razuos/AVAPolos avapolos`

`cd avapolos/build && bash compilar.sh`

Se a reinicialização da máquina for requisitada, reinicie e execute os seguintes comandos num terminal.

`cd avapolos/build && bash compilar.sh`

Após o término da compilação, instale a solução com o seguinte comando.

`sudo ·/NOMEDOINSTALADOR`

## Clonagem
Para clonar um servidor IES, basta executar os seguintes comandos:

`sudo avapolos --export-all`

Para instalá-lo:

`sudo ./NOMEDOINSTALADOR-CLONE`
