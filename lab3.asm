.model small
.stack 100h

.data   
message0 db 'Enter the array elements:',0Dh,0Ah,'$'
message1 db 'Array [','$'
message2 db '] = ','$'  
message3 db 0Dh,0Ah,'Type of sequence: ' ,'$'
random db 'Random',0Dh,0Ah,'$' 
increas db 'Increasing',0Dh,0Ah,'$' 
decreas db 'Decreasing',0Dh,0Ah,'$' 
one db 0Dh,0Ah,'Only one element ',0Dh,0Ah,'$'  
no db 0Dh,0Ah,'No elements ',0Dh,0Ah,'$'    
overflow db 'Overflow',0Dh,0Ah,'$'   
in_error db 'Input error!',0Dh,0Ah,'$'
slash_n db  0Dh,0Ah,'$'   
flag db 1
ten dw 10

size equ 10
str db size DUP ('$') 
size_array equ 5
array dw size_array DUP (?)   
current_element dw ? 

.code

print_str macro str 
    pusha
    mov ah,9
    mov dx,offset str
    int 21h                
    popa   
endm
                        
input_element proc
    pusha
    mov [flag],1
    lea dx,str
    mov offset str,size
    mov ah,10
    int 21h  
   
    lea si,str
    add si,2 
    mov dx,[si]
    cmp dl,0Dh
    je error1
    
    mov ax,0 
    mov di,1
    cmp dl,'-'
    jne positive
    inc si
    neg di
    jmp positive
    
    convert:
       cmp di,1
       je max
       cmp ax,32767
       ja error2 
       jmp mult
       max:
          cmp ax,32767
          ja error2
       mult:
          mov dx,[si]
          cmp dl, 0Dh
          je end
          mul ten 
          cmp dx,0
          jne error2
    
    positive: 
       mov dx,[si]
       cmp dl,'0'
       jl error1
       cmp dl,'9'
       jg error1  
      
       sub dl,30h
       mov dh,0
       add ax,dx
       jo error2 
       inc si 
       jmp convert
    
    error1: 
       print_str slash_n
       print_str in_error
       mov [flag],0 
    popa
    ret 
    error2: 
       cmp di,1
       je e  
       cmp ax,32768
       je end
       e:
          print_str slash_n
          print_str overflow
          mov [flag],0
    popa
    ret
    end:
       imul di
       mov current_element,ax     
    popa
    ret
input_element endp

out_index macro 
    local e
    pusha
    aam 
    add ax,3030h 
    mov dl,ah 
    mov dh,al 
    mov ah,02 
    cmp dl,30h
    je e
    int 21h 
    e:
      mov dl,dh 
      int 21h
    popa    
endm

type_seq proc   
   pusha   
   mov [flag],2
   mov cx,size_array 
   cmp cx,1
   je m4  
   dec cx
   mov di,0
   mov si,0
   add si,2
   f:
       mov ax,array[di]
       mov bx,array[si]
       cmp ax,bx
       jl increasing
       jg decreasing
       je rand
 
       decreasing:
           cmp flag,1
           je rand
           cmp flag,3
           je rand
           mov flag,0
           jmp next1
       increasing:
           cmp flag,0
           je rand
           cmp flag,3
           je rand
           mov flag,1
           jmp next1
       rand:
           mov flag,3       
       next1:
           add di,2 
           add si,2
   loop f 
   en: 
     print_str message3
     cmp flag,0
     je m0:
     cmp flag,1
     je m1
     cmp flag,3
     je m3
     m0:
        print_str decreas
        popa
        ret 
     m1:
        print_str increas
        popa
        ret
     m3:
        print_str random 
        popa
        ret
     m4:
     print_str one
   popa
   ret    
type_seq endp    

out_array proc
    pusha
    mov cx,size_array  
    mov di,0
    while: 
       mov si,'$'
       push si 
       mov [flag],0   
       sign:
          mov ax,array[di] 
          cmp ax,0
          js negative
          jns string
       negative: 
          neg ax
          mov [flag],1
          jmp string
       string:
          mov dx,0
          div ten
          add dx,30h 
          push dx
          cmp ax,0
          jne string
          jmp print
       print:
          cmp flag,1
          je minus 
          space:
             mov ah,2
             mov dx,' '
             int 21h 
          l1:
            pop dx
            cmp dl,'$'
            je next
            int 21h
            jmp l1          
       minus: 
          mov si,'-'
          push si
          jmp space 
       next:
          add di,2 
    loop while
    popa
    ret
out_array endp

start:
    mov ax,@data
    mov ds,ax  
    print_str message0  
    mov cx,size_array
    cmp cx,0
    je off
    mov ax,1 
    mov di,0
    for:
        repeat:
           print_str message1
           out_index
           inc ax
           print_str message2
           call input_element
           cmp flag,0 
           je error
           jmp add_element
        error:
           dec ax
           jmp repeat 
        add_element:
           print_str slash_n 
           mov bx,current_element 
           mov array[di],bx
           add di,2
    loop for
     
    print_str slash_n 
    call out_array
    call type_seq 
    mov ax,4C00h
    int 21h 
    
    off:
       print_str no 
       mov ax,4C00h
       int 21h
end start
    

