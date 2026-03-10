.8086

SSEG segment para stack use16 'STACK'
	db 256 dup(?)
SSEG ends

DSEG segment para public use16 'DATA'
	msg db 'Hello, world!', 0Dh, 0Ah, '$'
DSEG ends

CSEG segment readonly para public use16 'CODE'
assume CS:CSEG, DS:DSEG, SS:SSEG
start:

	mov ax, DSEG
	mov ds, ax
	mov ax, SSEG
	mov ss, ax

	; display string
	mov dx, offset msg
	mov ah, 9h
	int 21h

	mov ax, 4C00h
	int 21h

CSEG ends
end start
