; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$"
    CellColor db 10 ;berde 
    BRANCO equ 15
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

    ;MAIN
   
    call set_video 
    
    call printMenu
   
    
    
   
   
    
    ; add your code here
            
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
    
    ;ROTINAS

    ;*****************************************************************
    ; im - initialize mouse
    ; descricao: rotina que inicializa o rato
    ; input -  
    ; output - ax=0FFFFH if successfull if failed ax=0 / bx number of buttons
    ; destroi - 
    ;*****************************************************************     
    im proc 
        push ax
        
        mov ax, 0;initialize mouse
        int 33h
        
        pop ax    
        ret
    endp im
    ;*****************************************************************
    ; gmp - get mouse position
    ; descricao: rotina que devolve a posicao do rato
    ; input -  
    ; output - dx=ycoord /cx=xcoord / bx 1 left /click/ bx 2 right click/ bx 3 both clicks
    ; destroi -  
    ;*****************************************************************     
    gmp proc 
        push ax
        
        mov ax, 3;initialize mouse
        int 33h 
        
        shr cx, 1 ; cx/2 BUG
        
        pop ax    
        ret
    endp gmp

    set_video proc
        
        push ax
        
        mov ax,13h 
        int 10h
        
        pop ax
        ret
    endp set_video  
    
     
    ;funcao que desenha um quadrado/retangulo
    ;dx = Linha do canto superior esquerdo
    ;cx = Coluna do canto superior esquerdo
    ;al = cor
    ;push 1 = tamanho vertical
    ;push 2 = tamanho horizontal
    draw_rect proc
        
        push bp
        mov bp,sp       ;[bp + 6] -> tamanho Vertical
                        ;[bp + 4] -> tamanho horizontal
        
        
        
        mov bx,[bp + 6]       
        call drawVline 
        
        mov bx,[bp + 4]
        call drawHline
        
        sub dx , [bp + 6]
        mov bx , [bp + 4]
        sub cx , bx
        call drawHline
        
        mov bx , [bp + 6]
        call drawVline
        
        
        ;pop cx 
        pop bp
        ret 4
        
    endp
                  
    
    ;dx = Linha
    ;cx = inicio (Coluna)   ; destroi
    ;al = cor
    ;bx = tamanho
    ;draw vertical line
    drawHline proc    
        ;push bp     ;[bp + 4] -> tamanho 
        ;mov bp,sp   
        
        push ax

        
        add bx , cx ; aponta para o ultimo pixel da linha
        mov ah , 0ch
        
        loop1_Vline:
            
            int 10h  
            inc cx
            cmp cx,bx
        jb loop1_Vline 
        

        pop ax
        ret   
    endp
    
             
    ;dx = Inicio (Linha)
    ;cx = Coluna   ; destroi
    ;al = cor
    ;bx = tamanho
    ;draw vertical line
    drawVline proc
        
        push ax
        
        add bx , dx ; aponta para o ultimo pixel da linha
        mov ah , 0ch
        
        loop1_Hline:
            
            int 10h  
            inc dx
            cmp dx,bx
        jb loop1_Hline 
        
   
        pop ax
        ret
        
        ret    
    endp 
    ;*****************************************************************
    ; printMenu - imprime menu
    ; descricao: rotina que imprime o menu
    ; input -  
    ; output - 
    ; destroi - 
    ;***************************************************************** 
    printMenu proc
        
        ;funcao que desenha um quadrado/retangulo
        ;dx = Linha do canto superior esquerdo
        ;cx = Coluna do canto superior esquerdo
        ;al = cor
        ;push 1 = tamanho vertical
        ;push 2 = tamanho horizontal   
        mov dx, 10
        mov cx, 106
        mov al,BRANCO 
        push 30
        push 106
        call draw_rect  ;rect bem vindo
        
        mov dx, 60
        mov cx, 60
        push 20
        push 80
        call draw_rect  ;rect jogar 
        
        mov dx, 100
        mov cx, 60
        push 20
        push 80
        call draw_rect  ;rect exemplos
        
        mov dx, 140
        mov cx, 60
        push 20
        push 80
        call draw_rect  ;rect retomar
        
        mov dx, 60
        mov cx, 180
        push 20
        push 80
        call draw_rect  ;rect top 5 
        
        mov dx, 100
        mov cx, 180
        push 20
        push 80
        call draw_rect  ;rect creditos
        
        mov dx, 140
        mov cx, 180
        push 20
        push 80
        call draw_rect  ;rect sair
        
     
        ret
    endp printMenu    
    
    
    
ends    
end start ; set entry point and stop the assembler.
