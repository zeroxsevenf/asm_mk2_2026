.386

SSEG segment para stack use16 'STACK'
	db 256 dup(?)
SSEG ends

DSEG segment para public use16 'DATA'
	src_string	db "Try find symbol!"
	new_line	db 0dh, 0ah, '$'
	prompt		db "Enter a character: $"
	msg_found	db " - Found.", 0dh, 0ah, '$'
	msg_notfnd	db " - Not found.", 0dh, 0ah, '$'
	msg_src		db "Source string: $"
	src_len		dw ?
	request_cnt dw 0
	prev_empty	db 0
	buffer		db ?
DSEG ends

CSEG segment readonly para public use16 'CODE'
assume CS:CSEG, DS:DSEG, SS:SSEG
start:
	mov ax, DSEG
	mov ds, ax
	mov ax, SSEG
	mov ss, ax

	; find string length
	mov cx, offset new_line - offset src_string
	mov src_len, cx

main_loop:
	; increase counter
	inc word ptr [request_cnt]

	; print prompt
	mov dx, offset prompt
	mov ah, 09h
	int 21h

	; enter symbol
	mov ah, 01h
	int 21h

	; check for ENTER
	cmp al, 0Dh
	jne not_empty

	; empty
	cmp byte ptr [prev_empty], 1
	je exit_prog
	mov byte ptr [prev_empty], 1
	jmp check_periodic

not_empty:
	mov byte ptr [prev_empty], 0
	mov [buffer], al

	; find symbol in string
	mov al, [buffer]
	mov cx, src_len
	mov bx, offset src_string
	dec bx

search_loop:
	inc bx
	cmp al, [bx]
	loopne search_loop

	mov dx, offset new_line
	mov ah, 09h
	int 21h

	; print result
	mov dl, [buffer]
	mov ah, 02h
	int 21h

	je found
	mov dx, offset msg_notfnd
	jmp print_result

found:
	mov dx, offset msg_found

print_result:
	mov ah, 09h
	int 21h

check_periodic:
	; every five request print string
	mov ax, [request_cnt]
	mov bl, 5
	div bl
	cmp ah, 0
	jne main_loop

	mov dx, offset msg_src
	mov ah, 09h
	int 21h

	mov cx, src_len
	mov si, offset src_string

print_src:
	mov dl, [si]
	mov ah, 02h
	int 21h
	inc si
	loop print_src

	mov dx, offset new_line
	mov ah, 09h
	int 21h

	jmp main_loop

exit_prog:
	mov dx, offset new_line
	mov ah, 09h
	int 21h

	mov ax, 4C00h
	int 21h

CSEG ends
end start
