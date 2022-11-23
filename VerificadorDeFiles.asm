; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$",0 
    handler dw ? 
    str_error_create db "falha ao criar ficheiro",0   
    str_error_close db "falha ao fechar ficheiro",0
    str_error_open db "falha ao abrir ficheiro",0 
    str_error_write db "falha ao escrever no ficheiro",0
    str_error_read db "falha ao ler do ficheiro",0
    fileName db "c:\porcaontas",0
    str_test db "carla ola",0 ;string de teste para escrita em ficheiro
    str_read db 20 dup(?) ;buffer de leitura  
    filepath db "C:\gameOfLife", 0 	; path to be created  
    filepathcmp db "gameOfLife", 0 	;name of path to be compared  
    filepathExemplos db "C:\gameOfLife\Exemplos", 0 	; path to be created 
    filepathExemploscmp db "gameOfLife\Exemplos", 0 
    fileNameTop5 db "c:\gameOfLife\TOP5.txt",0  ;por agora 
    filenameLogs db "c:\gameOfLife\Logs.txt",0
    
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
   
        
                   
        call dfcheck ;verifica se diretorias e files tao em ordem           
    

       
ends

;ROTINAS
    ;*****************************************************************
    ; dfcheck - directory and file check
    ; descricao: rotina que verifica a presenca das diretorias e ficheiros do jogo
    ; input - 
    ; output - 
    ; destroi - 
    ;***************************************************************** 
    proc dfcheck
        
        push ax
        push bx
        push dx
        push cx
        push di
        push si
        
        
        ;parametros
        mov al, 2   ;0 - read \ 1 - write \ 2 read/write
        mov dx, offset fileNameTop5
        call fopen
        
        ;parametros
        mov dx, offset filepath ;nome da diretoria a criar
        mov di, offset filepathcmp ;nome da diretoria a comparar 
        mov cx,11;numero de bytes do cmp
        call mdirectory 
        
        ;parametros
        mov dx, offset filepathExemplos 
        mov di, offset filepathExemploscmp 
        mov cx,20
        call mdirectory
        
        ;parametros
        mov al, 2   ;0 - read \ 1 - write \ 2 read/write
        mov dx, offset fileNameTop5
        call fopen  ;cria uma file caso nao exista  
        
        ;parametros
        mov bx, handler
        mov dx, offset fileNameTop5  
        call fclose
        
        ;parametros
        mov al, 2   ;0 - read \ 1 - write \ 2 read/write
        mov dx, offset fileNameLogs
        call fopen  ;cria uma file caso nao exista 
        
        ;parametros
        mov bx, handler
        mov dx, offset fileNameLogs 
        call fclose
        
        pop si
        pop di
        pop cx
        pop dx
        pop bx
        pop ax
    
    endp dfcheck 
;*****************************************************************
; mdirectory - make directory
; descricao: rotina que cria uma diretoria do jogo, (caso nao exista)
; input - dx - offset para o nome da diretoria 
; output - 
; destroi - 
;*****************************************************************

proc mdirectory
    push ax
    
    mov ah, 47h
    int 21h ;vai para si o nome da diretoria
 
    repe cmpsb 
    
    jz dExists        ;isto ta cagado provavelmente sou eu 
    
    
    mov ah, 39h
    int 21h 
    
    dExists:
    
    
    pop ax
    ret
endp mdirectory    
;*****************************************************************
; fcreate - file create
; descricao: rotina que cria um ficheiro
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
           
    mov ah, 3dh ; open file       
    int 21h 
    
    jnc fopen_success ;salta se criar o ficheiro com sucesso
    
    cmp al, 3;codigo de erro caso ficheiro nao exista
    jne outroErro                                          
    
    
    ;parametros
    
    mov cx,0 ;normal file
    ;dx tem o offset certo (parametro de entrada)
    call fcreate
    
    jmp fopen_success
    
    outroErro:
    
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
    
    ret 
endp fread

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



end start ; set entry point and stop the assembler.
