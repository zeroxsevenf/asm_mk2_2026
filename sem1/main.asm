.386

SSEG segment para stack use16 'STACK'
	db 65535 dup(?)
SSEG ends

DSEG segment para public use16 'DATA'

	string_max db 255
	string_cur db ?
	string_buf db 256 dup(?)

	message1 db "CRC16: 0x$"
	message2 db "CRC32: 0x$"
	hex_num_crc16 db "0000$"
	hex_num_crc32 db "00000000$"

	hex_chars db "0123456789ABCDEF"

	; code correct for THIS constants table (exist 2 variants)
	; for this variant hash of '123456789' is 0x29B1
	; for other variant hash is 0xE5CC
	crc16_table	dw 00000h, 01021h, 02042h, 03063h, 04084h, 050A5h, 060C6h, 070E7h
				dw 08108h, 09129h, 0A14Ah, 0B16Bh, 0C18Ch, 0D1ADh, 0E1CEh, 0F1EFh
				dw 01231h, 00210h, 03273h, 02252h, 052B5h, 04294h, 072F7h, 062D6h
				dw 09339h, 08318h, 0B37Bh, 0A35Ah, 0D3BDh, 0C39Ch, 0F3FFh, 0E3DEh
				dw 02462h, 03443h, 00420h, 01401h, 064E6h, 074C7h, 044A4h, 05485h
				dw 0A56Ah, 0B54Bh, 08528h, 09509h, 0E5EEh, 0F5CFh, 0C5ACh, 0D58Dh
				dw 03653h, 02672h, 01611h, 00630h, 076D7h, 066F6h, 05695h, 046B4h
				dw 0B75Bh, 0A77Ah, 09719h, 08738h, 0F7DFh, 0E7FEh, 0D79Dh, 0C7BCh
				dw 048C4h, 058E5h, 06886h, 078A7h, 00840h, 01861h, 02802h, 03823h
				dw 0C9CCh, 0D9EDh, 0E98Eh, 0F9AFh, 08948h, 09969h, 0A90Ah, 0B92Bh
				dw 05AF5h, 04AD4h, 07AB7h, 06A96h, 01A71h, 00A50h, 03A33h, 02A12h
				dw 0DBFDh, 0CBDCh, 0FBBFh, 0EB9Eh, 09B79h, 08B58h, 0BB3Bh, 0AB1Ah
				dw 06CA6h, 07C87h, 04CE4h, 05CC5h, 02C22h, 03C03h, 00C60h, 01C41h
				dw 0EDAEh, 0FD8Fh, 0CDECh, 0DDCDh, 0AD2Ah, 0BD0Bh, 08D68h, 09D49h
				dw 07E97h, 06EB6h, 05ED5h, 04EF4h, 03E13h, 02E32h, 01E51h, 00E70h
				dw 0FF9Fh, 0EFBEh, 0DFDDh, 0CFFCh, 0BF1Bh, 0AF3Ah, 09F59h, 08F78h
				dw 09188h, 081A9h, 0B1CAh, 0A1EBh, 0D10Ch, 0C12Dh, 0F14Eh, 0E16Fh
				dw 01080h, 000A1h, 030C2h, 020E3h, 05004h, 04025h, 07046h, 06067h
				dw 083B9h, 09398h, 0A3FBh, 0B3DAh, 0C33Dh, 0D31Ch, 0E37Fh, 0F35Eh
				dw 002B1h, 01290h, 022F3h, 032D2h, 04235h, 05214h, 06277h, 07256h
				dw 0B5EAh, 0A5CBh, 095A8h, 08589h, 0F56Eh, 0E54Fh, 0D52Ch, 0C50Dh
				dw 034E2h, 024C3h, 014A0h, 00481h, 07466h, 06447h, 05424h, 04405h
				dw 0A7DBh, 0B7FAh, 08799h, 097B8h, 0E75Fh, 0F77Eh, 0C71Dh, 0D73Ch
				dw 026D3h, 036F2h, 00691h, 016B0h, 06657h, 07676h, 04615h, 05634h
				dw 0D94Ch, 0C96Dh, 0F90Eh, 0E92Fh, 099C8h, 089E9h, 0B98Ah, 0A9ABh
				dw 05844h, 04865h, 07806h, 06827h, 018C0h, 008E1h, 03882h, 028A3h
				dw 0CB7Dh, 0DB5Ch, 0EB3Fh, 0FB1Eh, 08BF9h, 09BD8h, 0ABBBh, 0BB9Ah
				dw 04A75h, 05A54h, 06A37h, 07A16h, 00AF1h, 01AD0h, 02AB3h, 03A92h
				dw 0FD2Eh, 0ED0Fh, 0DD6Ch, 0CD4Dh, 0BDAAh, 0AD8Bh, 09DE8h, 08DC9h
				dw 07C26h, 06C07h, 05C64h, 04C45h, 03CA2h, 02C83h, 01CE0h, 00CC1h
				dw 0EF1Fh, 0FF3Eh, 0CF5Dh, 0DF7Ch, 0AF9Bh, 0BFBAh, 08FD9h, 09FF8h
				dw 06E17h, 07E36h, 04E55h, 05E74h, 02E93h, 03EB2h, 00ED1h, 01EF0h

	crc32_table	dd 000000000h, 077073096h, 0EE0E612Ch, 0990951BAh, 0076DC419h, 0706AF48Fh, 0E963A535h, 09E6495A3h
				dd 00EDB8832h, 079DCB8A4h, 0E0D5E91Eh, 097D2D988h, 009B64C2Bh, 07EB17CBDh, 0E7B82D07h, 090BF1D91h
				dd 01DB71064h, 06AB020F2h, 0F3B97148h, 084BE41DEh, 01ADAD47Dh, 06DDDE4EBh, 0F4D4B551h, 083D385C7h
				dd 0136C9856h, 0646BA8C0h, 0FD62F97Ah, 08A65C9ECh, 014015C4Fh, 063066CD9h, 0FA0F3D63h, 08D080DF5h
				dd 03B6E20C8h, 04C69105Eh, 0D56041E4h, 0A2677172h, 03C03E4D1h, 04B04D447h, 0D20D85FDh, 0A50AB56Bh
				dd 035B5A8FAh, 042B2986Ch, 0DBBBC9D6h, 0ACBCF940h, 032D86CE3h, 045DF5C75h, 0DCD60DCFh, 0ABD13D59h
				dd 026D930ACh, 051DE003Ah, 0C8D75180h, 0BFD06116h, 021B4F4B5h, 056B3C423h, 0CFBA9599h, 0B8BDA50Fh
				dd 02802B89Eh, 05F058808h, 0C60CD9B2h, 0B10BE924h, 02F6F7C87h, 058684C11h, 0C1611DABh, 0B6662D3Dh
				dd 076DC4190h, 001DB7106h, 098D220BCh, 0EFD5102Ah, 071B18589h, 006B6B51Fh, 09FBFE4A5h, 0E8B8D433h
				dd 07807C9A2h, 00F00F934h, 09609A88Eh, 0E10E9818h, 07F6A0DBBh, 0086D3D2Dh, 091646C97h, 0E6635C01h
				dd 06B6B51F4h, 01C6C6162h, 0856530D8h, 0F262004Eh, 06C0695EDh, 01B01A57Bh, 08208F4C1h, 0F50FC457h
				dd 065B0D9C6h, 012B7E950h, 08BBEB8EAh, 0FCB9887Ch, 062DD1DDFh, 015DA2D49h, 08CD37CF3h, 0FBD44C65h
				dd 04DB26158h, 03AB551CEh, 0A3BC0074h, 0D4BB30E2h, 04ADFA541h, 03DD895D7h, 0A4D1C46Dh, 0D3D6F4FBh
				dd 04369E96Ah, 0346ED9FCh, 0AD678846h, 0DA60B8D0h, 044042D73h, 033031DE5h, 0AA0A4C5Fh, 0DD0D7CC9h
				dd 05005713Ch, 0270241AAh, 0BE0B1010h, 0C90C2086h, 05768B525h, 0206F85B3h, 0B966D409h, 0CE61E49Fh
				dd 05EDEF90Eh, 029D9C998h, 0B0D09822h, 0C7D7A8B4h, 059B33D17h, 02EB40D81h, 0B7BD5C3Bh, 0C0BA6CADh
				dd 0EDB88320h, 09ABFB3B6h, 003B6E20Ch, 074B1D29Ah, 0EAD54739h, 09DD277AFh, 004DB2615h, 073DC1683h
				dd 0E3630B12h, 094643B84h, 00D6D6A3Eh, 07A6A5AA8h, 0E40ECF0Bh, 09309FF9Dh, 00A00AE27h, 07D079EB1h
				dd 0F00F9344h, 08708A3D2h, 01E01F268h, 06906C2FEh, 0F762575Dh, 0806567CBh, 0196C3671h, 06E6B06E7h
				dd 0FED41B76h, 089D32BE0h, 010DA7A5Ah, 067DD4ACCh, 0F9B9DF6Fh, 08EBEEFF9h, 017B7BE43h, 060B08ED5h
				dd 0D6D6A3E8h, 0A1D1937Eh, 038D8C2C4h, 04FDFF252h, 0D1BB67F1h, 0A6BC5767h, 03FB506DDh, 048B2364Bh
				dd 0D80D2BDAh, 0AF0A1B4Ch, 036034AF6h, 041047A60h, 0DF60EFC3h, 0A867DF55h, 0316E8EEFh, 04669BE79h
				dd 0CB61B38Ch, 0BC66831Ah, 0256FD2A0h, 05268E236h, 0CC0C7795h, 0BB0B4703h, 0220216B9h, 05505262Fh
				dd 0C5BA3BBEh, 0B2BD0B28h, 02BB45A92h, 05CB36A04h, 0C2D7FFA7h, 0B5D0CF31h, 02CD99E8Bh, 05BDEAE1Dh
				dd 09B64C2B0h, 0EC63F226h, 0756AA39Ch, 0026D930Ah, 09C0906A9h, 0EB0E363Fh, 072076785h, 005005713h
				dd 095BF4A82h, 0E2B87A14h, 07BB12BAEh, 00CB61B38h, 092D28E9Bh, 0E5D5BE0Dh, 07CDCEFB7h, 00BDBDF21h
				dd 086D3D2D4h, 0F1D4E242h, 068DDB3F8h, 01FDA836Eh, 081BE16CDh, 0F6B9265Bh, 06FB077E1h, 018B74777h
				dd 088085AE6h, 0FF0F6A70h, 066063BCAh, 011010B5Ch, 08F659EFFh, 0F862AE69h, 0616BFFD3h, 0166CCF45h
				dd 0A00AE278h, 0D70DD2EEh, 04E048354h, 03903B3C2h, 0A7672661h, 0D06016F7h, 04969474Dh, 03E6E77DBh
				dd 0AED16A4Ah, 0D9D65ADCh, 040DF0B66h, 037D83BF0h, 0A9BCAE53h, 0DEBB9EC5h, 047B2CF7Fh, 030B5FFE9h
				dd 0BDBDF21Ch, 0CABAC28Ah, 053B39330h, 024B4A3A6h, 0BAD03605h, 0CDD70693h, 054DE5729h, 023D967BFh
				dd 0B3667A2Eh, 0C4614AB8h, 05D681B02h, 02A6F2B94h, 0B40BBE37h, 0C30C8EA1h, 05A05DF1Bh, 02D02EF8Dh

