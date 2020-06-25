sound08:
	.db $04
	.dw sound08Channel4 - 1
	.db $ff

sound08Channel4:
	.db $f0 $00 ; store $ff in $dfxe, $f0 in $dfxf
	.db $f1 $80 ; $80 in $dfxb
	.db $f2 $00 ; $00 in $dfx5
	.db $c0     ; ($df83) & 3, is idx of data_7ff0, store into $df87+($df83)
	.db $fa $16 ; $16 into sound mode 1 sweep
	.db $82
	.db $28
	.db $fa $1e
	.db $54
	.db $28
	.db $ff

sound09:
	.db $04
	.dw sound09Channel4 - 1
	.db $06
	.dw sound09Channel6 - 1
	.db $ff

sound09Channel4:
	ldh		a, (R_P1)		; $7ed2: $f0 $00
	pop		af			; $7ed4: $f1
	add		b			; $7ed5: $80
	ld		a, ($ff00+c)		; $7ed6: $f2
	add		b			; $7ed7: $80
	ret		nz			; $7ed8: $c0
	add		d			; $7ed9: $82
	inc		d			; $7eda: $14
	ld		(de), a			; $7edb: $12
	stop					; $7edc: $10
	ld		c, $ff			; $7edd: $0e $ff

sound09Channel6:
	ldh		a, (R_SB)		; $7edf: $f0 $01
	.db $fc
	.dw soundData_772a
	ret		nz			; $7ee4: $c0
	add		d			; $7ee5: $82
	jr		nz, $1e			; $7ee6: $20 $1e
	inc		e			; $7ee8: $1c
	ld		a, (de)			; $7ee9: $1a
	rst		$38			; $7eea: $ff

sound0a:
	.db $04
	.dw sound0aChannel4 - 1
	.db $06
	.dw sound0aChannel6 - 1
	.db $ff

sound0aChannel4:
	ldh		a, (R_P1)		; $7ef2: $f0 $00
	pop		af			; $7ef4: $f1
	add		b			; $7ef5: $80
	ld		a, ($ff00+c)		; $7ef6: $f2
	add		b			; $7ef7: $80
	ret		nz			; $7ef8: $c0
	add		d			; $7ef9: $82
	inc		d			; $7efa: $14
	ld		d, $18			; $7efb: $16 $18
	ld		a, (de)			; $7efd: $1a
	rst		$38			; $7efe: $ff

sound0aChannel6:
	ldh		a, (R_SB)		; $7eff: $f0 $01
	.db $fc
	.dw soundData_772a
	ret		nz			; $7f04: $c0
	add		d			; $7f05: $82
	inc		d			; $7f06: $14
	ld		d, $18			; $7f07: $16 $18
	ld		a, (de)			; $7f09: $1a
	rst		$38			; $7f0a: $ff

sound0b:
	.db $06
	.dw sound0bChannel6 - 1
	.db $ff

sound0bChannel6:
	ldh		a, (R_SB)		; $7f0f: $f0 $01
	.db $fc
	.dw soundData_772a
	ret		nz			; $7f14: $c0
	add		c			; $7f15: $81
	jr		nz, $24			; $7f16: $20 $24
	jr		z, $2c			; $7f18: $28 $2c
	jr		nc, -$7e			; $7f1a: $30 $82
	jr		nz, $1c			; $7f1c: $20 $1c
	jr		$14			; $7f1e: $18 $14
	stop					; $7f20: $10
	rst		$38			; $7f21: $ff

sound0c:
	.db $04
	.dw sound0cChannel4 - 1
	.db $ff

sound0cChannel4:
	ldh		a, (R_P1)		; $7f26: $f0 $00
	pop		af			; $7f28: $f1
	add		b			; $7f29: $80
	ld		a, ($ff00+c)		; $7f2a: $f2
	ld		b, b			; $7f2b: $40
	ret		nz			; $7f2c: $c0
	add		d			; $7f2d: $82
	jr		z, $26			; $7f2e: $28 $26
	inc		l			; $7f30: $2c
	ldi		a, (hl)			; $7f31: $2a
	jr		nc, $2e			; $7f32: $30 $2e
	rst		$38			; $7f34: $ff

sound0e:
	.db $05
	.dw sound0eChannel5 - 1
	.db $04
	.dw sound0eChannel4 - 1
	.db $ff

sound0eChannel5:
	ld		a, ($ff00+c)		; $7f3c: $f2
	ld		b, b			; $7f3d: $40
.db $c4

