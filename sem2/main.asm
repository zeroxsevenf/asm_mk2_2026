.386

; error codes
ERROR_SUCCESS         equ 0
ERROR_INVALID_NUM     equ 1
ERROR_INVALID_OP      equ 2
ERROR_MISSING_OP      equ 3
ERROR_MISSING_OPERAND equ 4
ERROR_EXTRA_TOKENS    equ 5
ERROR_DIV_ZERO        equ 6
ERROR_OVERFLOW        equ 7

arg1 equ 4
arg2 equ 6
arg3 equ 8

SSEG segment para stack use16 'STACK'
	db 256 dup(?)
SSEG ends

DSEG segment para public use16 'DATA'

	str_prompt db "Enter expression (prefix '0x' for hex): ", 0
	str_result db "Result: ", 0

	strbuf db 256 dup(0)
	numdec db 32 dup(?)
	numhex db 32 dup(?)

	; variables
	num_one   dw 0
	num_two   dw 0
	result    dd 0
	operation db 0

	; error messages
	err_invalid_num     db 13, 10, "Error: Invalid number", 13, 10, 0
	err_invalid_op      db 13, 10, "Error: Invalid operation (use + - * / %)", 13, 10, 0
	err_missing_op      db 13, 10, "Error: Missing operation", 13, 10, 0
	err_missing_operand db 13, 10, "Error: Missing operand", 13, 10, 0
	err_extra_tokens    db 13, 10, "Error: Extra characters after expression", 13, 10, 0
	err_div_by_zero     db 13, 10, "Error: Division by zero", 13, 10, 0
	err_overflow        db 13, 10, "Error: Signed overflow", 13, 10, 0

	temp_token db 256 dup(0)

DSEG ends

CSEG segment readonly para public use16 'CODE'
assume CS:CSEG, DS:DSEG, SS:SSEG

;------;
; MAIN ;
;------;

start:
	mov ax, DSEG
	mov ds, ax
	mov ax, SSEG
	mov ss, ax

	; print prompt
	lea ax, [str_prompt]
	push ax
	call _putstr
	add sp, 2

	; read string
	lea ax, [strbuf]
	push 254
	push ax
	call _getstr
	add sp, 4

	; validate and parse
	lea ax, [strbuf]
	push ax
	call _validate_and_prepare
	; safe CF
	pop cx
	; catch parsing errors
	jc handle_error

	; do calc
	mov al, byte ptr [operation]
	xor ah, ah
	push ax
	push word ptr [num_two]
	push word ptr [num_one]
	call _calc
	; safe CF
	pop cx
	pop cx
	pop cx
	; catch calculation errors
	jc handle_error

	; print result
	lea ax, [str_result]
	push ax
	call _putstr
	add sp, 2

	; print decimal
	mov ax, word ptr [result]
	mov dx, word ptr [result + 2]
	lea bx, [numdec]
	push bx
	push dx
	push ax
	call _itoa
	add sp, 6
	push bx
	call _putstr
	add sp, 2

	; formatting
	mov dx, ' '
	push dx
	call _putchar
	mov dx, '('
	push dx
	call _putchar
	mov dx, '0'
	push dx
	call _putchar
	mov dx, 'x'
	push dx
	call _putchar
	add sp, 8

	; print hexadecimal
	mov ax, word ptr [result]
	mov dx, word ptr [result + 2]
	lea bx, [numhex]
	push bx
	push dx
	push ax
	call _itoah
	add sp, 6
	push bx
	call _putstr
	add sp, 2

	mov dx, ')'
	push dx
	call _putchar
	add sp, 2

	call _putnewline

exit:
	call _exit0

;---------------;
; ERROR HANDLER ;
;---------------;

handle_error:
	cmp ax, ERROR_INVALID_NUM
	je _pr_inv_num
	cmp ax, ERROR_INVALID_OP
	je _pr_inv_op
	cmp ax, ERROR_MISSING_OP
	je _pr_mis_op
	cmp ax, ERROR_MISSING_OPERAND
	je _pr_mis_opnd
	cmp ax, ERROR_EXTRA_TOKENS
	je _pr_ext_tok
	cmp ax, ERROR_DIV_ZERO
	je _pr_div_z
	cmp ax, ERROR_OVERFLOW
	je _pr_ovf
	; fallback
	jmp exit

