.model  small
.code

mov ax,5       			
int 10h			 

;mov cx, 40 ; length
;mov ax, 103 ; x start
;mov bx, 100 ; y
;call draw_hbar
;mov cx, 40 ; height
;mov ax, 103 ; x
;mov bx, 100 ; y start
;call draw_vbar
mov bl, 10
mov bh, 10
mov cl, 10 ; dx
mov ch, 10 ; dy
call draw_line

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

; stack: dy,dx | xf,d | ...

draw_line proc ; bl - x0, bh - y0, cl - dx, ch - dy
and ax, 0
add ah, bl
add ah, cl
mov dl, ah
mov al, cl
shl al, 1
sub al, cl
mov ah, dl
and dl, 0
push ax ; xf,d0 |xf,d0| ...
push cx ; dy,dx |dy,dx|xf,d0| ...

and ax, 0
mov al, bl ; x0
mov bl, bh ; y0
and bh, 0
	dot:
call draw_dot
inc ax ; xi
pop dx ; dy,dx |xf,di-1| ...
pop cx ; xf,di-1 | ...
push cx ; |xf,di-1| ...
cmp al, ch
je ex
and cl, 80h
cmp cl, 0
je inc_y

pop cx ; xf,di-1 | ...
push dx
and dl, 0
shl dh, 1 ; 2*dy
add cl, dh ; di
pop dx ; dy,dx
push cx ; |xf,di| ...
push dx ; |dy,dx|xf,di| ...
and dx, 0
and cx, 0
jmp dot
	inc_y:
inc bx ; yi
and cx, 0
mov cl, dh
sub cl, dl
shl cl, 1 ; 2(dy-dx)
mov bh, al ; bx: xiyi
and ax, 0
pop ax ; xf,di-1 | ...
add al, cl ; xf,di
push ax ; |xf,di| ...
and ax, 0
mov al, bh
and bh, 0
push dx ; |dy,dx|xf,di| ...
and dx, 0
and cx, 0
jmp dot
	ex:
pop ax
and ax, 0
and bx, 0
and cx, 0
and dx, 0
ret
draw_line endp

end
