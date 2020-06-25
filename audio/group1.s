soundStub:
	.db $ff

sound01:
	.db $00
	.dw data_7758 - 1
	.db $01
	.dw data_785a - 1
	.db $02
	.dw sound01Channel2 - 1
	.db $03
	.dw data_7a2e - 1
	.db $ff

data_7758:
	.db $87 $54 $f0 $04 $f1 $80 $f2 $b0
	.db $f9 $01
	mu_call _soundData_7841
	.db $c0 $8c $30 $88 $54 $84 $54 $f0
	.db $02 $f2 $a0 $f3 $f4

_soundData_7772:
	.db $f4 $02
	mu_call _soundData_780e
	.db $88 $2a $86 $2d $88 $32 $86 $2a
	.db $88 $2d $86 $32 $88 $2a $86 $2d
	mu_call _soundData_7830
	.db $88 $29 $86 $2c $88 $32 $86 $29
	.db $88 $2c $86 $32 $88 $29 $86 $2c
	mu_call _soundData_781f
	mu_call _soundData_780e
	.db $88 $28 $86 $2e $88 $30 $86 $28
	.db $88 $2e $86 $30 $88 $28 $86 $2e
	.db $88 $29 $86 $2d $88 $30 $86 $29
	.db $88 $2d $86 $30 $88 $29 $86 $2d
	.db $f5
	mu_call _soundData_781f
	.db $88 $29 $86 $2d $88 $30 $86 $29
	.db $88 $2d $86 $30 $88 $29 $86 $2d
	mu_call _soundData_780e
	mu_call _soundData_7830
	mu_call _soundData_781f
	.db $88 $2b $86 $2e $88 $34 $86 $2b
	.db $88 $2e $86 $34 $88 $2b $86 $2e
	.db $88 $2d $86 $30 $88 $35 $86 $2d
	.db $88 $30 $86 $35 $88 $2d $86 $30
	.db $88 $35 $86 $34 $88 $33 $89 $32
	.db $86 $31 $88 $30 $86 $2f
	mu_goto _soundData_7772

_soundData_780e:
	.db $88 $29 $86 $2e $88 $32 $86 $29
	.db $88 $2e $86 $32 $88 $29 $86 $2e
	mu_ret

_soundData_781f:
	.db $88 $2b $86 $2e $88 $33 $86 $2b
	.db $88 $2e $86 $33 $88 $2b $86 $2e
	mu_ret

_soundData_7830:
	.db $88 $2b $86 $2e $88 $32 $86 $2b
	.db $88 $2e $86 $32 $88 $2b $86 $2e
	mu_ret

_soundData_7841:
	.db $c4 $88 $33 $c0 $86 $2e $c8 $88
	.db $29 $c0 $86 $33 $c4 $88 $32 $c0
	.db $86 $2e $c8 $88 $29 $c0 $86 $32
	mu_ret

data_785a:
	ldh		a, ($04)		; $785a: $f0 $04
	pop		af			; $785c: $f1
	add		b			; $785d: $80
	ld		a, ($ff00+c)		; $785e: $f2
	add		b			; $785f: $80
	mu_call _soundData_7841
	ret		nz			; $7863: $c0
	adc		l			; $7864: $8d
	jr		nc, -$10			; $7865: $30 $f0
	ld		(bc), a			; $7867: $02
	pop		af			; $7868: $f1
	ld		b, b			; $7869: $40
	di					; $786a: $f3
.db $f4