_pr_inv_num:
	lea ax, [err_invalid_num]
	jmp _do_print

_pr_inv_op:
	lea ax, [err_invalid_op]
	jmp _do_print

_pr_mis_op:
	lea ax, [err_missing_op]
	jmp _do_print

_pr_mis_opnd:
	lea ax, [err_missing_operand]
	jmp _do_print

_pr_ext_tok:
	lea ax, [err_extra_tokens]
	jmp _do_print

_pr_div_z:
	lea ax, [err_div_by_zero]
	jmp _do_print

_pr_ovf:
	lea ax, [err_overflow]

_do_print:
	push ax
	call _putstr
	add sp, 2
	jmp exit

;------------;
; CALCULATOR ;
;------------;

_calc:
	push bp
	mov bp, sp
	push bx
	push cx
	push dx

	mov ax, word ptr [bp + arg1]
	mov bx, word ptr [bp + arg2]
	mov cl, byte ptr [bp + arg3]

	cmp cl, '+'
	je __calc_add
	cmp cl, '-'
	je __calc_sub
	cmp cl, '*'
	je __calc_mul
	cmp cl, '/'
	je __calc_div
	cmp cl, '%'
	je __calc_mod
	jmp __calc_error

__calc_add:
	add ax, bx
	jo __calc_overflow
	cwd
	jmp __calc_store

__calc_sub:
	sub ax, bx
	jo __calc_overflow
	cwd
	jmp __calc_store

__calc_mul:
	; DX:AX = result
	imul bx
	jmp __calc_store

__calc_div:
	cmp bx, 0
	je __calc_div_by_zero
	; overflow check: -32768 / -1
	cmp ax, 8000h
	jne __calc_div_ok
	cmp bx, 0FFFFh
	je __calc_overflow

__calc_div_ok:
	cwd
	; AX = quotient, DX = remainder
	idiv bx
	cwd
	jmp __calc_store

__calc_mod:
	cmp bx, 0
	je __calc_div_by_zero
	cwd
	; AX = quotient, DX = remainder
	idiv bx
	mov ax, dx
	cwd
	jmp __calc_store

__calc_store:
	mov word ptr [result], ax
	mov word ptr [result + 2], dx
	mov ax, ERROR_SUCCESS
	clc
	jmp __calc_done

__calc_overflow:
	mov ax, ERROR_OVERFLOW
	stc
	jmp __calc_done

__calc_div_by_zero:
	mov ax, ERROR_DIV_ZERO
	stc
	jmp __calc_done

__calc_error:
	mov ax, ERROR_INVALID_OP
	stc

__calc_done:
	pop dx
	pop cx
	pop bx
	mov sp, bp
	pop bp
	ret

;----------------------;
; VALIDATOR AND PARSER ;
;----------------------;

_validate_and_prepare:
	push bp
	mov bp, sp
	push si
	push di
	push bx

	mov si, word ptr [bp + arg1]

	; get num1
	push si
	call _skip_spaces
	add sp, 2
	mov si, ax

	mov di, si

	push di
	call _find_token_end
	add sp, 2
	mov si, ax

	call __vp_extract_token
	; check extract error
	jc __vp_ret_err

	push offset temp_token
	call _validate_number
	pop cx
	; check validate error
	jc __vp_ret_err

	push offset temp_token
	call _uatoi
	pop cx
	; check parse overflow error
	jc __vp_ret_err
	mov [num_one], ax

	; get op
	push si
	call _skip_spaces
	add sp, 2
	mov si, ax

	cmp byte ptr [si], 0
	je __vp_fail_missing_op
	mov al, byte ptr [si]
	mov [operation], al
	inc si
	; op validation
	cmp al, '+'
	je __vp_op_ok
	cmp al, '-'
	je __vp_op_ok
	cmp al, '*'
	je __vp_op_ok
	cmp al, '/'
	je __vp_op_ok
	cmp al, '%'
	je __vp_op_ok
	jmp __vp_fail_op

