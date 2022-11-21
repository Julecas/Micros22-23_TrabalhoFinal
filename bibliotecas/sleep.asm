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
            
            dec bx
            jz fim_slp
            
                int 21h 
                mov al , dh
                jmp lp1_slp
            
        fim_slp:
        
        pop bx
        pop ax
        pop dx 
        pop cx
        ret
        
    endp
