; multi-segment executable file template.

data segment
    ; add your data here!
    ;----------CONSTANTES----------
    CellColor equ 15
    ECRAY equ 200
    ECRAX equ 320 
    GENnCHAR equ 8                  ;Nao ocupam memoria :^)
    CELLnCHAR equ 21
    NDigitos equ 4      ;Numero de digitos para os numeros 
    CHARDIM equ 8
    ;----------CONSTANTES----------
    
    Status_str db "Geracao:0000 Celulas:0000 Iniciar Sair",0  
    num_str db 5 dup(0)
    matriz_cell db 15360 dup(0) ; (320)/2 * (200 - 8)/2 
    matrizY dw 0
    matrizX dw 0  
    lado_cell db 2      
    gen_num dw 0    
    cell_num dw 0    
    fator_resolucao db 2

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
    
    call init_matriz_dim
    
    ;OSCILADOR PARA TESTE
    mov si , offset matriz_cell
    add si , 4
    add si , matrizX
    mov [si] , 1
    add si , matrizX
    mov [si] , 1
    add si , matrizX
    mov [si] , 1
    ;OSCILADOR PARA TESTE
    call set_video
    
    xor cx , cx  
    mov dx , CHARDIM
    xor bh , bh 
    mov Bl , lado_cell
    mov si , offset matriz_cell
    call print_matriz
    
    ;call set_video
    call wait_key_press
    call game_loop
    
    
    mov ax, 4c00h ; exit to operating system.
    int 21h
     
    mov cx , 4000
    mov si , offset matriz_cell
    loop1_main:
        
        inc si
        dec cx
        jz if1_main
        test cx,1
        jz loop1_main
        mov [si],0  
    jmp loop1_main
    if1_main:
    
    game_loop proc
        
        push cx 
        
        xor cx , cx  
        mov dx , CHARDIM
        xor bh , bh 
        mov Bl , lado_cell
        mov si , offset matriz_cell  
        call print_matriz
        
        mov di , offset matriz_cell
        loop1_gl:
            
            call prox_gen
            
            call wait_key_press
        jmp loop1_gl  
        
        pop cx
        ret
    endp 
    
    ;di = offset matriz com gen(n+1)
    ;precisa de ter gen(n) desenhada no ecra
    prox_gen proc
        
        ;push bp      ;[bp - 2] -> apontador para a posicao da matriz 
        ;mov bp , sp
        ;push 0
        
                              
        ;ler pixel 
        ;get_status 
        ;atualizar
        ;repetir
        
        push dx
        push cx
        push bx
        push ax
        push si
        push di
        
        mov si , di 
        
        xor ax , ax
        mov al , lado_cell
        
        xor cx , cx 
        ;xor ax , ax 
        mov dx , CHARDIM 
          
        loop1_pgen:
            
                call cell_status
                or  bl , bl
                jz endif_pgen
                
                    cmp bl , 1
                    jne if1_pgen
                        mov [di] , 0             
                    
                if1_pgen:
                    mov [di] , 1
                    
                endif_pgen:
            inc di
            add cx , ax
            cmp cx , matrizX
            jb loop1_pgen 
            
            xor cx , cx    
            add dx , ax
            cmp dx , matrizY
        jb loop1_pgen
        
        call set_video      ;limpar o ecra
        call print_status
        
        mov dx , CHARDIM 
        xor cx , cx
        mov bx , ax
        call print_matriz    
        
        pop di
        pop si
        pop ax
        pop bx
        pop cx
        pop dx
        ret
                              
    endp        
    
    ;dx = Linha
    ;cx = Coluna                                          
    ;Bl = resultado , 0 -> nao muda; 1 -> cell morre; 2 -> cell criada
    ;posicao do pixel do canto superior esquerdo da celula
    cell_status proc
        
        push bp
        mov bp , sp ;[bp - 2] -> lado_cell
        
        sub sp , 2
        
        push ax
        push bx
        push dx 
        push cx
        
        xor ah , ah
        mov al , lado_cell
        mov [bp - 2],ax
        
        mov AH , 0Dh
        xor bx , bx
        int 10h    
        
        mov bh , al ;Guardar estado da celula
        
        dec cx  
        
        INT 10h     ;(-1,0)
        
        or al , al
        jz if1_cst
            inc bl 
        if1_cst: 
        
        inc cx
        add cx , ax
        int 10h     ;(1,0)
         
        or al , al 
        jz if2_cst 
            inc bl
        if2_cst:
        
        dec dx
        int 10h    ;(1,-1)
        
        or al , al 
        jz if3_cst
            inc bl
        if3_cst:
        
        dec cx
        int 10h     ;(0,-1)
        
        or al , al 
        jz if4_cst
            inc bl
        if4_cst:
        
        sub cx , [bp - 2]
        int 10h    ;(-1,-1)
        
        or al , al 
        jz if5_cst
            inc bl
        if5_cst:
        
        add dx , [bp - 2]
        inc dx
        int 10h   ;(-1,1)  
        
        or al , al 
        jz if6_cst
            inc bl
        if6_cst:
        
        inc cx
        int 10h ;(0,1)
        
        or al , al 
        jz if7_cst
            inc bl
        if7_cst:
        
        add cx , [bp - 2]
        int 10h ;(1,1) 
        
        or al , al 
        jz if8_cst
            inc bl
        if8_cst:
         
        ;Decide estado da celula 
        jnz if9_cst
            
            cmp bl , 3
            jne if9_cst
                mov bl , 2
                jmp fim_cst
                
        if9_cst:
        
        cmp bl , 2
        jb if10_csft
            cmp bl , 3
            ja if10_csft 
                xor bl , bl;ser diferente para criar ou manter poupa ciclos
                jmp fim_cst
            
        if10_csft:
        
        mov bl , 1
        
        fim_cst:
        
        pop cx
        pop dx
        pop bx
        pop ax 
        add sp , 2
        inc sp
        pop bp
        ret
         
    endp
    
    
    ;di = offsett de matriz para guardar
    fill_matriz proc
        
        
       ret
        
    endp 
    
    ;mete nas variaves 
    ;matrizY/X os valores
    ;tendo em conta o lado do quadrado da celula 
    ;precisa de ser inicializado antes do jogo comecar
    init_matriz_dim proc
        
        push ax
        ;push dx
        
        ;xor dx , dx
        
        mov ax , ECRAY
        sub ax , CHARDIM
        div lado_cell 
        ;xor ah , ah     ;limpa o resto da divisao   (nao [e preciso)
        
        mov matrizY , ax
        
        mov ax , ECRAx
        div lado_cell 
        
        mov matrizX , ax
        pop ax 
        ;pop dx 
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
            call co 
            dec cx 

        jnz loop2_prtint        
        endlp2_prtint:
        
        pop bx
        pop dx
        pop cx
        pop bp
        ret               
    endp                    
    
    
    ;escreve no ecra a geracao
    ; 
    update_gen proc
 
        ;call print_quadrado preto por cima do numero de geracoes
        ;cursor no sitio certo
        ;escreve o numero de geracoes
    endp                             
    
    update_cellnum proc              
        
        ;call print_quadrado preto por cima do numero de celulas
        ;cursor no sitio certo
        ;escreve o numero de celulas
    endp                            
    
    print_parar proc                 
        
        ;call print_quadrado preto por cima de inciar
        ;cursor no sitio certo
        ;escreve parar
    endp
     
     
    print_iniciar proc
        
        
        ;call print_quadrado preto por cima de parar
        ;cursor no sitio certo
        ;escreve iniciar
        
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
        
        dec dx  ;conta a partir de 0
        
        mov al , CellColor
        
        loop1_ptrmtr:
            
                ;mov al,[si]             ;cor = valor na matriz, talvez trocar isto no futuro
                
                or [si],0
                jz if1_ptrmtr
                    
                   ;HLT
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
        ;push ax
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
           
        ; wait for any key....    
        mov ah, 1
        int 21h
           
        pop ax
        ret
        
    endp 
    
    set_video proc
        
        push ax
        xor ax,ax
        mov al,13h 
        int 10h        
        
        pop ax
        ret
    endp 
    
    
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
        ;pop ax               
        pop bp
        ret 4
    endp


ends

end start ; set entry point and stop the assembler.
