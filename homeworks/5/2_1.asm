.386

SSEG segment para stack use16 'STACK'
	db 256 dup(?)
SSEG ends

DSEG segment para public use16 'DATA'
	max_len		equ 100
	buffer		db max_len, ?, max_len dup (?)
	new_line	db 0dh, 0ah, '$'
	msg_range	db "Enter range (two characters, for example: 'A Z'): $"
	msg_string	db "Enter string: $"
	msg_fail	db "Some character in the string IS NOT within the specified range.$"
	msg_ok		db "All characters in the string IS within the specified range.$"
	low_char	db ?
	high_char	db ?
DSEG ends

CSEG segment readonly para public use16 'CODE'
assume CS:CSEG, DS:DSEG, SS:SSEG
start:
	mov ax, DSEG
	mov ds, ax
	mov ax, SSEG
	mov ss, ax

	; enter range
	mov dx, offset msg_range
	mov ah, 09h
	int 21h

	mov ah, 01h
	int 21h
	mov [low_char], al
	mov ah, 01h
	int 21h
	cmp al, ' '
	je skip_space
	mov [high_char], al
	jmp after_range

skip_space:
	mov ah, 01h
	int 21h
	mov [high_char], al

after_range:
	mov dx, offset new_line
	mov ah, 09h
	int 21h

	; enter string
	mov dx, offset msg_string
	mov ah, 09h
	int 21h

	mov dx, offset buffer
	mov ah, 0Ah
	int 21h

	mov dx, offset new_line
	mov ah, 09h
	int 21h

	; check
	mov cl, [buffer+1]
	mov ch, 0
	mov si, offset buffer+2
	mov al, [low_char]
	mov bl, [high_char]

check_loop:
	mov dl, [si]
	cmp dl, al
	jb	not_in_range
	cmp dl, bl
	ja	not_in_range
	inc si
	loop check_loop

	; all passed
	mov dx, offset msg_ok
	mov ah, 09h
	int 21h

	mov dx, offset new_line
	mov ah, 09h
	int 21h

	; return 0
	mov ax, 4C00h
	int 21h

not_in_range:
	mov dx, offset msg_fail
	mov ah, 09h
	int 21h

	mov dx, offset new_line
	mov ah, 09h
	int 21h

	; return -1
	mov ax, 4CFFh
	int 21h

CSEG ends
end start