DSEG ends

CSEG segment readonly para public use16 'CODE'
assume CS:CSEG, DS:DSEG, SS:SSEG

start:
	mov ax, DSEG
	mov ds, ax
	mov ax, SSEG
	mov ss, ax

	; input string
	lea dx, [string_max]
	mov ah, 0Ah
	int 21h

	; terminate string
	mov bl, byte ptr [string_cur]
	mov bh, 0
	lea si, [string_buf]
	add si, bx
	mov byte ptr [si], "$"

	; confirm string
	lea dx, [string_buf]
	mov ah, 09h
	int 21h

	; new line
	mov dl, 0Dh
	mov ah, 02h
	int 21h
	mov dl, 0Ah
	mov ah, 02h
	int 21h

	; compute CRC16-CCITT
	lea bx, [string_buf]
	mov cl, byte ptr [string_cur]
	mov ch, 0
	call crc16ccitt

	nop

	; convert CRC16 to hex string
	mov ax, dx
	lea di, [hex_num_crc16]
	call to_hex

	; print message1
	lea dx, [message1]
	mov ah, 09h
	int 21h

	; print crc16
	lea dx, [hex_num_crc16]
	mov ah, 09h
	int 21h

	; new line
	mov dl, 0Dh
	mov ah, 02h
	int 21h
	mov dl, 0Ah
	mov ah, 02h
	int 21h

	; compute CRC32
	lea bx, [string_buf]
	mov cl, byte ptr [string_cur]
	mov ch, 0
	call crc32_hash

	nop

	; convert CRC32 to hex string
	lea di, [hex_num_crc32 + 4]
	call to_hex
	mov ax, dx
	lea di, [hex_num_crc32]
	call to_hex

	; print message2
	lea dx, [message2]
	mov ah, 09h
	int 21h

	; print crc32
	lea dx, [hex_num_crc32]
	mov ah, 09h
	int 21h

	; new line
	mov dl, 0Dh
	mov ah, 02h
	int 21h
	mov dl, 0Ah
	mov ah, 02h
	int 21h

