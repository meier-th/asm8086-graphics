.model  small
.code

mov ax,5       			
int 10h			

mov al, -1
mov bl, 15
mov cl, 30
mov dl, 20
call draw_half

mov al, 0
mov bl, 15
mov cl, 53
mov dl, 20
call draw_quarter

mov bl, 24
mov bh, 5
mov cl, -5
mov ch, 24
call steep_line

mov bl, 47
mov bh, 5
mov cl, -5
mov ch, 24
call steep_line


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
mov dx, cx
and ch, 80h
cmp ch, 0
push 1
je cont
xor dh, 0ffh
inc dh
pop cx
push -1
	cont:
mov cx, dx
and dx, 0
and ax, 0
add ah, bl
add ah, cl ; x0+dx
mov dl, ah ; x0+dx
mov al, ch ; dy
shl al, 1 ; 2dy
sub al, cl ; 2dy - dx (d0)
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
pop dx ; dy,dx |xf,di-1| ...
pop cx ; xf,di-1 | ...
push cx ; |xf,di-1| ...
cmp al, ch
je ex ; if x == xf
inc ax
and cl, 80h
cmp cl, 0
je inc_y ; if (di-1) >= 0

pop cx ; xf,di-1 | ...
push dx ; |dy,dx| ...
and dl, 0
shl dh, 1 ; 2*dy
add cl, dh ; di = di-1 + 2dy
pop dx ; dy,dx
push cx ; |xf,di| ...
push dx ; |dy,dx|xf,di| ...
and dx, 0
and cx, 0
jmp dot
	inc_y:
pop cx; xf,di-1 | ...
mov bh, ch
mov ah, cl
pop cx ; +-1
cmp cx, -1
je dec_y
inc bl ; yi
jmp after_y
	dec_y:
dec bl ; yi
	after_y:
push cx
mov cl, ah
mov ch, bh
and ah, 0
and bh, 0
push cx ; |xf,di-1| ...
and cx, 0
mov cl, dh ; dy
sub cl, dl ; dy-dx
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
pop ax
and ax, 0
and bx, 0
and cx, 0
and dx, 0
ret
draw_line endp

steep_line proc ; bl - x0, bh - y0, cl - dx, ch - dy
mov dx, cx ; dydx
and cl, 80h
cmp cl, 0
push 1
je s_cont ; if dx >= 0
xor dl, 0ffh
inc dl ; dx = |dx|
pop cx
push -1
	s_cont:
mov cx, dx ; dydx
and dx, 0
and ax, 0
add ah, bh
add ah, ch ; yf
mov dl, ah 
mov al, cl ; dx
shl al, 1 ; 2dx
sub al, ch ; 2dx-dy
mov ah, dl
and dl, 0
push ax ; yf,d0 |yf,d0| ...
push cx ; dy,dx |dy,dx|yf,d0| ...

and ax, 0
and cx, 0
mov al, bl ; x0
mov bl, bh ; y0
and bh, 0
	s_dot:
call draw_dot
pop dx ; dy,dx |yf,di-1| ...
pop cx ; yf,di-1 | ...
push cx ; |yf,di-1| ...
cmp bl, ch
je s_ex ; if y == yf
inc bl ; yi

and cl, 80h
cmp cl, 0
je inc_x ; if di-1 >= 0

pop cx ; yf,di-1 | ...
push dx ; |dy,dx| ...
and dh, 0
shl dl, 1 ; 2*dx
add cl, dl ; di = di-1 + 2dx
pop dx ; dy,dx
push cx ; |yf,di| ...
push dx ; |dy,dx|yf,di| ...
and dx, 0
and cx, 0
jmp s_dot
	inc_x: ; |yf,di-1| ... al : x, bl: y, cx: yf,di-1, dx: dy,dx
pop cx
mov ah, cl
mov bh, ch
pop cx ; +-1
add al, cl ; xi
push cx ; +-1
mov cl, ah
mov ch, bh
push cx ; |yf,di-1| ...
and ah, 0
and bh, 0
mov bh, al ; bx: xy
and al, 0
mov al, dl ; dx
sub al, dh ; dx-dy
shl al, 1 ; 2(dx-dy)
add al, cl ; di = di-1 + x(dx-dy)
mov cl, al
pop ax ; |...
push cx ; |yf,di| ...
push dx ; |dy,dx|yf,di| ...
and ax, 0
mov al, bh; ax = 0x
and bh, 0 ; bx = 0y
and cx, 0
and dx, 0
jmp s_dot
	s_ex:
pop ax
pop ax
and ax, 0
and bx, 0
and cx, 0
and dx, 0
ret
steep_line endp

draw_quarter proc ; al - x, bl - y, cl - x_offset, dl - y_offset
push cx
push dx
mov cx, 0
mov dx, 0
	iteration:
inc al
add dx, ax
cmp dl, bl
jl draw_c_dot
sub dl, bl
dec bl
	draw_c_dot:
pop cx
mov dh, cl
pop cx
push cx
sub cl, al
push ax
mov al, cl ; offset - x
add bl, dh ; y + offset
mov cl, dh
push cx
and cx, 0
and dh, 0

push dx
and dx, 0
call draw_dot
pop dx

pop cx
mov dh, cl
pop cx
mov al, cl ; x
sub bl, dh ; y
mov cl, dh
push cx
and cx, 0
and dh, 0

cmp al, bl
jge end_circle
jmp iteration
    end_circle:
pop dx
pop cx
and cx, 0
and dx, 0
ret
draw_quarter endp

draw_half proc ; al - x, bl - y, cl - x_offset, dl - y_offset
push cx
push dx
mov cx, 0
mov dx, 0
	h_iteration:
inc al
add dx, ax
cmp dl, bl
jl h_draw_c_dot
sub dl, bl
dec bl
	h_draw_c_dot:
pop cx ; y offset
mov dh, cl
pop cx ; x offset
push cx ; x offset
sub cl, al
push ax ; x
mov al, cl ; offset - x
add bl, dh ; y + offset
mov cl, dh
push cx ; y offset
and cx, 0
and dh, 0

push dx
and dx, 0
call draw_dot
pop dx
pop cx
mov dh, cl
pop cx
add al, cl
add al, cl
push cx
mov cl, dh
push cx
and cx, 0
and dh, 0
push dx
call draw_dot
pop dx

pop cx
mov dh, cl
pop cx
mov al, cl ; x
sub bl, dh ; y
mov cl, dh
push cx
and cx, 0
and dh, 0

cmp al, bl
jge h_end_circle
jmp h_iteration
    h_end_circle:
pop dx
pop cx
and cx, 0
and dx, 0
ret
draw_half endp

end
