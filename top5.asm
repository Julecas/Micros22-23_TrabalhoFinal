; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$"
    str_error_create db "falha ao criar ficheiro",0   
    str_error_close db "falha ao fechar ficheiro",0
    str_error_open db "falha ao abrir ficheiro",0 
    str_error_write db "falha ao escrever no ficheiro",0
    str_error_read db "falha ao ler do ficheiro",0
    fileName db "c:\TOP5.txt",0 
    str_rodapeTop5 db "GEN  CELLS  PLAYER      DATE     TIME",0AH,0DH,0
    str_read db 20 dup(?) ;buffer de leitura
   
    handler dw ? 
    
    c equ 6  


    
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
    
    call set_video
    
    call top5        
    
    
    mov ax, 4c00h ; exit to operating system.
    int 21h  
    
    
    
    
    ;ROTINAS 
    set_video proc
        
        push ax
        
        mov ax,13h 
        int 10h
        
        pop ax
        ret
    endp set_video  
    ;*****************************************************************
    ; top5 
    ; descricao: rotina que apresenta o top 5 jogadores
    ; input -  
    ; output - 
    ; destroi - ax 
    ;***************************************************************** 
    proc top5
        
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
        
        push bp 
        mov bp, sp
        
        push 6  ;[bp + 4] -> VlineFile
        
            readLoop:
            mov cx, 0
            push cx
            
            ;parametros
           
            mov bx, handler
            mov dx, offset str_read
            mov cx, 3 ;number of bytes to read
            call fread
           
            
            mov dl, 1
            mov dh, [bp + 4]
            mov si, offset str_read ; buffer for data
            call print_pos ;print geracao 1a linha 
            
            ;parametros
            mov bx, handler
            mov cx, 4 ;number of bytes to read  
            mov dx, offset str_read
            call fread 
            
            
            mov dl, 6
            mov dh, [bp + 4]
            mov si, offset str_read ; buffer for data
            call print_pos ;rint cellnumber 1a linha
            
            ;parametros
            mov bx, handler
            mov dx, offset str_read
            mov cx, 10 ;number of bytes to read
            call fread 
        
            
            mov dl, 12
            mov dh, [bp + 4]
            mov si, offset str_read ; buffer for data
            call print_pos ;print player 1a linha 
            
            ;parametros
            mov cx, 8 ;number of bytes to read 
            mov dx, offset str_read
            mov bx, handler
            call fread
            
            
            mov dl, 23
            mov dh, [bp + 4]
            mov si, offset str_read ; buffer for data
            call print_pos ;print data 1a linha  
            
            ;parametros
            mov cx, 9 ;number of bytes to read 
            mov bx, handler    
            mov dx, offset str_read
            call fread
          
            
            mov dl, 32
            mov dh, [bp + 4]
            mov si, offset str_read ; buffer for data
            call print_pos ;print hora 1a linha 
            
            pop cx
            
            add [bp + 4], 1; new line
            
            cmp cx, 4
            je readLoop
        
        
        
        
        
        
        
        
        
        pop cx
        pop ax
        pop dx
        
        ret
    endp top5
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
ends

end start ; set entry point and stop the assembler.
