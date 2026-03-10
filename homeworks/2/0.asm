.8086

SSEG segment para stack use16 'STACK'
	db 256 dup(?)
SSEG ends

DSEG segment para public use16 'DATA'
	msg db 'Hello, asm!', 0Dh, 0Ah, '$'
DSEG ends

CSEG segment readonly para public use16 'CODE'
assume CS:CSEG, DS:DSEG, SS:SSEG
start:

	mov ax, DSEG
	mov ds, ax
	mov ax, SSEG
	mov ss, ax

	; get address of letter 'a' in BX
	lea bx, [msg + 7]

	; set letter to 'X'
	mov byte ptr [bx], 'X'

	; read next letter and print it (letter 's')
	mov dl, [bx + 1]
	mov ah, 02h
	int 21h

	mov ax, 4C00h
	int 21h

CSEG ends
end start
