; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$"
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
   
    
   
   
    ; add your code here
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    

    ;espera que nenhum botao do rato esteja a ser pressionado
    mouse_release proc
        
        push ax
        push bx
        push cx 
        push dx   
        
        mov ax , 3
        
        lp1_msrl:
            
            int 33h
            or bx , bx 
        jnz lp1_msrl    
        
        pop dx
        pop cx
        pop bx 
        pop ax
        ret
    endp

ends
    
    ;ROTINAS

;*****************************************************************
; im - initialize mouse
; descricao: rotina que inicializa o rato
; input -  
; output - ax=0FFFFH if successfull if failed ax=0 / bx number of buttons
; destroi - 
;*****************************************************************     
im proc 
    
    mov ax, 0;initialize mouse
    int 33h
    
        
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
    
    mov ax, 3;initialize mouse
    int 33h 
    
    shr cx, 1 ; cx/2 BUG
    
        
    ret
endp gmp 


end start ; set entry point and stop the assembler.
