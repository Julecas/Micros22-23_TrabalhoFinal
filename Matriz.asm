; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$" 
    matriz_vec db 15000 dup(13)   ; 150 * 100
    matriz2_vec db 15000 dup(?)   ; 150 * 100
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

    ; add your code here
    
    call set_video
    
    mov cx ,15000            
    mov si,offset matriz_vec
    
    loop1Main:
    
        test si,1  ; verifica se ]e par
        jnz ifmain
            mov [si],3
        ifmain:
        inc si
        dec cx
        or cx,cx
    jnz loop1Main
                
    ;encer matriz
    
    mov ah, 1
    int 21h
    mov si , offset matriz_vec
    mov ax , 150
    mov bx , 100
    call print_double
    
    ;lea dx, pkey
    ;mov ah, 9
    ;int 21h        ; output string at ds:dx
    
     
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h   
    
    
    
    
    mov al,14
    mov dx,4
    mov cx,4 
    mov bx,20
    call print_quadrado
    mov al,15
    call print_quadrado
    
     
    mov si,offset matriz_vec
    mov di,offset matriz2_vec
    mov dx,150
    mov cx,100
    call matriz_cpy 
    
    
    ;si = matriz vec
    ;dx = Linhas
    ;cx = Colunas 
    ;Ax = Limite de Linhas
    ;Bx = Limite de colunas
    get_cell_status proc
        
        
        
    endp
    
    ;si = offset matriz
    ;Ax = colunas
    ;Bx = Linhas
    print_double proc
        
        push bp 
        mov bp,sp
        
        shl bx,1  ;multiplicar ambos por dois
        shl ax,1  ;para que limite seja o do ecra e nao o da matrix
        push bx ;bp - 2 = Linhas
        push ax ;bp - 4 = Colunas
        push dx ;linha
        push cx ;coluna
        
        xor dx,dx
        xor cx,cx 
        
        mov bx,2
              
        loop1_prtdbl:
            
            loop2_prtdbl:
                
                mov al ,[si]
                or al,al
                jz elseif1_prtdbl
                
                    call print_quadrado;deixa cx na posicao certa    
                    jmp endif1_prtdbl
                    
                elseif1_prtdbl:
                    add cx,2    
                endif1_prtdbl:
                
                inc si
                ;inc cx
            cmp cx,[bp - 4]
            jb loop2_prtdbl             
            
            xor cx,cx 
            add dx,bx  ;proximo quadrado
            ;inc dx
        cmp dx,[bp - 2] 
        jb loop1_prtdbl
              
        
        pop cx
        pop dx            
        pop ax
        pop bx
        pop bp 
        ret
    endp
    
    ;dx = linhas
    ;cx = colunas
    ;al = cor
    ;bx = largura
    print_quadrado proc
        ;push ax
        push bp
        
        mov bp,sp
        sub bp,2    ;aponta para a largura do ecra
        
        push bx
        
        xor bx,bx ;bx = 0
        
        mov ah, 0ch
        
        lp_prtqd:
            lp2_prtqd:
                
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
    
    ;recebe uma posicao x,y , de uma matrix, bidimenssional e devolve a posicao no vetor unidimenssional
    ;Dx = dimx (Numero de Colunas)
    ;Ax = Linha  (1,y)
    ;Cx = Coluna (1,x)
    ;dx,ax= Posicao final
    get_matriz_pos proc
        
        xchg dx,cx
        push dx
        xor dx,dx
        mul cx      ;Linhas * Dimx
        
        pop cx      ;Coluna
        add ax,cx
        
        jnc matriz_pos_add
                       
            inc dx  ;add carry 
                       
        matriz_pos_add: ret
    endp 
        
    
    ;si = offset matriz original
    ;di = offset matriz nova
    ;Cx = Colunas           ;em bytes
    ;Dx = Linhas            ;em bytes
    ;Cx*Dx < 16 bits
    matriz_cpy proc
                 
        push ax
        push cx
        push dx
                     
        mov Ax,Dx
        xor Dx,Dx
        mul Cx   
        
        mov cx,ax
             
        cld
             
        rep movsb 
            
        pop dx
        pop cx
        pop ax      
        ret
    endp
    
     set_video proc
        
        push ax
        ;xor ax,ax
        mov ax,13h 
        int 10h
        
        pop ax
        ret
    endp
        
ends

end start ; set entry point and stop the assembler.
