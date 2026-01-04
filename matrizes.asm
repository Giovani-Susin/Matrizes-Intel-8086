        .model small
		.stack
		.data

        nomeArq			db "MAT.TXT",0      ;nome do arquivo a ser lido 
        op1             db "ADD",0          ;operação 1 (adição)
        op2             db "MUL",0          ;operação 2 (multiplicação)
        op3             db "UNDO",0         ;operação 3 (desfazer)
        op4             db "WRITE",0        ;operação 4 (escrever)
        op5             db "END",0          ;operação 5 (encerrar o programa) - fiz como um extra
        operandos       dw 2 DUP(0)         ;operandos das operações ADD e MUL 
        matriz          dw 56 DUP(0)        ;matriz, contendo o tamanho máximo possível
        matrizAux       dw 56 DUP(0)        ;matriz auxiliar para o comando de undo
        bufferArq       db 0                ;string auxiliar para ler do arquivo
        handle          dw 0                ;variável auxiliar que armazena o handle do arquivo
        lin             db 0                ;variável de controle das linhas da matriz
        col             db 0                ;variável de controle das colunas da matriz
        colAnterior     db 0                ;variável de controle de colunas para captar erros de formatação do arquivo de emtrada
        index           dw 0                ;varíavel que auxilia a controlar o índice da matriz
        entrada         db 64 DUP(?)        ;tamanho maxímo da entrada digitada
        arqEntrada      db 48 DUP(?)        ;variável para leitura do nome do arquivo para escrever a matriz
        stringAux       db 7 DUP(?)         ;string auxiliar que armazena o número convertido para ascii
        enderecoAux     dw 0                ;variável auxiliar para armazenar bx na conversão de ascii para número
        CRLF            db 13,10,0          ;string que auxilia a ir para a próxima linha
        pontoVirgula   db ";",0            ;string que auxilia a por o ponto e vírgula
        mensagem1       db "Numero de colunas/linhas invalido",13,10,0  ;mensagem caso a matriz do arquivo tenha número de linhas ou colunas inválido
        mensagem2       db "Matriz invalida na linha ",0  ;mensagem caso a linha x tenha menos colunas que as outras
        mensagem3       db "Comando invalido",13,10,0 ;mensagem caso o usuário tenha digitado um comando inválido
        mensagem4       db "Erro ao abrir o arquivo",13,10,0 ;mensagem caso não tenha sido possível abrir o arquivo
        mensagem5       db "Erro ao fechar o arquivo",13,10,0 ;mensagem caso não tenha sido possível fechar o arquivo
        ;mensagem caso ocorra estouro em um número da matriz
        mensagem6       db "Estouro na linha ",0
        mensagem7       db "coluna ",0
        mensagem8       db "Operandos mal formatados",13,10,0 ;mensagem caso os operandos das operações estejam mal formatados
        mensagem9       db "Numero errado de operandos",13,10,0 ;mensagem caso o número de operandos esteja incorreto
        mensagem10      db "Operando excede o limite de 16 bits",13,10,0    ;mensagem caso um dos operandos exceda o limite de 16 bits
        mensagem11      db "Estouro na operacao",13,10,0    ;mensagem caso um dos elementos da matriz resultante exceda 16 bits
        mensagem12      db "Erro ao escrever no arquivo",13,10,0    ;mensagem caso ocorra um erro ao escrever no arquivo
        mensagem13      db "Numero incorreto de argumentos",13,10,0 ;mensagem caso esteja faltando o nome do arquivo ao utilizar write
        mensagem14      db "Erro ao criar o arquivo",13,10,0 ;mensagem caso esteja faltando o nome do arquivo ao utilizar write

        .code
		.startup



    ;le o arquivo de entrada
    call    leArquivo
    jc      fim
    call    mostraMatriz    ;apresenta a matriz na tela

loop_main:
    ;realiza a leitura de teclado
    mov     cx,63
    lea     bx,entrada
    call    scanf
    
    ;imprime final de linha após scanf
    lea     bx,CRLF
    call    printf
    
    ;transforma a entrada em maiusculo
    lea     bx,entrada
    call    upper

    ;confere se é o comando ADD
    lea     bp,op1
    mov     cx,3
    call    strcmp
    jnz     confere_MUL

    call    adiciona        ;reliza a operação
    jc      loop_main
    call    mostraMatriz    ;imprime a matriz na tela
    jmp short   loop_main

confere_MUL:
    ;confere se é o comando MUL
    lea     bp,op2
    mov     cx,3
    call    strcmp
    jnz     confere_UNDO

    call    multiplica      ;reliza a operação
    jc      loop_main
    call    mostraMatriz    ;imprime a matriz na tela
    jmp short   loop_main

confere_UNDO:
    ;confere se é o comando UNDO
    lea     bp,op3
    mov     cx,4
    call    strcmp
    jnz     confere_WRITE

    call    undo            ;reliza a operação
    call    mostraMatriz    ;imprime a matriz na tela
    jmp short   loop_main

confere_WRITE:
    ;confere se é o comando WRITE
    lea     bp,op4
    mov     cx,5
    call    strcmp
    jnz     confere_END

    call    write           ;reliza a operação
    jmp short   loop_main

confere_END:
    ;confere se é o comando END (encerra o programa)
    lea     bp,op5
    mov     cx,3
    call    strcmp
    jz     fim      ;se for end, encerra o programa

    ;se não for nenhum dos acima, é um comando inválido
    lea     bx,mensagem3
    call    printf
    jmp short   loop_main

