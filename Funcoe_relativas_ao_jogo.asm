; multi-segment executable file template.

data segment
    ; add your data here!
    ;----------CONSTANTES----------  
    
    STR_Rel_DIM equ 18 ; Formato "dd/mm/aaaa HH:MM:ss",0
    RelDIM equ 7
     
    CHAR_STR_NOME equ 11        ;numero de char num username
    CellColor equ 15
    ECRAY equ 200
    ECRAX equ 320 
    GENnCHAR equ 8                  ;Nao ocupam memoria :^)
    CELLnCHAR equ 21
    NDigitos equ 4      ;Numero de digitos para os numeros 
    CHARDIM equ 8    
    ;----------CONSTANTES----------
    
    ;DEBUG
    Username db "Matrim    ",0
    ;DEBUG
    
    ;RELOGIO
    relogio db RelDIM dup(0)
    str_relogio db  STR_Rel_DIM dup(0)
    ;RELOGIO
    
    ;FICHEIROS
    ;Username db CHAR_STR_NOME dup(0)    
    filepath db "C:\GameOfLife\",0,db 42 dup(0)	; path to be created  
                        ;Numero maximo de char que um file path pode ter
    Exemplos db "Exemplos", 0 	; path to be created 
    JogosGuardados db "JogosGuardados",0    
    ext_str db ".GAM",0         ;str com o nome da extensao do jogo
    ;FICHEIROS
    
    ;JOGO
    Status_str db "Geracao:0000 Celulas:0000 Iniciar Sair",0  
    
    num_str db 5 dup(0)         ;EU ACHO Q NAO USAMOS ESTA VAR
    
    matriz_cell db 15360 dup(0) ; (320)/2 * (200 - 8)/2 
    matrizY dw 0
    matrizX dw 0  
    lado_cell db 0              ;NAO MEXER , so se mexe no fator de res      
    gen_num dw 0    
    cell_num dw 0    
    fator_res db 1              ;Depois de mexer aqui chamar funcao init_matriz_dim
    ;JOGO
    
    rato_preso db 0             ;Verdadeiro =>1 Falso == 1(define a opcao mouse release)

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
    
    call saveGame
    
        
    call init_matriz_dim
    
    call init_mouse
    
    ;glider PARA TESTE
    mov si , offset matriz_cell
    add si , 4 
    
    ;add si , matrizX
    ;add si , matrizX
    ;add si , matrizX
    ;add si , matrizX
    ;mov [si] , 1    
    ;inc si
    ;add si , matrizX
    ;mov [si] , 1
    ;inc si
    ;mov [si] , 1
    ;add si , matrizX
    ;sub si , 3
    ;mov [si] , 1  
    ;inc si 
    ;mov [si] , 1
    ;glider PARA TESTE
    call set_video
    
    call print_status 
    mov di , offset matriz_cell
    call fill_matriz
    
    xor cx , cx  
    mov dx , CHARDIM
    xor bh , bh 
    mov Bl , lado_cell
    mov si , offset matriz_cell
    ;call wait_key_press
    ;call print_matriz
    
    ;call set_video
    call wait_key_press
    call game_loop
    
    
    mov ax, 4c00h ; exit to operating system.
    int 21h          
    
    ;LIXO PARA DEBUG; 
    
    mov cx , 3840
    mov si , offset matriz_cell
    loop1_main:
        
        inc si
        dec cx
        jz if1_main
        test cx,1
        jz loop1_main
        mov [si],1  
    jmp loop1_main
    if1_main:
    ;LIXO PARA DEBUG;
    
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
            
            ;call wait_key_press ;temporario ? 
            
            push ax 
            
            mov ah, 1
            int 21h
            mov bl , al
            
            pop ax
            
            inc gen_num
        
        cmp bl , 8;backspace
        je saveGame_gl    
        or ax , ax     
        jnz loop1_gl  
        
        jmp end_gl
        
        saveGame_gl:
            call saveGame
            
        end_gl:
        pop cx
        ret
    endp 
    
    
    ;NOTA ANTES DE CHEGAR AQUI
    ;mov di , offset matriz_cell
    ;call load_matriz
    ;se nao escreve a gen anterior
    saveGame proc
        
        push bp
        mov bp , sp
        
        push offset filepath    ;[bp - 2] -> endereco da str filepath
        
        push cx
        push dx
        push si
        push di      
        
        mov si , [bp - 2]   
        mov di , si
        add si , 14             ;para ter a certeza que nao tenho 
        mov [si], 0             ;outro filepath na str
        
        ;mov di , [bp - 2]
        mov si , offset JogosGuardados  ;filepath  ]e assim o caminho para a pasta
        call app_str                    ;com os jogos 
        
        dec di                          ;di esta a apontar para a posicao a seguir ao 0
        mov [di] , '\' 
        mov di , [bp - 2]
        
        mov si , offset username
        call app_str            ;por o nome do user
        
        mov di , offset relogio
        mov si , di     ;a funcao make_relogio_str precisa do offset relogio
        call ler_relogio     
        
        mov di , offset str_relogio
        call make_relogio_str     
        
        mov si , offset str_relogio
        push si
        mov bl , '/'
        call del_char
        
        pop si 
        sub sp , 2  ;continuar com si na stack
        mov bl , ':'
        call del_char 
        
        pop si
        mov di , [bp - 2] 
        call app_str
         
        ;O CODIGO A BAIXO TIRA OS ESPACOS DA STR
        ;NAO SEI SE }E PRECISO!!! 
        ;mov si , [bp - 2]
        ;mov bl , ' '
        ;call del_char
        ;Apartidaqui a string esta pronta 
        
        ;isto tem de ser feito antes
        ;mov di , offset matriz_cell
        ;call load_matriz
        
        ;agr so falta criar destrutivamente o ficheiro
        ;e escrever a fator_res(no primeiro byte) e matriz_cell no resto ficheiro
            
        pop di
        pop si
        pop cx
        pop dx
        
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
            
            call get_mouse_pos
            
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
    
    ;tambem serve como clear screen
    set_video proc
        
        push ax
        xor ax,ax
        mov al,13h 
        int 10h        
        
        pop ax
        ret
    endp 
    
    
   
       ;------------STRINGS------------;
    
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
        jz endlp1_prtint
        or ax,ax
        jnz loop1_prtint
        
        endlp1_prtint:
        
        add cx , [bp - 2]   ;numero de char para dar print 
        
        loop2_prtint:
            
            pop ax
            call co
            dec cx
        jnz loop2_prtint        
        
        pop bx
        pop dx
        pop cx
        pop bp
        ret               
    endp 
    
    ;Si = inicio do numero na str
    ;Cl = num de char =< 5
    ;Ax = resultado
    str_int proc
        
        push dx ;inicializar as variaveis
        push cx
        push si
        
        xor ax , ax  
        xor dh , dh
        
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
    
    ;Di = inicio str destino
    ;Ax = num  
    ;cx = numero de char
    int_str proc
        
        push bp     ;[bp - 2] -> numero de char
        mov bp,sp
        
        push cx
        push dx 
        push bx
        push ax
        
       ; mov cx , bx 
        
        mov bx , 10 
        
        loop1_intstr:  
        
            xor dx , dx    
            div bx
            add dl , '0'
            push dx
        
        dec cx
        jz if1_intstr
        or ax,ax
        jz endlp1_intstr
        jmp loop1_intstr
        
        endlp1_intstr:
            
            push 48     ;'0'
            dec cx
        jnz endlp1_intstr
        
        if1_intstr:
        mov cx , [bp - 2]   ;numero de char para dar print 
        
        loop2_intstr:
            
            pop ax
            xor ah , ah;provavelmente nao ]e preciso
            mov byte ptr[di] , al
            inc di 
            dec cx 
            
        jnz loop2_intstr        
        endlp2_intstrt:
        
        pop bx
        pop dx
        pop cx  
        pop ax
        pop bp
        ret               
    endp
         
    ;Di = inicio str destino
    ;Ax = num
    ;bh = 0,para terminar str com 0  
    ;bl = numero de char
    int_strVlh proc
                 
        push cx
        push dx
        push ax
        push bx
        
        ;xor bx,bx 
        mov cx,10
        
        ;cnt_intsrt:
        ;    
        ;    inc bl
        ;    xor dx,dx        ;dx tem de ser 0
        ;    div cx
        ;    or ax,ax
        ;    
        ;jnz cnt_intsrt 
        
        ;dec di 
        xor bh , bh;bx = bl 
        dec bx
        add di , bx
        pop bx
        
        or bl,bl
        jnz end_intstr
            inc di
            mov [di],0;terminar a string    
            dec di
        end_intstr:
            
        pop ax
        lp1_intstr:
            
            xor dx,dx        ;dx tem de ser 0
            div cx
            add dl,'0'      ;dl tem o char menos significativo
            mov [di], dl    ;adiciona a string      
                        
            dec di          ;prox posicao
            or ax,ax
            jnz lp1_intstr 
        
        ;pop bx
        pop dx
        pop cx
        ret
        
    endp
 
    ;Di = inicio str terminada em 0
    ;Ax = valor     
    cnt_str proc
            
        push cx
        push di
            
        mov al,0
        mov cx,-1
            
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
    ;escreve char a char str1 em di
    strcpy proc
        
        push ax
        push cx
             
        mov cx,di
        mov di,si
        
        call cnt_str
        mov di,cx       ;numero de char na str [si] em cx
        mov cx,ax
        
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
            call printf_min_max
            ret
        
        print_min:
            mov bl,'A'
            mov bh,'Z'
            mov cl,'a'-'A'
            call printf_min_max
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



    printf_min_max proc
    
        push si
        printf_bgl1: mov al,byte ptr [si]
            or al,al
            jz printf_Endl1
            
            cmp al,bh
            ja printf_if1;'Z'
            
            cmp al,bl
            jb printf_if1 ;'A'
                       
                add al,cl;normaliza se o char estiver entre 'A' e 'Z'
                       
            printf_if1:
            call co    
            inc si
            jmp printf_bgl1
        printf_Endl1:
        pop si
        
        ret
    endp