_soundData_786c:
	mu_call _soundData_7924
	adc		c			; $786f: $89
	jr		nc, $2c			; $7870: $30 $2c
	adc		b			; $7872: $88
	dec		hl			; $7873: $2b
	add		(hl)			; $7874: $86
	daa					; $7875: $27
	adc		b			; $7876: $88
	dec		hl			; $7877: $2b
	adc		c			; $7878: $89
	ldd		(hl), a			; $7879: $32
	add		(hl)			; $787a: $86
	jr		nc, -$78			; $787b: $30 $88
	ld		l, $86			; $787d: $2e $86
	dec		l			; $787f: $2d
	adc		b			; $7880: $88
	ld		l, $86			; $7881: $2e $86
	dec		l			; $7883: $2d
	adc		b			; $7884: $88
	ld		l, $89			; $7885: $2e $89
	add		hl, hl			; $7887: $29
	add		(hl)			; $7888: $86
	dec		hl			; $7889: $2b
	adc		c			; $788a: $89
	dec		l			; $788b: $2d
	adc		b			; $788c: $88
	dec		hl			; $788d: $2b
	add		(hl)			; $788e: $86
	jr		z, -$78			; $788f: $28 $88
	dec		hl			; $7891: $2b
	adc		c			; $7892: $89
	ldd		(hl), a			; $7893: $32
	add		(hl)			; $7894: $86
	jr		nc, -$78			; $7895: $30 $88
	ld		l, $86			; $7897: $2e $86
	dec		l			; $7899: $2d
	adc		b			; $789a: $88
	jr		nc, -$77			; $789b: $30 $89
	add		hl, hl			; $789d: $29
	add		(hl)			; $789e: $86
	add		hl, hl			; $789f: $29
	adc		b			; $78a0: $88
	add		hl, hl			; $78a1: $29
	add		(hl)			; $78a2: $86
	dec		l			; $78a3: $2d
	adc		c			; $78a4: $89
.db $30
	mu_call _soundData_7924
	adc		b			; $78a9: $88
	jr		nc, -$7a			; $78aa: $30 $86
	ldd		(hl), a			; $78ac: $32
	adc		b			; $78ad: $88
	inc		sp			; $78ae: $33
	add		(hl)			; $78af: $86
	dec		(hl)			; $78b0: $35
	adc		b			; $78b1: $88
	inc		sp			; $78b2: $33
	add		(hl)			; $78b3: $86
	ldd		(hl), a			; $78b4: $32
	adc		b			; $78b5: $88
	inc		sp			; $78b6: $33
	adc		c			; $78b7: $89
	dec		hl			; $78b8: $2b
	add		(hl)			; $78b9: $86
	ld		l, $89			; $78ba: $2e $89
	inc		sp			; $78bc: $33
	adc		b			; $78bd: $88
	ldd		(hl), a			; $78be: $32
	add		(hl)			; $78bf: $86
	ld		sp, $3288		; $78c0: $31 $88 $32
	adc		c			; $78c3: $89
	add		hl, hl			; $78c4: $29
	add		(hl)			; $78c5: $86
	ld		l, $89			; $78c6: $2e $89
	ldd		(hl), a			; $78c8: $32
	jr		nc, $2e			; $78c9: $30 $2e
	dec		l			; $78cb: $2d
	dec		hl			; $78cc: $2b
	add		hl, hl			; $78cd: $29
	adc		b			; $78ce: $88
	add		hl, hl			; $78cf: $29
	adc		c			; $78d0: $89
	add		hl, hl			; $78d1: $29
	add		(hl)			; $78d2: $86
	dec		l			; $78d3: $2d
	adc		b			; $78d4: $88
	jr		nc, -$7a			; $78d5: $30 $86
	ldd		(hl), a			; $78d7: $32
	adc		c			; $78d8: $89
	inc		sp			; $78d9: $33
	inc		sp			; $78da: $33
	adc		b			; $78db: $88
	inc		sp			; $78dc: $33
	add		(hl)			; $78dd: $86
	ldd		(hl), a			; $78de: $32
	adc		b			; $78df: $88
	inc		sp			; $78e0: $33
	adc		d			; $78e1: $8a
	dec		(hl)			; $78e2: $35
	adc		c			; $78e3: $89
	inc		sp			; $78e4: $33
	ldd		(hl), a			; $78e5: $32
	jr		nc, $32			; $78e6: $30 $32
	ldd		(hl), a			; $78e8: $32
	adc		b			; $78e9: $88
	ldd		(hl), a			; $78ea: $32
	add		(hl)			; $78eb: $86
	jr		nc, -$78			; $78ec: $30 $88
	ldd		(hl), a			; $78ee: $32
	adc		c			; $78ef: $89
	dec		hl			; $78f0: $2b
	dec		hl			; $78f1: $2b
	add		(hl)			; $78f2: $86
	dec		hl			; $78f3: $2b
	adc		b			; $78f4: $88
	dec		hl			; $78f5: $2b
	add		(hl)			; $78f6: $86
	ld		l, $89			; $78f7: $2e $89
	ldd		(hl), a			; $78f9: $32
	adc		c			; $78fa: $89
	inc		sp			; $78fb: $33
	inc		sp			; $78fc: $33
	adc		b			; $78fd: $88
	inc		sp			; $78fe: $33
	add		(hl)			; $78ff: $86
	ldd		(hl), a			; $7900: $32
	adc		b			; $7901: $88
	inc		sp			; $7902: $33
	adc		d			; $7903: $8a
	inc		(hl)			; $7904: $34
	adc		c			; $7905: $89
	inc		(hl)			; $7906: $34
	adc		b			; $7907: $88
	inc		(hl)			; $7908: $34
	add		(hl)			; $7909: $86
	jr		nc, -$78			; $790a: $30 $88
	inc		(hl)			; $790c: $34
	adc		d			; $790d: $8a
	dec		(hl)			; $790e: $35
	adc		c			; $790f: $89
	dec		(hl)			; $7910: $35
	dec		(hl)			; $7911: $35
	dec		(hl)			; $7912: $35
	adc		b			; $7913: $88
	dec		(hl)			; $7914: $35
	add		(hl)			; $7915: $86
	inc		(hl)			; $7916: $34
	adc		b			; $7917: $88
	inc		sp			; $7918: $33
	adc		c			; $7919: $89
	ldd		(hl), a			; $791a: $32
	add		(hl)			; $791b: $86
	ld		sp, $3088		; $791c: $31 $88 $30
	add		(hl)			; $791f: $86
	cpl					; $7920: $2f
	mu_goto _soundData_786c

