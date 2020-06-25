sound02:
	.db $00
	.dw data_7a5a - 1
	.db $01
	.dw data_7ae7 - 1
	.db $02
	.dw data_7b90 - 1
	.db $03
	.dw soundStub - 1
	.db $ff

data_7a5a:
	ldh		a, ($05)		; $7a5a: $f0 $05
	pop		af			; $7a5c: $f1
	add		b			; $7a5d: $80
	ld		a, ($ff00+c)		; $7a5e: $f2
	add		b			; $7a5f: $80
	ret		nz			; $7a60: $c0
	and		h			; $7a61: $a4
	ld		a, (de)			; $7a62: $1a
	and		(hl)			; $7a63: $a6
	ld		a, (de)			; $7a64: $1a
	and		h			; $7a65: $a4
	ld		a, (de)			; $7a66: $1a
	and		(hl)			; $7a67: $a6
	ld		a, (de)			; $7a68: $1a
	ld		d, h			; $7a69: $54
	and		h			; $7a6a: $a4
	dec		e			; $7a6b: $1d
	and		(hl)			; $7a6c: $a6
	dec		e			; $7a6d: $1d
	and		h			; $7a6e: $a4
	dec		e			; $7a6f: $1d
	and		(hl)			; $7a70: $a6
	dec		e			; $7a71: $1d
	ld		d, h			; $7a72: $54
	and		(hl)			; $7a73: $a6
	ld		a, (de)			; $7a74: $1a
	ld		a, (de)			; $7a75: $1a
	dec		e			; $7a76: $1d
	ld		e, $1f			; $7a77: $1e $1f
	ld		d, h			; $7a79: $54
	ld		a, ($ff00+c)		; $7a7a: $f2
	ld		b, b			; $7a7b: $40
	ret		z			; $7a7c: $c8
	add		c			; $7a7d: $81
.db $f4
	inc		c			; $7a7f: $0c
	inc		a			; $7a80: $3c
	dec		sp			; $7a81: $3b
	push		af			; $7a82: $f5
	ld		a, ($ff00+c)		; $7a83: $f2
	add		b			; $7a84: $80
	ret		nz			; $7a85: $c0

_soundData_7a86:
	.db $f9 $01
	mu_call _soundData_7b61
	.db $29 $f9 $00
	.db $a4 $1a $a6 $1a $a4 $1a $a6 $1f
	.db $1d $a8 $1a $54 $f9 $01
	mu_call _soundData_7b61
	.db $2f $f9 $00 $21 $a4 $1c $1c
	.db $a6 $1d $1c $54 $1f $1f $54 $f2
	.db $a0 $f9 $01 $a4
	mu_call _soundData_7ad1
	.db $f4
	.db $04 $28 $24 $1f $24 $f5
	mu_call _soundData_7ad1
	.db $f2 $80 $a4 $1a $a6 $1a $a4
	.db $1a $a6 $1f $23 $26 $54 $54 $54
	mu_goto _soundData_7a86

_soundData_7ad1:
.db $f4
	inc		b			; $7ad2: $04
	add		hl, hl			; $7ad3: $29
	inc		h			; $7ad4: $24
	ld		hl, $f524		; $7ad5: $21 $24 $f5
.db $f4
	inc		b			; $7ad9: $04
	jr		z, $24			; $7ada: $28 $24
	rra					; $7adc: $1f
	inc		h			; $7add: $24
	push		af			; $7ade: $f5
.db $f4
	inc		b			; $7ae0: $04
	ld		h, $23			; $7ae1: $26 $23
	rra					; $7ae3: $1f
	inc		hl			; $7ae4: $23
	push		af			; $7ae5: $f5
	mu_ret

