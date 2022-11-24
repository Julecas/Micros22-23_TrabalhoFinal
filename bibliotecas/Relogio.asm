; multi-segment executable file template.

data segment
    
    STR_Rel_DIM equ 18 ; Formato "dd/mm/aaaa|HH:MM:ss",0
    RelDIM equ 7
    ;EXEMPLO
    Relogio db 23,10,22,22,41,10        ;dia 23 
                                        ;mes 10
                                        ;ano 2022
                                        ;hora 22
                                        ;minuto 41
                                        ;segundo 10    
   str_relogio db "24/11/22 14:50:22",0;STR_Rel_DIM  dup(0)
   str db 6 dup(0) 
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
    
    ;mov  di , offset Relogio
    ;call Ler_relogio
      
    
    mov si , offset str_relogio
    mov di , offset Relogio
    call strToRelogio     
    
    mov si , offset Relogio
    mov di , offset str_relogio  
    call make_relogio_str 
    
    mov si , offset str_relogio
    mov bl , 0
    call printf
    
    ;mov ax , 12345
    ;mov cx , 3
    ;mov di , offset str
    ;call int_str
    
    ;mov si , offset str
    ;mov bl , 0
    ;call printf
    
    ;mov si , offset Relogio
    ;call load_relogio_stack
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
     
    
    ;escreve a data e a hora para uma estrutura relogio
    ;Di = offset relogio
    Ler_relogio proc
        
        push ax
        ;push bx
        push cx
        push dx
        
        mov ah , 2ah    ;int get system date
        int 21h 
        
        mov [di] , dl
        inc di
        mov [di] , dh
        inc di
        
        xor dx , dx
        mov ax , cx
        mov cx , 100
        div cx      ;em dx ficam os ultimos dois digitos decimais
                    ;99 < 255
        mov [di] , dl              
        inc di  
        
        mov ah , 2ch;interrupt get system time
        int 21h
        
        mov [di] , ch
        inc di
        
        mov [di] , cl
        inc di
        mov [di] , dh
        
        pop dx
        pop cx
        ;pop bx
        pop ax
        ret   
        
    endp
    
    ;si = offset relogio
    ;di = offset str
    make_relogio_str proc
        
        ;push bp 
        ;mov sp , bp 
        
        ;sub sp , 2
        
        push cx 
        push ax
        
        xor ax ,ax 
        
        mov cx , 2
        
        mov al , [si]          ;dia
        call int_str
        
        mov [di] , '/'
        inc di
        inc si    
         
        mov cx , 2             ;mes
        mov al , [si]
        call int_str
        
        mov [di] , '/'
        inc di 
        inc si
        
        mov cx , 2             ;ano
        mov al , [si]
        call int_str               
        
        mov [di] , ' '
        inc di 
        inc si
        
        mov cx , 2
        mov al , [si]          ;hora
        call int_str
        
        mov [di] , ':'
        inc di
        inc si    
         
        mov cx , 2             ;minutos
        mov al , [si]
        call int_str
        
        mov [di] , ':'
        inc di 
        inc si
        
        mov cx , 2             ;segundos
        mov al , [si]
        call int_str   
        
        mov [di] , 0    ;terminar a str
        
        pop ax 
        pop cx
        ret
        
    endp
    
    ;si = offset string
    ;di = offset relogio
    ;usa uma string com data e hora 
    ;no formato dd/mm/aa HH:MM:ss e mete na estrutura de dados relogio
    strToRelogio proc
        
        push cx   
        push bx
        push ax
        
        mov cl , 2
        mov bx , RelDIM
        
        lp1_strrel:
                
            call str_int   
            
            mov [di] , al
            inc di
            
            add si , 3
        dec bx
        jnz lp1_strrel
        
        pop ax
        pop bx
        pop cx
        
        ret
    endp
    
    ;------------STRINGS------------;
    
    ;Ax = num
    ;cx = numero de char a escrever
    print_int proc
        
        push bp     ;[bp - 2] -> numero de char
        mov bp,sp
        
        push cx
        push dx 
        push bx
        
        mov bx , 10 
        
        loop1_prtint:  
        
            xor dx , dx    
            div bx
            add dl , '0'
            push dx
        
        dec cx
        jz endlp1_prtint
        or ax,ax
        jnz loop1_prtint
        
        endlp1_prtint:
        
        add cx , [bp - 2]   ;numero de char para dar print 
        
        loop2_prtint:
            
            pop ax
            call co
            dec cx
        jnz loop2_prtint        
        
        pop bx
        pop dx
        pop cx
        pop bp
        ret               
    endp 
    
    ;Si = inicio do numero na str
    ;Cl = num de char =< 5
    ;Ax = resultado
    str_int proc
        
        push dx ;inicializar as variaveis
        push cx
        push si
        
        xor ax , ax  
        xor dh , dh
        
        mov ch,10
                 
        str_intLp:
            
            mov dl,byte ptr [si];char 
            or dl,dl
            jz str_int_end      ;para no fim da string
            or cl,cl
            jz str_int_end
            sub dl,'0'          ;passar para inteiro
            
            mul ch              ;multiplicar o resultado por 10
            add ax,dx           ;adicionar o numero novo
            dec cl              ;contar ciclos
            inc si
            jmp str_intLp
            
        str_int_end:
        
        pop si
        pop cx
        pop dx
        ret   
    endp
    
    ;Di = inicio str destino
    ;Ax = num  
    ;cx = numero de char
    int_str proc
        
        push bp     ;[bp - 2] -> numero de char
        mov bp,sp
        
        push cx
        push dx 
        push bx
        push ax
        
       ; mov cx , bx 
        
        mov bx , 10 
        
        loop1_intstr:  
        
            xor dx , dx    
            div bx
            add dl , '0'
            push dx
        
        dec cx
        jz if1_intstr
        or ax,ax
        jz endlp1_intstr
        jmp loop1_intstr
        
        endlp1_intstr:
            
            push 48     ;'0'
            dec cx
        jnz endlp1_intstr
        
        if1_intstr:
        mov cx , [bp - 2]   ;numero de char para dar print 
        
        loop2_intstr:
            
            pop ax
            xor ah , ah;provavelmente nao ]e preciso
            mov byte ptr[di] , al
            inc di 
            dec cx 
            
        jnz loop2_intstr        
        endlp2_intstrt:
        
        pop bx
        pop dx
        pop cx  
        pop ax
        pop bp
        ret               
    endp
         
    ;Di = inicio str destino
    ;Ax = num
    ;bh = 0,para terminar str com 0  
    ;bl = numero de char
    int_strVlh proc
                 
        push cx
        push dx
        push ax
        push bx
        
        ;xor bx,bx 
        mov cx,10
        
        ;cnt_intsrt:
        ;    
        ;    inc bl
        ;    xor dx,dx        ;dx tem de ser 0
        ;    div cx
        ;    or ax,ax
        ;    
        ;jnz cnt_intsrt 
        
        ;dec di 
        xor bh , bh;bx = bl 
        dec bx
        add di , bx
        pop bx
        
        or bl,bl
        jnz end_intstr
            inc di
            mov [di],0;terminar a string    
            dec di
        end_intstr:
            
        pop ax
        lp1_intstr:
            
            xor dx,dx        ;dx tem de ser 0
            div cx
            add dl,'0'      ;dl tem o char menos significativo
            mov [di], dl    ;adiciona a string      
                        
            dec di          ;prox posicao
            or ax,ax
            jnz lp1_intstr 
        
        ;pop bx
        pop dx
        pop cx
        ret
        
    endp
 
    ;Di = inicio str terminada em 0
    ;Ax = valor     
    cnt_str proc
            
        push cx
        push di
            
        mov al,0
        mov cx,-1
            
        cld 
        repne scasb                           
                      
        mov ax,-1          
        sub ax, cx  ; ax = -(Cx + 1) 
        
        pop di    
        pop Cx
        ret
    endp
    
    
    ;si= offset str
    ;bl=char
    del_char proc;si= offset str;bl=char
        
        push dx ;dl, guarda o char
        push di ;ptr antes  ' '
        push bx ;ptr depois ' ' 
        mov di,si
        
        lp1_del_char:
            
            mov dl,byte ptr [si];guardar o char
            or dl,dl
            jz end_dlch         ;procurar fim da str
            
            cmp dl,bl
            jne endif_dlch      ;procurar o char em bl
                inc si
                jmp lp1_del_char    
            
            endif_dlch:
            
            movsb
            jmp lp1_del_char
    
        end_dlch:
        
        mov [di],0
        pop bx
        pop di
        pop bx
        ret
    endp
    
    ;Di = offset str
    ;bl = char para mudar
    ;bh = char novo
    swtch_char proc
        
        push cx
        push ax
        
        push di
        call cnt_str
        pop di
        
        mov cx,ax
        mov al,bl
        add di,cx
        
        lp1_swchar:
            
            inc cx          ;repne decrementa uma vez a mais       
            std
            repne scasb     ;procura o char 
 
            jnz end_swchar   ;acaba se tiver percorrido a str toda
            inc di
            
            mov [di],bh     ;substitui 
            jmp lp1_swchar
            
        end_swchar:   
        
        pop ax
        pop cx
        ret
        
    endp
        
        
    ;si = str1
    ;di = str2
    ;resultado "str2""str1"
    app_str proc
        
        push ax
        push cx
        
        call cnt_str
        add di , ax ;aponta para o fim da str
        dec di
        
        mov cx ,di
        mov di,si    ;guardar di
        
        call cnt_str ;conta char da str
        
        mov di , cx
        mov cx , ax    
        
        cld 
        repne movsb ;mov o char todos
        
        pop cx
        pop ax
        ret
        
    endp
        
    ;si = str1
    ;di = str2
    ;se str1 == str2 flag de zero = 1
    str_cmp proc
    
        push ax
        push cx
           
        call cnt_str     ;conta os char da str
        mov cx,ax
        
        cld
        repe cmpsb       ;se str1 == str2 Flag de zero == 1
        
        end_strcmp:   
        pop cx
        pop ax
        ret
         
         
    endp
    
    
    ;si = str1
    ;di = destino
    ;escreve char a char str1 em di
    strcpy proc
        
        push ax
        push cx
             
        mov cx,di
        mov di,si
        
        call cnt_str
        mov di,cx       ;numero de char na str [si] em cx
        mov cx,ax
        
        cld
        rep movsb
        
        pop cx
        pop ax
        ret   
    endp
    
    
    ;TODO REFAZER
    ;si=inicio ax = quantos char salta
    ; exemplo 1+2+3+4 onde si aponta para 2 e ax = 2
    ; fica 1+2+4
    str_shift proc
 
        push cx
        push si
        
        inc si

        lp1_strshft:
                    
            add si,ax
            mov ch,[si]
            sub si,ax
            mov [si],ch
            inc si
            or ch,ch
        
        jnz lp1_strshft
        
        pop si
        pop cx
        ret
        
    endp
    
    printf proc
    
        or bl,bl
        jz print_0
        
        cmp bl,1
        je print_min
        
        cmp bl,2
        je print_max
        
        cmp bl,4
        je print_enter
        
        print_max:
            mov bl,'a'
            mov bh,'z'
            mov cl, 'A'-'a'
            call printf_min_max
            ret
        
        print_min:
            mov bl,'A'
            mov bh,'Z'
            mov cl,'a'-'A'
            call printf_min_max
            ret
        
        print_0:
            call printf_norm
            ret
        
        print_enter:
            call printf_norm
            mov al,0dh
            call co
            mov al,0ah
            call co
            ret
    
    printf endp

    printf_norm proc
    
        L1: mov al,byte ptr [si]
            or al,al
            jz fimprtstr
            call co
            inc si
            jmp L1
        fimprtstr: ret
    
    endp

;*****************************************************************
; co - caracter output
; descricao: rotina que faz o output de um caracter para o ecra
; input - al=caracter a escrever
; output - nenhum
; destroi - nada
;*****************************************************************
    co proc
        push ax
        push dx
        mov ah,02H
        mov dl,al
        int 21H
        pop dx
        pop ax
        ret
    co endp



    printf_min_max proc
    
        push si
        printf_bgl1: mov al,byte ptr [si]
            or al,al
            jz printf_Endl1
            
            cmp al,bh
            ja printf_if1;'Z'
            
            cmp al,bl
            jb printf_if1 ;'A'
                       
                add al,cl;normaliza se o char estiver entre 'A' e 'Z'
                       
            printf_if1:
            call co    
            inc si
            jmp printf_bgl1
        printf_Endl1:
        pop si
        
        ret
    endp

;------------STRINGS------------;
        
ends
    
    
ends

end start ; set entry point and stop the assembler.

