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
        pop bp
        ret
         
    endp
