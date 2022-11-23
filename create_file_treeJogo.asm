; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$" 
    handler dw ? 
    ;str_error_create db "falha ao criar ficheiro",0   
    ;str_error_close db "falha ao fechar ficheiro",0
    str_error_open db "falha ao abrir ficheiro",0 
    str_error_write db "falha ao escrever no ficheiro",0
    ;str_error_read db "falha ao ler do ficheiro",0
    ;filepath db "c:\",0
    str_test db "carla ola",0 ;string de teste para escrita em ficheiro
    str_read db 20 dup(?) ;buffer de leitura  
    filepath db "C:\GameOfLife\" 	; path to be created  
    db 14 dup(0)                    ; numero de chars q posso  escrever 
    ;filepathcmp db "gameOfLife", 0 	;name of path to be compared  
    Exemplos db "Exemplos", 0 	; path to be created 
    JogosGuardados db "JogosGuardados",0
    ;filepathExemploscmp db "gameOfLife\Exemplos", 0 
    Top5 db "TOP5.txt",0  ;por agora 
    Logs db "Logs.txt",0
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
    
    ;mov di , dx
        
    
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    

    create_file_tree proc
         
        mov dx , offset filepath              
        mov di , dx                           
         
        mov AH,39h
        INT 21h
         
        jc if_cftr   ;File existe Cf = 1
        
            ;criar ficheiro TODOS os ficheiros 
         
        if_cftr:                        
        ;FATA DAR HANDLE AOS ERROS 
         
        call cnt_str
                 
        add di , ax  ;aponta para o fim da str
         
        mov di , dx 
        push dx
        mov si , offset JogosGuardados
        
        call app_str            
        
        mov dx , offset filepath
        
        ;mov AH,39h
        INT 21h 
        
        pop di
        mov si , offset Exemplos
        call app_str            
        
        INT 21h 
         
        jnc if2_cftr 
            ;HANDLE AO ERRO      
        if2_cftr:          
        
        
        
              
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
        mov ax,0
        mov dh,0
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
    ;bh = 0,para terminar str com 0  
    ;bl = numero de char
    int_str proc
                 
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
    
    ;*****************************************************************
    ; fopen - open file
    ; descricao: rotina que abre um ficheiro
    ; input - dx - offset para o nome do ficheiro \ al - tipo de leitura   
    ; output - 
    ; destroi - 
    ;*****************************************************************
    
    proc fopen
               
        mov ah, 3dh ; open file file      
        int 21h 
        
        ;jnc fopen_success ;salta se criar o ficheiro com sucesso
        
       ; mov si, offset str_error_open 
        
        
        ;parametros
        ;mov ax,0 ;0 impressao de strings \ 1 - impressao de inteiros
        ;mov bx,0 ;0 impressao normal \ 1 impressao em minusculas\ 2 impressao em maisculas\3 impressao com enter no final
        ;call printf
        
        ;fopen_success:  
        
        ret    
    endp fclose 
    ;***********

ends

end start ; set entry point and stop the assembler.