fim:

    .exit


;===================
;MOSTRA MATRIZ
;===================
;Objetivo: apresentar a matriz na tela
;===================
mostraMatriz proc near
    lea     bx,matriz       ;carrega em bx o endereço da matriz

    mov     dl,lin          ;carrega dl com o número de linhas

linha:
    cmp     dl,0            ;enquanto dl for maior que 0
    jbe     fimMostraMatriz

    mov     cl,col          ;carrega em cx o número de colunas para realizar um loop
    mov     ch,0

loopMostraMatriz:

    push    cx              ;salva o conteúdo de cx
    push    dx              ;salva o conteúdo de dx
    push    bx              ;salva o conteúdo de bx

    ;converte o elemento atual da matriz para string ascii
    mov     ax,[bx]
    lea     bx,stringAux
    call    numAscii
    ;bx possui o ponteiro da string

    ;calcula o tamanho da string e imprime o espaçamento correto
    call    strlen      ;cx possui o tamanho da string
    call    printEspaco

    call    printf      ;imprime a string

    pop     bx              ;retorna o conteúdo de bx
    pop     dx              ;retorna o conteúdo de dx
    pop     cx              ;retorna o conteúdo de cx

    add     bx,2            ;vai para o próximo elemento

    loop    loopMostraMatriz

    push    bx              ;salva o conteudo de bx
    push    cx              ;salva o conteúdo de cx
    push    dx              ;salva o conteúdo de dx

    lea     bx,CRLF
    call    printf          ;printa nova linha na tela


    pop     dx              ;retorna o conteúdo de dx
    pop     cx              ;retorna o conteúdo de cx
    pop     bx              ;retorna o conteúdo de bx

    dec     dl
    jmp short linha

fimMostraMatriz:
    ret
    
mostraMatriz endp



;===================
;NUM ASCII
;===================
;Objetivo: transformar uma word em uma string ascii correspondente (funciona para números com sinal)
;Entrada: Word Word
;   (AX) - número a ser convertido
;   (BX) - ponteiro da string resultante
;Saída: Word (ponteiro para a string resultante em bx)
;   (BX) - ponteiro da string resultante
;===================
numAscii proc near

    ;salva registradores que são alterados na função
    push    si
    push    cx
    push    ax
    push    dx

    mov     si,0        ;incializa ponteiro da string no elemento 0
    mov     cx,0        ;inicializa com 0 o contador de elementos da string


    test    ax,ax       ;confere o flag de sinal do ax
    jns     positivo    

    ;se for negativo
    mov     byte ptr[bx+si],'-'   ;insere o sinalizador de sinal na string
    inc     si
    neg     ax          ;transforma ax em positivo
    ;como as divisões abaixo não consideram sinal, números entre -32767 e 32767 não serão problema

positivo:
    mov     enderecoAux,bx          ;salva bx em uma variável auxiliar
    mov     bx,10       ;precisamos do resto da divisão por 10

divisao:
    inc     cx          ;incremento o contador de elementos na string
    mov     dx,0        ;para evitar overflow, será feita uma divisão de 32 bits / 16 bits

    div     bx          ;divide ax por 10

    add     dl,'0'      ;transformo o resto da divisão em caractere ascii
    push    dx          ;insiro o caractere na pilha para poder inverter a ordem depois

    or      ax,ax
    jnz    divisao      ;realiza o processo até que o número seja 0


    mov     bx,enderecoAux  ;retorna o conteúdo de bx 

    ;agora que a string já está formada na pilha, retiramos da pilha 
    ;e o número estará na ordem correta, pois inserimos inversamente
retiraPilha:
    ;retiro o caractere da pilha e insiro na string
    pop    ax       
    mov     byte ptr[bx+si],al
    inc     si          ;incremento o ponteiro da string
    loop    retiraPilha ;continuo ate que tenham sido retirados todos elementos (cx já estava inicializado com o número correto de elementos)

    mov     byte ptr[bx+si],0   ;coloca o \0 para indicar o final da string

    ;retorna registradores
    pop     dx
    pop     ax
    pop     cx
    pop     si

    ret

numAscii endp


;===================
;PRINTF
;===================
;Objetivo: colocar uma string na tela
;Entrada: Word
;   (BX) - ponteiro da string
;===================
printf proc near

    mov     si,0        ;incializa si com 0

loopPrintf:
    mov     dl,[bx+si]  ;coloca em dl o caractere a ser escrito

    or      dl,dl
    jz      fimPrintf   ;se for \0, encerra a função

    mov     ah,2        ;imprime na tela o caractere
    int     21H

    inc     si          ;incrementa o ponteiro

    jmp short loopPrintf    ;repete o loop

fimPrintf:     

    ret

printf endp

;===================
;PRINT ESPACO
;===================
;Objetivo: imprimir o numero correto de espaços para que o número seja apresentado em 8 caracteres
;Entrada:   Word
;   (CX) - tamanho da string
;===================
printEspaco proc near

    ;calcula o número de espaços a serem colocados na tela
    mov     ax,8    ;8 é o espaçamento máximo para cada número da matriz
    sub     ax,cx
    mov     cx,ax

    ;carrega dl com o espaço e informa a interrupção em ah
    mov     dl,' '
    mov     ah,2
    
loop_printEspaco:
    ;imprime os espaços na tela
    int     21H
    loop    loop_printEspaco

