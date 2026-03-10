.8086

SSEG segment para stack use16 'STACK'
	db 256 dup(?)
SSEG ends

DSEG segment para public use16 'DATA'
	max_len db 240
	cur_len db ?
	buffer db 241 dup(?)
DSEG ends

CSEG segment readonly para public use16 'CODE'
assume CS:CSEG, DS:DSEG, SS:SSEG
start:

	mov ax, DSEG
	mov ds, ax
	mov ax, SSEG
	mov ss, ax

	; buffered keyboard input
	mov dx, offset max_len
	mov ah, 0Ah
	int 21h

	; add line terminator
	mov bl, cur_len
	mov bh, 0
	mov si, offset buffer
	add si, bx
	mov byte ptr [si], '$'

	; new line
	mov dl, 0Dh
	mov ah, 02h
	int 21h
	mov dl, 0Ah
	mov ah, 02h
	int 21h

	; display string
	mov dx, offset buffer
	mov ah, 09h
	int 21h

	mov ax, 4C00h
	int 21h

CSEG ends
end start