exit:
	mov ax, 4C00h
	int 21h

;|------------------------------------------------------------------|
;| CRC16-CCITT hash function (check: 0x29B1 poly: 0x1021)
;|------------------------------------------------------------------|
;| IN:
;|  bx - string pointer
;|  cx - string length
;| OUT:
;|  dx - calculated hash
;|------------------------------------------------------------------|
crc16ccitt:
	; init with value 0xFFFF
	mov dx, 0FFFFh

	; exit if string empty
	jcxz crc16ccitt_exit

	push si
	push di

; (crc << 8) ^ table[(crc >> 8) ^ (*string++)]
;      |     |   |        |     |      |
;     (4)   (6) (5)      (2)   (3)    (1)
crc16ccitt_loop:
	; save CRC
	push dx

	; step (1)
	mov al, byte ptr [bx]
	mov ah, 0
	inc bx

	; step (2)
	shr dx, 8

	; step (3)
	xor ax, dx
	mov si, 0
	mov si, ax

	; restore CRC
	pop dx

	; step (4)
	shl dx, 8

	; step (5)
	; 2*si (lookup table element is 2 bytes in size)
	shl si, 1
	mov di, word ptr [crc16_table + si]

	; step (6)
	xor dx, di

	loop crc16ccitt_loop

	pop di
	pop si

