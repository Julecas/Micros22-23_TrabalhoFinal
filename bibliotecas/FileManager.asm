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
    
    
    ;parametros
    mov dx, offset fileName ;nome do ficheiro a criar 
    mov cx, 0   ;file attributes 0-normal
    call fcreate 
    
    ;parametros
    mov al, 2      ;0 - read \ 1 - write \ 2 read/write  
    mov dx, offset fileName
    call fopen 
    
    ;parametros
    mov cx, 20 ;number of bytes to write
    mov bx, handler 
    mov dx, offset str_test  ;data to write 
    call fwrite 
    
    ;parametros
    mov bx, handler ; file handler
    mov dx, offset fileName
    call fclose 
    
    ;parametros
    mov al, 2      ;0 - read \ 1 - write \ 2 read/write  
    mov dx, offset fileName
    call fopen  
    
    ;parametros 
    mov cx, 20 ;number of bytes to read
    mov bx, handler 
    mov dx, offset str_read  ;data to write 
    call fread 
    
    ;parametros
    mov bx, handler ; file handler
    mov dx, offset fileName
    call fclose 
    
    ;parametros
    mov si, offset str_read
    mov ax,0 ;0 impressao de strings \ 1 - impressao de inteiros
    mov bx,0 ;0 impressao normal \ 1 impressao em minusculas\ 2 impressao em maisculas\3 impressao com enter no final
    call printf 
    
    
    
    
    
    
   
    ; add your code here
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

;ROTINAS
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
           
    mov ah, 3dh ; open file file      
    int 21h 
    
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
;*****************************************************************
; printf - string output
; descricao: rotina que faz o output de uma string NULL terminated para o ecra
; input - si=deslocamento da string a escrever desde o início do segmento de dados 
; output - nenhum
; destroi - al, si
;*****************************************************************   

printf proc
    
    push ax
    push si
    push bx
    push dx 
    push cx
    
    
    
    L2: 	
    
    cmp ax,01H
    je AX01h 
    
    
    mov al,byte ptr [si]
    or al,al
    jz fimprtstr
    call co
    inc si
    jmp L2 ;loop 2
    fimprtstr:
    
    cmp bx,04H
    jne L04H    
    
    mov ah, 02H
    mov dl, 0DH ;meter enter em dl (estou a estragar o valor de dl mas nao faz mal)          
    int 21H
    mov dl, 0AH ;meter enter em dl (estou a estragar o valor de dl mas nao faz mal)          
    int 21H 
    
    jmp L04H
    
    AX01h:
    
    mov ax ,[si] 
    
    L4:
    
    mov bx, 10   
        
    div bx     ;mete o resultado de dl com al em ax  
    
    
    cmp al,0 ;fim da divisao  
    je L04H
    
    add ah, 48  ; converte o inteiro em 
       
    mov al,ah

    call co    
    
    jmp L4 
    
    L04H:
    
    pop cx
    pop dx
    pop bx
    pop si
    pop ax
    
    ret
printf endp

;*****************************************************************
; co - caracter output 
; descricao: rotina que faz o output de um caracter para o ecra
; input - al= caracter a escrever
; output - nenhum
; destroi - nada
;*****************************************************************  

co proc
    push bx
    push ax
    push dx 
    
    
    
    mov ah,02H     ;para o interrupt
    mov dl,al  
    
    
    cmp bx, 00h    ;compara com o comportamento da impressao
    je L00h
    cmp bx, 04h    ;compara com o comportamento da impressao
    je L00h
    
    cmp bx, 01h
    je L01h
    cmp bx, 02h
    je L02h 
   

    L02h:
    
    cmp dl, 'a'
    jb L00h 
    
    sub dl, 'a'-'A' ;tabela ascii              ;coloca em maiscula
    jmp L00h
    
    
    L01h:
    cmp dl, 'a'
    jae L00h 
    
    add dl, 'a'-'A' ;tabela ascii              ;coloca em minuscula
    
    L00h:      ;tratamento normal da string
    
    
    int 21H
    
    pop dx
    pop ax
    pop bx
    ret
co endp
ends
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


end start ; set entry point and stop the assembler.