data_7ae7:
	ldh		a, ($05)		; $7ae7: $f0 $05
	pop		af			; $7ae9: $f1
	add		b			; $7aea: $80
	ld		a, ($ff00+c)		; $7aeb: $f2
	add		b			; $7aec: $80
	ret		nz			; $7aed: $c0
	and		h			; $7aee: $a4
	rra					; $7aef: $1f
	and		(hl)			; $7af0: $a6
	rra					; $7af1: $1f
	and		h			; $7af2: $a4
	rra					; $7af3: $1f
	and		(hl)			; $7af4: $a6
	rra					; $7af5: $1f
	ld		d, h			; $7af6: $54
	and		h			; $7af7: $a4
	ld		hl, $21a6		; $7af8: $21 $a6 $21
	and		h			; $7afb: $a4
	ld		hl, $21a6		; $7afc: $21 $a6 $21
	ld		d, h			; $7aff: $54
	and		(hl)			; $7b00: $a6
	rra					; $7b01: $1f
	rra					; $7b02: $1f
	ld		hl, $2322		; $7b03: $21 $22 $23
	ld		d, h			; $7b06: $54
	ld		a, ($ff00+c)		; $7b07: $f2
	ld		b, b			; $7b08: $40
	call		nz, $f481		; $7b09: $c4 $81 $f4
	inc		c			; $7b0c: $0c
	dec		sp			; $7b0d: $3b
	inc		a			; $7b0e: $3c
	push		af			; $7b0f: $f5
	ld		a, ($ff00+c)		; $7b10: $f2
	add		b			; $7b11: $80
	ret		nz			; $7b12: $c0

_soundData_7b13:
	mu_call _soundData_7b61
	add		hl, hl			; $7b16: $29
	and		h			; $7b17: $a4
	rra					; $7b18: $1f
	and		(hl)			; $7b19: $a6
	rra					; $7b1a: $1f
	and		h			; $7b1b: $a4
	rra					; $7b1c: $1f
	and		(hl)			; $7b1d: $a6
	inc		hl			; $7b1e: $23
	ld		hl, $1fa8		; $7b1f: $21 $a8 $1f
	ld		d, h			; $7b22: $54
	mu_call _soundData_7b61
	cpl					; $7b26: $2f
	inc		h			; $7b27: $24
	and		h			; $7b28: $a4
	rra					; $7b29: $1f
	rra					; $7b2a: $1f
	and		(hl)			; $7b2b: $a6
	ld		hl, $541f		; $7b2c: $21 $1f $54
	inc		hl			; $7b2f: $23
	inc		h			; $7b30: $24
	ld		d, h			; $7b31: $54
	ldh		a, ($04)		; $7b32: $f0 $04
	mu_call _soundData_7b83
	and		(hl)			; $7b37: $a6
	ldd		(hl), a			; $7b38: $32
	ld		sp, $2f30		; $7b39: $31 $30 $2f
	xor		b			; $7b3c: $a8
	dec		hl			; $7b3d: $2b
	and		(hl)			; $7b3e: $a6
	cpl					; $7b3f: $2f
	dec		(hl)			; $7b40: $35
	xor		h			; $7b41: $ac
	inc		(hl)			; $7b42: $34
	mu_call _soundData_7b83
	and		(hl)			; $7b46: $a6
	ldd		(hl), a			; $7b47: $32
	ldd		(hl), a			; $7b48: $32
	ldd		(hl), a			; $7b49: $32
	ldd		(hl), a			; $7b4a: $32
	ldd		(hl), a			; $7b4b: $32
	jr		nc, $2f			; $7b4c: $30 $2f
	dec		l			; $7b4e: $2d
	and		h			; $7b4f: $a4
	rra					; $7b50: $1f
	and		(hl)			; $7b51: $a6
	rra					; $7b52: $1f
	and		h			; $7b53: $a4
	rra					; $7b54: $1f
	and		(hl)			; $7b55: $a6
	inc		hl			; $7b56: $23
	ld		h, $2b			; $7b57: $26 $2b
	ld		d, h			; $7b59: $54
	ld		d, h			; $7b5a: $54
	ld		d, h			; $7b5b: $54
	ldh		a, ($05)		; $7b5c: $f0 $05
	mu_goto _soundData_7b13

_soundData_7b61:
	add		e			; $7b61: $83