printEspaco endp

;===================
;STRLEN
;===================
;Objetivo: retornar o número de caractereres de uma string
;Entrada:
;   (BX) - ponteiro da string
;Saida: 
;   (CX) - número de caracteres da string
;===================
strlen proc near

    ;inicializa a string no elemento 0
    mov     si,0
    ;inicializa a contagem de elementos em 0
    mov     ax,0

loop_strlen:
    ;verifica se chegou ao final da string
    cmp     byte ptr[bx+si],0
    je      fim_strlen

    ;se não acabou, vai para o próximo elemento e incrementa a contagem
    inc     ax
    inc     si
    jmp short   loop_strlen

fim_strlen:
    mov     cx,ax   ;move o resultado para cx
    ret

strlen  endp


;===================
;ATOI
;===================
;Objetivo: transformar um caractere ascii em um número inteiro de 16 bits com sinal
;Entrada: Word
;   (BX) - ponteiro da string a ser convertida
;Saída:  Word Bit
;   (BX) - número resultante
;   (CF) - 0 se não houve estouro, 1 se houve estouro
;===================
atoi proc near
    ;salva registradores utilizados na função
    push    si
    push    ax
    push    dx
    push    cx

    mov     si,0        ;inicializa ponteiro da string no elemento 0
    ;inicializa o resultado da operação com 0
    mov     ax,0        
    mov     dx,0

    cmp     byte ptr[bx+si],'-'   
    jnz     loopAtoi
    ;se for negativo, pula o byte indicador de sinal
    inc     si

loopAtoi:
    cmp     byte ptr[bx+si],0    ;enquanto não for \0
    jz      sinalAtoi

    mov     cx,10       ;multiplica ax por 10
    mul     cx

    ;se dx for diferente de 0, houve estouro
    or      dx,dx
    jnz     estouroAtoi

    mov     ch,0        
    mov     cl,[bx+si]  ;coloco o caractere atual em cl
    sub     cl,'0'      ;subtraio 0 em ascii par isolar o valor numérico
    add     ax,cx       ;adiciono o valor numérico em ax

    ;verifica se houve estouro ao somar o novo caractere
    jo     estouroAtoi

    inc     si          ;vai para o próximo elemento
    jmp short   loopAtoi
   
estouroAtoi:
    stc     ;seta flag de carry, informando que houve estouro
    jmp short   fimAtoi  

sinalAtoi:

    ;confere se era negativo e muda o sinal do resultado
    cmp     byte ptr[bx],'-'
    jnz     positivoAtoi
    ;negativo
    neg     ax

positivoAtoi:
    ;positivo
    mov     bx,ax

    clc     ;limpa flag de carry, informando que não houve estouro

fimAtoi:
    ;retorna registradores utilizados
    pop     cx
    pop     dx
    pop     ax
    pop     si
    ret


atoi endp

;===================
;SCANF
;===================
;Objetivo: ler a entrada digitada pelo usuário
;Entrada: Word Word
;   (BX) - ponteiro da string a ser lida
;   (CX) - número de caracteres a serem lidos
;Saída:  Word
;   (BX) - ponteiro da string
;===================
scanf proc near
    mov		dx,0

scanfLoop:
	mov		ah,7			;chama função que aguarda pela leitura de uma tecla
	int		21H

    cmp		al,0DH			;compara a tecla com CR
	jne		backspace

	mov		byte ptr[bx],0	;se for CR, termina a string com \0
	ret

;backspace
backspace:
	cmp		al,08H			;compara a tecla com BS (backspace)
	jne		caractere

	cmp		dx,0			;se for a posição 0
	jz		scanfLoop	    ;retorna a ler outro caractere

	;se não for 0
	push	dx				;armazena dx na pilha
		
	mov		dl,08H			;chama função de imprimir na tela com o backspace
	mov		ah,2
	int		21H
		
	mov		dl,' '			;chama função de imprimir na tela com o espaço para limpar o caractere
	mov		ah,2
	int		21H
		
	mov		dl,08H			;chama função de imprimir na tela com o backspace
	mov		ah,2
	int		21H
		
	pop		dx				;retorna o valor de dx da pilha

	dec		bx				;decrementa bx (ponteiro da string)
	inc		cx				;incrementa cx (contador de caracteres)
	dec		dx				;decrementa dx (posição da string)
		
	jmp		scanfLoop


caractere:
	cmp		cx,0			;se contador atingir 0, para de ler
	je		scanfLoop

	cmp		al,' '			;se caractere digitado for maior ou igual que espaço
	jl		scanfLoop

	mov		[bx],al			;insere o caractere na string

	inc		bx				;incrementa o ponteiro da string
	dec		cx				;decrementa o contador
	inc		dx				;incrementa posição da string

	push	dx				;imprime o caractere digitado na tela
	mov		dl,al
    mov		ah,2
	int		21H
	pop		dx

	jmp		scanfLoop
scanf endp

;===================
;STRCMP
;===================
;Objetivo: comparar duas strings (uma delas já é a da entrada por padrão)
;Entrada: Word Word
;   (BP) - ponteiro da string a ser comparada
;   (CX) - número de caracteres comparados
;Saída:  Bit
;   (ZF) - 0 se forem diferentes, 1 se forem iguais
;===================
strcmp  proc near
    mov     si,0        ;incializa ponteiro da string de entrada no elemento 0
    mov     di,0        ;incializa ponteiro da string a ser comparada no elemento 0
    lea     bx,entrada  ;carrega em bx o ponteiro da string de entrada

