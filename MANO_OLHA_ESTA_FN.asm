;dx = Linha
    ;cx = Coluna
    ;posicao do pixel do canto superior esquerdo da celula
    cell_status proc
        ;FALTA LER O ESTADO INICIAL DA CELULA
        
                      ;[bp - 2] -> numero de vizinhos
                      ;[bp - 4] -> lado_cell
        push bp       ;[bp - 6] -> posx max vizinho na matriz
        mov bp , sp   ;(nao usei)[bp - 8] -> posy max vizinho na matriz 
                      
        
        sub sp , 6    ;guardar espaco na stack para as variaveis
        
        push bx
        push ax
        push cx
        push dx
        
        mov [bp - 2] , 0
        mov bl , 11111111b   ;comeco a poder ler todos os vizinhos 
        xor ax , ax
        mov al , lado_cell 
        mov [bp - 4], ax  
        
        mov [bp - 6] , cx        ;limite horizontal
        add [bp - 6] , ax        ; ax = [bp - 4] = lado_cell            
        
        ;mov [bp - 8] , dx       ;limite vertical
        ;add [bp - 8] , [bp - 4] 
        
        ;sub dx , CHARDIM    ;para nao contar com a linha de char
        
        ;verificar cantos
        
        cmp dx , CHARDIM        ;ver se esta no lado de cima
        jne if1_cst
            and bl , 00011111b  ;nao le nenhuma das posicoes de cima
        if1_cst:
        
        or cx , cx              ;Ve se esta no lado esquerdo
        jnz if2_cst
            and bl , 01101011b
        if2_cst: 
        
        add dx , ax      ;porque a posicao dx,cx esta no canto superior esquerdo do quadrado da celula
        cmp dx , ECRAY
        jne if3_cst
            and bl , 11111000b  ;Ve se esta na ultima linha
        if3_cst:
        
        add cx , ax
        cmp cx , ECRAX
        jne if4_cst
            and bl , 11010110b  ;Ve se esta no lado direito
        if4_cst:
        ;end verificar cantos
        
        ;LEBRAR QUE CAGUEI OS VALORES EM CX E DX
        mov bh , 10000000b
        
        mov ah , 0Dh
        
        pop dx
        pop cx
        
        sub sp , 2          ;Mantem cx na stack
        
        sub dx , [bp - 4]  ;(-1,-1)
        sub cx , [bp - 4]  ;[bp - 4] -> lado da celula
        
        loop1_cst:      
        
                test bh , bl     ;para saber se ]e para ler aquela posicao
                jnz if5_cst:    
                    
                    int 10h     ;ler a cor do pixel
                    or al , al  ;saber se a cor do pixel ]e preto ou nao
                    jz if5_cst
                        inc [bp - 2] ;-> numero de vizinhos
                        
                if5_cst:
                
                shr bh , 1          ;testar o proximo bit
                add cx , [bp - 4]      
                cmp cx , [bp - 6]   ;saber se chegou ao limite
            jb  loop1_cst
            
            pop cx
            sub sp , 2              ;mantem cx na stack
            
            cmp bh , 00010000b      ;se bh = 00100000b entao estou na primeira linha(mais facil de vizualizar com o excel)
            jb fimloop_cst
            
                mov bh , 00000100b 
                
                add dx , [bp - 4]       ;para ler as linhas por baixo da celula
                add dx , [bp - 4]
 
            jmp loop1_cst 
            
        fimloop_cst:
        ;Linhas da celula sao um caso especial por causa da propria celula
            mov bh , 00010000b 
            
            sub dx , [bp - 4]
            
            loop2_cst:
                test bh , bl
                
                jnz if6_cst:    
                        
                    int 10h     ;ler a cor do pixel
                    or al , al  ;saber se a cor do pixel ]e preto ou nao
                    jz if6_cst
                        inc [bp - 2] ;-> numero de vizinhos
                        
            if6_cst:
            
            cmp bh , 00010000b
            jne endlp2_cst
                shr bh 
                add cx , [bp - 4]       ;para ler a coluna a direita da celula
                add cx , [bp - 4]
                jmp loop2_cst 
                    
        endlp2_cst:
        
        ;Decide estado da celula 
        jnz if7_cst
            
            cmp [bp - 2] , 3
            jne if7_cst
                mov bl , 2
                jmp fim_cst
                
        if7_cst:
        
        cmp [bp - 2] , 2
        jb if8_csft
            cmp [bp - 2] , 3
            ja if8_csft 
                xor bl , bl;ser diferente para criar ou manter poupa ciclos
                jmp fim_cst
            
        if8_csft:
        
        mov bl , 1
        
        fim_cst:
        
        pop ax    
        pop bx
        
        add sp , 6
        pop bp 
        ret
    endp