crc16ccitt_exit:
	ret
;|------------------------------------------------------------------|

;|------------------------------------------------------------------|
;| CRC32 hash function (check: 0xCBF43926 poly: 0x04C11DB7)
;|------------------------------------------------------------------|
;| IN:
;|  bx - string pointer
;|  cx - string length
;| OUT:
;|  dx:ax - calculated hash
;|------------------------------------------------------------------|
crc32_hash:
	; init with value 0xFFFFFFFF
	mov ax, 0FFFFh
	mov dx, 0FFFFh

	; exit if string empty
	jcxz crc32_exit

	push si
	push di
	push bp

; crc = (crc >> 8) ^ table[(crc ^ *string++) & 0xFF]
;            |     |   |        |     |      |
;           (5)   (6) (4)      (2)   (1)    (3)
crc32_loop:
	; save CRC
	push dx
	push ax

	; step (1)
	mov dl, byte ptr [bx]
	inc bx

	; restore original CRC
	pop si
	pop di

	; step (2+3) (low byte)
	mov ax, si
	xor al, dl
	mov ah, 0
	mov bp, ax

	; save string pointer
	push bx

	; step (4)
	; 4*bp (lookup table element is 4 bytes in size)
	shl bp, 2
	mov bx, word ptr [crc32_table + bp]
	mov ax, word ptr [crc32_table + bp + 2]

	; step (5)
	; high
	mov dx, di
	shr dx, 8
	; low
	mov bp, si
	shr bp, 8
	; low byte of original high
	and di, 0FFh
	shl di, 8
	or bp, di

	; step (6)
	xor dx, ax
	xor bp, bx

	; CRC in dx:bp -> dx:ax
	mov ax, bp

	; restore string pointer
	pop bx

	loop crc32_loop

	pop bp
	pop di
	pop si

crc32_exit:
	; xor out
	not ax
	not dx

	ret
;|------------------------------------------------------------------|

;|------------------------------------------------------------------|
;| number to hex string function
;|------------------------------------------------------------------|
;| IN:
;|  ax - value
;|  di - pointer to string buffer
;| OUT:
;|  di - hex string of value
;|------------------------------------------------------------------|
to_hex:
	push ax
	push bx
	push cx
	push si
	push di

	mov bx, offset hex_chars
	mov cx, 4

convert_loop:
	rol ax, 4
	push ax
	and ax, 0Fh
	mov si, ax
	mov al, byte ptr [bx + si]
	mov byte ptr [di], al
	inc di
	pop ax
	loop convert_loop

	pop di
	pop si
	pop cx
	pop bx
	pop ax

	ret
;|------------------------------------------------------------------|

CSEG ends
end start