__vp_op_ok:
	; get num2
	push si
	call _skip_spaces
	add sp, 2
	mov si, ax

	mov di, si

	push di
	call _find_token_end
	add sp, 2
	mov si, ax

	call __vp_extract_token
	jc __vp_ret_err

	push offset temp_token
	call _validate_number
	pop cx
	jc __vp_ret_err

	push offset temp_token
	call _uatoi
	pop cx
	jc __vp_ret_err
	mov [num_two], ax

	; check for junk
	push si
	call _skip_spaces
	add sp, 2
	mov si, ax

	cmp byte ptr [si], 0
	jne __vp_fail_extra

	mov ax, ERROR_SUCCESS
	clc
	jmp __vp_ret_err

__vp_fail_missing_op:
	mov ax, ERROR_MISSING_OP
	stc
	jmp __vp_ret_err

__vp_fail_op:
	mov ax, ERROR_INVALID_OP
	stc
	jmp __vp_ret_err

__vp_fail_extra:
	mov ax, ERROR_EXTRA_TOKENS
	stc

__vp_ret_err:
	pop bx
	pop di
	pop si
	mov sp, bp
	pop bp
	ret

_skip_spaces:
	push bp
	mov bp, sp
	push si
	mov si, word ptr [bp + arg1]

__ss_loop:
	cmp byte ptr [si], ' '
	je __ss_inc
	cmp byte ptr [si], 9
	je __ss_inc
	mov ax, si
	pop si
	mov sp, bp
	pop bp
	ret

__ss_inc:
	inc si
	jmp __ss_loop

_find_token_end:
	push bp
	mov bp, sp
	push si
	push di
	mov di, word ptr [bp + arg1]
	mov si, di

__fe_loop:
	cmp byte ptr [si], 0
	je __fe_done
	cmp byte ptr [si], ' '
	je __fe_done
	cmp byte ptr [si], 9
	je __fe_done
	cmp si, di
	je __fe_next
	cmp byte ptr [si], '+'
	je __fe_done
	cmp byte ptr [si], '-'
	je __fe_done
	cmp byte ptr [si], '*'
	je __fe_done
	cmp byte ptr [si], '/'
	je __fe_done
	cmp byte ptr [si], '%'
	je __fe_done

__fe_next:
	inc si
	jmp __fe_loop

__fe_done:
	mov ax, si
	pop di
	pop si
	mov sp, bp
	pop bp
	ret

__vp_extract_token:
	mov cx, si
	sub cx, di
	jz __vp_et_fail

	cmp cx, 255
	ja __vp_et_fail_len

	mov bx, offset temp_token

__vp_ex_loop:
	mov al, byte ptr [di]
	mov byte ptr [bx], al
	inc di
	inc bx
	loop __vp_ex_loop
	mov byte ptr [bx], 0
	clc
	ret

__vp_et_fail:
	mov ax, ERROR_MISSING_OPERAND
	stc
	ret

__vp_et_fail_len:
	mov ax, ERROR_OVERFLOW
	stc
	ret

; number validation
_validate_number:
	push bp
	mov bp, sp
	push si
	mov si, word ptr [bp + arg1]

	; skip sign for validation
	cmp byte ptr [si], '-'
	jne __vn_plus
	inc si
	jmp __vn_check

__vn_plus:
	cmp byte ptr [si], '+'
	jne __vn_check
	inc si

__vn_check:
	; Check hex prefix
	cmp byte ptr [si], '0'
	jne __vn_dec
	mov al, byte ptr [si+1]
	cmp al, 'x'
	je __vn_hex
	cmp al, 'X'
	je __vn_hex

__vn_dec:
	; validate decimal digits
__vn_dec_loop:
	mov al, byte ptr [si]
	test al, al
	jz __vn_ok
	cmp al, '0'
	jb __vn_fail
	cmp al, '9'
	ja __vn_fail
	inc si
	jmp __vn_dec_loop

