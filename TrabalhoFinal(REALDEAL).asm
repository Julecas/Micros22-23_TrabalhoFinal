; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "returning in ( )s press any key..",0AH,0DH,0
    str_bemVindo db "Bem vindo",0 
    str_jogar db "Jogar",0
    str_exemplos db "Exemplos",0
    str_retomar db "Retomar",0
    str_top5 db "TOP 5",0
    str_creditos db "creditos",0
    str_sair db "Sair",0
    str_julio db "Julio Lopes n 62633",0AH,0DH,0 
    str_martim db "Martim Agostinho n 62964",0 
    str_error_create db "falha ao criar ficheiro",0   
    str_error_close db "falha ao fechar ficheiro",0
    str_error_open db "falha ao abrir ficheiro",0 
    str_error_write db "falha ao escrever no ficheiro",0
    str_error_read db "falha ao ler do ficheiro",0
    fileName db "c:\gameOfLife\TOP5.txt",0 
    str_rodapeTop5 db "GEN  CELLS  PLAYER      DATE     TIME",0AH,0DH,0
    str_read db 20 dup(?) ;buffer de leitura
    Status_str db "Geracao:0000 Celulas:0000 Iniciar Sair",0  
    num_str db 5 dup(0)
    matriz_cell db 15360 dup(0) ; (320)/2 * (200 - 8)/2 
    matrizY dw 0
    matrizX dw 0  
    lado_cell db 0              ;NAO MEXER , so se mexe no fator de res      
    gen_num dw 0    
    cell_num dw 0    
    fator_res db 2              ;Depois de mexer aqui chamar funcao init_matriz_dim
    rato_preso db 0             ;Verdadeiro =>1 Falso == 1(define a opcao mouse release)
   
    handler dw ? 
    
    VlineFile equ 6                          
    
    CellColor equ 15
    GENnCHAR equ 8                  ;Nao ocupam memoria :^)
    CELLnCHAR equ 21
    NDigitos equ 4      ;Numero de digitos para os numeros 
    CHARDIM equ 8
    BRANCO equ 15
    ECRAY equ 200
    ECRAX equ 320 
    HposRectLeft equ 60; Coluna do canto superior esquerdo dos quadrados da esquerda do menu 
    HposRectRight equ 180; Coluna do canto superior esquerdo dos quadrados da direita do menu
    VlenghtRect equ 20 ; tamanho vertical dos quadrados do menu 
    HlenghtRect equ 80 ; tamanho horizontal dos quadrados do menu
    
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    ;MAIN
   
    main_loop:
    
    call set_video 
    
    call printMenu 
    
    call select_op 
    
    jmp main_loop
   
    
    
   
   
    
    ; add your code here
            
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
    
    ;ROTINAS 
    
    ;Lado do quadrado de cada ponto da matrix
    ;inicio onde escreve
    ;Dx     = Linha
    ;Cx     = Coluna
    ;Bx     = Lado quadrado
    ;si     = offsest matrix
    ;precisa de receber valores compativeis
    print_matriz proc
                          
        push bx
        push ax
        
        mov al , CellColor
        
        loop1_ptrmtr:
            
                ;mov al,[si]             ;cor = valor na matriz, talvez trocar isto no futuro
                
                or [si],0
                jz if1_ptrmtr

                    call print_quadrado            
                
                jmp endif1_ptrmtr
                if1_ptrmtr:
                    add cx , bx     ; proxima posicao
                
                endif1_ptrmtr:
                
                inc si
                
                cmp cx , ECRAX            ;ate ao fim do ecra     
            
            jb loop1_ptrmtr
            
            xor cx , cx         ;cx = 0
            add dx , bx         ;proxima linha
            cmp dx , ECRAY
        jb loop1_ptrmtr
            
        pop ax    
        pop bx            
        ret 
    endp
    
    ;matem dx e deixa cx na proxima posicao (Cx(inicial) + (Lado quadrado))
    ;dx = linhas
    ;cx = colunas
    ;al = cor
    ;bx = largura
    print_quadrado proc

        push bp
        
        mov bp,sp
        sub bp,2    ;aponta para a largura do quadrado
        
        push bx
        
        xor bx,bx ;bx = 0
        
        mov ah, 0ch
        
        lp_prtqd:
            lp2_prtqd:   ;TODO TIRAR UMAS DA LABELS
                
                int 10h 
                inc bh
                inc dx
                cmp bh,[bp]
            jb lp2_prtqd
            inc cx
            sub dx,[bp]
            xor bh,bh
            inc bl 
            
        cmp bl,[bp]
        jb lp_prtqd       
        
        pop bx               
        pop bp
        ret
    endp
        
    ;para o programa ate receber keypress    
    wait_key_press proc
       
        push ax
               
        mov ah, 1
        int 21h
           
        pop ax
        ret
        
    endp 
     game_loop proc
        
        push cx 
        
        xor cx , cx  
        mov dx , CHARDIM
        xor bh , bh 
        mov Bl , lado_cell
        mov si , offset matriz_cell  
        call print_matriz
        mov di , offset matriz_cell  
        mov gen_num , 0  
        
        loop1_gl: 
            
            call set_video ;limpar o ecra
            
            call print_status
            
            xor cx , cx  
            mov dx , CHARDIM
            xor bh , bh 
            mov Bl , lado_cell
            mov si , offset matriz_cell  
            call print_matriz  
            
            call prox_gen
            
            call wait_key_press ;temporario ? 
            
            inc gen_num
            
        or ax , ax     
        jnz loop1_gl  
        
        pop cx
        ret
    endp 
    
    ;di = offset matriz com gen(n+1)  
    ;Ax = quantas celulas mudaram de posicao nesta geracao
    ;precisa de ter gen(n) desenhada no ecra
    prox_gen proc
        
        push bp      ;[bp - 2] -> aponta para a rate of change das celulas
        mov bp , sp
        sub sp , 2             
        mov word ptr [bp - 2] , 0
        
        push dx
        push cx
        push bx
        push si
        push di
        
        mov si , di 
        
        xor ax , ax
        mov al , lado_cell 
        
        xor cx , cx 
        mov dx , CHARDIM 
          
        loop1_pgen:
                  
                call cell_status                                 
                
                ;se = 0 nao faz nada
                ;else if = 1 morre
                ;else criar uma celula
                
                or  bl , bl             ;outcome mais provavel   
                jz endif_pgen
                
                    cmp bl , 1          ;celula morre
                    jne if1_pgen
                        mov [di] , 0 
                        dec cell_num  
                        inc [bp - 2]
                        jmp endif_pgen             
                    
                if1_pgen:               ;criar celula
                    mov [di] , 1  
                    inc [bp - 2]
                    inc cell_num
                    
                endif_pgen:
            inc di
            add cx , ax
            cmp cx , ECRAX ;- lado_cell
            jb loop1_pgen 
            
            xor cx , cx    
            add dx , ax
            cmp dx , ECRAY
        jb loop1_pgen
        
        call set_video      ;limpar o ecra
        call print_status
        
        mov dx , CHARDIM 
        xor cx , cx
        mov bx , ax
        call print_matriz    
        
        mov ax , [bp - 2]
        pop di
        pop si
        pop bx
        pop cx
        pop dx
        
        add sp , 2;variavel local
        pop bp
        ret
                              
    endp        
    
    
    ;dx = Linha
    ;cx = Coluna 
    ;Bl = resultado , 0 -> nao muda; 1 -> cell morre; 2 -> cell criada
    ;posicao do pixel do canto superior esquerdo da celula
    cell_status proc
        
                      ;[bp - 2] -> numero de vizinhos
                      ;[bp - 4] -> lado_cell
        push bp       ;[bp - 6] -> posx max vizinho na matriz
        mov bp , sp   ;[bp - 8] -> estado inicial da celula 
                      
        sub sp , 8    ;guardar espaco na stack para as variaveis
        
        push ax
        push cx
        push dx
        
        xor ax , ax
        mov [bp - 2] , ax
        mov [bp - 8] , ax
        mov bl , 11111111b   ;comeco a poder ler todos os vizinhos 
        mov al , lado_cell 
        mov [bp - 4], ax  
        
        mov [bp - 6] , cx        ;limite horizontal
        add [bp - 6] , ax        ; ax = [bp - 4] = lado_cell            
        
        cmp dx , CHARDIM        ;ver se esta no lado de cima
        jne if1_cst
            and bl , 00011111b  ;nao le nenhuma das posicoes de cima
        if1_cst:
        
        or cx , cx              ;Ve se esta no lado esquerdo
        jnz if2_cst
            and bl , 01101011b
        if2_cst: 
        
        add dx , ax      ;porque a posicao dx,cx esta no canto superior esquerdo do quadrado da celula
        cmp dx , ECRAY
        jne if3_cst
            and bl , 11111000b  ;Ve se esta na ultima linha
        if3_cst:
        
        add cx , ax
        cmp cx , ECRAX
        jne if4_cst
            and bl , 11010110b  ;Ve se esta no lado direito
        if4_cst:
        ;end verificar cantos
        
        mov bh , 10000000b
        
        mov ah , 0Dh
        
        pop dx
        pop cx
        sub sp , 2          ;Mantem cx na stack
        
        int 10h
        mov [bp - 7] , al
        
        sub dx , [bp - 4]  ;(-1,-1)
        sub cx , [bp - 4]  ;[bp - 4] -> lado da celula
        
        loop1_cst:      
        
                test bh , bl     ;para saber se ]e para ler aquela posicao
                jz if5_cst:            
                    
                    int 10h     ;ler a cor do pixel
                    or al , al  ;saber se a cor do pixel ]e preto ou nao
                    jz if5_cst
                        inc [bp - 2] ;-> numero de vizinhos
                        
                if5_cst:
                
                shr bh , 1          ;testar o proximo bit
                add cx , [bp - 4]      
                cmp cx , [bp - 6]   ;saber se chegou ao limite
            jbe  loop1_cst
            
            pop cx 
            sub sp , 2              ;mantem cx na stack
            sub cx , [bp - 4]
            
            cmp bh , 00010000b      ;se bh = 00100000b entao estou na primeira linha(mais facil de vizualizar com o excel)
            jb fimloop_cst
            
                mov bh , 00000100b 
                
                add dx , [bp - 4]       ;para ler as linhas por baixo da celula
                add dx , [bp - 4]
 
            jmp loop1_cst 
            
        fimloop_cst:
        ;Linhas da celula sao um caso especial por causa da propria celula
            mov bh , 00010000b 
            
            sub dx , [bp - 4]
            
            loop2_cst:
                test bh , bl
                
                jz if6_cst:    
                        
                    int 10h     ;ler a cor do pixel
                    or al , al  ;saber se a cor do pixel ]e preto ou nao
                    jz if6_cst
                        inc [bp - 2] ;-> numero de vizinhos
                        
            if6_cst:
            
            cmp bh , 00010000b
            jne endlp2_cst
                shr bh ,1
                add cx , [bp - 4]       ;para ler a coluna a direita da celula
                add cx , [bp - 4]
                jmp loop2_cst 
                    
        endlp2_cst:
        
        ;Decide estado da celula 
        cmp word ptr [bp - 8], 0
        jne if7_cst
            
            cmp word ptr [bp - 2] , 3    ;se a celula estiver morta ve se tem 3 vizinhos
            jne if9_cst
                mov bl , 2
                jmp fim_cst
                
        if7_cst:
        
        cmp word ptr [bp - 2] , 2        ;se estiver viva ve se tem entre 2 e 3 vizinhos
        jb if8_csft
            cmp word ptr [bp - 2] , 3
            ja if8_csft
                if9_cst: 
                xor bl , bl;ser diferente para criar ou manter poupa ciclos
                jmp fim_cst
            
        if8_csft:
        
        mov bl , 1
        
        fim_cst:
        
        pop cx
        pop ax 
        
        add sp , 8  ;variaveis locais(4*8)
        pop bp 
        ret
    endp
    
    ;escreve num vetor o estado do ecra
    ;di = offset da matriz
    load_matriz proc
               
        push ax
        push cx
        push dx 
        push bx
        
        xor bx , bx
        mov bl , lado_cell
        
        xor cx , cx 
        mov dx , CHARDIM 
        mov ah , 0dh    ;interrupt
        
        lp1_ldmtr:
            
            int 10h 
            
            mov [di] , al  
            
            inc di
            add cx , bx
            cmp cx , ECRAX
            jb lp1_ldmtr 
            
            xor cx , cx
            add dx , bx
            cmp dx , ECRAY
        
        jb lp1_ldmtr 
        
        pop bx
        pop dx
        pop cx
        pop ax
        ret
    endp
    
    ;di = offsett de matriz para guardar
    fill_matriz proc
        
        push cx 
        push dx
        push ax
        push bx
        
        xor ax , ax   
        xor bx , bx
        not ax      ; bx = FFFFh
        
        xor cx , cx
        mov cl , fator_res 

        shr ax , cl
        shl ax , cl ;fica com 0 nos bits que eu nao quero ler, 
        
        loop1_fmtr:
            
            call gmp;get mouse pos
            
            push bx
            cmp bl , 1
            jne endif_fmtr
                
                cmp dx , CHARDIM
                jb endif_fmtr 
                
                    and cx , ax
                    and dx , ax        ;Isto torna o a posicao do rato num numero divisivel pelo lado_cell
                      
                    add dx , CHARDIM    ;se dx = 0 assim desenha o quadrado depois dos char
                    
                    push ax
                    
                    mov ah , 0dh
                    
                    int 10h
                    
                    or al , al 
                    jz if2_fmtr        ;se houver la uma celula  
                    
                        mov al , 0  
                        dec cell_num
                        jmp endif2_fmtr
                    
                    if2_fmtr:
                        mov al , CellColor
                        inc cell_num
                    endif2_fmtr:
                    
                    mov bl , lado_cell
                    call print_status
                    call print_quadrado
                    
                    call mouse_release
                    
                    pop ax
            endif_fmtr:
            
            pop bx           
            cmp bl , 2 ;TEMPORARIO usa botao 2 para sair
            je fim_fmtr:
        jmp loop1_fmtr
        fim_fmtr:  
        
        mov di , offset matriz_cell
        call load_matriz
        
        pop bx
        pop ax
        pop dx
        pop cx
        ret
        
    endp 
    
    ;mete nas variaves 
    ;matrizY/X os valores
    ;tendo em conta o lado do quadrado da celula 
    ;precisa de ser inicializado antes do jogo comecar
    init_matriz_dim proc
        
        push ax
        push cx
        
        mov cl , fator_res
        mov lado_cell , 1
        shl lado_cell , cl        ;o lado da celula vai ser 2^(fator_res)
        
        mov ax , ECRAY
        sub ax , CHARDIM
        div lado_cell
        
        mov matrizY , ax
        
        mov ax , ECRAx
        div lado_cell 
        
        mov matrizX , ax
        
        pop cx
        pop ax  
        ret
    endp
    
    print_status proc
        
        push ax
        push cx
        push dx
        push si
        push di
        push bx
        
        xor dx , dx   ;= 0
            
        mov AH , 2  ;cursor na posicao 0,0    
        mov bh , 0
        INT 10h
        
        mov si , offset status_str
        mov bl , 0
        call printf
        
                             ;nao tenho a certeza se e preciso
        mov dx , GENnCHAR    ; cursor nos numeros
        mov ah , 2
        mov bh , 0
        int 10h
        
        mov ax , gen_num
        mov cx , Ndigitos
        call print_int             
        
        mov dx , CELLnCHAR
        mov ah , 2
        mov bh , 0
        int 10h
        
        mov ax , cell_num
        mov cx , Ndigitos
        call print_int
        
        pop bx
        pop di
        pop si
        pop dx       
        pop cx
        pop ax 
        
        ret  
    endp
    ;*****************************************************************
    ; jogo 
    ; descricao: rotina que inicializa o jogo
    ; input - 
    ; output - 
    ; destroi - 
    ;*****************************************************************
    
    proc jogo
          
    push si
    push di
    push cx
    push dx
          
    call init_matriz_dim
   
    ;glider PARA TESTE
    mov si , offset matriz_cell
    add si , 4 
    
    call set_video
    
    call print_status 
    mov di , offset matriz_cell
    call fill_matriz
    
    xor cx , cx  
    mov dx , CHARDIM
    xor bh , bh 
    mov Bl , lado_cell
    mov si , offset matriz_cell
  
    call wait_key_press
    call game_loop
    
    ;call set_video
        
    push dx
    push cx
    push di
    push si
        
        ret
    endp jogo    
    
    ;*****************************************************************
    ; fcreate - file create
    ; descricao: rotina que cria um fi\cheiro
    ; input - dx - offset para o nome do ficheiro / cx- tipo de ficheiro 
    ; output - 
    ; destroi - 
    ;*****************************************************************
    
    proc fcreate
               
        mov ah, 3ch ;create file      
        int 21h 
        
        jnc fcreate_success ;salta se criar o ficheiro com sucesso
        
        mov si, offset str_error_create 
         
        ;parametros
        mov ax,0 ;0 impressao de strings \ 1 - impressao de inteiros
        mov bx,0 ;0 impressao normal \ 1 impressao em minusculas\ 2 impressao em maisculas\3 impressao com enter no final
        call printf
        
        fcreate_success:  
        
        mov handler, ax ; mover o handler do ficheiro para uma varaiavel global
        
        mov bx, ax ; colocar o handler em bx para fechar o ficheiro de seguida
        
        ;close file
        mov ah, 3eh ;close file
        int 21h
        
        jnc fcreateClose_success ;salta se fechar o ficheiro com sucesso 
        
        mov si, offset str_error_close  
        
        
        call printf
        
        fcreateClose_success:
        
        ret    
    endp fcreate
    ;*****************************************************************
    ; fopen - open file
    ; descricao: rotina que abre um ficheiro
    ; input - dx - offset para o nome do ficheiro \ al - tipo de leitura   
    ; output - 
    ; destroi - 
    ;*****************************************************************
    
    proc fopen
               
        mov ah, 3dh ; open file file      
        int 21h
        
        mov handler, ax 
        
        jnc fopen_success ;salta se criar o ficheiro com sucesso
        
        mov si, offset str_error_open 
        
        
        ;parametros
        mov ax,0 ;0 impressao de strings \ 1 - impressao de inteiros
        mov bx,0 ;0 impressao normal \ 1 impressao em minusculas\ 2 impressao em maisculas\3 impressao com enter no final
        call printf
        
        fopen_success:  
        
        ret    
    endp fclose 
    ;*****************************************************************
    ; fclose - close file
    ; descricao: rotina que fecha um ficheiro
    ; input - dx - offset para o nome do ficheiro \ bx - file handler   
    ; output - 
    ; destroi - 
    ;*****************************************************************
    proc fclose
        push ax
        push si
        push bx
        
        ;close file
        mov ah, 3eh ;close file
        int 21h
        
        jnc fclose_success ;salta se fechar o ficheiro com sucesso 
        
        mov si, offset str_error_close  
        
        ;parametros
        mov ax,0 ;0 impressao de strings \ 1 - impressao de inteiros
        mov bx,0 ;0 impressao normal \ 1 impressao em minusculas\ 2 impressao em maisculas\3 impressao com enter no final
        call printf
        
        fclose_success:
        
        pop bx
        pop si
        pop ax
        
        ret 
    endp fclose
    ;*****************************************************************
    ; fwrite - write file
    ; descricao: rotina que escreve para um ficheiro
    ; input - dx - offset para o nome do ficheiro \ bx - file handler \ cx - number of bytes to read  
    ; output - 
    ; destroi - 
    ;*****************************************************************
    proc fwrite
        ;close file
        mov ah, 40h ;close file
        int 21h
        
        jnc fwrite_success ;salta se fechar o ficheiro com sucesso 
        
        mov si, offset str_error_write  
        
        ;parametros
        mov ax,0 ;0 impressao de strings \ 1 - impressao de inteiros
        mov bx,0 ;0 impressao normal \ 1 impressao em minusculas\ 2 impressao em maisculas\3 impressao com enter no final
        call printf
        
        fwrite_success:
        
        ret 
    endp fwrite
    ;*****************************************************************
    ; fread - read file
    ; descricao: rotina que le um ficheiro para um buffer
    ; input - dx - offset para o nome do ficheiro \ bx - file handler \ cx - number of bytes to read  
    ; output - 
    ; destroi - 
    ;*****************************************************************
    proc fread
        push ax
        push bx
        
        ;close file
        mov ah, 3fh ;read file
        int 21h
        
        jnc fread_success ;salta se fechar o ficheiro com sucesso 
        
        mov si, offset str_error_read  
        
        ;parametros
        mov ax,0 ;0 impressao de strings \ 1 - impressao de inteiros
        mov bx,0 ;0 impressao normal \ 1 impressao em minusculas\ 2 impressao em maisculas\3 impressao com enter no final
        call printf
        
        fread_success:
        
        pop bx
        pop ax
        
        ret 
    endp fread
    ;*****************************************************************
    ; freadLine - read file line
    ; descricao: rotina que le uma linha de ficheiro para um buffer
    ; input -  bx - file handler \ cx:dx offset from origin of new, file position\ al 0,1,2 star of file,current file position,end of file (respetivamente)   
    ; output -  
    ; destroi - 
    ;*****************************************************************
    proc freadLine
        ;close file
        mov ah, 42h ;read file (seek)
        int 21h
        
        jnc freadLine_success ;salta se fechar o ficheiro com sucesso 
        
        mov si, offset str_error_read  
        
        ;parametros
        mov ax,0 ;0 impressao de strings \ 1 - impressao de inteiros
        mov bx,0 ;0 impressao normal \ 1 impressao em minusculas\ 2 impressao em maisculas\3 impressao com enter no final
        call printf
        
        freadLine_success:
        
        ret 
    endp freadLine 
    ;*****************************************************************
    ; top5 
    ; descricao: rotina que apresenta o top 5 jogadores
    ; input -  
    ; output - 
    ; destroi - ax 
    ;***************************************************************** 
    proc top5
        
        push bp 
        mov bp, sp
        
        push 6  ;[bp - 2] -> VlineFile
        
        
        push dx
        push ax
        push cx 
        
        
        call set_video ;clear screen 
        
        mov dl, 1
        mov dh, 4
        mov si, offset str_rodapeTop5
        call print_pos ;print str rodape do top 5   
        
        mov dx, offset fileName 
              
        mov al, 0      ;0 - read \ 1 - write \ 2 read/write  
        call fopen
        
        xor cx,cx;cx = 0
        
            
            readLoop:
             
            push cx
            
            ;parametros
           
            mov bx, handler
            mov dx, offset str_read
            mov cx, 3 ;number of bytes to read
            call fread
            
            mov di, dx
            add di, cx
            mov [di], 0
           
            
            mov dl, 1
            mov dh, [bp - 2]
            mov si, offset str_read ; buffer for data
            call print_pos ;print geracao 1a linha 
            
            ;parametros
            ;mov bx, handler
            mov cx, 4 ;number of bytes to read  
            mov dx, offset str_read
            call fread
            
            mov di, dx
            add di, cx
            mov [di], 0
            
            mov dl, 6
            mov dh, [bp - 2]
            mov si, offset str_read ; buffer for data
            call print_pos ;rint cellnumber 1a linha
            
            ;parametros
            ;mov bx, handler
            mov dx, offset str_read
            mov cx, 10 ;number of bytes to read
            call fread 
            
            mov di, dx
            add di, cx
            mov [di], 0
            
            mov dl, 12
            mov dh, [bp - 2]
            mov si, offset str_read ; buffer for data
            call print_pos ;print player 1a linha 
            
            ;parametros
            mov cx, 8 ;number of bytes to read 
            mov dx, offset str_read
            ;mov bx, handler
            call fread
            
            mov di, dx
            add di, cx
            mov [di], 0
            
            mov dl, 23
            mov dh, [bp - 2]
            mov si, offset str_read ; buffer for data
            call print_pos ;print data 1a linha  
            
            ;parametros
            mov cx, 10 ;number of bytes to read 
            ;mov bx, handler    
            mov dx, offset str_read
            call fread 
            
            mov di, dx
            add di, 8
            mov [di], 0
            
            mov dl, 32
            mov dh, [bp - 2]
            mov si, offset str_read ; buffer for data 
            
            call print_pos ;print hora 1a linha 
            
            pop cx
            
            add [bp - 2], 2; new line
            
            inc cx
            cmp cx, 5
            jne readLoop
        
        ;parametros
        mov dx, offset fileName 
        mov bx, handler
        call fclose
        
        pop cx
        pop ax
        pop dx 
        
        add sp, 2
        pop bp
        
        ret
    endp top5
    
    ;*****************************************************************
    ; showMousep - show mouse position   
    ; descricao: rotina que imprime a posicao do rato
    ; input -  
    ; output - 
    ; destroi -  
    ;*****************************************************************  
    
    showMousep proc 
        
        call im    ;inicializa rato
        call gmp   
        
        ;parametros
        ;cx num carateres a escrever
        ;ax numero a escrever
        ;dh linha/dl coluna
        
        mov ax,cx ;x coord
        mov dh, 0
        mov dl, 20
        call print_pos_int
        
        mov ax,dx ;y coord
        mov dh, 0
        mov dl, 20
        call print_pos_int
        
        
        
        ret
    endp showMousep    
        
    ;*****************************************************************
    ; c_time -check time 
    ; descricao: rotina que apresenta o tempo com base no relogio do computador
    ; input -  
    ; output - CH = hour /  CL = minute / DH = second / DL = 1/100 seconds
    ; destroi -  
    ;*****************************************************************
    c_time proc 
        
        mov ah ,2Ch 
        int 21h ;get system time; 


        
        ret
    endp c_time 
    ;returns: AL = 00h if no character available, AL = 0FFh if character is available.
    imput_status proc
        
        
        mov AH,0Bh
        INT 21h  ;get input status; 
               
        
        ret
    endp imput_status
    
    ;bx = numero de segundos  
    ;para o programa x segundos
    ;Provavelmente tem comportamentos estranhos no emulador
    ;incerteza -> tempo de espera existe ]bx - 1(seg) +- (incerteza do interrupt) , bx [
    sleep_key_press proc
        
        push cx 
        push dx
        push ax
        push bx
             
        mov ah , 2ch
        
        int 21h
        mov al , dh
        
        lp1_slpkp:
                
                push dx
                push ax 
                
                mov ah , 6
                mov dl , 255
                int 21h     
                                                      
                pop ax
                pop dx
                
                jnz fim_slpkp    ;verifica por keypress
                
                int 21h
        
            cmp dh , al     ;enquanto estiver no msm segundo repete
            je lp1_slpkp
            
            ;push bx
            push dx
            push cx 
            push ax
            
            dec bx
            ;parametros
            ;cx num carateres a escrever
            ;ax numero a escrever
            ;dh linha/dl coluna
            mov cx, 1 
            mov ax,bx
            mov dl, 14               
            mov dh, 0
            call print_pos_int
  
            
            pop ax
            pop cx
            pop dx
            ;pop bx
              
            or bx , bx
            jz fim_slpkp
            
                int 21h 
                mov al , dh
                jmp lp1_slpkp
            
        fim_slpkp:
        
        pop bx
        pop ax
        pop dx 
        pop cx
        ret
        
    endp
    
    ;*****************************************************************
    ; creditos 
    ; descricao: rotina que apresenta os credito ao utilizador
    ; input -  
    ; output - 
    ; destroi - ax 
    ;***************************************************************** 
    creditos proc
        
        call c_time
        
        
        push ax
        push cx
        push dx
        push si
        
        call set_video ;clear screen
        
        mov dl, 9 ;coluna
        mov dh, 6 ;linha
        mov si, offset str_julio
        call print_pos ;print str julio   
        
        mov dl, 9
        mov dh, 10
        mov si, offset str_martim
        call print_pos ;print str martim
        
        mov dl, 0
        mov dh, 0
        mov si, offset pkey
        call print_pos ;print str pkey  

        
        mov bx, 10 ;10 segundos de espera
        call sleep_key_press ;funcao de espera 
        
        
        pop si
        pop dx
        pop cx
        pop ax
        
        ret
    endp creditos    
    
    ;*****************************************************************
    ; im - initialize mouse
    ; descricao: rotina que inicializa o rato
    ; input -  
    ; output - ax=0FFFFH if successfull if failed ax=0 / bx number of buttons
    ; destroi - 
    ;*****************************************************************     
    im proc 
        push ax
        
        mov ax, 0;initialize mouse
        int 33h
        
        pop ax    
        ret
    endp im
    ;*****************************************************************
    ; gmp - get mouse position
    ; descricao: rotina que devolve a posicao do rato
    ; input -  
    ; output - dx=ycoord /cx=xcoord / bx 1 left /click/ bx 2 right click/ bx 3 both clicks
    ; destroi -  
    ;*****************************************************************     
    gmp proc 
        push ax
        
        mov ax, 3
        int 33h 
        
        shr cx, 1 ; cx/2 BUG
        
        pop ax    
        ret
    endp gmp

    set_video proc
        
        push ax
        
        mov ax,13h 
        int 10h
        
        pop ax
        ret
    endp set_video  
    
     
    ;funcao que desenha um quadrado/retangulo
    ;dx = Linha do canto superior esquerdo
    ;cx = Coluna do canto superior esquerdo
    ;al = cor
    ;push 1 = tamanho vertical
    ;push 2 = tamanho horizontal
    draw_rect proc
        
        push bp
        mov bp,sp       ;[bp + 6] -> tamanho Vertical
                        ;[bp + 4] -> tamanho horizontal
        
        
        
        mov bx,[bp + 6]       
        call drawVline 
        
        mov bx,[bp + 4]
        call drawHline
        
        sub dx , [bp + 6]
        mov bx , [bp + 4]
        sub cx , bx
        call drawHline
        
        mov bx , [bp + 6]
        call drawVline
        
        
        ;pop cx 
        pop bp
        ret 4
        
    endp
                  
    
    ;dx = Linha
    ;cx = inicio (Coluna)   ; destroi
    ;al = cor
    ;bx = tamanho
    ;draw vertical line
    drawHline proc    
        ;push bp     ;[bp + 4] -> tamanho 
        ;mov bp,sp   
        
        push ax

        
        add bx , cx ; aponta para o ultimo pixel da linha
        mov ah , 0ch
        
        loop1_Vline:
            
            int 10h  
            inc cx
            cmp cx,bx
        jb loop1_Vline 
        

        pop ax
        ret   
    endp
    
             
    ;dx = Inicio (Linha)
    ;cx = Coluna   ; destroi
    ;al = cor
    ;bx = tamanho
    ;draw vertical line
    drawVline proc
        
        push ax
        
        add bx , dx ; aponta para o ultimo pixel da linha
        mov ah , 0ch
        
        loop1_Hline:
            
            int 10h  
            inc dx
            cmp dx,bx
        jb loop1_Hline 
        
   
        pop ax
        ret
        
        ret    
    endp 
    ;Ax = num
    ;cx = numero de char a escrever
    print_int proc
        
        push bp     ;[bp - 2] -> numero de char
        mov bp,sp
        
        push cx
        push dx 
        push bx
        
        mov bx , 10 
        
        loop1_prtint:  
        
            xor dx , dx    
            div bx
            add dl , '0'
            push dx
        
        dec cx
        jz if1_prtint
        or ax,ax
        jz endlp1_prtint
        jmp loop1_prtint
        
        endlp1_prtint:
            
            push 48     ;'0'
            dec cx
        jnz endlp1_prtint
        
        if1_prtint:
        mov cx , [bp - 2]   ;numero de char para dar print 
        
        loop2_prtint:
            
            pop ax
            ;xchg al , ah
            call co 
            dec cx 
            ;jz endlp2_prtint
            ;mov al,ah
            ;call co
            ;dec cx
        jnz loop2_prtint        
        endlp2_prtint:
        
        pop bx
        pop dx
        pop cx
        pop bp
        ret               
    endp
    ;*****************************************************************
    ; co - caracter output
    ; descricao: rotina que faz o output de um caracter para o ecra
    ; input - al=caracter a escrever
    ; output - nenhum
    ; destroi - nada
    ;*****************************************************************
        co proc
            push ax
            push dx
            mov ah,02H
            mov dl,al
            int 21H
            pop dx
            pop ax
            ret
        co endp 
    ;*****************************************************************
    ; pn - printf-normal
    ; descricao: rotina que imprime um conjunto de carateres
    ; input - si - offset da string a imprimir
    ; output - nenhum
    ; destroi - nada
    ;*****************************************************************  
      printf_norm proc
    
        L1: mov al,byte ptr [si]
            or al,al
            jz fimprtstr
            call co
            inc si
            jmp L1
        fimprtstr: ret
    
       endp
    ;*****************************************************************
    ; pp - print pos
    ; descricao: rotina que imprime uma string numa posicao do ecra
    ; input - si - offset da string a imprimir/ dh linha/dl coluna
    ; output - nenhum
    ; destroi - nada
    ;*****************************************************************  
    print_pos proc
        
        push ax
        push bx
        
            
        mov ah , 2  ;cursor na posicao 0,0    
        mov bh , 0  ;pagina
        INT 10h
       
        mov bl , 0
        call printf
        
         
        pop bx
        pop ax
        ret
    endp print_pos 
    ;*****************************************************************
    ; ppi - print pos inteiros
    ; descricao: rotina que imprime um inteiro numa posicao do ecra
    ; input - si - offset da string a imprimir/ dh linha/dl coluna
    ; output - nenhum
    ; destroi - nada
    ;*****************************************************************  
    print_pos_int proc
        
        push bx
        push ax
        
            
        mov ah , 2  ;cursor na posicao 0,0    
        mov bh , 0  ;pagina
        INT 10h
        
 
        pop ax
        ;add sp , 2  ;macumba
        
        mov bl , 0
        call print_int
        
        pop bx
         
        
        ret
    endp print_pos_int
    ;*****************************************************************
    ; printf 
    ; descricao: rotina que imprime uma string numa posicao do ecra
    ; input - si - offset da string a imprimir/ bx = 0 impressao normal/ bx = 1 minusculas/bx = 2 maiusculas/bx = 3 enter no final/
    ; output - nenhum
    ; destroi - nada
    ;*****************************************************************
    printf proc
    
        
        or bl,bl
        jz print_0
        
        cmp bl,1
        je print_min
        
        cmp bl,2
        je print_max
        
        cmp bl,4
        je print_enter
        
        print_max:
            mov bl,'a'
            mov bh,'z'
            mov cl, 'A'-'a'
            ;call printf_min_max      ;por agora nao e preciso
            ret
        
        print_min:
            mov bl,'A'
            mov bh,'Z'
            mov cl,'a'-'A'
            ;call printf_min_max
            ret
        
        print_0:
            call printf_norm
            ret
        
        print_enter:
            call printf_norm
            mov al,0dh
            call co
            mov al,0ah
            call co
            ret
    
    printf endp
    
    ;*****************************************************************
    ; printMenu - imprime menu
    ; descricao: rotina que imprime o menu
    ; input -  
    ; output - 
    ; destroi - 
    ;***************************************************************** 
    printMenu proc
        
        push ax
        push cx
        push dx
        push si
        
        ;funcao que desenha um quadrado/retangulo
        ;dx = Linha do canto superior esquerdo
        ;cx = Coluna do canto superior esquerdo
        ;al = cor
        ;push 1 = tamanho vertical
        ;push 2 = tamanho horizontal   
        mov dx, 12
        mov cx, 106
        mov al,BRANCO 
        push 30
        push 106
        call draw_rect  ;rect bem vindo
        
        ;funcao que imprime no ecra um conjunto de carateres
        ;dh- linha /dl- coluna
        ;si = offset str a escrever
        mov dl, 15  ;coluna
        mov dh, 3   ;linha
        mov si, offset str_bemVindo 
        call print_pos ;print str bem vindo
        
        mov dx, 58
        mov cx, HposRectLeft
        push VlenghtRect
        push HlenghtRect
        call draw_rect  ;rect jogar
        
        mov dl, 10
        mov dh, 8
        mov si, offset str_jogar
        call print_pos ;print str jogar 
        
        mov dx, 98
        mov cx, HposRectLeft
        push VlenghtRect
        push HlenghtRect
        call draw_rect  ;rect exemplos
        
        mov dl, 9
        mov dh, 13
        mov si, offset str_exemplos
        call print_pos ;print str exemplos 
        
        mov dx, 138
        mov cx, HposRectLeft
        push VlenghtRect
        push HlenghtRect
        call draw_rect  ;rect retomar
        
        mov dl, 9
        mov dh, 18
        mov si, offset str_retomar
        call print_pos ;print str retomar
        
        mov dx, 58
        mov cx, HposRectRight
        push VlenghtRect
        push HlenghtRect
        call draw_rect  ;rect top 5
        
        mov dl, 25
        mov dh, 8
        mov si, offset str_top5
        call print_pos ;print str top 5 
        
        mov dx, 98
        mov cx, HposRectRight
        push VlenghtRect
        push HlenghtRect
        call draw_rect  ;rect creditos
        
        mov dl, 24  ;coluna
        mov dh, 13   ;linha
        mov si, offset str_creditos
        call print_pos ;print str creditos
        
        mov dx, 138
        mov cx, HposRectRight
        push VlenghtRect
        push HlenghtRect
        call draw_rect  ;rect sair
        
        mov dl, 25  ;coluna
        mov dh, 18   ;linha
        mov si, offset str_sair
        call print_pos ;print str sair
        
        pop si
        pop dx
        pop cx
        pop ax
      
        ret
    endp printMenu 
    
    ;*****************************************************************
    ; select_op - select option from menu
    ; descricao: rotina que verifica posicao do rato e escolhe opcao do menu
    ; input -  
    ; output - 
    ; destroi -  
    ;*****************************************************************    
    
    proc select_op
        
        call im     ;incializa o rato
        xor  dx, dx  ;para meter os prints todos em (0,0)
                              
        loop_select_op:    ;retorna posicao do rato e botoes primidos   xcoor = cx/ ycoord =dx
                            ; bx= 1 left b /bx= 2 right b/ bx= 3 both b 
            ;call mouse_release
            call gmp 
            
            cmp bx, 1; verifica se o utilizador selecionou op (nao ta a funcionar :( )
            jne loop_select_op
            
            cmp dx, 58                 ;esta compreendido entre as verticais
            jb notRectJogar         
            
            cmp dx, 58+VlenghtRect     
            ja notRectJogar 
      
            cmp cx, HposRectLeft       ;esta compreendido entre as horizontais
            jb notRectJogar 
            
            cmp cx, HposRectLeft+HlenghtRect
            ja notRectJogar  
            
                                        ;aqui vai tar a nossa condicao
            call jogo
            
            jmp end_loop_select_op                    ;agora serve so de teste
        
        notRectJogar:
        
            cmp dx, 98                 
            jb notRectExemplos         
            
            cmp dx, 98+VlenghtRect     
            ja notRectExemplos 
      
            cmp cx, HposRectLeft       
            jb notRectExemplos 
            
            cmp cx, HposRectLeft+HlenghtRect
            ja notRectExemplos  
            
            mov si ,offset str_exemplos             ;aqui vai tar a nossa condicao
            call print_pos                    ;agora serve so de teste
        
        notRectExemplos:
        
            cmp dx, 138                 
            jb notRectRetomar         
            
            cmp dx, 138+VlenghtRect     
            ja notRectRetomar
      
            cmp cx, HposRectLeft       
            jb notRectRetomar 
            
            cmp cx, HposRectLeft+HlenghtRect
            ja notRectRetomar  
            
            mov si ,offset str_retomar             ;aqui vai tar a nossa condicao
            call print_pos                   ;agora serve so de teste
        
        notRectRetomar: 
        
            cmp dx, 58                 
            jb notRectTop5         
            
            cmp dx, 58+VlenghtRect     
            ja notRectTop5 
      
            cmp cx, HposRectRight       
            jb notRectTop5  
            
            cmp cx, HposRectRight+HlenghtRect
            ja notRectTop5   
            
            call top5
            
            jmp end_loop_select_op
        
        notRectTop5: 
        
            cmp dx, 98                 
            jb notRectCreditos         
            
            cmp dx, 98+VlenghtRect     
            ja notRectCreditos
      
            cmp cx, HposRectRight       
            jb notRectCreditos  
            
            cmp cx, HposRectRight+HlenghtRect
            ja notRectCreditos   
            
            ;funcao que apresenta os creditos
            call creditos 
            
            jmp end_loop_select_op
        
  
        notRectCreditos:
        
            cmp dx, 138                 
            jb notRectSair         
            
            cmp dx, 138+VlenghtRect     
            ja notRectSair
      
            cmp cx, HposRectRight       
            jb notRectSair 
            
            cmp cx, HposRectRight+HlenghtRect
            ja notRectSair   
            
            mov si ,offset str_sair             ;aqui vai tar a nossa condicao
            call print_pos
            
            mov ax, 4c00h ; exit to operating system.
            int 21h                     ;agora serve so de teste
            
            notRectSair:
           
            jmp loop_select_op 
        
        end_loop_select_op:           
        
           ret    
    endp select_op
    
    ;------------STRINGS------------;

    ;Si = inicio do numero na str
    ;Cl = num de char =< 5
    ;Ax = resultado
    str_int proc
        
        push dx ;inicializar as variaveis
        push cx
        push si
        mov ax,0
        mov dh,0
        mov ch,10
                 
        str_intLp:
            
            mov dl,byte ptr [si];char 
            or dl,dl
            jz str_int_end      ;para no fim da string
            or cl,cl
            jz str_int_end
            sub dl,'0'          ;passar para inteiro
            
            mul ch              ;multiplicar o resultado por 10
            add ax,dx           ;adicionar o numero novo
            dec cl              ;contar ciclos
            inc si
            jmp str_intLp
            
        str_int_end:
        
        pop si
        pop cx
        pop dx
        ret   
    endp
         
    
    ;Di = inicio str terminada em 0
    ;Ax = valor     
    cnt_str proc
            
        push cx
        push di
            
        mov al,0  ;necessario ?
        mov cx,-1 ;para contar ao contrario
            
        cld 
        repne scasb                           
                      
        mov ax,-1          
        sub ax, cx  ; ax = -(Cx + 1) 
        
        pop di    
        pop Cx
        ret
    endp
    
    ;si= offset str
    ;bl=char
    del_char proc;si= offset str;bl=char
        
        push dx ;dl, guarda o char
        push di ;ptr antes  ' '
        push bx ;ptr depois ' ' 
        mov di,si
        
        lp1_del_char:
            
            mov dl,byte ptr [si];guardar o char
            or dl,dl
            jz end_dlch         ;procurar fim da str
            
            cmp dl,bl
            jne endif_dlch      ;procurar o char em bl
                inc si
                jmp lp1_del_char    
            
            endif_dlch:
            
            movsb
            jmp lp1_del_char
    
        end_dlch:
        
        mov [di],0
        pop bx
        pop di
        pop bx
        ret
    endp
    
    ;Di = offset str
    ;bl = char para mudar
    ;bh = char novo
    swtch_char proc
        
        push cx
        push ax
        
        push di
        call cnt_str
        pop di
        
        mov cx,ax
        mov al,bl
        add di,cx
        
        lp1_swchar:
            
            inc cx          ;repne decrementa uma vez a mais       
            std
            repne scasb     ;procura o char 
 
            jnz end_swchar   ;acaba se tiver percorrido a str toda
            inc di
            
            mov [di],bh     ;substitui 
            jmp lp1_swchar
            
        end_swchar:   
        
        pop ax
        pop cx
        ret
        
    endp
        
        
    ;si = str1
    ;di = str2
    ;resultado "str2""str1"
    app_str proc
        
        push ax
        push cx
        
        call cnt_str
        add di , ax ;aponta para o fim da str
        dec di
        
        mov cx ,di
        mov di,si    ;guardar di
        
        call cnt_str ;conta char da str
        
        mov di , cx
        mov cx , ax    
        
        cld 
        repne movsb ;mov o char todos
        
        pop cx
        pop ax
        ret
        
    endp
        
    ;si = str1
    ;di = str2
    ;se str1 == str2 flag de zero = 1
    str_cmp proc
    
        push ax
        push cx
           
        call cnt_str     ;conta os char da str
        mov cx,ax
        
        cld
        repe cmpsb       ;se str1 == str2 Flag de zero == 1
        
        end_strcmp:   
        pop cx
        pop ax
        ret
   
    endp
    
    
    ;si = str1
    ;di = destino  
    ;cx = num char, 0 = entao conta chars ate 0
    ;escreve char a char str1 em di
    strcpy proc
        
        push ax
        push cx
        
        dec cx
        cmp cx , -1   
        jne if1_strcpy     
            mov cx,di
            mov di,si
            call cnt_str
            mov di,cx       ;numero de char na str [si] em cx
            mov cx,ax
        if1_strcpy:
        
        cld
        rep movsb
        
        pop cx
        pop ax
        ret
    endp
    
    
    ;TODO REFAZER
    ;si=inicio ax = quantos char salta
    ; exemplo 1+2+3+4 onde si aponta para 2 e ax = 2
    ; fica 1+2+4
    str_shift proc
 
        push cx
        push si
        
        inc si

        lp1_strshft:
                    
            add si,ax
            mov ch,[si]
            sub si,ax
            mov [si],ch
            inc si
            or ch,ch
        
        jnz lp1_strshft
        
        pop si
        pop cx
        ret
        
    endp
    
    ;espera que nenhum botao do rato esteja a ser pressionado
    mouse_release proc
        
        push ax
        mov al , rato_preso
        or al , al  
        jz fim_msrl 
        
        push bx
        push cx 
        push dx   
        
        mov ax , 3
        
        lp1_msrl:
            
            int 33h
            or bx , bx 
        jnz lp1_msrl    
        
        pop dx
        pop cx
        pop bx 
        fim_msrl:pop ax
        ret
    endp
    
    
    
    
ends    
end start ; set entry point and stop the assembler.
