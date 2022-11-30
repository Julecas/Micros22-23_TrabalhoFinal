; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "$"
    strg db 15 dup(?)
    str2 db "PIXA aaAA",0dH,0aH,0
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
    
    mov di , offset strg
    mov cx , 15
    call scanf
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h             
    
    
    ;di = str de destino
    ;cx  = numero de char a ler
    scanf proc
                 ;guardar valor anterior
        push bp 
        mov bp , sp  ;[bp -2] -> numero de char
        
        push cx
        push bx 
        push ax
        
        dec [bp - 2]
        
        xor cx , cx 
        xor bx , bx
        
        ;dec cx    ;reservo o ultimo char para terminar a str
        ;add bx,di
        
        scanf_Bgwhile1:
            
            
            mov ah,1
            int 21h  ;ler 1 char
          
            cmp al,0dh      ;para parar no enter
            je scanf_Endwhile1
            
            cmp al,08h          ;backspace
            jne endif_scanf 
                
                or cx , cx
                jz scanf_Bgwhile1         
                dec di           
                dec cx
                jmp scanf_Bgwhile1
            
            endif_scanf:
  
            mov [di], al    ;adiciona o char na memoria
                    
            inc di  
            inc cx 
            cmp cx , [bp - 2]
            jb scanf_Bgwhile1 
        scanf_Endwhile1:
        
        mov [di],0        
        
        pop ax  
        pop Bx  
        pop cx
        pop bp
        ret 
    endp
      
ends

end start ; set entry point and stop the assembler.
