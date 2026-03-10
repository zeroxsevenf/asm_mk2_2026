.386

SSEG		segment para stack use16 'STACK'
		db 256 dup(?)
SSEG		ends

DSEG		segment para public use16 'DATA'
max_len		equ 100
buffer		db max_len, ?, max_len dup (?)
new_line	db 0dh, 0ah, '$'
msg_range	db "Enter range (two characters, for example: 'A Z'): $"
msg_string	db "Enter string: $"
msg_fail	db "Some character in the string IS NOT within the specified range.$"
msg_ok		db "All characters in the string IS within the specified range.$"
low_char	db ?
high_char	db ?

; data for extended task
mismatches	db max_len * 2 dup (?)	; store pairs [index, char]
mismatch_count	dw 0			; number of mismatches found
msg_fail_start	db "Some character(s) in the string IS NOT within the specified range: $"

; helper variables for decimal conversion and printing
dec_buffer	db 4 dup (?)		; buffer for decimal digits (max 3 digits + safety)
temp_si		dw ?			; temporary storage for SI
first_flag	db ?			; flag for first mismatch entry
DSEG		ends

CSEG		segment readonly para public use16 'CODE'
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

		; check the whole string, collect mismatches
		mov cl, [buffer+1]		; string length
		mov ch, 0
		mov si, offset buffer+2		; pointer to first char
		mov di, offset mismatches	; pointer to storage
		mov bx, 1			; current index (starting from 1)
		mov [mismatch_count], 0		; reset counter

check_loop:
		mov dl, [si]
		cmp dl, [low_char]
		jb mismatch_found
		cmp dl, [high_char]
		ja mismatch_found
		jmp next_char

mismatch_found:
		; store index (bl) and character (dl)
		mov [di], bl
		inc di
		mov [di], dl
		inc di
		inc word ptr [mismatch_count]

next_char:
		inc si
		inc bx
		loop check_loop

		; decide what to print
		cmp [mismatch_count], 0
		je all_ok

		; there are mismatches – print the list
		mov dx, offset msg_fail_start
		mov ah, 09h
		int 21h

		; initialise print loop
		mov bp, [mismatch_count]	; bp = number of items
		mov si, offset mismatches	; si points to first pair
		mov [first_flag], 1		; first item flag

print_mismatch_loop:
		; if not first item, print ", "
		cmp [first_flag], 1
		je print_item
		mov ah, 02h
		mov dl, ','
		int 21h
		mov dl, ' '
		int 21h

print_item:
		mov [first_flag], 0		; clear flag after first

		; print '['
		mov ah, 02h
		mov dl, '['
		int 21h

		; save SI because we need it later
		mov [temp_si], si

		; convert index (byte at [si]) to decimal and print
		mov al, [si]			; index (1‑based)
		mov di, offset dec_buffer + 3	; point to end of buffer
		mov cx, 0			; digit counter
		mov dl, 10			; divisor

convert_index:
		xor ah, ah
		div dl
		add ah, '0'			; remainder → ASCII digit
		mov [di], ah
		dec di
		inc cx
		test al, al
		jnz convert_index
		inc di				; di now points to first digit

		; print the digits
		mov si, di			; use si as pointer to digits (original saved)
print_digits:
		mov dl, [si]
		mov ah, 02h
		int 21h
		inc si
		loop print_digits

		; restore original si
		mov si, [temp_si]

		; print " - "
		mov ah, 02h
		mov dl, ' '
		int 21h
		mov dl, '-'
		int 21h
		mov dl, ' '
		int 21h

		; print character
		mov dl, [si+1]
		mov ah, 02h
		int 21h

		; print ']'
		mov dl, ']'
		int 21h

		; move to next pair
		add si, 2
		dec bp
		jnz print_mismatch_loop

		; print final '.' and new line
		mov ah, 02h
		mov dl, '.'
		int 21h
		mov dx, offset new_line
		mov ah, 09h
		int 21h

		mov ax, 4CFFh
		int 21h

all_ok:
		mov dx, offset msg_ok
		mov ah, 09h
		int 21h
		mov dx, offset new_line
		mov ah, 09h
		int 21h
		mov ax, 4C00h
		int 21h

CSEG		ends
		end start