loopStrcmp:
    ;compara os caracteres
    mov     al,[bp+di]
    cmp     byte ptr[bx+si],al
    jnz     fimStrcmp   ;se não forem iguais, encerra a função

    inc     si
    inc     di
    ;se for igual, confere o próximo dígito
    loop loopStrcmp

    test    ax,0    ;seta ZF

fimStrcmp:
    ret

strcmp endp

;===================
;UPPER
;===================
;Objetivo: transforma a primeira palavra de uma string de minusculo para maiusculo
;Entrada: Word
;   (BX) - ponteiro da string a ser transformada
;Saída:  Word
;   (BX) - ponteiro da string resultante
;===================
upper proc near
    ;inicializa si em -1 para facilitar o loop a seguir
    mov     si,-1

loop_upper:
    inc     si

    cmp     byte ptr[bx+si],' '
    jz      fim_upper

    ;se for menor que 'a', vai para o próximo caractere
    cmp     byte ptr[bx+si],'a'
    jb      loop_upper

    ;se for maior que 'z' vai para o próximo caractere
    cmp     byte ptr[bx+si],'z'
    jg      loop_upper

    ;se for letra minuscula, transforma em maiuscula
    sub     byte ptr[bx+si],32

    jmp short   loop_upper

fim_upper:
    ret
upper endp

;===================
;MULTIPLICA
;===================
;Objetivo: dadas uma linha da matriz e uma constante, multiplica a linha da matriz pela constante
;===================
multiplica proc near
    ;separa os operandos da entrada
    call    separaOperandos
    jc      fim_multiplica

    ;salva a matriz de antes da operação
    call    salvaMatriz

    lea     bp,operandos    ;carrega em bp o vetor de operandos
    mov     al,lin      ;carrega em ax o número de linhas para poder fazer verificações
    mov     ah,0

;confere se os operandos estão corretos (dentro dos limites)
    cmp     word ptr[bp],ax
    ja      erroOperandos2

    cmp     word ptr[bp],1
    jae     calculaMultiplica

erroOperandos2:
    ;se estão errados, imprime mensagem informando
    lea     bx,mensagem8
    call    printf
    stc     ;seta flag de carry indicando que houve erro
    jmp short   fim_multiplica

 ;como a linha máxima é 7, realizarei uma multiplicação de 8 bits
calculaMultiplica:
    ;move para al o número da linha a ser multiplicada
    mov     ax,[bp]
    ;transforma ax para uma forma 0-indexada
    dec     ax
    mov     ch,col     ;move para ch o número de colunas

    ;calcula o indice na matriz da linha a ser multiplicada
    ;ax = ch x al
    mul     ch
    ;multiplica ax por 2, pois precisamos do indice em word
    shl     ax,1
    ;salva o indice da linha
    mov     si,ax

    lea     bx,matriz   ;carrega o ponteiro da matriz em bx
    mov     cl,col      ;carrega em cx o número de colunas para o loop
    mov     ch,0
    
loop_multiplica:    
    mov     ax,[bx+si]  ;carrega em ax o número da matriz a ser multiplicado
    mov     dx,[bp+2]   ;carrega a constante em dx
    imul    dx

    ;verificação de estouro
    ;verfica o sinal do número
    cmp    dx,0
    jl     estouroNegativo      ;se for menor que 0 realiza uma verificação para o caso de número negativo

    jne    estouro_multiplica   ;se dx for diferente de 0 e o número for positivo, houve estouro
    jmp short   prox_multiplica ;se não houve estouro, vai para o próximo elemento

estouroNegativo:
    cmp    dx,-1            ;se o número for negativo e dx for diferente de -1, houve estouro
    jne     estouro_multiplica

prox_multiplica:
    
    mov     word ptr[bx+si],ax  ;salva o resultado na matriz
    add     si,2                ;vai para o próximo elemento
    loop    loop_multiplica

    clc     ;limpa flag de carry, indicando que ocorreu corretamente
    jmp short fim_multiplica

estouro_multiplica:
    ;se houve estouro na multiplicação, desfaz a operação e imprime mensagem de erro
    call    undo
    lea     bx,mensagem11
    call    printf
    stc     ;seta flag de carry, indicando que houve erro

fim_multiplica:
    ret
multiplica endp

;===================
;ADICIONA
;===================
;Objetivo: dadas duas linhas da matriz, soma uma linha a outra na matriz
;===================
adiciona proc near
    ;separa os operandos da entrada
    call    separaOperandos
    jc      fim_adiciona

    ;salva a matriz de antes da operação
    call    salvaMatriz


    lea     bp,operandos    ;carrega em bp o vetor de operandos
    mov     al,lin      ;carrega em ax o número de linhas para poder fazer verificações
    mov     ah,0

;confere se as linhas informadas existem
    cmp     word ptr[bp],ax
    ja      erroOperandos

    cmp     word ptr[bp],1
    jb     erroOperandos

    cmp     word ptr[bp+2],ax
    ja      erroOperandos

    cmp     word ptr[bp+2],1
    jae     calculaAdiciona

erroOperandos:
    ;se as linhas não existem na matriz, imprime mensagem de erro
    lea     bx,mensagem8
    call    printf
    stc     ;seta flag de carry par indicar erro
    jmp short   fim_adiciona

    ;como a linha máxima é 7, realizarei uma multiplicação de 8 bits
