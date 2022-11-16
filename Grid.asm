; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$" 
    GRIDCOLOR equ 15
    ECRAY equ 200
    ECRAX equ 320  
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
    
    call set_video
    
    mov dx , 10
    ;mov cx , 100
    mov al , 10
    push 5
    push 7
    call draw_grid
    
    mov dx,50
    mov al,12
    push 4
    push 10
    call draw_column
    
    mov al , 10
    mov dx , 49
    call draw_line  
    
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx 
    
    mov dx , 100
    mov cx , 100
    mov al , 10
    mov bh , 50
    mov bl , 69
    call print_retangulo
    
    call wait_key_press
    
    mov ax, 4c00h ; exit to operating system.
    int 21h 
    
    ;dx = pos inicial de linhas  
    ;Al = cor
    ;push 1 = altura dos quadrados
    ;push 2 = comprimentro dos quadrados
    draw_grid proc
        
        push bp
        mov bp,sp       ;[bp + 4] -> altura
                        ;[bp + 6] -> comprimento
        push cx
        
        xor cx,cx       ;cx = 0
        
        loop1_drgrd:
        
            call draw_line
            inc dx
            push [bp + 4]
            push [bp + 6]
            call draw_column
            add dx , [bp + 4]
            cmp dx , ECRAY 
            jb loop1_drgrd
                   
        
        pop cx 
        pop bp
        ret 4
        
    endp
    
    ;Desenha tracos verticais comecando no dx, com push 1 de altura e push 2 de largura
    ;Dx = Linha de inicio
    ;Al = cor
    ;push 1 = altura da coluna
    ;push 2 = largura entre colunas
    draw_column proc
    
        push bp     ;[bp + 6] -> Altura     (Push 1)
        mov bp,sp   ;[bp + 4] -> Largura    (Push 2)
        
        push ax
        push bx
        push cx
                            ;para acerta com os if statements 
        inc [bp + 4]        ;se nao nao conta com o ultimo
        
        xor bx,bx
        xor cx,cx           ;Cx = 0
         
        mov ah , 0ch        ;interrupt
        mov bx , [bp + 6]   ;Altura   (evita estar sempre a ler a stack)
        
        loop1_drclm:
            
            int 10h
            inc dx
            dec bx              ;dec e inc afeta flags
            jnz  loop1_drclm    ;repete enquando nao tiver repetido altura vezes
                                        
            mov bx , [bp + 6]
            sub dx , bx
            add cx , [bp + 4]
            cmp cx , ECRAX      ;procura o limite do ecra
        jb loop1_drclm
        
        pop cx
        pop bx
        pop ax
        pop bp
        
        ret 4
        
    endp
    
    ;Desenha uma linha na linha numero Dx no ecra, conta a partir do 0
    ;Dx = Linha
    ;Al = Cor
    draw_line proc
    
        push cx
        push ax
        
        mov cx, ECRAX
        mov ah, 0ch
        
        loop1_drln:
            dec cx  
            int 10h        
        jnz loop1_drln
        
        pop ax
        pop cx
        ret    
    endp
    
    
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
       
ends

end start ; set entry point and stop the assembler.

