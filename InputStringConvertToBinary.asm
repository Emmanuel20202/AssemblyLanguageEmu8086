org 100h

jmp start 

msg1 db 0Dh,0Ah, " Enter any number from -32768 to 65535. or zero to stop: $"
msg2 db 0Dh,0Ah, " Binary form: $"

; buffer for int 21h/0ah
; 1st byte is buffer size, 2nd byte is number of chars actually read
buffer db 7,?, 5 dup (0), 0, 0
; for result
binary dw ?      

start:
    ; print nessage
    mov dx, offset msg1
    mov ah, 9
    int 21h
         
    ; input string
    mov dx, offset buffer
    mov ah, 0ah
    int 21h
       
    ; make sure the string is zero terninated
    mov bx, 0
    mov bl, buffer[1]
    mov buffer[bx+2], 0
    
    ; buffer starts from third byte
    lea si, buffer + 2
    call tobin 
    
    ; the number is in cx register, for -1234' it's Ofb2eh
    mov binary, cx
    
    jcxz stop 
         
    ; print pre-result message
    mov dx, offset msg2
    mov ah, 9
    int 21h
    
    ; print result in binary
    mov bx, binary
    mov cx, 16
    
print:
    mov ah, 2
    mov dl, '0'
    
    ; test first bit
    test bx, 1000000000000000b
    jz   zero
    mov  dl, '1'

zero:
    int  21h
    shl  bx, 1
    loop print
    jmp  start
    
stop:
    ret
    
; this proc edure converts string number to binary nunber
; the result is stored in ex register
; paraneters: si- address of string nunber <zero terninated>
tobin   proc near
        push dx
        push ax
        push si 
       
jmp process    

make_minus      db ?   ; used as a flag.
ten             dw 10  ; used as nultiplier
                        
process:
     ; resets the accunulator
     mov cx, 0 
     
     ; resets flag
     mov cs:make_minus, 0 
     
next_digit:
    ; reads char to al and point to next byte
    mov al, [si]
    inc si 
    
    ; checks for the end of string
    cmp al, 0
    jne not_end
    Jmp stop_input 
    
not_end:
    ; check for minus
    cmp al, '-'
    jne ok_digit
    
    ; sets the flag
    mov cs:make_minus, 1
    jmp next_digit
    
 
ok_digit:
   ; multiply cx by 10 (first tine the result is zero>
   push ax
   mov  ax, cx 
   
   ; dx:ax - ax*10
   mul cs:ten
   mov cx, ax
   pop ax
        
       
   ; it is assuned that dx is zero - overflow not checked
   ; convert from ascii code
   sub al, 30h
                                 
   ; add al to cx
   mov ah, 0   
   
   ; backup. in case the result will be too big
   mov dx, cx
   add cx, ax
   
   ; add - overflow not checked
   jmp next_digit
   
stop_input:
    ; check f lag. if string nunber had '-'
    ; make sure the result is negative
   cmp cs:make_minus, 0
   je  not_minus                   
   neg cx
   
not_minus:
   pop si
   pop ax
   pop dx
   ret
     
tobin endp