calculaAdiciona:
    ;move para al o número da linha de origem
    mov     ax,[bp]
    ;transforma ax para uma forma 0-indexada
    dec     ax
    mov     ch,col     ;move para ch o número de colunas

    ;calcula o indice na matriz da linha de origem
    ;ax = ch x al
    mul     ch
    ;multiplica ax por 2, pois precisamos do indice em word
    shl     ax,1
    ;salva o indice de origem
    mov     si,ax


    ;move para ax o número da linha de destino
    mov     ax,[bp+2]
    ;transforma ax para uma forma 0-indexada
    dec     ax
    mov     ch,col     ;move para cx o número de colunas

    ;calcula o indice na matriz da linha de destino
    ;ax = ch x al
    mul     ch
    ;multiplica ax por 2, pois precisamos do indice em word
    shl     ax,1
    ;salva o indice de destino
    mov     di,ax

    ;carrega em bx o ponteiro da matriz
    lea     bx,matriz
    mov     cl,col  ;carrega em cx o número de colunas
    mov     ch,0

loop_adiciona:

    ;adiciona um elemento ao outro
    mov     ax,[bx+di]
    add     ax,[bx+si]
    ;verifica se houve estouro de representação
    jo      estouro_adiciona

    ;se não houve estouro, armazena na matriz
    mov     word ptr[bx+di],ax
    ;vai para o proximo elemento de ambas as linhas da matriz
    add     di,2
    add     si,2
    loop    loop_adiciona

    clc     ;limpa flag de carry, indicando que ocorreu corretamente
    jmp short   fim_adiciona

estouro_adiciona:
    ;se deu estouro, desfaz a operação e imprime mensagem de erro
    call    undo
    lea     bx,mensagem11
    call    printf
    stc     ;seta flag de carry para indicar erro

fim_adiciona:
    ret
adiciona endp

;===================
;SEPARA OPERANDOS
;===================
;Objetivo: separa os operando da string de entrada em duas variáveis diferentes
;Entrada: Word
;   (BX) - ponteiro da string de entrada
;Saida: Word Word Bit
;   Operando1
;   Operando2
;   (CF) - 0 se houve um erro, 1 se estão corretos
;===================
separaOperandos proc near
    ;copia o ponteiro da string para bp
    mov     bp,bx
    ;começa no 3 elemento da string, pois as duas operações que contém dois operandos são ADD e MUL
    add     bp,3

    ;carrega em bx a string auxiliar para ajudar a montar os operandos
    lea     bx,stringAux

    ;inicializa a string do operando no elemento 0
    mov     si,0
    ;incializa os operandos no indice 0
    mov     di,0

    ;compara se há um espaçamento entre o comando e os operandos
    cmp     byte ptr[bp],' '
    jne     operandosMalFormatados

loop_separaOperandos:
    ;incrementa o ponteiro da string
    inc     bp

    ;enquanto a entrada não tiver terminado
    cmp     byte ptr[bp],0
    je      ultimoOperando

    ;compara com espaço
    cmp     byte ptr[bp],' '
    je      salvaOperando   ;armazena o operando quando encontra espaçamento

    ;compara com sinal negativo
    cmp     byte ptr[bp],'-'
    je      insereString    ;insere na string

    ;confere se é um dígito
    cmp     byte ptr[bp],'0'
    jb      operandosMalFormatados

    cmp     byte ptr[bp],'9'
    ja      operandosMalFormatados

insereString:
    ;confere se a string excedeu o limite de caracteres
    cmp     si,6
    je      estouroOperando

    ;se não excedeu o limite, insere na string
    mov     al,[bp]
    mov     byte ptr[bx+si],al
    inc     si
    jmp short    loop_separaOperandos

salvaOperando:
    ;se di for maior que 2, ha mais operandos que o necessário
    cmp     di,2
    jg      numeroIncorretoOperandos

    ;transforma para inteiro
    mov     byte ptr[bx+si],0   ;coloca \0 na string
    call    atoi
    jc     estouroOperando  ;se deu estouro, coloca mensagem na tela informando

    ;se não deu estouro, salva o operando
    push    bp  ;salva bp na pilha
    lea     bp,operandos
    mov     [bp+di],bx
    add     di,2
    mov     si,0
    pop     bp  ;retorna bp da pilha

    ;verifico se é o último operando (final da string), se sim, finaliza a função
    cmp     byte ptr[bp],0
    je      operandoBemFormatados

    jmp short   loop_separaOperandos

ultimoOperando:
    ;se di for igual a 2, ainda pode estar faltando o último operando
    cmp     di,2
    jne     verificaOperandos

    ;verifica se si ainda está no elemento 0, se for 0, não havia segundo operando
    cmp     si,0
    jne     salvaOperando

verificaOperandos:
    ;se di for igual a 4, ambos operandos já foram informados
    cmp     di,4
    je      operandoBemFormatados

numeroIncorretoOperandos:
    ;se estão faltando operandos, imprime mensagem de erro informando
    lea     bx,mensagem9
    call    printf
    stc     ;seta CF, informando que o número de operandos está incorreto
    jmp short   fim_separaOperandos

operandosMalFormatados:
    ;se os operandos estão mal-formatados, imprime mensagem de erro informando
    lea     bx,mensagem8
    call    printf
    stc     ;seta flag de carry, informando que operandos estão mal formatados
    jmp short   fim_separaOperandos