_soundData_7924:
	adc		b			; $7924: $88
	ldd		(hl), a			; $7925: $32
	add		(hl)			; $7926: $86
	inc		sp			; $7927: $33
	adc		b			; $7928: $88
	ldd		(hl), a			; $7929: $32
	adc		c			; $792a: $89
	add		hl, hl			; $792b: $29
	add		(hl)			; $792c: $86
	ld		l, $89			; $792d: $2e $89
	ldd		(hl), a			; $792f: $32
	adc		b			; $7930: $88
	ld		d, h			; $7931: $54
	adc		c			; $7932: $89
	ldd		(hl), a			; $7933: $32
	add		(hl)			; $7934: $86
	ldd		(hl), a			; $7935: $32
	adc		b			; $7936: $88
	ldd		(hl), a			; $7937: $32
	add		(hl)			; $7938: $86
	jr		nc, -$78			; $7939: $30 $88
	ld		l, $86			; $793b: $2e $86
	dec		l			; $793d: $2d
	adc		c			; $793e: $89
	ld		l, $2e			; $793f: $2e $2e
	adc		b			; $7941: $88
	ld		l, $86			; $7942: $2e $86
	jr		nc, -$78			; $7944: $30 $88
	ld		l, $89			; $7946: $2e $89
	inc		l			; $7948: $2c
	inc		l			; $7949: $2c
	add		(hl)			; $794a: $86
	.db $2e
	mu_ret

sound01Channel2:
	.db $f0 $01
	.db $fc
	.dw soundData_772a
	.db $c0 $86 $1b
	.db $54 $54 $1b $54 $54 $1a $54 $54
	.db $1a $54 $54 $18 $54 $11 $88 $54
	.db $84 $11 $54 $86 $11 $54 $13 $89
	.db $15

