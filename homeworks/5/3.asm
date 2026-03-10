.386

SSEG segment para stack use16 'STACK'
	db 256 dup(?)
SSEG ends

DSEG segment para public use16 'DATA'
	new_line	db 0dh, 0ah, '$'
	space		db ' $'
	title_left	db "Left aligned:", 0dh, 0ah, '$'
	title_right db "Right aligned:", 0dh, 0ah, '$'
	num_buf		db 3 dup('$')
DSEG ends

CSEG segment readonly para public use16 'CODE'
assume CS:CSEG, DS:DSEG, SS:SSEG
start:
	mov ax, DSEG
	mov ds, ax
	mov ax, SSEG
	mov ss, ax

	; left align
	mov dx, offset title_left
	mov ah, 09h
	int 21h

	mov si, 0

row_loop_left:
	mov di, 0

col_loop_left:
	mov ax, si
	mov bl, 10
	mul bl
	add ax, di

	; print left aligned
	mov bl, 10
	xor ah, ah
	div bl
	; tens
	mov cl, al
	; ones
	mov ch, ah

	cmp cl, 0
	jne left_two_digits
	mov dl, ch
	add dl, '0'
	mov ah, 02h
	int 21h
	mov dl, ' '
	int 21h
	jmp left_done

left_two_digits:
	mov dl, cl
	add dl, '0'
	mov ah, 02h
	int 21h
	mov dl, ch
	add dl, '0'
	int 21h

left_done:
	cmp di, 9
	je no_space_left
	mov dl, ' '
	mov ah, 02h
	int 21h

no_space_left:
	inc di
	cmp di, 10
	jl col_loop_left

	mov dx, offset new_line
	mov ah, 09h
	int 21h

	inc si
	cmp si, 10
	jl row_loop_left

	; right align
	mov dx, offset title_right
	mov ah, 09h
	int 21h

	mov si, 0

row_loop_right:
	mov di, 0

col_loop_right:
	mov ax, si
	mov bl, 10
	mul bl
	add ax, di

	; print right aligned
	mov bl, 10
	xor ah, ah
	div bl
	mov cl, al
	mov ch, ah

	cmp cl, 0
	jne right_two_digits
	mov dl, ' '
	mov ah, 02h
	int 21h
	mov dl, ch
	add dl, '0'
	int 21h
	jmp right_done

right_two_digits:
	mov dl, cl
	add dl, '0'
	mov ah, 02h
	int 21h
	mov dl, ch
	add dl, '0'
	int 21h

right_done:
	cmp di, 9
	je no_space_right
	mov dl, ' '
	mov ah, 02h
	int 21h

no_space_right:
	inc di
	cmp di, 10
	jl col_loop_right

	mov dx, offset new_line
	mov ah, 09h
	int 21h

	inc si
	cmp si, 10
	jl row_loop_right

	mov ax, 4C00h
	int 21h

CSEG ends
end start