estouroOperando:
    ;se houve estouro de representação, imprime mensagem de erro informando
    lea     bx,mensagem10
    call    printf
    stc     ;seta CF, informando erro
    jmp short   fim_separaOperandos

operandoBemFormatados:
    clc     ;limpa CF informando que os operandos estão ok

fim_separaOperandos:
    ret
separaOperandos endp

;===================
;SALVA MATRIZ
;===================
;Objetivo: salvar a matriz da última operação
;===================
salvaMatriz proc near
    ;incializa es = ds
    mov     ax,ds
    mov     es,ax

    ;carrega o endereço das matrizes
    lea     si,matriz
    lea     di,matrizAux

    ;contabiliza o número de elementos a serem tranferidos
    mov     cl,lin
    mov     al,col
    mul     cl
    mov     cx,ax

    cld ;limpa a DF para incrementar di e si

    mov     ch,0

    ;copia todos elementos da matriz para a matriz auxiliar
    rep movsw

    ret

salvaMatriz endp

;===================
;UNDO
;===================
;Objetivo: desfazer a última operação
;===================
undo proc near
    ;incializa es = ds
    mov     ax,ds
    mov     es,ax

    ;carrega o endereço das matrizes
    lea     si,matrizAux
    lea     di,matriz

    ;contabiliza o número de elementos a serem tranferidos
    mov     cl,lin
    mov     al,col
    mul     cl
    mov     cx,ax

    cld ;limpa a DF para incrementar di e si

    mov     ch,0

    ;copia todos elementos da matriz auxiliar para a principal
    rep movsw

    ret
undo endp

;===================
;LE ARQUIVO
;===================
;Objetivo: ler o arquivo e montar a matriz
;saída: Bit
;   (CF) - 0 se está tudo correto, 1 se ocorreu erro
;===================
leArquivo  proc near
        
    ;abre o arquivo
    lea     bx,nomeArq
    call    fopen
    jc      fimLeArquivo

    mov     index,0        ;inicializa o índice da matriz em 0
    mov     lin,0          ;inicializa contagem de linhas em 0
    mov     col,0          ;inicializa contagem das colunas em 0
    mov     colAnterior,0   ;inicializa varíavel auxiliar das colunas em 0
    mov     si,0              ;inicializa si em 0

    ;realiza leitura do arquivo
loopLeArquivo:
    ;le 1 caractere do arquivo
    mov     ah,3FH
    mov     bx,handle
    mov     cx,1
    lea     dx,bufferArq
    int     21H

    ;se ax = 0, o arquivo acabou
    or      ax,ax
    jz      fimLoopLeArq

    ;se ax != 0, interpreta o arquivo
    call    interpretaArq
    jc      fechaArquivo

    jmp short   loopLeArquivo

fimLoopLeArq:
    ;confere se ainda há um elemento a ser adicionado na matriz
    cmp     si,0
    je     confereNCOlunas

    ;se ainda possui, adiciona o elemento
    lea     bx,stringAux
    call    salvaNaMatriz
    jc      fechaArquivo

    inc     lin ;incrementa a contagem de linhas

    ;confere se o número de colunas está correto
    call    confereColuna
    jc      fimInterpretaArq

confereNCOlunas:
    ;confere se o número de linhas e colunas seguem as especificações do trabalho
    ;como o número de colunas pode ser zerado na última leitura, movemos o valor salvado em colAnterior para col
    mov     al,colAnterior
    mov     col,al
    call    confereLinha

fechaArquivo:
    ;fecha o arquivo
    pushf   ;guarda as flags na pilha para poder controlar o sucesso ou não da função
    call    fclose  ;fecha o arquivo
    jc      fimLeArquivo

fimLeArquivo:
    popf   ;retorna as flags da pilha
    ret

leArquivo endp

;===================
;INTERPRETA ARQ
;===================
;Objetivo: interpretar uma string lida do arquivo, montando a matriz
;saída: Bit
;   (CF) - 0 se está tudo correto, 1 se ocorreu erro ao montar a matriz
;===================
interpretaArq proc near

    ;coloca em cx o caractere lido
    lea     bx,bufferArq
    mov     cl,[bx]

    lea     bx,stringAux    ;carrega em bx a string aux para auxiliar a montar o número

    ;confere se é ';'
    cmp     cl,';'
    jz      guardaMatriz

    ;confere se chegou ao final da linha (como CR e LF aparecem juntos, se for CR já indico como final de linha)
    cmp     cl,13      ;compara com CR
    jz     CR

    ;confere se é LF e ignora, indo para a próxima linha
    cmp     cl,10      ;compara com LF
    jz     fimInterpretaArqSErro   ;se for LF, encerra a função

    ;se for um caractere normal, insere na string
    mov     byte ptr[bx+si],cl ;coloca o caractere na string
    ;incrementa os ponteiro da string
    inc     si
    jmp short   fimInterpretaArqSErro       ;encerra a função

CR:
    cmp     si,0                    ;se si for 0, era uma linha em branco
    jz      fimInterpretaArqSErro

    ;salva o elemento na matriz
    call    salvaNaMatriz
    jc      fimInterpretaArq

    ;incrementa a contagem de linhas
    inc     lin

    ;confere se o número de colunas está correto
    call    confereColuna
    jc      fimInterpretaArq
    ;zera as colunas
    mov     col,0
    jmp short   fimInterpretaArqSErro

