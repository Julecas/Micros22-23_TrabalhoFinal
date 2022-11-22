; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "Press any key to continue...",0AH,0DH,0
    str_bemVindo db "Bem vindo",0 
    str_jogar db "Jogar",0
    str_exemplos db "Exemplos",0
    str_retomar db "Retomar",0
    str_top5 db "TOP 5",0
    str_creditos db "creditos",0
    str_sair db "Sair",0
    str_julio db "Julio Lopes n 62633",0AH,0DH,0 
    str_martim db "Martim Agostinho n 62964",0  

   
    time0 db ?  
    
   
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
    sleep proc
        
        push cx 
        push dx
        push ax
        push bx
             
        mov ah , 2ch
        
        int 21h
        mov al , dh
        
        lp1_slp:
        
                int 21h
        
            cmp dh , al     ;enquanto estiver no msm segundo repete
            je lp1_slp 
            
            ;push ax
            ;mov ah ,6 ;wait for key press                             ;not working :( a cena do key press ou ent sou burro
            ;int 21h  
            ;pop ax
            ;jz fim_slp: ;se o utilizador der press a uma key
            
            dec bx
            jz fim_slp
            
                int 21h 
                mov al , dh
                
                
                ;push ax
            ;mov ah ,6 ;wait for key press
            ;int 21h  
            ;pop ax
            ;jz fim_slp: ;se o utilizador der press a uma key

                jmp lp1_slp
            
        fim_slp:
        
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
        
        mov dl, 0 ;(0,0) canto inferior esquerdo
        mov dh, 0
        mov si, offset pkey
        call print_pos ;print str martim
        
        
        mov bx, 10 ;numero de segundos
        call sleep ;conta segundos
        ;c_time_creditos_loop:
        
         
        
        ;je fimDoTempo
        
        
        
        
        ;jmp c_time_creditos_loop 
        
        fimDoTempo:
        
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
        
        push ax
        push bx
        
            
        mov ah , 2  ;cursor na posicao 0,0    
        mov bh , 0  ;pagina
        INT 10h
       
        mov bl , 0
        call print_int
        
         
        pop bx
        pop ax
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
            
            mov si ,offset str_jogar             ;aqui vai tar a nossa condicao
            call print_pos                    ;agora serve so de teste
        
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
            
            ;rotina que apresenta o top5 
             mov si ,offset str_top5            ;aqui vai tar a nossa condicao
            call print_pos                   ;agora serve so de teste
        
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
            call print_pos                    ;agora serve so de teste
            
            notRectSair:
           
            jmp loop_select_op 
        
        end_loop_select_op:           
        
           ret    
    endp select_op
    
    ;bx = numero de segundos  
    ;para o programa x segundos
    ;Provavelmente tem comportamentos estranhos no emulador
    ;incerteza -> tempo de espera existe ]bx - 1(seg) +- (incerteza do interrupt) , bx [
    sleep_key_press proc ; Falta printpos
        
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
                
                jnz fim_cslp    ;verifica por keypress
                
                int 21h
        
            cmp dh , al     ;enquanto estiver no msm segundo repete
            je lp1_slpkp
            push cx 
            push ax
            
            dec bx
            
            mov ax , bx
            mov cx , 1
            call print_int
            
            pop ax
            pop cx  
            or dx , dx
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
    
ends    
end start ; set entry point and stop the assembler.
