;bx = numero de segundos  
    ;para o programa x segundos , ou ate clicar numa tecla
    ;Provavelmente tem comportamentos estranhos no emulador
    ;incerteza -> tempo de espera existe ]bx - 1(seg) +- (incerteza do interrupt) , bx [
    sleep_key_press proc
        
        push cx 
        push dx
        push ax
        push bx
             
        mov ah , 2ch
        
        int 21h
        mov al , dh
        
        lp1_slpkp:
                
                push dx
                push ax 
                
                mov ah , 6
                mov dl , 255
                int 21h     
                
                pop ax
                pop dx
                
                jnz fim_cslp    ;verifica por keypress
                
                int 21h
        
            cmp dh , al     ;enquanto estiver no msm segundo repete
            je lp1_slpkp
            
            dec bx
            jz fim_slpkp
            
                int 21h 
                mov al , dh
                jmp lp1_slpkp
            
        fim_slpkp:
        
        pop bx
        pop ax
        pop dx 
        pop cx
        ret
        
    endp