.db $f4
	inc		b			; $7b63: $04
	dec		hl			; $7b64: $2b
	jr		z, -$0b			; $7b65: $28 $f5
	and		(hl)			; $7b67: $a6
	inc		(hl)			; $7b68: $34
	ldd		(hl), a			; $7b69: $32
	jr		nc, $2f			; $7b6a: $30 $2f
	dec		l			; $7b6c: $2d
	dec		hl			; $7b6d: $2b
	add		hl, hl			; $7b6e: $29
	jr		z, $26			; $7b6f: $28 $26
	inc		h			; $7b71: $24
	inc		hl			; $7b72: $23
	ld		hl, $541f		; $7b73: $21 $1f $54
	add		e			; $7b76: $83
.db $f4
	inc		b			; $7b78: $04
	add		hl, hl			; $7b79: $29
	ld		h, $f5			; $7b7a: $26 $f5
	and		(hl)			; $7b7c: $a6
	ldd		(hl), a			; $7b7d: $32
	jr		nc, $2f			; $7b7e: $30 $2f
	dec		l			; $7b80: $2d
	dec		hl			; $7b81: $2b
	mu_ret

_soundData_7b83:
	and		(hl)			; $7b83: $a6
	dec		l			; $7b84: $2d
	dec		l			; $7b85: $2d
	jr		nc, $30			; $7b86: $30 $30
	xor		b			; $7b88: $a8
	dec		(hl)			; $7b89: $35
	and		(hl)			; $7b8a: $a6
	dec		l			; $7b8b: $2d
	dec		(hl)			; $7b8c: $35
	xor		h			; $7b8d: $ac
	inc		(hl)			; $7b8e: $34
	mu_ret

data_7b90:
	ldh		a, (R_SB)		; $7b90: $f0 $01
	.db $fc
	.dw soundData_772a
	ret		nz			; $7b95: $c0
	add		e			; $7b96: $83
	inc		de			; $7b97: $13
	ld		d, h			; $7b98: $54
	and		h			; $7b99: $a4
	inc		de			; $7b9a: $13
	ld		d, h			; $7b9b: $54
	add		e			; $7b9c: $83
	inc		de			; $7b9d: $13
	ld		d, h			; $7b9e: $54
	and		h			; $7b9f: $a4
	inc		de			; $7ba0: $13
	and		a			; $7ba1: $a7
	ld		d, h			; $7ba2: $54
	add		e			; $7ba3: $83
	dec		d			; $7ba4: $15
	ld		d, h			; $7ba5: $54
	and		h			; $7ba6: $a4
	dec		d			; $7ba7: $15
	ld		d, h			; $7ba8: $54
	add		e			; $7ba9: $83
	dec		d			; $7baa: $15
	ld		d, h			; $7bab: $54
	and		h			; $7bac: $a4
	dec		d			; $7bad: $15
	and		a			; $7bae: $a7
	ld		d, h			; $7baf: $54
	and		h			; $7bb0: $a4
	ld		a, (de)			; $7bb1: $1a
	ld		d, h			; $7bb2: $54
	jr		$54			; $7bb3: $18 $54
	rla					; $7bb5: $17
	ld		d, h			; $7bb6: $54
	dec		d			; $7bb7: $15
	ld		d, h			; $7bb8: $54
	inc		de			; $7bb9: $13
	and		a			; $7bba: $a7
	ld		d, h			; $7bbb: $54
	xor		b			; $7bbc: $a8
	ld		d, h			; $7bbd: $54

