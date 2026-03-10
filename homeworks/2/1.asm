.8086

SSEG segment para stack use16 'STACK'
	db 256 dup(?)
SSEG ends

DSEG segment para public use16 'DATA'

DSEG ends

CSEG segment readonly para public use16 'CODE'
assume CS:CSEG, DS:DSEG, SS:SSEG
start:

	mov ax, DSEG
	mov ds, ax
	mov ax, SSEG
	mov ss, ax

	; console input without echo (to AL)
	mov ah, 08h
	int 21h

	; print symbol
	mov dl, al
	mov ah, 02h
	int 21h

	mov ax, 4C00h
	int 21h

CSEG ends
end start
