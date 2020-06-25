; sound channel pointer
sound03:
	.db $00
	.dw data_7c4f - 1
	.db $01
	.dw data_7c90 - 1
	.db $02
	.dw data_7cb6 - 1
	.db $03
	.dw soundStub - 1
	.db $ff

data_7c4f:
	.db $99 $54 $f0 $02 $f1 $80 $f2 $b0
	.db $f9 $01 $98

_soundData_7c5a:
	.db $c0 $24 $c8 $28 $c0 $2b $c4 $29
	.db $c0 $28 $c8 $26 $c0 $28 $c4 $26
	.db $c0 $24 $c8 $29 $c0 $28 $c4 $26
	.db $c0 $24 $c8 $28 $c0 $2b $c4 $96
	.db $2d $2b $c0 $98 $29 $c8 $28 $c0
	.db $26 $c4 $24 $c0 $23 $c8 $1f $c0
	.db $23 $c4 $26
	mu_goto _soundData_7c5a

data_7c90:
	.db $f2 $80 $c0 $f0 $02 $f1 $80 $98

_soundData_7c98:
	.db $24 $28 $2b $29 $28 $26 $28 $26
	.db $24 $29 $28 $26 $24 $28 $2b $96
	.db $2d $2b $98 $29 $28 $26 $24 $23
	.db $1f $23 $26
	mu_goto _soundData_7c98

data_7cb6:
	.db $f0 $01
	.db $fc
	.dw soundData_772a
	.db $c0 $9b

_soundData_7cbd:
	.db $18 $1a $1c $1d $18 $19 $1a $13
	mu_goto _soundData_7cbd

sound04:
	.db $00
	.dw data_7cd5 - 1
	.db $01
	.dw data_7cdb - 1
	.db $02
	.dw data_7cfb - 1
	.db $03
	.dw soundStub - 1
	.db $ff

data_7cd5:
	.db $f9 $01
	.db $c0
	mu_goto _soundData_7cdc

data_7cdb:
	.db $c0

_soundData_7cdc:
	adc		b			; $7cdc: $88
	ld		d, h			; $7cdd: $54
	ldh		a, ($02)		; $7cde: $f0 $02
	pop		af			; $7ce0: $f1
	add		b			; $7ce1: $80
	ld		a, ($ff00+c)		; $7ce2: $f2
	add		b			; $7ce3: $80
	di					; $7ce4: $f3
	cp		$86			; $7ce5: $fe $86
	dec		hl			; $7ce7: $2b
	adc		b			; $7ce8: $88
	ldi		a, (hl)			; $7ce9: $2a
	add		(hl)			; $7cea: $86
	dec		hl			; $7ceb: $2b
	adc		b			; $7cec: $88
	dec		l			; $7ced: $2d
	add		(hl)			; $7cee: $86
	inc		l			; $7cef: $2c
	adc		b			; $7cf0: $88
	dec		l			; $7cf1: $2d
	add		(hl)			; $7cf2: $86
	cpl					; $7cf3: $2f
	adc		c			; $7cf4: $89
	jr		nc, -$78			; $7cf5: $30 $88
	cpl					; $7cf7: $2f
	adc		c			; $7cf8: $89
	jr		nc, -$01			; $7cf9: $30 $ff

data_7cfb:
	ldh		a, (R_SB)		; $7cfb: $f0 $01
	.db $f3 $fe
	.db $fc
	.dw soundData_772a
	ret		nz			; $7d02: $c0
	add		(hl)			; $7d03: $86
	rra					; $7d04: $1f
	ld		d, h			; $7d05: $54
	add		h			; $7d06: $84
	rra					; $7d07: $1f
	ld		d, h			; $7d08: $54
	add		(hl)			; $7d09: $86
	rra					; $7d0a: $1f
	ld		d, h			; $7d0b: $54
	add		h			; $7d0c: $84
	rra					; $7d0d: $1f
	ld		d, h			; $7d0e: $54
	add		(hl)			; $7d0f: $86
	ld		e, $54			; $7d10: $1e $54
	add		h			; $7d12: $84
	ld		e, $54			; $7d13: $1e $54
	add		(hl)			; $7d15: $86
	dec		e			; $7d16: $1d
	ld		d, h			; $7d17: $54
	add		h			; $7d18: $84
	dec		e			; $7d19: $1d
	ld		d, h			; $7d1a: $54
	add		(hl)			; $7d1b: $86
	jr		-$78			; $7d1c: $18 $88
	ld		d, h			; $7d1e: $54
	add		(hl)			; $7d1f: $86
	inc		de			; $7d20: $13
	ld		d, h			; $7d21: $54
	jr		-$01			; $7d22: $18 $ff