;------------STRINGS------------;
      
    
    ;dx = linhas
    ;cx = colunas
    ;al = cor
    ;bh = altura
    ;bl = comprimento
    print_retangulo proc

        push bp
        
        mov bp,sp   ;[bp - 1] -> Largura
                    ;[bp - 2] -> Comprimento
                           
        push bx     ;bx = comprimento
        
        xor bx,bx ;bx = 0
        
        mov ah, 0ch
        
        lp_prret:   
        
            int 10h     
            inc cx
            inc bl
            cmp bl,[bp - 2] ; comprimento
            jb lp_prret
            
            inc dx
            
            push bx         ;nao perder info
            xor bh,bh
            sub cx,bx       ;reset do comprimento
            pop bx
            xor bl,bl       ;reset do comprimento
            inc bh
            inc dx          ; proxima linha
            cmp bh,[bp - 1]
        jb lp_prret
        

        pop bx               
        pop bp
        ret 4
    endp
      
    ;--------RATO--------;  
      
    ;*****************************************************************
    ; im - initialize mouse
    ; descricao: rotina que inicializa o rato
    ; input -  
    ; output - ax=0FFFFH if successfull if failed ax=0 / bx number of buttons
    ; destroi - 
    ;*****************************************************************     
    init_mouse proc 
        
        mov ax, 0;initialize mouse
        int 33h
           
        ret
    endp 
    ;*****************************************************************
    ; gmp - get mouse position
    ; descricao: rotina que devolve a posicao do rato
    ; input -  
    ; output - dx=ycoord /cx=xcoord / bx 1 left /click/ bx 2 right click/ bx 3 both clicks
    ; destroi - 
    ;*****************************************************************     
    get_mouse_pos proc 
        
        push ax
        mov ax, 3;initialize mouse
        int 33h 
        
        shr cx, 1 ; cx/2 BUG
        
        pop ax   
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
    
    ;--------RATO--------;  
    
    ;--------RELOGIO--------; 
     ;escreve a data e a hora para uma estrutura relogio
    ;Di = offset relogio
    Ler_relogio proc
        
        push ax
        ;push bx
        push cx
        push dx
        
        mov ah , 2ah    ;int get system date
        int 21h 
        
        mov [di] , dl
        inc di
        mov [di] , dh
        inc di
        
        xor dx , dx
        mov ax , cx
        mov cx , 100
        div cx      ;em dx ficam os ultimos dois digitos decimais
                    ;99 < 255
        mov [di] , dl              
        inc di  
        
        mov ah , 2ch;interrupt get system time
        int 21h
        
        mov [di] , ch
        inc di
        
        mov [di] , cl
        inc di
        mov [di] , dh
        
        pop dx
        pop cx
        ;pop bx
        pop ax
        ret   
        
    endp
    
    ;si = offset relogio
    ;di = offset str
    make_relogio_str proc
        
        ;push bp 
        ;mov sp , bp 
        
        ;sub sp , 2
        
        push cx 
        push ax
        
        xor ax ,ax 
        
        mov cx , 2
        
        mov al , [si]          ;dia
        call int_str
        
        mov [di] , '/'
        inc di
        inc si    
         
        mov cx , 2             ;mes
        mov al , [si]
        call int_str
        
        mov [di] , '/'
        inc di 
        inc si
        
        mov cx , 2             ;ano
        mov al , [si]
        call int_str               
        
        mov [di] , ' '
        inc di 
        inc si
        
        mov cx , 2
        mov al , [si]          ;hora
        call int_str
        
        mov [di] , ':'
        inc di
        inc si    
         
        mov cx , 2             ;minutos
        mov al , [si]
        call int_str
        
        mov [di] , ':'
        inc di 
        inc si
        
        mov cx , 2             ;segundos
        mov al , [si]
        call int_str   
        
        mov [di] , 0    ;terminar a str
        
        pop ax 
        pop cx
        ret
        
    endp
    
    ;si = offset string
    ;di = offset relogio
    ;usa uma string com data e hora 
    ;no formato dd/mm/aa HH:MM:ss e mete na estrutura de dados relogio
    strToRelogio proc
        
        push cx   
        push bx
        push ax
        
        mov cl , 2
        mov bx , RelDIM
        
        lp1_strrel:
                
            call str_int   
            
            mov [di] , al
            inc di
            
            add si , 3
        dec bx
        jnz lp1_strrel
        
        pop ax
        pop bx
        pop cx
        
        ret
    endp
    
    ;--------RELOGIO-------;
ends

end start ; set entry point and stop the assembler.
