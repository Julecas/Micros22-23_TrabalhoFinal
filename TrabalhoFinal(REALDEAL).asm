; multi-segment executable file template.

data segment

    ;----------CONSTANTES----------  
    ;Definicoes
    
    PxVerPosOp1 equ 55 ;posicao vertical em pixeis nas definicoes da opcao 1
    
    ;Definicoes  
    
    BRANCO equ 15
    ECRAY equ 200                 
    
    ECRAX equ 320 
    HposRectLeft equ 60; Coluna do canto superior esquerdo dos quadrados da esquerda do menu 
    HposRectRight equ 180; Coluna do canto superior esquerdo dos quadrados da direita do menu
    VlenghtRect equ 20 ; tamanho vertical dos quadrados do menu 
    HlenghtRect equ 80 ; tamanho horizontal dos quadrados do menu 
    rwawr equ 15
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
    
    handler dw ? 
    nl db 0dh , 0ah   ;Newline  
    time0 db 0
    
    ;-------------USERNAME---------
    
    str_insiraUser db "Insira o seu nome de utilizador",0AH,0DH,0AH,0DH,"      :",0
    Username db 10 dup(' '),0 ;Professor ]e fita cola preta mesmo 
    UserRegistado db 0 
    
    ;------------TOP5------------             

    str_rodapeTop5 db "GEN  CELLS  PLAYER      DATE     TIME",0AH,0DH,0
    str_read db 33 dup(0) ;buffer de leitura
    
    ;------------RELOGIO------------
    
    relogio db RelDIM dup(0)                
    str_relogio db  STR_Rel_DIM dup(0)
    
    ;------------sair------------     
    
    guardar_str db "Guardar",0
    menu_str db "Menu",0       
    
    ;------------Definicoes------------
    
    def_str db "Definicoes",0  
    res_str db "Resolucao:",0 
    rato_str db "Rato Preso",0
    rato_preso db 1             ;Verdadeiro =>1 Falso == 1(define a opcao mouse release)   
    voltar_str db 17,"Voltar",0             
    
    
    ;------------FICHEIROS------------
    
    Logs_str db "Logs.txt",0
    Ftop_str db "TOP5.txt",0
    pedir_nome db "Nome do ficheiro:",0
    input_str db 12 dup(0)           
    str_file_error db "File error num:",0    
    filepath    db "C:\GOLife",0
                db 43 dup(0)	; path to be created  
                        ;Numero maximo de char que um file path pode ter
    Exemplos db "Exemplos", 0 	; path to be created 
    Jogos db "Jogos",0    
    ext_str db ".GAM",0         ;str com o nome da extensao do jogo  
    str_top db , 37 dup(0)      ;str com o formato de uma entrada no top5
                                ;EX.: 0930336canibal	 22/11/03 03:35:59
  
    ;------------JOGO------------
    
    Status_str db "Geracao:0000 Celulas:0000 Iniciar Sair",0  
    
    num_str db 5 dup(0)         ;EU ACHO Q NAO USAMOS ESTA VAR
    
    matriz_cell db 15360 dup(0) ; (320)/2 * (200 - 8)/2 
    matrizY dw 0
    matrizX dw 0  
    lado_cell db 0              ;NAO MEXER , so se mexe no fator de res      
    gen_num dw 0 
    cell_num dw 0   
    fator_res db 2              ;Depois de mexer aqui chamar funcao init_matriz_dim
    
    ;------------MENU------------
    
    pkey db "returning in 10sec press any key...",0AH,0DH,0
    str_bemVindo db "Bem vindo",0 
    str_jogar db "Jogar",0
    str_definicoes db "Definicoes",0
    str_retomar db "Retomar",0
    str_top5 db "TOP 5",0
    str_creditos db "creditos",0
    str_sair db "Sair",0
    str_julio db "Julio Lopes n 62633",0AH,0DH,0 
    str_martim db "Martim Agostinho n 62964",0  
   
    
    pepe    db 0,0,0,0,0,2,2,0,2,2,0,0,0,0,0,0,0,0,0,0
            db 0,0,0,0,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0
            db 0,0,0,2,2,7,0,7,7,0,2,0,2,0,0,0,0,0,0,0
            db 2,0,0,2,2,2,2,2,2,2,0,2,0,0,0,0,0,0,0,0
            db 2,0,2,2,2,2,4,4,4,4,2,0,0,0,0,0,0,0,0,0
            db 2,0,2,2,2,2,2,2,2,1,0,0,0,0,0,0,0,0,0,0
            db 0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0

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
    
    call main  
    
    mov ax, 4c00h ; exit to operating system.
    int 21h       
    
    ;ROTINAS
    
    main proc
        
        main_loop:
         
            call set_video
            call printMenu
            call select_op  
            call mouse_release   
            
        jmp main_loop
                    
        ret
    endp
    
    ;--------------MENU--------------
    
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
        
        mov cl , UserRegistado   ;para nao pedir sempre a porra do nome ne
        or cl , cl
        
        jnz user_reg
        
        ;*******************Username*****************  antes de imprimir o menu :)
        
        
        mov dl, 5  ;coluna
        mov dh, 10   ;linha
        mov si, offset str_insiraUser 
        call print_pos 
        
        
        mov di, offset Username
        mov cx, 10 ;Max name size
        call scanf   
        mov [di] , ' '
        
        call set_video
        
        ;call wait_key_press ;DEBUGG 
        
        mov cl,1
        mov UserRegistado, cl
        
        ;********************************************  
        
        user_reg:
        
        mov dx, 12
        mov cx, 106
        mov al,BRANCO 
        push 30
        push 106
        call draw_rect  ;rect bem vindo
        
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
        
        mov dl, 8
        mov dh, 13
        mov si, offset str_definicoes
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
        
        push dx
        push bx
        push ax
        push si 
        
        call im     ;incializa o rato
        xor  dx, dx  ;para meter os prints todos em (0,0)    
        
        mov ax, 1  ;show mouse cursor
        int 33h
                               
        loop_select_op:    ;retorna posicao do rato e botoes primidos   xcoor = cx/ ycoord =dx
                            ; bx= 1 left b /bx= 2 right b/ bx= 3 both b 
            ;call mouse_release 
            call gmp 
            
            cmp bx, 1; verifica se o utilizador selecionou op (nao ta a funcionar :( )
            jne loop_select_op
                    ;quarto push
            
            mov ax, VlenghtRect 
            push ax
            mov ax, HlenghtRect
            push ax
            mov ax, 58
            push ax
            mov ax, HposRectLeft
            push ax
            call m_hitbox
            
            cmp ax, 0
            
            je notRectJogar
                
                ;TODO perguntar username 
                
                mov gen_num , 0
                mov cell_num , 0
                call jogo  
            
            jmp end_loop_select_op 
            
        notRectJogar:
        
            mov ax, VlenghtRect 
            push ax
            mov ax, HlenghtRect
            push ax
            mov ax, 98
            push ax
            mov ax, HposRectLeft
            push ax
            call m_hitbox
            
            cmp ax, 0
            
            je notRectdefinicoes
                
                call set_video
                call definicoes 
            
            jmp end_loop_select_op 
            
        notRectdefinicoes:
        
            mov ax, VlenghtRect 
            push ax
            mov ax, HlenghtRect
            push ax
            mov ax, 138
            push ax
            mov ax, HposRectLeft
            push ax
            call m_hitbox
            
            cmp ax, 0
            
            je notRectRetomar
            
                call op_retomar                 ;aqui vai tar a nossa condicao
                                                ;agora serve so de teste 
            
            jmp end_loop_select_op 
        
        notRectRetomar: 
            
            mov ax, VlenghtRect 
            push ax
            mov ax, HlenghtRect
            push ax
            mov ax, 58
            push ax
            mov ax, HposRectRight
            push ax
            call m_hitbox
            
            cmp ax, 0
            
            je notRectTop5
                 
                call readtop5                      
            
            jmp end_loop_select_op
        
        notRectTop5: 
        
            mov ax, VlenghtRect 
            push ax
            mov ax, HlenghtRect
            push ax
            mov ax, 98
            push ax
            mov ax, HposRectRight
            push ax
            call m_hitbox
            
            cmp ax, 0
            
            je notRectCreditos
                                         
                call creditos                      
            
            jmp end_loop_select_op
        
  
        notRectCreditos:
            
            mov ax, VlenghtRect 
            push ax
            mov ax, HlenghtRect
            push ax
            mov ax, 138
            push ax
            mov ax, HposRectRight
            push ax
            call m_hitbox
            
            cmp ax, 0
            
            je notRectSair
                
                ;call writeTop5 
                call writelog
                mov ax, 4c00h ; exit to operating system.
                int 21h                 
            
            jmp end_loop_select_op
            
            
            notRectSair:
           
            jmp loop_select_op 
        
        end_loop_select_op:  
        
        ;***
        ;jmp loop_select_op 
        ;DEBUGG   
           
        pop si
        pop ax
        pop bx
        pop dx
           
        ret 
           
    endp select_op  
    
    ;*****************************************************************
    ; creditos 
    ; descricao: rotina que apresenta os credito ao utilizador
    ; input -  
    ; output - 
    ; destroi - ax 
    ;***************************************************************** 
    creditos proc
        
        push ax
        push cx
        push dx
        push si
        
        call set_video ;clear screen 
        
        call pepe_the_frog
        
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
    
    ;--------------MENU--------------
    
    ;----------------Jogo----------------
    
    ;*****************************************************************
    ; writeLog  
    ; descricao: rotina que escreve no ficheiro logs o (log do jogador) ao sair do programa
    ; input -  
    ; output - 
    ; destroi -  
    ;*****************************************************************
    proc writeLog
    
        push di
        push dx
        push cx
        push ax
        
        mov si , offset filepath   
        mov di , si
        add si , 9            ;para ter a certeza que nao tenho 
        mov [si], '\'             ;outro filepath na str
        inc si
        mov [si] , 0 
        
        mov si , offset Logs_str
        call app_str
        
        mov dx, offset filepath ;MARTIM TENS QUE MUDAR 
        mov al, 1
        call fopen
     
        ;SEEK TO END OF FILE
        ; input -  
        ; bx - file handler 
        ; cx colunas
        ; dx deLinhas :( 
        
        xor dx,dx
        xor cx,cx
        mov al,2 ;end of file
        
        mov ah, 42h ;read file (seek)
        int 21h
            
            jnc if_wl 
            
                call print_file_error  
                jmp end_wlog
                
            if_wl:
                        
        mov di , offset relogio
        mov si , di 
        call ler_relogio       
        
        mov di , offset str_relogio
        push di
        call make_relogio_str
        pop si  
        sub sp , 2  ;manter si na stack
        mov bl , '/' 
        call del_char
        
        pop si
        sub sp , 2  ;manter si na stack
        mov bl , ':'
        call del_char
        
        pop di 
        mov dx , di
        mov bl , ' '
        mov bh , ':'
        call swtch_char 
        
        mov bx, handler
        mov cx, 13
        call fwrite ;write gen
                
        mov bx, handler
        mov cx, 10 
        mov dx,offset Username 
        call fwrite ;write name
        
        mov di,offset str_top  ;vou usar str_read como buffer de escrita
        mov ax, gen_num
        mov cx, 4 
        call int_str
        
        mov bx, handler
        mov dx,offset str_top
        mov cx, 4  
        call fwrite ;write gen     
        
        mov di,offset str_top  
        mov ax, cell_num
        mov cx, 4 
        call int_str
        
        mov bx, handler
        mov dx,offset str_top
        mov cx, 4  
        call fwrite ;write cell num 
        
        mov bx, handler
        mov dx,offset nl
        mov cx, 2  
        call fwrite 
        
        mov dx, offset filepath
        call fclose   
        
       
        end_wlog: 
        pop ax
        pop cx
        pop dx
        pop di    
        ret
    endp  
               
    
    ;loop principal do jogo
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
        
        mov ax, 2  ;hide mouse cursor
        int 33h
        
        loop1_gl: 
            
            call black_out ;limpar o ecra

            call print_status
            
            xor cx , cx  
            mov dx , CHARDIM
            xor bh , bh 
            mov Bl , lado_cell
            mov si , offset matriz_cell  
            call print_matriz  
            
            call prox_gen
            
            or ax , ax 
            jz end_gl
            
            ;call wait_key_press ;temporario ? 
            
            jmp if2_gl
                
            lp2_gl:
            
                push ax
                
                call gmp   
                
                or bx , bx    
                jz if1_gl   ;verifica se estou a clicar
                 
                    mov ax , 10
                    push ax
                    mov ax , 40
                    push ax      
                    mov ax , 1
                    push ax
                    mov ax ,268
                    push ax      
                    call m_hitbox 
                
                or ax , ax
                jz if1_gl
                      
                    call op_sair  
                    pop ax      ;para nao cagar a stack do push la de cima 
                    jmp end_gl  
                    
                if1_gl:
                
                
                mov dl , 255
                mov ah , 6
                int 21h
                
                pop ax      
                jz lp2_gl  ;salta se nao houver um char no buffer
            
            
            push ax
                
            mov ax, 2  ;hide mouse cursor
            int 33h
            
            pop ax
            if2_gl:
            
            mov dl , 255
            mov ah , 6
            int 21h
            
            jz if3_gl  ;salta se houver um char no buffer 
                
                push ax
                mov ax, 1  ;show mouse cursor
                int 33h
                pop ax
                jmp lp2_gl  
                
            if3_gl:
            
            inc gen_num
                        
        or ax , ax     
        jnz loop1_gl  
        
            
        end_gl:
        
        call mouse_release 
        pop cx
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
       
        mov si , offset matriz_cell
        
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
        call game_loop
        
        call writetop5
        
        ;call set_video
            
        pop dx
        pop cx
        pop di
        pop si
        
        ret
    endp jogo
    
    ;----------------Jogo----------------
    
              
    ;------------TOP5------------
    
    ;di = offset onde escrever a str
    ;o resto dos valores esta funcao usas as variaveis globais
    top5_str proc
        
        push ax
        push si
        push cx
        
        mov [di] , 0 ;terminar a string logo ao inicio
        mov ax , cell_num
        mov cx , 4
        call int_str
        
        mov ax , gen_num
        mov cx , 4 
        call int_str
        
        mov [di] , 0
        dec di
        mov si , offset Username  
        call app_str
        
        mov di , offset relogio
        mov si , di     
        
        call ler_relogio
        
        mov di , offset str_relogio 
        push di 
        call make_relogio_str
        
        pop si
        mov di , offset str_top
        call app_str
        
        pop cx
        pop si
        pop ax
        ret
        
    endp     
    
    ;*****************************************************************
    ; writeTop5  
    ; descricao: rotina que escreve no top 5 um novo elemento
    ; input -  
    ; output - 
    ; destroi -  
    ;***************************************************************** 
    proc writeTop5
        
        mov si , offset filepath   
        mov di , si
        add si , 9            ;para ter a certeza que nao tenho 
        mov [si], '\'             ;outro filepath na str
        inc si
        mov [si] , 0 
        
        mov di , offset filepath  
        mov si , offset Ftop_str 
        call app_str
        
        mov dx, offset filepath      
        mov al, 2   ;0 - read \ 1 - write \ 2 read/write  
        call fopen 
         
        call tlcmp ; ISTO TA BOM 
        
        ;call wait_key_press ; DEBUGG
        
        cmp dx, 6
        je endWriteTop5 ;isto signifca que o gajo dos logs e tao mau tao mau
                        ;que nos so vamos cagar nele mesmo

        push dx
        
        mov ax, dx 
        
        mov dx, 3
        
        mov bx, handler 
       
        writeTop5Lp:
    
            mov cx, 37
            push cx
            xor cx,cx
            call seek
            
            push dx
            
            mov dx, offset str_top 
            mov cx,35  ;number of bytes to read
            call fread 
             
            pop dx 
            
            inc dx
            
            mov cx, 37
            push cx
            xor cx,cx
            call seek 
            
            push dx
            
            mov dx, offset str_top 
            mov cx,35  ;number of bytes to read
            call fwrite
            
            pop dx 
            
            sub dx, 2
            
            inc ax 
            
            cmp ax, 5
            
            jb writeTop5Lp 
            
        
        ;call wait_key_press ; DEBUGG
        
        pop dx  
        
        dec dx ; pos -1
            
        mov cx, 37
        push cx
        xor cx,cx
        call seek 
        
        mov di , offset str_top
        call top5_str
        
        mov dx, offset  str_top
        mov cx,35  ;number of bytes to read
        call fwrite                     
        
        endWriteTop5:
    
        mov bx, handler 
        mov dx, offset filepath  
        call fclose
        
        ret
    endp writeTop5 
    
    
     
     ;*****************************************************************
    ; tlcmp - top5 log compare 
    ; descricao: rotina que compara o numero de cells num log com os elementos do top 5
    ; input -  
    ; output - dx
    ;   dx = 6 se o marmanjo nao tinha mais cells que o ultimo (ou seja cagamos nele)
    ;   dx = 5 se ele era maior que o menor
    ;   dx = 4 se ele era maior que o quarto
    ;   dx = 3 se ele era maior que o terceiro
    ;   dx = 2 se ele for maior que o segundo
    ;   dx = 1 se o dos logs for o maior O REI DELES TODOS portanto
    ; destroi -  
    ;***************************************************************** 
    proc tlcmp 
        
        push bx
        push cx
        push ax
        push si

        mov bx, handler  
            
        mov dx,4   ;DeLinhas
        mov cx,4   ;colunas
  
        tlcmpLp:
           
            mov ax, 37
            push ax
            call seek
            
            push cx
            push dx

            mov bx, handler          
            mov cx, 4 ;bytes to read
            mov dx, offset str_top    
            call fread                 ;
            
            ;parametros
            mov si, offset str_top
            mov cl, 4
            call str_int
            
            pop dx 
            pop cx 
                              
            ;cmp ax, lowerCells  ;se o marmanjo for menor que o menor entao cagamos nele
            cmp cell_num, ax                                                                            
                                                                                         
            jb endTlcmp
            
            dec dx 
            
            cmp dx, -1  ;para se o gajo dos logs for realmen O REI
            je endTlcmp
                     
            jmp tlcmpLp:
     
        endTlcmp: 
        
        add dx, 2  ;agora ja nao
        
        pop si
        pop ax
        pop cx
        pop bx
                                                
        ret
    endp tlcmp     
    
    ;*****************************************************************
    ; readtop5 
    ; descricao: rotina que apresenta o top 5 jogadores
    ; input -  
    ; output - 
    ; destroi - ax 
    ;***************************************************************** 
    proc readtop5
        
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
        
        mov si , offset filepath   
        mov di , si
        add si , 9              ;para ter a certeza que nao tenho 
        mov [si], '\'             ;outro filepath na str
        inc si
        mov [si] , 0 
        
        mov di , offset filepath  
        mov si , offset Ftop_str 
        call app_str
        
        mov dx, offset filepath
              
        mov al, 0      ;0 - read \ 1 - write \ 2 read/write  
        call fopen
        
        xor cx,cx;cx = 0
        
            
            readLoop:
             
            push cx
            
            ;parametros
           
            mov bx, handler
            mov dx, offset str_read
            mov cx, 4 ;number of bytes to read
            call fread
            
            mov di, dx
            add di, cx
            mov [di], 0
           
            
            mov dl, 6
            mov dh, [bp - 2]
            mov si, offset str_read ; buffer for data        ;GEN
            call print_pos ;print geracao 1a linha 
            
            ;parametros
            ;mov bx, handler
            mov cx, 4 ;number of bytes to read  
            mov dx, offset str_read
            call fread
            
            mov di, dx
            add di, cx
            mov [di], 0
            
            mov dl, 1
            mov dh, [bp - 2]                              ;CELLS
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
            mov si, offset str_read ; buffer for data       ;NOME
            call print_pos ;print player 1a linha 
            
            ;parametros
            mov cx, 9 ;number of bytes to read 
            mov dx, offset str_read
            ;mov bx, handler
            call fread
            
            mov di, dx
            ;inc cx ;para ele saltar o espaco
            add di, cx
            mov [di], 0
            
            mov dl, 23
            mov dh, [bp - 2]
            mov si, offset str_read ; buffer for data      ;DATA
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
            mov si, offset str_read ; buffer for data     ;HORA
            
            call print_pos ;print hora 1a linha 
            
            pop cx
            
            add [bp - 2], 2; new line
            
            inc cx
            cmp cx, 5
            jne readLoop
        
        ;parametros 
                   
        mov dx, offset filepath
        mov bx, handler
        call fclose
        
        pop cx
        pop ax
        pop dx 
        
        add sp, 2
        pop bp 
        
        call wait_key_press
        
        ret
    endp readtop5
    
    ;------------TOP5------------
    
    ;pop-up para sair do jogo
    op_sair proc             
        
        call mouse_release
        
        mov ax , 0;cor do retangulo
        mov dx , 75
        mov cx , 90
        mov bx , 140
        push bx
        mov bx , 50
        push bx
        call print_retangulo    
        
        mov al , 15
        mov dx , 75
        mov cx , 90
        mov bx , 50
        push bx
        mov bx , 140
        push bx
        call draw_rect
        
        
        ;menu
        mov al , 15
        mov dx , 86
        mov cx , 140
        mov bx , 10
        push bx
        mov bx , 40
        push bx
        call draw_rect      
        
        mov dh , 11
        mov dl , 18
        mov si , offset Menu_str  
        call print_pos       
        
        ;Guardar
        mov al , 15
        mov dx , 102
        mov cx , 125
        mov bx , 10
        push bx
        mov bx , 70
        push bx
        call draw_rect      
        
        mov dh , 13
        mov dl , 17
        mov si , offset Guardar_str
        call print_pos 
        
        loop_os:
            
            call gmp
               
            or bx , bx ;verifica se estou a clicar
            jz loop_os
                
                ;menu
                mov ax , 10
                push ax
                mov ax , 40
                push ax
                mov ax , 86
                push ax
                mov ax , 140
                push ax 
                call m_hitbox
                
                or ax , ax
                jnz menu_os 
                
                ;Guardar
                mov ax , 10
                push ax
                mov ax , 40
                push ax
                mov ax , 102
                push ax 
                mov ax , 125
                push ax 
                call m_hitbox
                
            or ax , ax
            jnz if1_os
                   
                call saveGame 
                mov ax, 4c00h ; exit to operating system.
                int 21h 
                   
            if1_os:
            
        jmp loop_os 
            
        
        ;falta hitbox         
        
        menu_os:
        
        ret
    endp
     
    ;menu de definicoes
    definicoes proc
        
        push bp
        mov bp , sp     ;[bp - 2] -> cor do quadrado da opcao rato preso
                        
        sub sp , 2
        
        mov [bp - 2] , 15   ;BRANCO
        
        push ax
        push bx 
        push cx
        push dx
        
        mov AX , 1
        INT 33h 
        
        mov dx , 14
        mov cx , PxVerPosOp1
        mov al , 15     ;BRANCO   
          
        mov bx , 10 
        push bx                ;a funcao recebe words
        mov bx , 200
        push bx
        call draw_rect 
        
        mov dh , 2
        mov dl , 15
        mov si , offset def_str  
        call print_pos
        
        loop1_def:
            
            
            ;Resolucao
            mov dx , 30
            mov cx , PxVerPosOp1
            ;mov al , 15     ;BRANCO 
            mov ax , 10
            push ax
            mov ax , 100
            push ax
            mov al , 15 ; BRANCO
            call draw_rect  
            
            mov dh , 4
            mov dl , 7
            mov si , offset Res_str  
            call print_pos
            
            mov dh , 4
            mov dl , 17 
            mov cx , 2
            mov al , lado_cell
            call print_pos_int
        
            ;Voltar
            mov dx , 46
            mov cx , 125
            mov ax , 10
            push ax
            mov ax , 70
            push ax
            mov al , 15 ; BRANCO
            call draw_rect  
            
            mov dh , 6
            mov dl , 17
            mov si , offset voltar_str  
            call print_pos
                         
                         
            ;Rato Preso 
            
            mov dx , 30
            mov cx , 165  
            mov ax , 10
            push ax
            mov ax , 90
            push ax
            mov ax , [bp - 2];cor do retangulo
            call draw_rect  
            
            
            mov dh , 4
            mov dl , 21
            mov si , offset rato_str  
            call print_pos 
            
            lp2_def:
                
                call gmp
                call mouse_release
                or bx , bx
                
            jz lp2_def   
            
            ;Voltar 
            
            mov ax , 10  
            push ax
            mov ax , 70
            push ax
            mov ax , 46
            push ax
            mov ax , 125
            push ax
            call m_hitbox
            
            or ax , ax
            jz if4_def
                            
                ;call menu                        
                jmp exit_def
                
            if4_def:
             
            ;res
            mov ax , 10
            push ax
            mov ax , 100
            push ax
            mov ax , 30
            push ax
            mov ax , PxVerPosOp1
            push ax
            call m_hitbox
            
            or ax , ax
            jz if3_def
            
                call inc_res
            
            if3_def: 
            
            mov ax , 10
            push ax
            mov ax , 90
            push ax
            mov ax , 30
            push ax
            mov ax , 165
            push ax
            call m_hitbox
            
            or ax , ax 
            jz if1_def       
                
                cmp [bp - 2] , 15 
                jne if2_def       
                
                    mov [bp - 2] , 2  
                    mov rato_preso , 1
                    jmp loop1_def 
                if2_def:
                
                mov [bp - 2] , 15 
                mov rato_preso , 0
                ;jmp loop1_def 
            
            if1_def:
            
            ;mov [bp - 2] , 15;branco    
            jmp loop1_def     
        
        exit_def:
        
        pop dx
        pop cx
        pop bx
        pop ax
        add sp , 2 
        pop bp
        ret
    endp
    
    ;incrementa a resolucao 
    inc_res proc
        
        
        cmp fator_res , 5
        jae if1_ires
            
            inc fator_res
            jmp end_ires
            
        if1_ires:
            
            mov fator_res , 1
            
        end_ires: 
        
        call init_matriz_dim
        ret   
        
    endp  
    
    ;pop up para retomar o jogo
    op_retomar proc
        
        ;criar quadrado preto no ecra
        ;outline
        ;pedir ao user o nome do ficheiro 
        ;call loadGame0 
        push ax
        push bx
        push cx
        push dx 
        push si
        push di
        
        mov ax , 0;cor do retangulo
        mov dx , 49
        mov cx , 42
        mov bx , 180
        push bx
        mov bx , 50
        push bx
        call print_retangulo
        
        mov si , offset pedir_nome 
        mov dh , 7
        mov dl , 8
        mov bx , 0
        call print_pos
         
        inc dh
        mov ah , 2  ;cursor na posicao 0,0    
        mov bh , 0  ;pagina
        INT 10h    
        
        mov al , 15
        mov dx , 49
        mov cx , 42
        mov bx , 50
        push bx
        mov bx , 180
        push bx
        call draw_rect

        mov dh , 9
        mov dl , 8
        xor  bx ,bx
        mov ah , 2
        int 10h         
               
        mov cx , 12
        mov di , offset input_str
        call scanf    
        
        mov si , offset filepath   
        mov di , si
        add si , 9              ;para ter a certeza que nao tenho 
        mov [si], '\'             ;outro filepath na str
        inc si
        mov [si] , 0
        
        mov si , offset Jogos
        call app_str    
        
        dec di
        mov [di] , '\'            
        inc di 
        mov [di] , 0
        mov si , offset input_str
        call app_str    
        
        dec di 
        mov [di] , 0
        
        mov dx , offset filepath  
        mov AH , 3Dh 
        mov al , 2
        int 21h   
        
        jc if1_retomar
            
            mov bx , ax       
            mov ah , 3eh
            INT 21h ;close file
            
            call loadGame    
            
            call set_video
            
            xor cx , cx  
            mov dx , CHARDIM
            xor bh , bh 
            mov Bl , lado_cell
            mov si , offset matriz_cell  
            call print_matriz  
            
            mov di , offset matriz_cell
            call fill_matriz  
            call game_loop
            
        if1_retomar:

        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        
        ret
    endp
    
    ;Funcao que atualiza o jogo 
    ;input_str tem de ter o nome do ficheiro
    ;filepath com o ficheiro
    LoadGame proc
        
        push si
        push di 
        push ax
        
        mov dx , offset filepath 
        mov al , 2
        mov ah, 3dh ; open file      
        int 21h 
        
        jnc if1_ldgm                  
        
            ;PRINT FICHEIRO NAO EXISTE  
            jmp endf_ldgm
        if1_ldgm:  
                 
        mov bx , ax
        mov dx , offset fator_res
        mov cx , 1
        call fread
        
        mov dx , offset relogio
        mov cx , RelDIM
        call fread
        
        mov dx , offset Username
        mov cx , 11
        call fread 
        
        mov dx , offset cell_num
        mov cx , 2
        call fread
        
        mov dx , offset gen_num
        mov cx , 2
        call fread
        
        mov dx , offset matriz_cell
        mov cx , 15630
        call fread   
        
        mov AH , 3Eh
        INT 21h  
        
        endf_ldgm:
        pop ax
        pop di
        pop si 
        ret
    endp
    
    ;NOTA ANTES DE CHEGAR AQUI
    ;mov di , offset matriz_cell
    ;call load_matriz
    ;se nao escreve a gen anterior
    saveGame proc
        
        ;push bp
        ;mov bp , sp
        
        ;push offset filepath    ;[bp - 2] -> endereco da str filepath
        
        push dx
        push ax
        push cx
        push si
        push di

        mov si , offset filepath   
        mov di , si
        add si , 9              ;para ter a certeza que nao tenho 
        mov [si], '\'             ;outro filepath na str
        inc si
        mov [si] , 0
        
        mov si , offset Jogos           ;filepath  ]e assim o caminho para a pasta
        call app_str                    ;com os jogos 
        
        dec di                          ;di esta a apontar para a posicao a seguir ao 0
        mov [di] , '\' 
        inc di      
        mov al , Username
        mov [di] , al          ;primeiro char do nome
      
        ;mov si , offset Username
        ;call app_str            ;por o nome do user
        
        mov di , offset relogio 
        mov si , di     ;a funcao make_relogio_str precisa do offset relogio
        call ler_relogio     
        
        mov di , offset str_relogio     ;continuar com offset da str_relogio no si
        push di
        call make_relogio_str     
        
        pop si
        sub sp , 2            
        mov bl , ':'
        call del_char 
        
        pop si                  
        add si , 9 ;para usar so os HHMMSS 
        
        mov di , offset filepath
        call app_str  
        
        mov si , offset ext_str
        mov di , offset filepath
        call app_str
         
        ;O CODIGO A BAIXO TIRA OS ESPACOS DA STR
        ;NAO SEI SE }E PRECISO!!! 
        
        ;mov si , [bp - 2]
        ;mov bl , ' '
        ;call del_char
        
        ;Apartir daqui a string esta pronta 
        
        ;isto tem de ser feito antes
        ;mov di , offset matriz_cell
        ;call load_matriz
         

        xor cx , cx   
        mov dx , offset filepath
        call fcreate     
        
        mov dx , offset filepath
        mov al , 2
        call fopen  
        
        mov bx , handler ;REDUNDANCIAS VER SE NAO ME CAGA OS VALORES
        mov cx , 1
        mov dx , offset fator_res     
        call fwrite 
        
        mov dx , offset relogio
        mov bx , handler ;REDUNDANCIAS VER SE NAO ME CAGA OS VALORES
        mov cx , RelDIM
        call fwrite
        
        mov bx , handler ;REDUNDANCIAS VER SE NAO ME CAGA OS VALORES
        mov cx , 11
        mov dx , offset Username
        call fwrite
        
        mov bx , handler ;REDUNDANCIAS VER SE NAO ME CAGA OS VALORES
        mov cx , 2
        mov dx , offset cell_num
        call fwrite             
        
        mov bx , handler ;REDUNDANCIAS VER SE NAO ME CAGA OS VALORES
        mov cx , 2
        mov dx , offset gen_num     
        call fwrite
        
        mov bx , handler
        mov cx , 15360
        mov dx , offset matriz_cell
        call fwrite 
        
        mov bx , handler
        mov dx , offset filepath
        call fclose
            
        pop di
        pop si
        pop cx 
        pop ax
        pop dx 
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
        
        ;call set_video      ;limpar o ecra
        call black_out
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
        
        mov ax, 2  ;hide mouse cursor
        int 33h
        
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
        
        mov ax, 1  ;hide mouse cursor
        int 33h
        
        pop bx
        pop dx
        pop cx
        pop ax 
        ret
    endp
    
    ;di = offsett de matriz para guardar 
    ;Funcao para o utilizador escrever as celulas no ecra
    fill_matriz proc
        
        push cx 
        push dx
        push ax
        push bx
        
        xor ax , ax   
        xor bx , bx
        not ax      ; ax = FFFFh
        
        xor cx , cx
        mov cl , fator_res 
        ;dec cl

        shr ax , cl
        shl ax , cl ;fica com 0 nos bits que eu nao quero ler, 
        
        loop1_fmtr:
        
            push ax
            mov ax, 1  ;show mouse cursor
            int 33h
            
            call gmp
                       
            or bx , bx    
            jz if1_fmtr   ;verifica se estou a clicar
                 
                    mov ax , 10
                    push ax
                    mov ax , 56
                    push ax      
                    mov ax , 1
                    push ax
                    mov ax ,204
                    push ax      
                    call m_hitbox 
                
                or ax , ax
                jz if1_fmtr
                      
                    pop ax      ;para nao cagar a stack do push la de cima 
                    jmp fim_fmtr  
                    
                if1_fmtr: 
            
            pop ax  
            call gmp
            push bx
            cmp bl , 1
            jne endif_fmtr
                
                push ax
                mov ax, 2  ;hide mouse cursor
                int 33h
                pop ax
                
                cmp dx , CHARDIM
                jb endif_fmtr 
                
                    and cx , ax
                    
                    sub dx , CHARDIM 
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
            ;cmp bl , 2 ;TEMPORARIO usa botao 2 para sair
            ;je fim_fmtr:
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
    
    ;Escreve as linha de char que indicam o estado jogo
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
        
       
    ;------------STRINGS------------; 
    
    ;di = str de destino
    ;cx  = numero de char a ler
    scanf proc
                 ;guardar valor anterior
        push bp 
        mov bp , sp  ;[bp -2] -> numero de char
        
        push cx
        push bx 
        push ax
        
        dec [bp - 2]
        
        xor cx , cx 
        xor bx , bx
        
        ;dec cx    ;reservo o ultimo char para terminar a str
        ;add bx,di
        
        scanf_Bgwhile1:
            
            
            mov ah,1
            int 21h  ;ler 1 char
          
            cmp al,0dh      ;para parar no enter
            je scanf_Endwhile1
            
            cmp al,08h          ;backspace
            jne endif_scanf 
                
                or cx , cx
                jz scanf_Bgwhile1         
                dec di           
                dec cx
                jmp scanf_Bgwhile1
            
            endif_scanf:
  
            mov [di], al    ;adiciona o char na memoria
                    
            inc di  
            inc cx 
            cmp cx , [bp - 2]
            jb scanf_Bgwhile1 
        scanf_Endwhile1:
        
        mov [di],0        
        
        pop ax  
        pop Bx  
        pop cx
        pop bp
        ret 
    endp
      
