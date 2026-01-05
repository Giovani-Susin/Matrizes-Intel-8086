
# Objetivo

Este projeto é o trabalho final da cadeira Arquitetura de Computadores 1. O objetivo principal deste projeto é ler uma matriz N x N+1 (N variando de 1 a 7) de um arquivo txt e aplicar operações elementares dadas pelo usuário através de comandos sobre a matriz.


## Setup
Para usar o programa, primeiro você precisa ter o DOSBox e o montador MASM instalados na sua máquina para poder montar e rodar o executável no ambiente DOS emulado. No meu caso, utilizei o DOSBox 0.74-3 e MASM 6.11. Após instalar os programas acima, realize as configurações necessárias do DOSBox para rodar no seu dispositivo.

### Requerimentos da matriz
Após configurar o DOS, crie um arquivo txt com o nome "MAT.txt" e escreva sua matriz. Sua matriz deve seguir os requerimentos abaixo:

- O número de linhas deve variar 1 a 7
- O número de colunas deve ser linhas + 1
- Os números na matriz devem ser inteiros entre o intervalo [-32767, 32767]
- Os números devem ser separados por ";" (exceto o último da linha)

Em caso de má formatação, o programa informá onde ocorre o problema.

Exemplo de matriz:
```javascript
-20;-78;10;0
-1;2;30;100
32767;100;-7;5
```
## Utilização

### Compilar

Utilize o comando abaixo para montar o código e gerar o objeto.
```bash
  MASM matrizes
```
Após, utilizar o comando link para gerar o executável.
```bash
  LINK matrizes
```
Por fim, chamar o código executável com o comando abaixo.
```bash
  matrizes
```

### Comandos
O programa possui 5 comandos diferentes que podem ser utilizados durante a execução:

- ADD: adiciona a linha de origem à linha de destino.
```bash
  ADD org dest
```
- MUL: multiplica a linha de origem por uma constante inteira no intervalo de [-32767, 32767].
```bash
  MUL org const
```
- UNDO: desfaz a última operação feita.
```bash
  UNDO
```
- WRITE: escreve a matriz do programa no arquivo indicado. Se o arquivo existir, adiciona no seu final, se o arquivo não existir, cria o arquivo com a matriz.
```bash
  WRITE exemplo.txt
```
- END: encerra o programa.
```bash
  END
```

Os comandos podem ser tanto maiúculos ou minúsculos, a má formatação de um comando será informada pelo programa.