__vn_hex:
	add si, 2
	; digit counter
	mov cx, 0

__vn_hex_loop:
	mov al, byte ptr [si]
	test al, al
	jz __vn_hex_done
	inc cx
	cmp al, '0'
	jb __vn_fail
	cmp al, '9'
	jbe __vn_hnext
	; to uppercase
	and al, 0DFh
	cmp al, 'A'
	jb __vn_fail
	cmp al, 'F'
	ja __vn_fail

__vn_hnext:
	inc si
	jmp __vn_hex_loop

__vn_hex_done:
	test cx, cx
	jz __vn_fail

__vn_ok:
	mov ax, ERROR_SUCCESS
	clc
	jmp __vn_end

__vn_fail:
	mov ax, ERROR_INVALID_NUM
	stc

__vn_end:
	pop si
	mov sp, bp
	pop bp
	ret

;---------------;
; ATOI FUNCTION ;
;---------------;

; universal version
_uatoi:
	push bp
	mov bp, sp
	push si
	mov si, word ptr [bp + arg1]

	; skip sign to check prefix
	mov bx, si
	cmp byte ptr [bx], '-'
	je __ua_skip_s
	cmp byte ptr [bx], '+'
	jne __ua_check_hex

__ua_skip_s:
	inc bx

__ua_check_hex:
	cmp byte ptr [bx], '0'
	jne __ua_call_dec
	mov al, byte ptr [bx + 1]
	cmp al, 'x'
	je __ua_call_hex
	cmp al, 'X'
	je __ua_call_hex

__ua_call_dec:
	push si
	call _atoi
	pop cx
	; CF from _atoi
	jmp __ua_done

__ua_call_hex:
	xor dx, dx
	cmp byte ptr [si], '-'
	jne __ua_h_pos
	mov dx, 1

__ua_h_pos:
	push bx
	call _ahtoi
	pop cx
	; failed
	jc __ua_done

	test dx, dx
	jz __ua_h_pos_check

	; apply negative sign and valid range
	cmp ax, 8000h
	ja __ua_overflow
	je __ua_min_int
	neg ax
	clc
	jmp __ua_done

__ua_h_pos_check:
	clc
	jmp __ua_done

__ua_min_int:
	mov ax, 8000h
	clc
	jmp __ua_done

__ua_overflow:
	mov ax, ERROR_OVERFLOW
	stc

__ua_done:
	pop si
	mov sp, bp
	pop bp
	ret

; hex version
_ahtoi:
	push bp
	mov bp, sp
	push si
	; save to prevent corrupting DX
	push dx
	mov si, word ptr [bp + arg1]
	add si, 2
	xor ax, ax

__ah_loop:
	mov cl, byte ptr [si]
	test cl, cl
	jz __ah_done

	; check shift left 4 bits drop high bit
	test ah, 0F0h
	jnz __ah_overflow

	shl ax, 4
	cmp cl, '9'
	jbe __ah_dig
	and cl, 0DFh
	sub cl, 'A'-10
	jmp __ah_acc

__ah_dig:
	sub cl, '0'

__ah_acc:
	or al, cl
	inc si
	jmp __ah_loop

__ah_overflow:
	mov ax, ERROR_OVERFLOW
	stc
	jmp __ah_end

__ah_done:
	clc

__ah_end:
	pop dx
	pop si
	mov sp, bp
	pop bp
	ret

; normal version
_atoi:
	push bp
	mov bp, sp
	push si
	push bx
	mov si, word ptr [bp + arg1]
	xor ax, ax
	xor bx, bx

__at_skip:
	cmp byte ptr [si], ' '
	jne __at_sign
	inc si
	jmp __at_skip

__at_sign:
	cmp byte ptr [si], '-'
	jne __at_plus
	mov bx, 1
	inc si
	jmp __at_loop

__at_plus:
	cmp byte ptr [si], '+'
	jne __at_loop
	inc si