ends
    
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
    ;int to str
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
        
        pop ax
        pop bx
        pop dx  
        pop cx
        pop bp
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
    
    

;------------STRINGS------------;
      
    
    ;dx = linhas
    ;cx = colunas
    ;al = cor
    ;push1 = comprimento
    ;push2 = altura
    print_retangulo proc

        push bp
        
        mov bp,sp   ;[bp + 4] -> altura
                    ;[bp + 6] -> Comprimento
                           
        push bx     ;bx = comprimento
        push cx 
        
        mov bx , [bp + 6]
        ;xor bx,bx ;bx = 0
        
        mov ah, 0ch      
        push ax    
        
        lp_prret:   
            
            pop ax
            sub sp , 2
            int 10h     
            inc cx
            dec bx ; comprimento
            jnz lp_prret
            
            mov bx , [bp + 6]       ;reset do comprimento
            sub cx , bx
            inc dx          ; proxima linha
            dec word ptr[bp + 4]
            mov ax , [bp + 4]       
            or ax , ax
            
        jnz lp_prret
        
        add sp , 2
        pop cx
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
    im proc 
        
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
    gmp proc 
        
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
    
    ;*****************************************************************
    ; m_hitbox - mouse hitbox
    ; descricao: rotina que verifica se o rato esta numa dada posicao
    ; input - 
    ; push 1 tamanho vertical
    ;/push 2 tamanho horizontal
    ;/push 3 posicao do canto sup esquerdo
    ;/push 4 posicao canto inferior direito 
    ; output - 
    ; destroi -  
    ;***************************************************************** 
    
    m_hitbox proc
     ;call mouse_release   
           
            push bp
            mov bp, sp
            
            push bx
            push dx
            push cx
        
            ;[bp + 4] pos horizontal canto sup esquerdo [bp + 8] tamanho horizontal 
            ;[bp + 6] pos vertical canto sup esquerdo   [bp + 10] tamanho vertical
            
            
            cmp dx, [bp + 6]       ;esta compreendido entre as verticais
            jb notRect        
            
            mov bx,[bp + 6]
            add bx,[bp + 10] 
            cmp dx, bx     
            ja notRect 
      
            cmp cx, [bp + 4]      ;esta compreendido entre as horizontais
            jb notRect 
            
            
            mov bx,[bp + 4]
            add bx,[bp + 8]
            cmp cx, bx
            ja notRect
            
            
            mov ax, 1;j? esta esta dentro?(foi o q ela disse :^))
            
            jmp rect
            
            notRect:  
            
            mov ax, 0
            
            rect:
            
            pop cx
            pop dx
            pop bx
            pop bp
            
            ret 8                          
    endp m_hitbox 
    
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
                       
 pepe_the_frog proc
        
        push dx
        push cx
        push bx
        push si 
               
        mov dx , 7 
        mov cx , 0
        mov bx , 16
        mov si , offset pepe  
        
        loop1_pepe:
            
                mov al,[si]             ;cor = valor na matriz, talvez trocar isto no futuro
                
                or [si],0
                jz if1_pepe

                    call print_quadrado            
                
                jmp endif1_pepe
                if1_pepe:
                    add cx , bx     ; proxima posicao
                
                endif1_pepe:
                
                inc si
                
                cmp cx , ECRAX            ;ate ao fim do ecra     
            
            jb loop1_pepe
            
            xor cx , cx         ;cx = 0
            add dx , bx         ;proxima linha
            cmp dx , ECRAY
        jb loop1_pepe
           
        
        pop si
        pop bx
        pop cx
        pop dx
        ret
    endp
    
     
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
                       
    ;------------------Files------------------
    
    ;*****************************************************************
    ; fcreate - file create
    ; descricao: rotina que cria um ficheiro
    ; input - dx - offset para o nome do ficheiro / cx- tipo de ficheiro 
    ; output - 
    ; destroi - 
    ;*****************************************************************
    
    proc fcreate
        push ax
        push bx
        
               
        mov ah, 3ch ;create file      
        int 21h 
        
        jnc fcreate_success ;salta se criar o ficheiro com sucesso
        
            call print_file_error
        
        fcreate_success:  
        
        mov handler, ax ; mover o handler do ficheiro para uma varaiavel global
        
        mov bx, ax ; colocar o handler em bx para fechar o ficheiro de seguida
        
        ;close file
        mov ah, 3eh ;close file
        int 21h
        
        jnc fcreateClose_success ;salta se fechar o ficheiro com sucesso 
        
            call print_file_error
        
        fcreateClose_success: 
        
        pop bx
        pop ax
        
        ret    
    endp fcreate
    ;*****************************************************************
    ; fopen - open file
    ; descricao: rotina que abre um ficheiro
    ; input - dx - offset para o nome do ficheiro \ al - 0 (read)/ 1(write)/ 2 R/W tipo de leitura    
    ; output - bx file handler 
    ; destroi - 
    ;*****************************************************************
    
    proc fopen
        push ax
               
        mov ah, 3dh ; open file file      
        int 21h 
        
        mov handler, ax ; mover o handler do ficheiro para uma varaiavel global
        
        mov bx, ax ;move handler
        
        jnc fopen_success ;salta se criar o ficheiro com sucesso
        
            call print_file_error
        
        fopen_success:  
        
        pop ax

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
        
        mov ah, 3eh ;close file
        int 21h
        
        jnc fclose_success ;salta se fechar o ficheiro com sucesso 
        
            call print_file_error
        
        fclose_success:
        
        pop ax
        ret 
    endp fclose
    ;*****************************************************************
    ; fwrite - write file
    ; descricao: rotina que escreve para um ficheiro
    ; input - dx - offset para o buffer leitura \ bx - file handler \ cx - number of bytes to read  
    ; output - 
    ; destroi - 
    ;*****************************************************************
    proc fwrite
        push ax
        
        mov ah, 40h ;close file
        int 21h
        
        jnc fwrite_success ;salta se fechar o ficheiro com sucesso 
        
            call print_file_error
        
        fwrite_success:
        
        pop ax
        ret 
    endp fwrite
    ;*****************************************************************
    ; fread - read file
    ; descricao: rotina que le um ficheiro para um buffer
    ; input - dx - offset para o buffer de leitura \ bx - file handler \ cx - number of bytes to read  
    ; output - 
    ; destroi - 
    ;*****************************************************************
    proc fread
        push ax
        
        mov ah, 3fh ;read file
        int 21h
        
        jnc fread_success ;salta se fechar o ficheiro com sucesso 
        
            call print_file_error
        
        fread_success:
        
        pop ax
        ret 
    endp fread  
    
    
    ;*****************************************************************
    ; seek - read file line
    ; descricao: rotina que le uma linha de ficheiro para um buffer
    ; input -  
    ; bx - file handler 
    ; cx colunas
    ; dx deLinhas :( 
    ; push 1 num de carateres (bytes) por linha
    ; al 0,1,2 start of file ,current file position ,end of file (respetivamente)   
    ; output -  
    ; destroi - 
    ;*****************************************************************
    proc seek
        
        push bp  
        mov bp,sp
        
        push bx
        push ax
        push dx
        push cx
        
        mov cx, dx
        xor dx, dx 
        mov ax, [bp + 4] ;number of bytes de uma linha 
 
        mul cx
        mov cx,dx
        mov dx,ax
        
        pop bx
        add dx,bx
        adc cx, 0 ; 0 + CF  

        sub sp, 2 ;aponta para onde estava
        
        mov bx, [bp - 2]
        
        mov al,0 ;begin of file 
        
        
        mov ah, 42h ;read file (seek)
        int 21h
        
        jnc seek_success ;salta se fechar o ficheiro com sucesso 
        
            call print_file_error  
      
        seek_success:
        
        pop cx
        pop dx
        pop ax
        pop bx
        pop bp
        
        ret 2 
    endp seek 
    
    ;escreve "File error num:XXXXX",
    ;sendo XXXXX -> o numero do erro em decimal  
    ;recebe em ax o numero do erro
    print_file_error proc 
        
        push cx 
        push dx
        push bx
        push si
        push ax 
        
        mov AH ,2
        xor dx ,dx 
        xor bh , bh;cursor na posicao 0,0
        INT 10h     
        
        mov si , offset str_file_error
        mov bh , 0
        call printf
        
        pop ax 
        mov cx , 5
        call print_int;escreve o numero do erro em decimal
        
        pop si
        pop bx
        pop dx
        pop cx
        ret
    endp
    
    ;------------------Files------------------   
    
      
    ;bx = numero de segundos  
    ;para o programa x segundos
    ;Provavelmente tem comportamentos estranhos no emulador
    ;incerteza -> tempo de espera existe ]bx - 1(seg) +- (incerteza do interrupt) , bx [
    sleep_key_press proc   
        push ax
        push bx
        push cx 
        push dx
        
        mov ah,2ch
        
        int 21h  ;get system time
        
        mov time0, dh ;segundo inicial
                  
        cmp time0, 50
        
        ja sleep_case ;quando no relogio temos 50 segundos  
        
        add time0, bl ;bx tem segundos
        
        sleep_lp:
        
            ;keypress
               push dx
               push ax 
                
               mov ah , 6
               mov dl , 255     ;interrupt de io
               int 21h     
                                                      
               pop ax
               pop dx
            ;keypress
            jnz sleep_end_lp 
        
        
            mov ah,2ch
            int 21h  ;get system time
            
            
            cmp time0, dh  
                          
            
            je sleep_end_lp

            jmp sleep_lp 
            
            
        sleep_case:
            
        mov cl, 60
        
        sub cl, time0    
             
        
        sleep_case_lp:
        
        ;keypress
             push dx
                push ax 
                
                mov ah , 6
                mov dl , 255     ;interrupt de io
                int 21h     
                                                      
                pop ax
                pop dx
        ;keypress 
        jnz sleep_end_lp 
        
        push cx
        mov ah,2ch       ;dh segundos
        int 21h  ;get system time 
        pop cx
        
        cmp cl, dh 
    
        je sleep_end_lp 
        
        jmp sleep_case_lp
          
        sleep_end_lp:
        
        pop dx
        pop cx
        pop bx
        pop ax
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
        mov al , 1 
        INT 33h 
        
        pop ax
        ret
    endp      
    
    black_out proc       
            
        push cx
        push dx  
        push ax
        
        mov al , 0
        mov dx , CHARDIM  
        mov cx , ECRAX    
        push cx
        mov cx , 192 
        push cx
        xor cx , cx
        call print_retangulo
        
        pop ax
        pop dx
        pop cx
        ret 
    endp
 
ends

end start ; set entry point and stop the assembler.