_soundData_7bbe:
	mu_call _soundData_7c0f
	rla					; $7bc1: $17
	ld		d, h			; $7bc2: $54
	inc		de			; $7bc3: $13
	ld		d, h			; $7bc4: $54
	and		h			; $7bc5: $a4
	jr		$54			; $7bc6: $18 $54
	inc		de			; $7bc8: $13
	ld		d, h			; $7bc9: $54
	dec		d			; $7bca: $15
	ld		d, h			; $7bcb: $54
	rla					; $7bcc: $17
	ld		d, h			; $7bcd: $54
	mu_call _soundData_7c0f
	and		h			; $7bd1: $a4
	jr		$54			; $7bd2: $18 $54
	add		e			; $7bd4: $83
	inc		de			; $7bd5: $13
	ld		d, h			; $7bd6: $54
	inc		de			; $7bd7: $13
	ld		d, h			; $7bd8: $54
	and		(hl)			; $7bd9: $a6
	dec		d			; $7bda: $15
	and		h			; $7bdb: $a4
	inc		de			; $7bdc: $13
	ld		d, h			; $7bdd: $54
	and		h			; $7bde: $a4
	ld		d, h			; $7bdf: $54
	ld		d, h			; $7be0: $54
	rla					; $7be1: $17
	ld		d, h			; $7be2: $54
	jr		$54			; $7be3: $18 $54
	ld		d, h			; $7be5: $54
	ld		d, h			; $7be6: $54
	and		(hl)			; $7be7: $a6
	mu_call _soundData_7c29
	jr		$54			; $7beb: $18 $54
	inc		de			; $7bed: $13
	ld		d, h			; $7bee: $54
	jr		$54			; $7bef: $18 $54
	inc		de			; $7bf1: $13
	ld		d, h			; $7bf2: $54
	mu_call _soundData_7c29
	add		e			; $7bf6: $83
	inc		de			; $7bf7: $13
	ld		d, h			; $7bf8: $54
	and		h			; $7bf9: $a4
	inc		de			; $7bfa: $13
	ld		d, h			; $7bfb: $54
	add		e			; $7bfc: $83
	inc		de			; $7bfd: $13
	ld		d, h			; $7bfe: $54
	and		h			; $7bff: $a4
	rla					; $7c00: $17
	ld		d, h			; $7c01: $54
	ld		a, (de)			; $7c02: $1a
	ld		d, h			; $7c03: $54
	rra					; $7c04: $1f
	ld		d, h			; $7c05: $54
	inc		de			; $7c06: $13
	ld		d, h			; $7c07: $54
	dec		d			; $7c08: $15
	ld		d, h			; $7c09: $54
	rla					; $7c0a: $17
	ld		d, h			; $7c0b: $54
	mu_goto _soundData_7bbe

_soundData_7c0f:
	and		(hl)			; $7c0f: $a6
	jr		$54			; $7c10: $18 $54
	inc		de			; $7c12: $13
	ld		d, h			; $7c13: $54
	jr		$54			; $7c14: $18 $54
	add		hl, de			; $7c16: $19
	ld		d, h			; $7c17: $54
	ld		a, (de)			; $7c18: $1a
	ld		d, h			; $7c19: $54
	inc		de			; $7c1a: $13
	ld		d, h			; $7c1b: $54
	ld		a, (de)			; $7c1c: $1a
	ld		d, h			; $7c1d: $54
	inc		de			; $7c1e: $13
	ld		d, h			; $7c1f: $54
	ld		a, (de)			; $7c20: $1a
	ld		d, h			; $7c21: $54
	dec		d			; $7c22: $15
	ld		d, h			; $7c23: $54
	ld		a, (de)			; $7c24: $1a
	ld		d, h			; $7c25: $54
	dec		d			; $7c26: $15
	ld		d, h			; $7c27: $54
	mu_ret

_soundData_7c29:
	dec		d			; $7c29: $15
	ld		d, h			; $7c2a: $54
	ld		de, $1554		; $7c2b: $11 $54 $15
	ld		d, h			; $7c2e: $54
	rla					; $7c2f: $17
	ld		d, h			; $7c30: $54
	jr		$54			; $7c31: $18 $54
	inc		de			; $7c33: $13
	ld		d, h			; $7c34: $54
	jr		$54			; $7c35: $18 $54
	inc		de			; $7c37: $13
	ld		d, h			; $7c38: $54
	rla					; $7c39: $17
	ld		d, h			; $7c3a: $54
	inc		de			; $7c3b: $13
	ld		d, h			; $7c3c: $54
	rla					; $7c3d: $17
	ld		d, h			; $7c3e: $54
	inc		de			; $7c3f: $13
	ld		d, h			; $7c40: $54
	mu_ret