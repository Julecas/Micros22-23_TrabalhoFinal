; multi-segment executable file template.

data segment
    ; add your data here!
    
    fileNameTop5 db "c:\gameOfLife\TOP5.txt",0 
    str_rodapeTop5 db "GEN  CELLS  PLAYER      DATE     TIME",0AH,0DH,0
    str_read db 33 dup(0) ;buffer de leitura 
    str_top db 37 dup(0) 
    str_file_error db "File error num:",0 
    str_FilenameLog db "c:\gameOfLife\Logs.txt",0  
    nl db 0dh , 0ah  ;new line
    
    ;exemplos de logs para debugg
    
    str_relogio db "24/11/22 14:53:22",0;STR_Rel_DIM  dup(0)
    
    str_log db "00360960Novais    22/11/03 03:35:59",0      
    
    cell_num  dw 554
    
    gen_num dw 753
    
    Username db "joulecas  ",0
    
    lowerCells dw ? ;quem tem menos cells no top 5
   
    ;*********************************** DEBUGG
    
    handler dw ? 
    
    VlineFile equ 6  
    

   
    
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
    
    call writeLog
    
    ;call writeTop5
    
    ;call readtop5
        
    
    mov ax, 4c00h ; exit to operating system.
    int 21h  
    
    
    
    
    ;ROTINAS 
    
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

    ;input - dx - offset para o nome do ficheiro \ al - 0 (read)/ 1(write)/ 2 R/W tipo de leitura   
    ;output - bx file handler 
    
    mov dx, offset str_FilenameLog ;MARTIM TENS QUE MUDAR
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
      
        if_wl:
    
    ;input - dx - offset para o buffer de escrita \ bx - file handler \ cx - number of bytes to read  


             
    ;Di = inicio str destino
    ;Ax = num  
    ;cx = numero de char   
    ;int to str
    
    mov di,offset str_read  ;vou usar str_read como buffer de escrita
    mov ax, gen_num
    mov cx, 4 
    call int_str
    
    mov bx, handler
    mov dx,offset str_read
    mov cx, 4  
    call fwrite ;write gen     
    
    
    mov di,offset str_read  
    mov ax, cell_num
    mov cx, 4 
    call int_str
    
    mov bx, handler
    mov dx,offset str_read
    mov cx, 4  
    call fwrite ;write cell num 
    
    
    mov bx, handler
    mov cx, 10 
    mov dx,offset Username 
    call fwrite ;write name 
    
    
    mov bx, handler
    mov dx, offset str_relogio
    mov cx, 17 ;number of bytes to write
    call fwrite ;write date 
    
    
    mov bx, handler
    mov dx, offset nl
    mov cx, 2 ;number of bytes to write
    call fwrite ;write date  
    
    
    mov dx, offset str_FilenameLog
    call fclose
    
    pop ax
    pop cx
    pop dx
    pop di    
        ret
    endp writeLog     
    ;*****************************************************************
    ; writeTop5  
    ; descricao: rotina que escreve no top 5 um novo elemento
    ; input -  
    ; output - 
    ; destroi -  
    ;***************************************************************** 
    proc writeTop5
        
        mov dx, offset fileNameTop5      
        mov al, 2   ;0 - read \ 1 - write \ 2 read/write  
        call fopen 
         
        call tlcmp ; ISTO TA BOM 
        
        ;call wait_key_press ; DEBUGG
        
        cmp dx, 6
        je endWriteTop5 ;isto signifca que o gajo dos logs e tao mau tao mau
                        ;que nos so vamos cagar nele mesmo
        
        ;mov dx, offset fileNameTop5      
        ;mov al, 1   ;0 - read \ 1 - write \ 2 read/write  
        ;call fopen  
        
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
        
        ;TEMPORARIO, IRA SOFRER ALTERACOES NA SEMANA DE 7-14 DE DEZEMBRO 
        mov dx, offset str_log 
        mov cx,35  ;number of bytes to read
        call fwrite
            
        ;jmp writeTop5Lp                 
        
        endWriteTop5:
        
       
        
        mov bx, handler 
        mov dx, offset fileNameTop5  
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
        
    
        
        
        ;SEEK    
        ;input - bx - file handler 
        ;cx:dx offset from origin of new, file position  (cx-linha no ficheiro\ dx- coluna no fich?iro)
        ;al 0,1,2 start of file ,current file position ,end of file (respetivamente)
        
        mov bx, handler  
            
        mov dx,4   ;DeLinhas
        mov cx,4   ;colunas
  
        
         ;procura o numero de Cells do jogador em ultimo   
        
        tlcmpLp:
           
            mov ax, 37
            push ax
            call seek
            
            push cx
            push dx
        
            ;*****************************************************************
            ; fread - read file
            ; descricao: rotina que le um ficheiro para um buffer
            ; input - dx - offset para o buffer de leitura \ bx - file handler \ cx - number of bytes to read  
            ; output - 
            ; destroi - 
            ;*****************************************************************        
        
            mov bx, handler          
            mov cx, 4 ;bytes to read
            mov dx, offset str_top    
            call fread                 ;EEEEEEEEEPA TA A CAGAAAAAAAAAR AQUI :((
            
            
            ;parametros
            mov si, offset str_top
            mov cl, 4
            call str_int
            ;result stored in ax (menor numero de cells)
              
            ;mov lowerCells, ax ;menor valor de cells no top5
            
            ;parametros
            ;mov si, offset str_log  ;exemplo
            ;add si, 30 ;tou a tentar percorrer a string dos logs ate chegar a cell number
            ;mov cl, 4                  
            ;call str_int
            ;result stored in ax (menor numero de cells)                  
            
            pop dx 
            pop cx 
                              
            ;cmp ax, lowerCells  ;se o marmanjo for menor que o menor entao cagamos nele
            cmp cell_num, ax                                                                            
                                                                                         
            jb endTlcmp
            
            dec dx 
            
            cmp dx, -1  ;para se o gajo dos logs for realmen O REI
            je endTlcmp
                     
            jmp tlcmpLp:
        
            
            ;AGORA E ASSIM CARALHO OUVE BEM
            ;em cx e suposto teres
            ;dx = 4 se o marmanjo nao tinha mais cells que o ultimo (ou seja cagamos nele)
            ;dx = 3 se ele era maior que o menor
            ;dx = 2 se ele era maior que o quarto
            ;dx = 1 se ele era maior que o terceiro
            ;dx = 0 se ele for maior que o segundo
            ;dx = -1 se o dos logs for o maior O REI DELES TODOS portanto
            
            
        
        endTlcmp: 
        
        add dx, 2  ;agora ja nao
        
        pop si
        pop ax
        pop cx
        pop bx
                                                
        ret
    endp tlcmp    
    
    ;incicializa modo grafico
    set_video proc
        
        push ax
        
        mov ax,13h 
        int 10h
        
        pop ax
        ret
    endp set_video  
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
        
        mov dx, offset fileNameTop5 
              
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
           
            
            mov dl, 1
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
            
            mov dl, 6
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
        mov dx, offset fileNameTop5
        mov bx, handler
        call fclose
        
        pop cx
        pop ax
        pop dx 
        
        add sp, 2
        pop bp
        
        ret
    endp readtop5
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
        
        push bx
        push ax
        
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
        
        pop bx
        pop dx
        pop cx  
        pop ax
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
    
   ;para o programa ate receber keypress
    wait_key_press proc

        push ax

        mov ah, 1
        int 21h

        pop ax
        ret

    endp

 




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

ends

end start ; set entry point and stop the assembler.