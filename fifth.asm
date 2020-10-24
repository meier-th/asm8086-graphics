.model  small
.code

mov ax,5       			
int 10h			 

mov cx, 40 ; length
mov ax, 103 ; x start
mov bx, 100 ; y
call draw_hbar
mov cx, 40 ; height
mov ax, 103 ; x
mov bx, 100 ; y start
call draw_vbar

xor ax,ax				
int 16h
mov ax,4c00h			
int 21h				
ret

; ax: x, bx: y
draw_dot PROC
push ax
push bx
and ax, 0
and bx, 0
pop ax
push ax
shr ax, 1
mov cl, 80
mul cl
mov bx, ax

xor dx, dx
pop cx
pop dx
push dx
push cx
mov cl, 2
shr dx, cl
add bx,dx ; bx = offset

pop ax
pop cx
push cx
push ax
and cx, 3
shl cx, 1; cl = shift

pop ax
push ax
and ax, 1
cmp ax, 1
je odd
mov ax,0b800h
jmp draw

	odd:
mov ax,0ba00h

	draw:
mov  es,ax          
and ax, 0 
mov al,10000000b
shr al,cl
mov dl, 0c0h ; mask
shr dl, cl
xor dl, 0ffh ; inverted mask
mov cl, es:[bx]
and cl, dl
or al, cl
mov es:[bx], al     
and ax, 0
and bx, 0
and cx, 0
and dx, 0
pop bx
pop ax
ret
draw_dot ENDP

draw_vbar proc ; ax - x, bx - y, cx - height
push cx
and cx, 0
	v_dot:
call draw_dot
pop cx
dec cx ; height countdown
inc bx ; next y
push cx
cmp cx, 0
jne v_dot
pop cx
ret
draw_vbar endp

draw_hbar proc ; ax - x, bx - y, cx - height
push cx
and cx, 0
	h_dot:
call draw_dot
pop cx
dec cx ; height countdown
inc ax ; next x
push cx
cmp cx, 0
jne h_dot
pop cx
ret
draw_hbar endp

end