guardaMatriz:
    ;salva o elemento na matriz
    call    salvaNaMatriz
    jc      fimInterpretaArq

fimInterpretaArqSErro:
   clc     ;limpa flag de carry, informando que está correto

fimInterpretaArq:
    ret

interpretaArq endp

;===================
;SALVA NA MATRIZ
;===================
;Objetivo: dada uma string numérica, salva como um elemento da matriz
;Entrada: Word Word
;   (BX) - ponteiro da string
;   (SI) - elemento atual da string
;saída: Bit
;   (CF) - 0 se está tudo correto, 1 se ocorreu erro ao montar a matriz
;===================
salvaNaMatriz proc near
 
    ;salva bp, pois é utilizado na função
    push    bp

    mov     byte ptr[bx+si],0   ;finaliza a string com \0
    call    atoi            ;transforma em inteiro
    jc      estouroMatriz       ;se deu estouro, finaliza a função com mensagem de erro

    ;coloca o elemento numérico na matriz
    lea     bp,matriz
    add     bp,index
    mov     [bp],bx
    
    inc     col     ;incrementa a contagem de colunas

    add     index,2           ;incrementa o indice
    mov     si,0            ;zera si, para montar o próximo elemento

    clc     ;limpa flag de carry, indicando que não houve erro
    jmp short   fim_salvaNaMatriz
    

estouroMatriz:
 ;imprime mensagem de erro, informando a linha e coluna da matriz onde ocorreu o estouro
    lea     bx,mensagem6
    call    printf

    ;estava no modo 0-indexado, passa para o modo 1-indexado
    mov     al,lin
    inc     al
    mov     ah,0
    lea     bx,stringAux
    call    numAscii
    call    printf

    lea     bx,mensagem7
    call    printf

    mov     al,col
    inc     al
    mov     ah,0
    lea     bx,stringAux
    call    numAscii
    call    printf

    lea     bx,CRLF
    call    printf  

    stc     ;seta flag de carry e encerra função

fim_salvaNaMatriz:
    pop     bp  ;retorna bp
    ret

salvaNaMatriz endp

;===================
;CONFERE LINHA
;===================
;Objetivo: confere se o número de linhas e colunas segue as regras
;Saída:  Bit
;   (CF) - 0 se está correto, 1 se houve uma violação
;===================
confereLinha proc near
    ;confere se o número de linhas é maior ou igual a 2
    cmp     lin,2
    jb     matrizInvalida  ;se for menor que 2 é invalida

confere1:
    cmp     lin,7
    ja     matrizInvalida   ;se número de linhas > 7

confere2:
    ;coloco em al o número de colunas e subtraio 1
    mov     al,col
    dec     al
    cmp     al,lin  ;comparo se lin = col -1 (ou seja se col é n+1)
    jnz      matrizInvalida

    clc     ;limpa flag de carry, informando que não houve erro
    jmp short   fimConfereLinha

matrizInvalida:
    ;imprime mensagem de erro
    lea     bx,mensagem1
    call    printf
    stc     ;seta a flag de carry, indicando que houve erro

fimConfereLinha:
    ret

confereLinha endp

;===================
;FOPEN
;===================
;Objetivo: abrir um arquivo
;Entrada: Word
;   (BX) - ponteiro para string do nome do arquivo
;Saída:  Bit
;   (CF) - 0 se o arquivo foi aberto, 1 se houve problema ao abrir
;===================
fopen proc near

    ;abre o arquivo
    mov     dx,bx
    mov     ah,3DH  
    mov     al,0
    int     21H

    ;se houve problema ao abrir o arquivo, finaliza a função e retorna com CF = 1
    jc     erro_abrir

    ;se não houve problema
    mov     handle,ax   ;salva o handle do arquivo 

    jmp short   fim_fopen

erro_abrir:
    lea     bx,mensagem4
    call    printf 
    stc     ;seta carry flag, informando que houve erro   

fim_fopen:
    ret
fopen endp

;===================
;FCLOSE
;===================
;Objetivo: fechar um arquivo
;Saída:  Bit
;   (CF) - 0 se o arquivo foi fechado, 1 se houve problema ao fechar
;===================
fclose proc near

    ;fecha o arquivo
    mov     ah,3EH
    mov     bx,handle
    int     21H

    jnc     fim_fclose

    ;se CF = 1, houve erro, imprime mensagem de erro
    lea     bx,mensagem5
    call    printf
    stc     ;seta carry flag, informando que houve erro

fim_fclose:
    ret
fclose endp

;===================
;CONFERE COLUNA
;===================
;Objetivo: confere se o número de colunas está correto
;Saída:  Bit
;   (CF) - 0 se está correto, 1 se houve uma violação
;===================
confereColuna proc near
    
    ;confere se colAnterior ainda não foi incializado
    mov     al,colAnterior
    or      al,al
    jnz     comparaColuna       ;se não for 0, compara o número de colunas atual com o número anterior

    ;se for 0, inicializa colAnterior e encerra a função
    mov     al,col
    mov     colAnterior,al
    jmp short   fim_confereColuna

comparaColuna:
    ;compara o número de colunas atual com o anterior
    cmp     al,col
    jnz     erroColuna     ;se forem diferentes, uma das colunas possui número diferente de elementos

    ;se forem iguais
    mov     al,col ;guarda o valor de colunas da linha atual 
    mov     colAnterior,al
    clc     ;limpa CF, indicando que não houve violação 
    jmp short   fim_confereColuna

