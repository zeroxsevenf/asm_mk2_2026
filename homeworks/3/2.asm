.8086

SSEG segment para stack use16 'STACK'
	db 256 dup(?)
SSEG ends

DSEG segment para public use16 'DATA'

	buf db 241 dup(?)
	tmp db ?
	cnt dw ?

	crlf db 0Dh, 0Ah

DSEG ends

CSEG segment readonly para public use16 'CODE'
assume CS:CSEG, DS:DSEG, SS:SSEG
start:

	mov ax, DSEG
	mov ds, ax
	mov ax, SSEG
	mov ss, ax

	; init
	mov cnt, 0
	lea si, [buf]

read_loop:

	; read symbol from stdin (fd 0)
	mov ah, 3Fh
	mov bx, 0
	mov cx, 1
	lea dx, [tmp]
	int 21h

	; check for error
	cmp ax, 0
	je done_read

	; check for ENTER
	mov al, tmp
	cmp al, 0Dh
	je done_read

	; save symbol to buffer
	mov [si], al
	inc si
	inc cnt
	jmp read_loop

done_read:

	; print string to stdout (fd 1)
	mov ah, 40h
	mov bx, 1
	mov cx, cnt
	lea dx, [buf]
	int 21h

	; print newline
	lea dx, [crlf]
	mov cx, 2
	mov ah, 40h
	int 21h

	mov ax, 4C00h
	int 21h

CSEG ends
end start