_soundData_7f3f:
	.db $f0 $02
	pop		af			; $7f41: $f1
	ld		b, b			; $7f42: $40
	add		h			; $7f43: $84
	ldd		(hl), a			; $7f44: $32
	ld		l, $29			; $7f45: $2e $29
	ld		l, $32			; $7f47: $2e $32
	add		(hl)			; $7f49: $86
	dec		(hl)			; $7f4a: $35
	rst		$38			; $7f4b: $ff

sound0eChannel4:
	.db $f2 $40
	.db $f9 $01
	.db $c8
	mu_goto _soundData_7f3f

sound0d:
	.db $04
	.dw sound0dChannel4 - 1
	.db $ff

sound0dChannel4:
	.db $f0 $00 ; store $ff in $dfxe, $f0 in $dfxf
	.db $f1 $80 ; $80 in $dfxb
	.db $f2 $40 ; store $40 in $dfx5
	.db $c0     ; ($df83) & 3, is idx of data_7ff0, store into $df87+($df83)
	.db $82
	.db $39
	.db $ff     ; end sound

sound0f:
	.db $06
	.dw sound0fChannel6 - 1
	.db $ff

sound0fChannel6:
	.db $01
	.db $fc
	.dw soundData_772a
	ret		nz			; $7f6b: $c0
	add		c			; $7f6c: $81
	jr		nz, $24			; $7f6d: $20 $24
	jr		z, $2c			; $7f6f: $28 $2c
	inc		h			; $7f71: $24
	jr		z, $2c			; $7f72: $28 $2c
	jr		nc, $28			; $7f74: $30 $28
	inc		l			; $7f76: $2c
	jr		nc, $34			; $7f77: $30 $34
	.db $ff

sound10:
	.db $04
	.dw sound10Channel4 - 1
	.db $ff

sound10Channel4:
	ldh		a, (R_P1)		; $7f7e: $f0 $00
	pop		af			; $7f80: $f1
	add		b			; $7f81: $80
	ld		a, ($ff00+c)		; $7f82: $f2
	ld		b, b			; $7f83: $40
	ret		nz			; $7f84: $c0
	add		d			; $7f85: $82
	jr		nc, $54			; $7f86: $30 $54
	inc		(hl)			; $7f88: $34
	ld		a, ($ff00+c)		; $7f89: $f2
	ret		nz			; $7f8a: $c0
	jr		nc, $54			; $7f8b: $30 $54
	inc		(hl)			; $7f8d: $34
	rst		$38			; $7f8e: $ff

sound11:
	.db $04
	.dw sound11Channel4 - 1
	.db $ff

sound11Channel4:
	ldh		a, (R_P1)		; $7f93: $f0 $00
	pop		af			; $7f95: $f1
	add		b			; $7f96: $80
	ld		a, ($ff00+c)		; $7f97: $f2
	ld		b, b			; $7f98: $40
	ret		nz			; $7f99: $c0
	add		d			; $7f9a: $82
	jr		nc, $2d			; $7f9b: $30 $2d
	ldi		a, (hl)			; $7f9d: $2a
	ld		a, ($ff00+c)		; $7f9e: $f2
	ret		nz			; $7f9f: $c0
	jr		nc, $2d			; $7fa0: $30 $2d
	ldi		a, (hl)			; $7fa2: $2a
	rst		$38			; $7fa3: $ff

sound12:
	.db $04
	.dw sound12Channel4 - 1
	.db $05
	.dw sound12Channel5 - 1
	.db $ff

sound12Channel4:
	.db $f9 $01
	.db $c0
	mu_goto _soundData_7fb2

sound12Channel5:
	.db $c0

_soundData_7fb2:
	ldh		a, ($05)		; $7fb2: $f0 $05
	pop		af			; $7fb4: $f1
	add		b			; $7fb5: $80
	ld		a, ($ff00+c)		; $7fb6: $f2
	ld		b, b			; $7fb7: $40
	add		h			; $7fb8: $84
	scf					; $7fb9: $37
	inc		(hl)			; $7fba: $34
	scf					; $7fbb: $37
	add		a			; $7fbc: $87
	inc		(hl)			; $7fbd: $34
	rst		$38			; $7fbe: $ff

sound13:
	.db $04
	.dw sound13Channel4 - 1
	.db $05
	.dw sound13Channel5 - 1
	.db $ff

sound13Channel4:
	.db $85
	.db $54
	.db $f2 $b0
	.db $c0
	mu_goto _soundData_7fd1

sound13Channel5:
	.db $f2 $40 $c0

_soundData_7fd1:
	.db $f0 $00 $f1 $80 $82 $30 $54 $2c
	.db $54 $29 $54 $27 $54 $26 $ff