func_2e4e:
	and		$0f			; $2e4e: $e6 $0f
	ld		hl, data_2e74		; $2e50: $21 $74 $2e
	sla		a			; $2e53: $cb $27
	call		addAToHl			; $2e55: $cd $6b $24
	ldi		a, (hl)			; $2e58: $2a
	ld		e, a			; $2e59: $5f
	ld		a, (hl)			; $2e5a: $7e
	ld		h, a			; $2e5b: $67
	ld		l, e			; $2e5c: $6b
	ld		a, (wIsDiagonalView)		; $2e5d: $fa $be $c2
	and		a			; $2e60: $a7
	jr		nz, +			; $2e61: $20 $05

	; every block of $30, 1st half is for top-down view, 2nd is for diagonal view
	ld		a, $18			; $2e63: $3e $18
	call		addAToHl			; $2e65: $cd $6b $24
+
	ld		bc, $c27c		; $2e68: $01 $7c $c2
	ld		d, $18			; $2e6b: $16 $18
-
	ldi		a, (hl)			; $2e6d: $2a
	ld		(bc), a			; $2e6e: $02
	inc		bc			; $2e6f: $03
	dec		d			; $2e70: $15
	jr		nz, -			; $2e71: $20 $fa
	ret					; $2e73: $c9

data_2e74:
	.dw data_2e92
	.dw data_2ec2
	.dw data_2ef2
	.dw data_2f22
	.dw data_2f52
	.dw data_2f82
	.dw data_2fb2
	.dw data_2fe2
	.dw data_3012
	.dw data_3042
	.dw data_3072
	.dw data_30a2
	.dw data_30d2
	.dw data_3102
	.dw data_3132

data_2e92:
	.db $ff $00 $94 $20
	.db $99 $20 $ff $00
	.db $a6 $20 $a0 $00
	.db $ff $00 $a3 $80
	.db $a1 $80 $ff $00
	.db $ff $00 $ff $00

	.db $ff $00 $94 $20
	.db $91 $20 $ff $00
	.db $97 $00 $94 $40
	.db $ff $00 $ff $00
	.db $ff $00 $ff $00
	.db $ff $00 $ff $00

data_2ec2:
	.db $ff $00 $ff $00
	.db $ff $00 $ff $00
	.db $a5 $20 $94 $00
	.db $ff $00 $a0 $20
	.db $9b $20 $ff $00
	.db $a1 $a0 $9d $a0

	.db $ff $00 $ff $00
	.db $ff $00 $ff $00
	.db $97 $40 $94 $00
	.db $ff $00 $94 $60
	.db $91 $60 $ff $00
	.db $ff $00 $ff $00

data_2ef2:
	.db $ff $00 $ff $00
	.db $ff $00 $94 $20
	.db $a5 $00 $ff $00
	.db $9b $00 $a0 $00
	.db $ff $00 $9d $80
	.db $a1 $80 $ff $00

	.db $ff $00 $ff $00
	.db $ff $00 $94 $20
	.db $97 $60 $ff $00
	.db $91 $40 $94 $40
	.db $ff $00 $ff $00
	.db $ff $00 $ff $00

data_2f22:
	.db $99 $00 $94 $00
	.db $ff $00 $a0 $20
	.db $a6 $00 $ff $00
	.db $a1 $a0 $a3 $80
	.db $ff $00 $ff $00
	.db $ff $00 $ff $00

	.db $91 $00 $94 $00
	.db $ff $00 $94 $60
	.db $97 $20 $ff $00
	.db $ff $00 $ff $00
	.db $ff $00 $ff $00
	.db $ff $00 $ff $00

data_2f52:
	.db $ff $00 $94 $20
	.db $99 $20 $ff $00
	.db $9f $20 $9a $00
	.db $ff $00 $a0 $20
	.db $9b $20 $ff $00
	.db $a1 $a0 $9d $a0

	.db $ff $00 $94 $20
	.db $91 $20 $ff $00
	.db $95 $20 $a8 $20
	.db $ff $00 $94 $60
	.db $91 $60 $ff $00
	.db $ff $00 $ff $00

data_2f82:
	.db $ff $00 $ff $00
	.db $ff $00 $94 $20
	.db $a9 $00 $94 $00
	.db $9b $00 $9c $00
	.db $9b $20 $9d $80
	.db $9e $80 $9d $a0

	.db $ff $00 $ff $00
	.db $ff $00 $94 $20
	.db $a9 $00 $94 $00
	.db $91 $40 $92 $40
	.db $91 $60 $ff $00
	.db $ff $00 $ff $00