sound05:
	.db $00
	.dw data_7d31 - 1
	.db $01
	.dw data_7dea - 1
	.db $02
	.dw data_7e3e - 1
	.db $03
	.dw soundStub - 1
	.db $ff

data_7d31:
	ld		a, ($ff00+c)		; $7d31: $f2
	add		b			; $7d32: $80
	or		$b2			; $7d33: $f6 $b2
	ld		a, l			; $7d35: $7d
	ret		nz			; $7d36: $c0
	xor		d			; $7d37: $aa
	cpl					; $7d38: $2f
	or		$5a			; $7d39: $f6 $5a
	ld		a, l			; $7d3b: $7d
	ret		nz			; $7d3c: $c0
	and		(hl)			; $7d3d: $a6
	jr		nc, $2f			; $7d3e: $30 $2f
	ld		l, $2d			; $7d40: $2e $2d
	inc		l			; $7d42: $2c
	dec		hl			; $7d43: $2b
	ldi		a, (hl)			; $7d44: $2a
	add		hl, hl			; $7d45: $29
	or		$5a			; $7d46: $f6 $5a
	ld		a, l			; $7d48: $7d
.db $f4
	ld		(bc), a			; $7d4a: $02
	ret		nz			; $7d4b: $c0
	jr		nc, -$3c			; $7d4c: $30 $c4
	dec		hl			; $7d4e: $2b
	ret		nz			; $7d4f: $c0
	jr		z, -$38			; $7d50: $28 $c8
	dec		hl			; $7d52: $2b
	push		af			; $7d53: $f5
	ldh		a, ($02)		; $7d54: $f0 $02
	ret		nz			; $7d56: $c0
	adc		h			; $7d57: $8c
	jr		nc, -$01			; $7d58: $30 $ff


; Unused sound data?
	and		h			; $7d5a: $a4
	ldh		a, ($05)		; $7d5b: $f0 $05
.db $f4
	ld		(bc), a			; $7d5e: $02
	ret		nz			; $7d5f: $c0
	dec		hl			; $7d60: $2b
	ret		z			; $7d61: $c8
	jr		z, -$40			; $7d62: $28 $c0
	inc		h			; $7d64: $24
	call		nz, $f528		; $7d65: $c4 $28 $f5
	ret		nz			; $7d68: $c0
	ldh		a, (R_P1)		; $7d69: $f0 $00
	and		a			; $7d6b: $a7
	dec		hl			; $7d6c: $2b
	add		c			; $7d6d: $81
	dec		hl			; $7d6e: $2b
	inc		l			; $7d6f: $2c
	dec		l			; $7d70: $2d
	ld		l, $2f			; $7d71: $2e $2f
	jr		nc, -$10			; $7d73: $30 $f0
	inc		b			; $7d75: $04
	xor		b			; $7d76: $a8
	jr		nc, -$5c			; $7d77: $30 $a4
	ldh		a, ($05)		; $7d79: $f0 $05
.db $f4
	ld		(bc), a			; $7d7c: $02
	ret		nz			; $7d7d: $c0
	dec		l			; $7d7e: $2d
	ret		z			; $7d7f: $c8
	add		hl, hl			; $7d80: $29
	ret		nz			; $7d81: $c0
	inc		h			; $7d82: $24
	call		nz, $f529		; $7d83: $c4 $29 $f5
	ret		nz			; $7d86: $c0
	ldh		a, (R_P1)		; $7d87: $f0 $00
	or		a			; $7d89: $b7
	dec		l			; $7d8a: $2d
	add		c			; $7d8b: $81
	ld		l, $2f			; $7d8c: $2e $2f
	jr		nc, -$10			; $7d8e: $30 $f0
	inc		b			; $7d90: $04
	xor		b			; $7d91: $a8
	jr		nc, -$5c			; $7d92: $30 $a4
	ldh		a, ($05)		; $7d94: $f0 $05
