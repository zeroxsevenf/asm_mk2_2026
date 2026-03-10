.386

SSEG segment para stack use16 'STACK'
	db 256 dup(?)
SSEG ends

DSEG segment para public use16 'DATA'
	; 4096 dec = 1000 hex
	number		dw 4096
	hex_str		db 5 dup('$')
	new_line	db 0dh, 0ah, '$'
	msg_num		db "Number in memory: $"
	hex_chars	db "0123456789ABCDEF"
	temp_ax		dw ?
DSEG ends

CSEG segment readonly para public use16 'CODE'
assume CS:CSEG, DS:DSEG, SS:SSEG
start:
	mov ax, DSEG
	mov ds, ax
	mov ax, SSEG
	mov ss, ax

	mov dx, offset msg_num
	mov ah, 09h
	int 21h

	; convert to hex string
	mov ax, [number]
	mov di, offset hex_str
	mov cx, 4
	; symbol table
	mov bx, offset hex_chars

convert_loop:
	; move 4 bits
	rol ax, 4
	; save ax
	mov [temp_ax], ax
	; get 4 bits
	and ax, 0Fh
	mov si, ax
	; get symbol from table
	mov al, [bx + si]
	mov [di], al
	inc di
	; restore ax
	mov ax, [temp_ax]
	loop convert_loop

	mov dx, offset hex_str
	mov ah, 09h
	int 21h

	mov dx, offset new_line
	mov ah, 09h
	int 21h

	mov ax, 4C00h
	int 21h

CSEG ends
end start
