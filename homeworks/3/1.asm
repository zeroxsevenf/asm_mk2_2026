.8086

SSEG segment para stack use16 'STACK'
	db 256 dup(?)
SSEG ends

DSEG segment para public use16 'DATA'

	str1_max db 240
	str1_cur db ?
	str1_buf db 240 dup(?)

	str2_max db 240
	str2_cur db ?
	str2_buf db 240 dup(?)

	str3_max db 240
	str3_cur db ?
	str3_buf db 240 dup(?)

	crlf db 0Dh, 0Ah

DSEG ends

CSEG segment readonly para public use16 'CODE'
assume CS:CSEG, DS:DSEG, SS:SSEG
start:

	mov ax, DSEG
	mov ds, ax
	mov ax, SSEG
	mov ss, ax

	; input first string
	lea dx, str1_max
	mov ah, 0Ah
	int 21h

	; input second string
	lea dx, str2_max
	mov ah, 0Ah
	int 21h

	; input third string
	lea dx, str3_max
	mov ah, 0Ah
	int 21h

	; print first string to stdout (fd 1)
	lea dx, str1_buf
	mov cl, str1_cur
	mov ch, 0
	mov bx, 1
	mov ah, 40h
	int 21h

	; print new line
	lea dx, crlf
	mov cx, 2
	mov ah, 40h
	int 21h

	; print second string to stdout (fd 1)
	lea dx, str2_buf
	mov cl, str2_cur
	mov ch, 0
	mov bx, 1
	mov ah, 40h
	int 21h

	; print new line
	lea dx, crlf
	mov cx, 2
	mov ah, 40h
	int 21h

	; print third string to stdout (fd 1)
	lea dx, str3_buf
	mov cl, str3_cur
	mov ch, 0
	mov bx, 1
	mov ah, 40h
	int 21h

	; print new line
	lea dx, crlf
	mov cx, 2
	mov ah, 40h
	int 21h

	mov ax, 4C00h
	int 21h

CSEG ends
end start
