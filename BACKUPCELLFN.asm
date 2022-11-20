;dx = Linha
    ;cx = Coluna
    ;posicao do pixel do canto superior esquerdo da celula
    ;push1 = lado do quadrado  (NAO PRECISO)
    cell_statusV2 proc
                      ;[bp + 4] -> Lado do quadrado         (NAO PRECISO)
        push bp       ;[bp - 2] -> dimx matriz
        mov bp , sp   ;[bp - 4] -> dimy matriz 
                      ;[bp - 6] -> numero de vizinhos
        
        sub sp , 6    ;guardar espaco na stack para as variaveis
        
        push bx
        push ax
        push cx
        push dx
        
        mov bl , 11111111b   ;comeco a poder ler todos os vizinhos 
        xor ax , ax
        mov al , lado_cell
        
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
        xor ax , ax 
        inc ax
        
        pop dx
        pop cx
        
        loop1_cst:
        
        
        
        pop ax    
        pop bx
        
        pop bp 
        ret
    endp