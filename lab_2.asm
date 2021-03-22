.model tiny  
.code
org  100h

print_str macro str
mov ah,9
mov dx,offset str
int 21h    
endm

start:  
print_str msg1  
lea dx,str
mov offset str,size
mov ah,10
int 21h 

print_str slash_n  
print_str msg2

lea bx,str
inc bx
output:
   inc bx
   mov dx,[bx]
   mov ah,2
   int 21h
   cmp dl, 0Dh
   jne output

print_str slash_n

lea si,str 
inc si 
lea di,str 
inc di
run:
cmp dl,' '
jne word   
begin: 
   mov si,di
   mov dx,[si]
   cmp dl,' '
   je word 
   cmp dl,09h
   je word 
   inc si
   inc di
   cmp dl, 0Dh
   je ex
   jmp begin
word:
   inc di 
   mov dx,[di] 
   cmp dl, ' '
   je begin
   cmp dl,09h
   je begin 
   cmp dl, 0Dh
   je ex  
   cmp dl,' '
   jne find_digit
   cmp dl,09h
   jne find_digit 
   find_digit:
       mov dx,[di] 
       cmp dl,'0'
       jl not_a_digit
       mov dx,[di]
       cmp dl,'9'
       jg not_a_digit
       inc di  
       cmp dl, 0Dh
       je ex
       jmp find_digit
   not_a_digit:
       cmp dl,' '
       je plus 
       cmp dl,09h
       je plus  
       cmp dl,0Dh
       je to_end
       jmp begin

plus:
   inc di
to_end:
   mov dx,[di] 
   cmp dl,0Dh
   jne plus
save:  
   mov dx,[di]
   push dx
   dec di
   cmp si,di
   jne save

inc si
mov di,si 
mov cx,0 
mov bx,0 
insert: 
   mov al,numb+bx 
   stosb 
   inc bx
   inc cx 
   cmp cx,7
   jne insert
   mov al,ah
   lea bl,al
pre_recording: 
   pop ax 
   stosb
   cmp al,0Dh
   jne pre_recording 
   mov cx,0
skip: 
   inc si
   inc cx
   cmp cx,7
   jne skip 
   mov di,si
   jmp begin
ex: 
   print_str msg3
   lea bx,str
   inc bx
   output3:
       inc bx
       mov dx,[bx]
       mov ah,2
       int 21h
       cmp dl, 0Dh
       jne output3 
       
print_str slash_n           
print_str msg4
ret   

msg1 db "Enter a string:",0Dh,0Ah,'$' 
msg2 db 0Dh,0Ah,"Original string:",0Dh,0Ah,'$' 
msg3 db 0Dh,0Ah,"String after processing:",0Dh,0Ah,'$'
msg4 db 0Dh,0Ah,"Program completed",0Dh,0Ah,'$'
slash_n db  0Dh,0Ah,'$'
numb db "number "
size equ 200
str db size DUP (?)  

end start
