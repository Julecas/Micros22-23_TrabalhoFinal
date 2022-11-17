; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$"  
    CellColor equ 15
    ECRAY equ 200
    ECRAX equ 320
    matriz_cell db 15600 dup(0) ; (320 - 8)/2 * (200)/2 
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

    call set_video
 
            
    
    mov dx , 7
    mov cx , 0
    mov bx , 4
    mov si , offset matriz_cell
    call print_matriz
        
    
    mov dx , 10
    mov cx , 50
    mov al , 14     
    
    mov bx , 9
    call print_quadrado
    
    
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
    
    ;di = offsett de matriz para guardar
    fill_matriz proc
        
        
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
                inc cx
                cmp cx,ECRAX            ;ate ao fim do ecra     
            
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
        
ends

end start ; set entry point and stop the assembler.