data_2fb2:
	.db $99 $00 $94 $00
	.db $ff $00 $9a $20
	.db $9f $00 $ff $00
	.db $9b $00 $a0 $00
	.db $ff $00 $9d $80
	.db $a1 $80 $ff $00

	.db $91 $00 $94 $00
	.db $ff $00 $a8 $00
	.db $95 $00 $ff $00
	.db $91 $40 $94 $40
	.db $ff $00 $ff $00
	.db $ff $00 $ff $00

data_2fe2:
	.db $99 $00 $92 $00
	.db $99 $20 $a0 $20
	.db $a2 $00 $a0 $00
	.db $a1 $a0 $a3 $80
	.db $a1 $80 $ff $00
	.db $ff $00 $ff $00

	.db $91 $00 $92 $00
	.db $91 $20 $94 $60
	.db $a9 $40 $94 $40
	.db $ff $00 $ff $00
	.db $ff $00 $ff $00
	.db $ff $00 $ff $00

data_3012:
	.db $ff $00 $94 $20
	.db $99 $20 $94 $20
	.db $96 $00 $9a $00
	.db $9b $00 $9c $00
	.db $9b $20 $9d $80
	.db $9e $80 $9d $a0

	.db $ff $00 $94 $20
	.db $91 $20 $94 $20
	.db $96 $00 $a8 $20
	.db $91 $40 $92 $40
	.db $91 $60 $ff $00
	.db $ff $00 $ff $00

data_3042:
	.db $99 $00 $94 $00
	.db $ff $00 $9a $20
	.db $96 $20 $94 $00
	.db $9b $00 $9c $00
	.db $9b $20 $9d $80
	.db $9e $80 $9d $a0

	.db $91 $00 $94 $00
	.db $ff $00 $a8 $00
	.db $96 $20 $94 $00
	.db $91 $40 $92 $40
	.db $91 $60 $ff $00
	.db $ff $00 $ff $00

data_3072:
	.db $99 $00 $92 $00
	.db $99 $20 $9a $20
	.db $a4 $00 $a0 $00
	.db $9b $00 $a0 $00
	.db $a1 $80 $9d $80
	.db $a1 $80 $ff $00

	.db $91 $00 $92 $00
	.db $91 $20 $a8 $00
	.db $96 $60 $94 $40
	.db $91 $40 $94 $40
	.db $ff $00 $ff $00
	.db $ff $00 $ff $00

data_30a2:
	.db $99 $00 $92 $00
	.db $99 $20 $a0 $20
	.db $a4 $20 $9a $00
	.db $a1 $a0 $a0 $20
	.db $9b $20 $ff $00
	.db $a1 $a0 $9d $a0

	.db $91 $00 $92 $00
	.db $91 $20 $94 $60
	.db $96 $40 $a8 $20
	.db $ff $00 $94 $60
	.db $91 $60 $ff $00
	.db $ff $00 $ff $00

data_30d2:
	.db $99 $00 $92 $00
	.db $99 $20 $9a $20
	.db $93 $00 $9a $00
	.db $9b $00 $9c $00
	.db $9b $20 $9d $80
	.db $9e $80 $9d $a0

	.db $91 $00 $92 $00
	.db $91 $20 $a8 $00
	.db $93 $00 $a8 $20
	.db $91 $40 $92 $40
	.db $91 $60 $ff $00
	.db $ff $00 $ff $00

data_3102:
	.db $ff $00 $94 $20
	.db $99 $20 $94 $20
	.db $a7 $00 $a0 $00
	.db $9b $00 $a0 $00
	.db $a1 $80 $9d $80
	.db $a1 $80 $ff $00

	.db $ff $00 $94 $20
	.db $91 $20 $94 $20
	.db $98 $00 $94 $40
	.db $91 $40 $94 $40
	.db $ff $00 $ff $00
	.db $ff $00 $ff $00

data_3132:
	.db $99 $00 $94 $00
	.db $ff $00 $a0 $20
	.db $a7 $20 $94 $00
	.db $a1 $a0 $a0 $20
	.db $9b $20 $ff $00
	.db $a1 $a0 $9d $a0

	.db $91 $00 $94 $00
	.db $ff $00 $94 $60
	.db $98 $20 $94 $00
	.db $ff $00 $94 $60
	.db $91 $60 $ff $00
	.db $ff $00 $ff $00