.db $f4
	ld		(bc), a			; $7d97: $02
	ret		nz			; $7d98: $c0
	cpl					; $7d99: $2f
	ret		z			; $7d9a: $c8
	dec		hl			; $7d9b: $2b
	ret		nz			; $7d9c: $c0
	ld		h, $c4			; $7d9d: $26 $c4
	dec		hl			; $7d9f: $2b
	push		af			; $7da0: $f5
	ret		nz			; $7da1: $c0
	cpl					; $7da2: $2f
	ret		z			; $7da3: $c8
	add		hl, hl			; $7da4: $29
	ret		nz			; $7da5: $c0
	dec		hl			; $7da6: $2b
	call		nz, $c029		; $7da7: $c4 $29 $c0
	dec		l			; $7daa: $2d
	ret		z			; $7dab: $c8
	add		hl, hl			; $7dac: $29
	ret		nz			; $7dad: $c0
	cpl					; $7dae: $2f
	call		nz, $f72b		; $7daf: $c4 $2b $f7
	ldh		a, ($05)		; $7db2: $f0 $05
	pop		af			; $7db4: $f1
	add		b			; $7db5: $80
	and		h			; $7db6: $a4
	ret		nz			; $7db7: $c0
	dec		hl			; $7db8: $2b
	call		nz, $c028		; $7db9: $c4 $28 $c0
	dec		hl			; $7dbc: $2b
	ret		z			; $7dbd: $c8
	jr		z, -$40			; $7dbe: $28 $c0
	inc		l			; $7dc0: $2c
	call		nz, $c028		; $7dc1: $c4 $28 $c0
	inc		l			; $7dc4: $2c
	ret		z			; $7dc5: $c8
	jr		z, -$40			; $7dc6: $28 $c0
	dec		l			; $7dc8: $2d
	call		nz, $c029		; $7dc9: $c4 $29 $c0
	dec		l			; $7dcc: $2d
	ret		z			; $7dcd: $c8
	add		hl, hl			; $7dce: $29
	ret		nz			; $7dcf: $c0
	ld		l, $c4			; $7dd0: $2e $c4
	add		hl, hl			; $7dd2: $29
	ret		nz			; $7dd3: $c0
	ld		l, $c8			; $7dd4: $2e $c8
	add		hl, hl			; $7dd6: $29
	ret		nz			; $7dd7: $c0
	cpl					; $7dd8: $2f
	call		nz, $c02b		; $7dd9: $c4 $2b $c0
	add		hl, hl			; $7ddc: $29
	ret		z			; $7ddd: $c8
	ld		h, $c0			; $7dde: $26 $c0
	inc		hl			; $7de0: $23
	call		nz, $c026		; $7de1: $c4 $26 $c0
	add		hl, hl			; $7de4: $29
	call		nz, $f02b		; $7de5: $c4 $2b $f0
	inc		b			; $7de8: $04
	rst_playSound

data_7dea:
	and		l			; $7dea: $a5
	ld		d, h			; $7deb: $54
	ld		a, ($ff00+c)		; $7dec: $f2
	or		b			; $7ded: $b0
	ld		sp, hl			; $7dee: $f9
	ld		bc, $b2f6		; $7def: $01 $f6 $b2
	ld		a, l			; $7df2: $7d
	ret		nz			; $7df3: $c0
	xor		c			; $7df4: $a9
	cpl					; $7df5: $2f
	add		e			; $7df6: $83
	ld		d, h			; $7df7: $54
	ldh		a, ($02)		; $7df8: $f0 $02
	ld		a, ($ff00+c)		; $7dfa: $f2
	and		b			; $7dfb: $a0
	or		$1b			; $7dfc: $f6 $1b
	ld		a, (hl)			; $7dfe: $7e
	ret		nz			; $7dff: $c0
	and		(hl)			; $7e00: $a6
	jr		nc, $2f			; $7e01: $30 $2f
	ld		l, $2d			; $7e03: $2e $2d
	inc		l			; $7e05: $2c
	dec		hl			; $7e06: $2b
	ldi		a, (hl)			; $7e07: $2a
	add		hl, hl			; $7e08: $29
	or		$1b			; $7e09: $f6 $1b
	ld		a, (hl)			; $7e0b: $7e
.db $f4
	ld		(bc), a			; $7e0d: $02
	ret		nz			; $7e0e: $c0
	jr		nc, -$3c			; $7e0f: $30 $c4
	dec		hl			; $7e11: $2b
	ret		nz			; $7e12: $c0
	jr		z, -$38			; $7e13: $28 $c8
	dec		hl			; $7e15: $2b
	push		af			; $7e16: $f5
	ret		nz			; $7e17: $c0
	adc		h			; $7e18: $8c
	jr		nc, -$01			; $7e19: $30 $ff
