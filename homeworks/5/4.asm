.386

SSEG segment para stack use16 'STACK'
	db 256 dup(?)
SSEG ends

DSEG segment para public use16 'DATA'
	hex_digits db "0123456789ABCDEF"

	; ascii special symbols names
	name00 db "NUL$"
	name01 db "SOH$"
	name02 db "STX$"
	name03 db "ETX$"
	name04 db "EOT$"
	name05 db "ENQ$"
	name06 db "ACK$"
	name07 db "BEL$"
	name08 db "BS$"
	name09 db "TAB$"
	name10 db "LF$"
	name11 db "VT$"
	name12 db "FF$"
	name13 db "CR$"
	name14 db "SO$"
	name15 db "SI$"
	name16 db "DLE$"
	name17 db "DC1$"
	name18 db "DC2$"
	name19 db "DC3$"
	name20 db "DC4$"
	name21 db "NAK$"
	name22 db "SYN$"
	name23 db "ETB$"
	name24 db "CAN$"
	name25 db "EM$"
	name26 db "SUB$"
	name27 db "ESC$"
	name28 db "FS$"
	name29 db "GS$"
	name30 db "RS$"
	name31 db "US$"
	name32 db "SP$"
	name127 db "DEL$"

	; offsets
	ptr_names dw offset name00, offset name01, offset name02, offset name03
			  dw offset name04, offset name05, offset name06, offset name07
			  dw offset name08, offset name09, offset name10, offset name11
			  dw offset name12, offset name13, offset name14, offset name15
			  dw offset name16, offset name17, offset name18, offset name19
			  dw offset name20, offset name21, offset name22, offset name23
			  dw offset name24, offset name25, offset name26, offset name27
			  dw offset name28, offset name29, offset name30, offset name31
			  dw offset name32

DSEG ends

CSEG segment readonly para public use16 'CODE'
assume CS:CSEG, DS:DSEG, SS:SSEG
start:
	mov ax, DSEG
	mov ds, ax
	mov ax, SSEG
	mov ss, ax

	; si - current symbol
	; di - current position in string
	xor si, si
	xor di, di

main_loop:
	; check for special symbols
	cmp si, 32
	jbe special
	cmp si, 127
	je special_del

	; printable symbol
	mov ax, si
	mov dl, al
	mov ah, 2
	int 21h
	jmp after_symbol

special:
	mov bx, si
	shl bx, 1
	mov dx, ptr_names[bx]
	mov ah, 9
	int 21h
	jmp after_symbol

special_del:
	mov dx, offset name127
	mov ah, 9
	int 21h

after_symbol:
	; print ": "
	mov dl, ':'
	mov ah, 2
	int 21h
	mov dl, ' '
	int 21h

	; print high hex dight
	mov ax, si
	shr al, 4
	xor ah, ah
	mov bx, offset hex_digits
	add bx, ax
	mov dl, [bx]
	mov ah, 2
	int 21h

	; print low hex digit
	mov ax, si
	and al, 0Fh
	xor ah, ah
	mov bx, offset hex_digits
	add bx, ax
	mov dl, [bx]
	mov ah, 2
	int 21h

	; print space
	mov dl, ' '
	int 21h

	; increase counter
	inc di
	cmp di, 8
	jne next_char

	; newline after 8 symbols
	mov dl, 13
	mov ah, 2
	int 21h
	mov dl, 10
	int 21h
	xor di, di

next_char:
	inc si
	cmp si, 256
	jb main_loop

	mov ax, 4C00h
	int 21h
CSEG ends
end start