_soundData_796e:
.db $f4
	ld		(bc), a			; $796f: $02
	xor		b			; $7970: $a8
	ld		d, $54			; $7971: $16 $54
	add		(hl)			; $7973: $86
	ld		d, $54			; $7974: $16 $54
	ld		de, $5416		; $7976: $11 $16 $54
	dec		d			; $7979: $15
	ld		d, h			; $797a: $54
	ld		d, h			; $797b: $54
	dec		d			; $797c: $15
	ld		d, h			; $797d: $54
	ld		d, h			; $797e: $54
	dec		d			; $797f: $15
	adc		c			; $7980: $89
	ld		a, (de)			; $7981: $1a
	add		(hl)			; $7982: $86
	dec		d			; $7983: $15
	ld		d, h			; $7984: $54
	ld		d, h			; $7985: $54
	inc		de			; $7986: $13
	ld		d, h			; $7987: $54
	ld		d, h			; $7988: $54
	inc		de			; $7989: $13
	ld		d, h			; $798a: $54
	ld		d, h			; $798b: $54
	inc		de			; $798c: $13
	ld		d, h			; $798d: $54
	ld		(de), a			; $798e: $12
	inc		de			; $798f: $13
	ld		d, h			; $7990: $54
	inc		d			; $7991: $14
	ld		d, h			; $7992: $54
	ld		d, h			; $7993: $54
	inc		d			; $7994: $14
	ld		d, h			; $7995: $54
	ld		d, h			; $7996: $54
	adc		c			; $7997: $89
	ld		d, $86			; $7998: $16 $86
	jr		-$77			; $799a: $18 $89
	ld		a, (de)			; $799c: $1a
	and		(hl)			; $799d: $a6
	dec		de			; $799e: $1b
	ld		d, h			; $799f: $54
	dec		de			; $79a0: $1b
	ld		d, h			; $79a1: $54
	add		(hl)			; $79a2: $86
	dec		de			; $79a3: $1b
	ld		d, h			; $79a4: $54
	dec		e			; $79a5: $1d
	dec		de			; $79a6: $1b
	ld		d, h			; $79a7: $54
	and		(hl)			; $79a8: $a6
	ld		a, (de)			; $79a9: $1a
	ld		d, h			; $79aa: $54
	ld		a, (de)			; $79ab: $1a
	ld		d, h			; $79ac: $54
	xor		b			; $79ad: $a8
	ld		d, $86			; $79ae: $16 $86
	jr		-$58			; $79b0: $18 $a8
	ld		a, (de)			; $79b2: $1a
	and		(hl)			; $79b3: $a6
	jr		$54			; $79b4: $18 $54
	jr		$54			; $79b6: $18 $54
	ld		d, $54			; $79b8: $16 $54
	inc		de			; $79ba: $13
	ld		d, h			; $79bb: $54
	ld		de, $8654		; $79bc: $11 $54 $86
	ld		de, $a854		; $79bf: $11 $54 $a8
	ld		de, $1386		; $79c2: $11 $86 $13
	xor		b			; $79c5: $a8
	dec		d			; $79c6: $15
	push		af			; $79c7: $f5
	add		(hl)			; $79c8: $86
	dec		de			; $79c9: $1b
	ld		d, h			; $79ca: $54
	ld		d, h			; $79cb: $54
	inc		de			; $79cc: $13
	ld		d, h			; $79cd: $54
	adc		c			; $79ce: $89
	dec		de			; $79cf: $1b
	add		(hl)			; $79d0: $86
	inc		de			; $79d1: $13
	ld		d, $54			; $79d2: $16 $54
	dec		de			; $79d4: $1b
	dec		e			; $79d5: $1d
	ld		d, h			; $79d6: $54
	ld		d, h			; $79d7: $54
	dec		d			; $79d8: $15
	ld		d, h			; $79d9: $54
	adc		c			; $79da: $89
	dec		e			; $79db: $1d
	add		(hl)			; $79dc: $86
	dec		de			; $79dd: $1b
	ld		a, (de)			; $79de: $1a
	ld		d, h			; $79df: $54
	jr		$16			; $79e0: $18 $16
	ld		d, h			; $79e2: $54
	ld		d, h			; $79e3: $54
	ld		de, $8954		; $79e4: $11 $54 $89
	ld		d, $86			; $79e7: $16 $86
	ld		de, $1688		; $79e9: $11 $88 $16
	add		(hl)			; $79ec: $86
	dec		d			; $79ed: $15
	inc		de			; $79ee: $13
	ld		d, h			; $79ef: $54
	ld		d, h			; $79f0: $54
	ld		(de), a			; $79f1: $12
	ld		d, h			; $79f2: $54
	adc		c			; $79f3: $89
	inc		de			; $79f4: $13
	add		(hl)			; $79f5: $86
	dec		d			; $79f6: $15
	ld		d, $54			; $79f7: $16 $54
	ld		a, (de)			; $79f9: $1a
	add		(hl)			; $79fa: $86
	dec		de			; $79fb: $1b
	ld		d, h			; $79fc: $54
	ld		d, h			; $79fd: $54
	inc		de			; $79fe: $13
	ld		d, h			; $79ff: $54
	adc		c			; $7a00: $89
	dec		de			; $7a01: $1b
	add		(hl)			; $7a02: $86
	inc		de			; $7a03: $13
	ld		d, $54			; $7a04: $16 $54
	dec		de			; $7a06: $1b
	inc		e			; $7a07: $1c
	ld		d, h			; $7a08: $54
	ld		d, h			; $7a09: $54
	dec		d			; $7a0a: $15
	ld		d, h			; $7a0b: $54
	adc		c			; $7a0c: $89
	inc		e			; $7a0d: $1c
	add		(hl)			; $7a0e: $86
	ld		d, $18			; $7a0f: $16 $18
	ld		d, h			; $7a11: $54
	inc		e			; $7a12: $1c
	ld		de, $1154		; $7a13: $11 $54 $11
	dec		d			; $7a16: $15
	ld		d, h			; $7a17: $54
	dec		d			; $7a18: $15
	jr		$54			; $7a19: $18 $54
	jr		$1b			; $7a1b: $18 $1b
	ld		d, h			; $7a1d: $54
	dec		de			; $7a1e: $1b
	dec		e			; $7a1f: $1d
	ld		d, h			; $7a20: $54
	inc		e			; $7a21: $1c
	dec		de			; $7a22: $1b
	ld		d, h			; $7a23: $54
	adc		c			; $7a24: $89
	ld		a, (de)			; $7a25: $1a
	add		(hl)			; $7a26: $86
	add		hl, de			; $7a27: $19
	jr		$54			; $7a28: $18 $54
	rla					; $7a2a: $17
	mu_goto _soundData_796e

data_7a2e:
	adc		l			; $7a2e: $8d
	ld		d, h			; $7a2f: $54
	ld		d, h			; $7a30: $54
	ret		nz			; $7a31: $c0

_soundData_7a32:
.db $f4
	ld		l, $f0			; $7a33: $2e $f0
	nop					; $7a35: $00
	ld		a, ($ff00+c)		; $7a36: $f2
	ret		nz			; $7a37: $c0
	adc		b			; $7a38: $88
	stop					; $7a39: $10
	add		(hl)			; $7a3a: $86
	ld		d, h			; $7a3b: $54
	ldh		a, ($03)		; $7a3c: $f0 $03
	ld		a, ($ff00+c)		; $7a3e: $f2
	add		b			; $7a3f: $80
	adc		b			; $7a40: $88
	jr		nz, -$7a			; $7a41: $20 $86
	jr		nz, -$0b			; $7a43: $20 $f5
	adc		c			; $7a45: $89
	jr		nz, $20			; $7a46: $20 $20
	jr		nz, $20			; $7a48: $20 $20
	mu_goto _soundData_7a32