.386

SSEG segment para stack use16 'STACK'
	db 256 dup(?)
SSEG ends

DSEG segment para public use16 'DATA'
	max_len		equ 100
	buffer		db max_len, ?, max_len dup (?)
	new_line	db 0dh, 0ah, '$'
	prompt_str	db "Enter a string: $"
	prompt_n	db "Enter number of repetitions (1-9): $"
	msg_rev		db "Reversed string: $"
	msg_repeat	db "Repeated string: $"
	n_value		dw ?
	temp_cx		dw ?
	temp_rep	dw ?
DSEG ends

CSEG segment readonly para public use16 'CODE'
assume CS:CSEG, DS:DSEG, SS:SSEG
start:
	mov ax, DSEG
	mov ds, ax
	mov ax, SSEG
	mov ss, ax

	; enter string
	mov dx, offset prompt_str
	mov ah, 09h
	int 21h

	mov dx, offset buffer
	mov ah, 0Ah
	int 21h

	mov dx, offset new_line
	mov ah, 09h
	int 21h

	mov bl, [buffer+1]
	xor bh, bh
	; save length
	mov [temp_cx], bx

	; print in reverse
	mov dx, offset msg_rev
	mov ah, 09h
	int 21h

	mov cx, bx
	mov si, offset buffer+2
	add si, cx
	dec si

reverse_loop:
	mov dl, [si]
	mov ah, 02h
	int 21h
	dec si
	loop reverse_loop

	mov dx, offset new_line
	mov ah, 09h
	int 21h

	; request number of prints
	mov dx, offset prompt_n
	mov ah, 09h
	int 21h

	mov ah, 01h
	int 21h
	sub al, '0'
	mov byte ptr [n_value], al

	mov dx, offset new_line
	mov ah, 09h
	int 21h

	mov dx, offset msg_repeat
	mov ah, 09h
	int 21h

	; print n times
	mov cx, [n_value]
	xor ch, ch
	mov [temp_rep], cx

repeat_loop:
	cmp word ptr [temp_rep], 0
	je repeat_done

	; string length
	mov cx, [temp_cx]
	mov si, offset buffer+2

print_loop:
	mov dl, [si]
	mov ah, 02h
	int 21h
	inc si
	loop print_loop

	dec word ptr [temp_rep]
	jmp repeat_loop

repeat_done:
	mov dx, offset new_line
	mov ah, 09h
	int 21h

	mov ax, 4C00h
	int 21h

CSEG ends
end start
