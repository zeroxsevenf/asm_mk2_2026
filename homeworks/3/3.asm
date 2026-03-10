.8086

SSEG segment para stack use16 'STACK'
	db 256 dup(?)
SSEG ends

DSEG segment para public use16 'DATA'

	x  dw 10
	y  dw 5
	a  dw 2
	b  dw 3

	; result of (x*y)/(x+y)
	z  dw ?

	; result of (a+b)^2
	c1 dw ?

	; result of (a+b)^3
	c2 dw ?

DSEG ends

CSEG segment readonly para public use16 'CODE'
assume CS:CSEG, DS:DSEG, SS:SSEG
start:

	mov ax, DSEG
	mov ds, ax
	mov ax, SSEG
	mov ss, ax

	; z = (x * y) / (x + y)
	mov ax, x
	; dx:ax = x * y
	imul y
	mov bx, x
	; bx = x + y
	add bx, y
	; ax = quotient, dx = remainder (not used)
	idiv bx
	mov z, ax

	; breakpoint
	int 03h

	; c1 = (a + b)^2
	mov ax, a
	; ax = a + b
	add ax, b
	mov bx, ax
	; dx:ax = (a+b)^2
	imul bx
	mov c1, ax

	; breakpoint
	int 03h

	; c2 = (a + b)^3
	mov ax, a
	; ax = a + b
	add ax, b
	; bx = sum
	mov bx, ax
	; dx:ax = (a+b)^2
	imul bx
	; cx = ^2 (low byte)
	mov cx, ax
	; ax = sum
	mov ax, bx
	; dx:ax = ^3
	imul cx
	; save low byte
	mov c2, ax

	; breakpoint
	int 03h

	mov ax, 4C00h
	int 21h

CSEG ends
end start