erroColuna:
    ;imprime mensagem informando erro, indicando em que linha da matriz houve erro
    lea     bx,mensagem2
    call    printf

    mov     al,lin
    mov     ah,0
    lea     bx,stringAux
    call    numAscii

    call    printf

    lea     bx,CRLF
    call    printf

    stc     ;seta flag de carry, indicando que houve erro

fim_confereColuna:
    ret

confereColuna endp

;===================
;WRITE
;===================
;Objetivo: escrever a matriz em um arquivo
;===================
write proc near

    ;realiza a leitura do nome do arquivo de saida
    call    separaNomeArq
    jc      fim_write

    ;abre o arquivo
    call    fopenWrite
    jc      fim_write

    ;carrega em cx a matriz no elemento 0
    lea     bx,matriz
    mov     si,0

    ;carrega o número de linhas em cx para o loop
    mov     cl,lin
    mov     ch,0

loop_linhaWrite:
    ;carrega em dx o número de colunas
    mov     dl,col
    mov     dh,0

loop_colunaWrite:
    ;salva registradores na pilha
    push    si
    push    dx
    push    cx
    push    bx

    ;transforma o número atual em ascii
    mov     ax,[bx+si]
    lea     bx,stringAux
    call    numAscii

    call    strlen  ;cx contém o número de caracteres a serem escritos

    ;escreve a string no arquivo
    mov     dx,bx
    mov     bx,handle
    mov     ah,40H
    int     21H
    jc      erroWrite

    ;retorna registradores da pilha
    pop     bx
    pop     cx
    pop     dx
    pop     si

    add     si,2        ;move o ponteiro para o próximo elemento da matriz

    dec     dx
    jz      proximaLinhaWrite

    ;salva registradores e imprime o ;
    push    dx
    push    cx
    push    bx

    ;imprime ;
    mov     cx,1
    lea     dx,pontoVirgula     
    mov     bx,handle
    mov     ah,40H
    int     21H
    jc      erroWrite

    pop     bx
    pop     cx
    pop     dx
    jmp short   loop_colunaWrite

proximaLinhaWrite:

    ;salva registradores e imprime o CRLF
    push    dx
    push    cx
    push    bx

    mov     cx,2
    lea     dx,CRLF
    mov     bx,handle
    mov     ah,40H
    int     21H
    jc      erroWrite

    pop     bx
    pop     cx
    pop     dx
    loop    loop_linhaWrite

    jmp short   fechaArquivoWrite

erroWrite:
    lea     bx,mensagem12
    call    printf

fechaArquivoWrite:
    call    fclose

fim_write:
    ret

write endp

;===================
;FOPEN WRITE
;===================
;Objetivo: abrir um arquivo para escrita e mover a escrita para o final do arquivo
;Saida:
;   (CF) - 0 se abriu corretamente, 1 se houve erro ao abrir
;===================
fopenWrite proc near


    ;abre o arquivo no modo de escrita
    mov     ah,3DH
    mov     al,2
    lea     dx,arqEntrada
    int     21H
    jc      erro_abrirEscrita

    mov     handle,ax   ;salva o handle do arquivo

    ;move o cursor de escrita para o final
    mov     ah,42H
    mov     al,2
    mov     dx,0
    mov     cx,0
    mov     bx,handle
    int     21H

    clc     ;limpa CF, indicando que abriu corretamente
    jmp short   fim_fopenWrite

erro_abrirEscrita:
    ;se ocorreu erro ao abrir o arquivo, é porque o arquivo não existe
    ;cria o arquivo
    mov     ah,3CH
    mov     cx,0
    ;dx já possui a string do nome do arquivo
    int     21H
    jc      erro_criaArq

    mov     handle,ax   ;salva o handle do arquivo
    clc     ;limpa CF, indicando que abriu corretamente
    jmp short   fim_fopenWrite

erro_criaArq:
    ;se houve erro ao criar o arquivo, imprime mensagem indicando o erro
    lea     bx,mensagem14
    call    printf
    stc     ;seta flag de carry, indicando que houve erro

fim_fopenWrite:
    ret
fopenWrite endp

;===================
;SEPARA NOME ARQ
;===================
;Objetivo: separar o nome do arquivo para realizar a escrita
;Saida:
;   (CF) - 0 occoreu corretamente, 1 se ocorreu um problema
;===================
separaNomeArq proc near

    ;carrega em bx a string de entrada para utilizar a função strlen
    lea     bx,entrada
    call    strlen  ;cx possui o tamanho da string

    ;se o tamanho da string for menor ou igual a 6, estão faltando argumentos
    cmp     cx,6
    jbe     erro_nome

    ;se o número de argumentos está correto
    lea     si,entrada      ;inicializa o ponteiro das strings para usar movsb
    lea     di,arqEntrada
    add     si,6            ;inicia a string de entrada no 7 elemento
    ;inicializa es para poder utilizar movsb
    mov     ax,ds
    mov     es,ax

    jmp short   separaNome

erro_nome:
    ;se o nome do arquivo não foi informado, imprime mensagem de erro
    lea     bx,mensagem13
    call    printf
    stc     ;seta CF, indicando que houve um problema
    jmp short   fim_separaNomeArq

separaNome:
    rep movsb   ;copia os elementos da entrada para a string do nome do arquivo

fim_separaNomeArq:
    ret

separaNomeArq endp

    end