__at_loop:
	mov cl, byte ptr [si]
	cmp cl, '0'
	jb __at_done
	cmp cl, '9'
	ja __at_done
	sub cl, '0'

	; unsigned range validate 16-bit
	mov dx, 10
	mul dx
	test dx, dx
	jnz __at_overflow_err

	xor ch, ch
	add ax, cx
	jc __at_overflow_err

	; check for signed range
	cmp ax, 8000h
	ja __at_overflow_err

	inc si
	jmp __at_loop

__at_done:
	test bx, bx
	jz __at_check_positive

	cmp ax, 8000h
	je __at_is_min_int
	neg ax
	clc
	jmp __at_end

__at_check_positive:
	cmp ax, 8000h
	jae __at_overflow_err
	clc
	jmp __at_end

__at_is_min_int:
	mov ax, 8000h
	clc
	jmp __at_end

__at_overflow_err:
	mov ax, ERROR_OVERFLOW
	stc

__at_end:
	pop bx
	pop si
	mov sp, bp
	pop bp
	ret

;---------------;
; ITOA FUNCTION ;
;---------------;

; normal version
_itoa:
	push bp
	mov bp, sp
	push si
	push di
	push bx

	mov ax, [bp + arg1]
	mov dx, [bp + arg2]
	mov di, [bp + arg3]
	test dx, dx
	jns __it_pos
	mov byte ptr [di], '-'
	inc di
	not dx
	not ax
	add ax, 1
	adc dx, 0

__it_pos:
	xor bx, bx
	mov cx, 10

__it_loop:
	push ax
	mov ax, dx
	xor dx, dx
	div cx
	mov si, ax
	pop ax
	div cx
	; remainder
	push dx
	inc bx
	mov dx, si
	mov si, ax
	or si, dx
	jnz __it_loop

__it_write:
	pop dx
	add dl, '0'
	mov [di], dl
	inc di
	dec bx
	jnz __it_write
	mov byte ptr [di], 0
	pop bx
	pop di
	pop si
	mov sp, bp
	pop bp
	ret

; hex version
_itoah:
	push bp
	mov bp, sp
	push si
	push di
	push bx
	mov ax, [bp+arg1]
	mov dx, [bp+arg2]
	mov di, [bp+arg3]
	xor bx, bx
	mov cx, 16

__ith_loop:
	push ax
	mov ax, dx
	xor dx, dx
	div cx
	mov si, ax
	pop ax
	div cx
	push dx
	inc bx
	mov dx, si
	mov si, ax
	or si, dx
	jnz __ith_loop

__ith_write:
	pop dx
	cmp dl, 10
	jb __ith_dig
	add dl, 'A'-10
	jmp __ith_st

__ith_dig:
	add dl, '0'

__ith_st:
	mov [di], dl
	inc di
	dec bx
	jnz __ith_write
	mov byte ptr [di], 0
	pop bx
	pop di
	pop si
	mov sp, bp
	pop bp
	ret

;------------------;
; HELPER FUNCTIONS ;
;------------------;

_putchar:
	push bp
	mov bp, sp
	mov dx, [bp + arg1]
	mov ah, 02h
	int 21h
	pop bp
	ret

_putstr:
	push bp
	mov bp, sp
	push si
	mov si, [bp + arg1]

__ps_loop:
	lodsb
	test al, al
	jz __ps_exit
	mov dl, al
	mov ah, 02h
	int 21h
	jmp __ps_loop

__ps_exit:
	pop si
	pop bp
	ret

_getstr:
	push bp
	mov bp, sp
	mov dx, [bp + arg1]
	mov cx, [bp + arg2]
	mov bx, 0
	mov ah, 3Fh
	int 21h
	; ax = bytes read
	mov bx, [bp + arg1]
	add bx, ax
	; check strip CRLF
	cmp ax, 2
	jb __gs_exit
	mov di, bx
	dec di
	cmp byte ptr [di], 10
	jne __gs_exit
	sub bx, 2

__gs_exit:
	mov byte ptr [bx], 0
	pop bp
	ret

_putnewline:
	mov dl, 13
	mov ah, 02h
	int 21h
	mov dl, 10
	mov ah, 02h
	int 21h
	ret

_exit0:
	mov ax, 4C00h
	int 21h

CSEG ends
end start
