; sound-related functions
initSoundRegisters:
	ld		a, $80

	; all sound on
	ldh		(R_NR52), a ; TODO: affected later

	; sound mode register 3 on
	ldh		(R_NR30), a ; TODO: affected later

	; amplify envelope of all sound registers - $08
	swap		a
	ldh		(R_NR12), a
	ldh		(R_NR22), a
	ldh		(R_NR32), a
	ldh		(R_NR42), a ; TODO: affected later

	; restart all sound registers - $80
	swap		a
	ldh		(R_NR14), a
	ldh		(R_NR24), a
	ldh		(R_NR34), a
	ldh		(R_NR44), a ; TODO: affected later

	; max S01 and S02 volume
	ld		a, $77
	ldh		(R_NR50), a

	; output sound 1 to S01 terminal
	xor		a
	ldh		(R_NR51), a ; TODO: affected later

	; write $00 every $10 bytes to $df00-$df80
	; ie dont process data in any of the sound channels
	ld		de, $0010
	ld		hl, wSoundChannelData
	ld		b, $08
-
	ld		(hl), a
	add		hl, de
	dec		b
	jr		nz, -
	ret


loadSoundsIntoWram:
	ld		hl, wNumSoundsToLoad
	ld		a, (hl)
	and		a
	ret		z
	dec		a
	ld		(hl), a
	inc		a
	add		l
	ld		l, a
	ld		a, (hl)
	add		a
	ld		de, soundChannelPointers
	ld		h, $00
	ld		l, a
	add		hl, de
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	ld		h, >wSoundChannelData
	ld		b, >wSoundChannelData
	; de is now pointer to sound data, eg sound01:

@initSoundChannelDataIntoWram:
	ld		a, (de)
	inc		a
	ret		z
	dec		a
	swap		a
	ld		l, a
	cp		$40
	jr		c, +

	; sound channel is 4+ (SND_08-SND_13)
	; set bit 7 of $df[snd channel-4]0
	sub		$40
	ld		c, a
	ld		a, (bc)
	or		$80
	ld		(bc), a
+
	; set bit 0 of df[snd channel]0
	set		0, (hl)

	; only keep bit 7 and bit 0 set in df[snd channel]0
	ld		a, $81
	and		(hl)
	ld		(hl), a

	; df[snd channel]1 = 1
	inc		l
	ld		(hl), $01

	; df[snd channel]5/6/7 = 0
	xor		a
	set		2, l
	ld		(hl), a
	inc		l
	ld		(hl), a
	inc		l
	ld		(hl), a

	; df[snd channel]8 is low byte of snd channel address
	inc		l
	inc		de
	ld		a, (de)
	ld		(hl), a

	; df[snd channel]9 is high byte of snd channel address
	inc		l
	inc		de
	ld		a, (de)
	ld		(hl), a

	inc		de
	jr		@initSoundChannelDataIntoWram


playSounds:
	; called during vblank interrupt
	ld		b, (<wSoundChannelDataEnd)>>4
_nextSoundChannelAfterHchanged:
	ld		h, >wSoundChannelData
_nextSoundChannel:
	dec		b

	; load new sounds after 8 sound channels processed
	bit		7, b
	jp		nz, loadSoundsIntoWram

	; hl = $dfx0
	ld		l, b
	swap		l

	; bit 0 of $dfx0 set, eg sound just loaded
	ld		a, (hl)			; $7234: $7e
	bit		0, a			; $7235: $cb $47
	jr		z, _nextSoundChannelAfterHchanged			; $7237: $28 $f0

	; $dfx1 = 1 (eg sound just loaded), call function
	inc		l			; $7239: $2c
	dec		(hl)			; $723a: $35
	jr		z, func_727c			; $723b: $28 $3f

	; $dfx2
	inc		l			; $723d: $2c
	dec		(hl)			; $723e: $35
	jr		nz, _nextSoundChannel			; $723f: $20 $ea

	; $dfx3
	inc		l			; $7241: $2c
	ld		e, (hl)			; $7242: $5e

	; $dfx4
	inc		l			; $7243: $2c
	ld		d, (hl)			; $7244: $56
	inc		de			; $7245: $13
	ld		a, (de)			; $7246: $1a
	ld		c, a			; $7247: $4f
	inc		de			; $7248: $13
	ld		a, (de)			; $7249: $1a

	; $dfx5
	inc		l			; $724a: $2c
	sub		(hl)			; $724b: $96
	jr		nc, +			; $724c: $30 $01
	xor		a			; $724e: $af
+
	dec		l			; $724f: $2d
	ld		(hl), d			; $7250: $72
	dec		l			; $7251: $2d
	ld		(hl), e			; $7252: $73
	dec		l			; $7253: $2d
	ld		(hl), c			; $7254: $71
	ld		c, a			; $7255: $4f
	ld		de, $df8f		; $7256: $11 $8f $df
	ld		a, ($df83)		; $7259: $fa $83 $df
	add		e			; $725c: $83
	ld		e, a			; $725d: $5f
	ld		a, c			; $725e: $79
	ld		(de), a			; $725f: $12
	dec		l			; $7260: $2d
	dec		l			; $7261: $2d
	bit		7, (hl)			; $7262: $cb $7e
	jr		nz, _nextSoundChannel			; $7264: $20 $c5
	push		hl			; $7266: $e5
	ld		hl, data_7fe0		; $7267: $21 $e0 $7f
	ld		a, b			; $726a: $78
	add		a			; $726b: $87
	add		l			; $726c: $85
	ld		l, a			; $726d: $6f
	ld		a, c			; $726e: $79
	ld		c, (hl)			; $726f: $4e
	ld		($ff00+c), a		; $7270: $e2
	inc		hl			; $7271: $23
	ld		c, (hl)			; $7272: $4e
	pop		hl			; $7273: $e1
	ld		a, $0d			; $7274: $3e $0d
	or		l			; $7276: $b5
	ld		l, a			; $7277: $6f
	ld		a, (hl)			; $7278: $7e
	ld		($ff00+c), a		; $7279: $e2
	jr		_nextSoundChannel			; $727a: $18 $af


; @param	b		index of sound channel
; @param	hl		$df[snd channel]1
func_727c:
	ld		a, b			; $727c: $78
	ld		($df83), a		; $727d: $ea $83 $df
	dec		l			; $7280: $2d
	set		3, l			; $7281: $cb $dd
	ld		e, (hl)			; $7283: $5e
	inc		l			; $7284: $2c
	ld		d, (hl)			; $7285: $56
	; de = address of sound channel data (-1)
processNextSoundByte:
	inc		de			; $7286: $13
func_7287:
	; a = sound byte being read
	; hl = $dfx9
	ld		a, (de)			; $7287: $1a
	bit		7, a			; $7288: $cb $7f
	jr		z, func_72f3			; $728a: $28 $67
	bit		6, a			; $728c: $cb $77
	jr		z, func_72a4			; $728e: $28 $14
	bit		5, a			; $7290: $cb $6f
	jr		z, func_72b5			; $7292: $28 $21
	push		hl			; $7294: $e5
	ld		hl, soundByteFxTable		; $7295: $21 $f7 $73
	and		$0f			; $7298: $e6 $0f
	add		a			; $729a: $87
	ld		c, a			; $729b: $4f
	ld		b, $00			; $729c: $06 $00
	add		hl, bc			; $729e: $09
	ld		b, (hl)			; $729f: $46
	inc		hl			; $72a0: $23
	ld		h, (hl)			; $72a1: $66
	ld		l, b			; $72a2: $68
	; jump to function in soundByteFxTable table
	jp		hl			; $72a3: $e9

func_72a4:
	push		hl			; $72a4: $e5
	res		7, a			; $72a5: $cb $bf
	ld		c, a			; $72a7: $4f
	ld		b, $00			; $72a8: $06 $00
	ld		hl, data_76ba		; $72aa: $21 $ba $76
	add		hl, bc			; $72ad: $09
	ld		a, (hl)			; $72ae: $7e
	pop		hl			; $72af: $e1
	inc		l			; $72b0: $2c
	ld		(hl), a			; $72b1: $77
	dec		l			; $72b2: $2d
	jr		processNextSoundByte			; $72b3: $18 $d1

; bit 7 and 6 of sound byte set, but not 5, ie $c0-$df
; @param	a		sound byte being read
func_72b5:
	and		$1f			; $72b5: $e6 $1f
	ld		b, a			; $72b7: $47
	ld		a, ($df83)		; $72b8: $fa $83 $df
	and		$03			; $72bb: $e6 $03
	add		b			; $72bd: $80
	push		hl			; $72be: $e5
	ld		hl, data_7ff0		; $72bf: $21 $f0 $7f
	add		l			; $72c2: $85
	ld		l, a			; $72c3: $6f
	ld		a, (hl)			; $72c4: $7e
	ld		hl, $df87		; $72c5: $21 $87 $df
	ld		b, a			; $72c8: $47
	ld		a, ($df83)		; $72c9: $fa $83 $df
	add		l			; $72cc: $85
	ld		l, a			; $72cd: $6f
	ld		(hl), b			; $72ce: $70
	pop		hl			; $72cf: $e1
	jr		processNextSoundByte			; $72d0: $18 $b4

; @param	hl		$dfx8
soundByte54:
	ld		a, ($df83)		; $72d2: $fa $83 $df
	ld		b, a			; $72d5: $47
	res		3, l			; $72d6: $cb $9d

	; $dfx0 - dont play music channel if sound channel playing
	set		1, (hl)			; $72d8: $cb $ce
	bit		7, (hl)			; $72da: $cb $7e
	jp		nz, _nextSoundChannel		; $72dc: $c2 $2b $72

	; a = ($df83)
	ld		a, b			; $72df: $78
	ld		hl, $df87		; $72e0: $21 $87 $df
	add		l			; $72e3: $85
	ld		l, a			; $72e4: $6f
	ld		a, (hl)			; $72e5: $7e
	cpl					; $72e6: $2f
	ld		c, a			; $72e7: $4f
	ldh		a, (R_NR51)		; $72e8: $f0 $25
	and		c			; $72ea: $a1
	swap		c			; $72eb: $cb $31
	and		c			; $72ed: $a1
	ldh		(R_NR51), a		; $72ee: $e0 $25
	jp		_nextSoundChannelAfterHchanged			; $72f0: $c3 $29 $72

; @param	a		current byte in sound data being read
; @param	hl		$dfx9
func_72f3:
	inc		l			; $72f3: $2c

	; $dfxa
	ld		c, (hl)			; $72f4: $4e
	res		3, l			; $72f5: $cb $9d
	dec		l			; $72f7: $2d

	; store $dfxa into $dfx1
	ld		(hl), c			; $72f8: $71

	; store addr of sound byte into $dfx9, $dfx8
	set		3, l			; $72f9: $cb $dd
	ld		(hl), d			; $72fb: $72
	dec		l			; $72fc: $2d
	ld		(hl), e			; $72fd: $73

	cp		$54			; $72fe: $fe $54
	jr		z, soundByte54			; $7300: $28 $d0

	; snd mode 3 or 7
	ld		c, a			; $7302: $4f
	ld		a, ($df83)		; $7303: $fa $83 $df
	and		$03			; $7306: $e6 $03
	cp		$03			; $7308: $fe $03
	jp		z, func_73a9		; $730a: $ca $a9 $73

	; $dfx7
	ld		a, c			; $730d: $79
	dec		l			; $730e: $2d
	add		(hl)			; $730f: $86
	; bc = $dfx7
	ld		c, l			; $7310: $4d
	ld		b, h			; $7311: $44
	add		a			; $7312: $87
	ld		e, a			; $7313: $5f
	ld		d, $00			; $7314: $16 $00
	ld		hl, data_75e8		; $7316: $21 $e8 $75
	add		hl, de			; $7319: $19
	
	; a value in data_75e8 is put into de
	ld		e, (hl)			; $731a: $5e
	inc		hl			; $731b: $23
	ld		d, (hl)			; $731c: $56
	; $dfx6
	dec		c			; $731d: $0d
	ld		a, (bc)			; $731e: $0a
	ld		l, a			; $731f: $6f
	ld		h, $00			; $7320: $26 $00
	add		hl, de			; $7322: $19
	ld		a, ($df83)		; $7323: $fa $83 $df
	and		$03			; $7326: $e6 $03
	cp		$02			; $7328: $fe $02
	jr		z, func_7332			; $732a: $28 $06
func_732c:
	ld		a, $80			; $732c: $3e $80
	or		h			; $732e: $b4
	ld		h, a			; $732f: $67
	jr		func_7338			; $7330: $18 $06
func_7332:
	ldh		a, (R_NR52)		; $7332: $f0 $26
	bit		2, a			; $7334: $cb $57
	jr		z, func_732c			; $7336: $28 $f4
func_7338:
	; if sound 3 is on,...
	set		3, c			; $7338: $cb $d9
	dec		c			; $733a: $0d
	ld		a, h			; $733b: $7c
	ld		(bc), a			; $733c: $02
	dec		c			; $733d: $0d
	ld		a, l			; $733e: $7d
	ld		(bc), a			; $733f: $02
	push		hl			; $7340: $e5
	inc		c			; $7341: $0c
	ld		l, c			; $7342: $69
	ld		h, b			; $7343: $60
	inc		c			; $7344: $0c
	res		3, l			; $7345: $cb $9d
	ld		a, (bc)			; $7347: $0a
	ld		e, a			; $7348: $5f
	inc		c			; $7349: $0c
	ld		a, (bc)			; $734a: $0a
	ld		d, a			; $734b: $57
	ld		a, (de)			; $734c: $1a
	ld		c, a			; $734d: $4f
	inc		de			; $734e: $13
	ld		a, (de)			; $734f: $1a
	sub		(hl)			; $7350: $96
	jr		nc, +			; $7351: $30 $01
	xor		a			; $7353: $af
+
	dec		l			; $7354: $2d
	ld		(hl), d			; $7355: $72
	dec		l			; $7356: $2d
	ld		(hl), e			; $7357: $73
	dec		l			; $7358: $2d
	ld		(hl), c			; $7359: $71
	ld		c, a			; $735a: $4f
	ld		de, $df8f		; $735b: $11 $8f $df
	ld		a, ($df83)		; $735e: $fa $83 $df
	add		e			; $7361: $83
	ld		e, a			; $7362: $5f
	ld		a, c			; $7363: $79
	ld		(de), a			; $7364: $12
	dec		l			; $7365: $2d
	dec		l			; $7366: $2d
	bit		7, (hl)			; $7367: $cb $7e
	jr		nz, func_73a1			; $7369: $20 $36
	push		hl			; $736b: $e5
	ld		hl, data_7fe0		; $736c: $21 $e0 $7f
	ld		c, a			; $736f: $4f
	ld		a, ($df83)		; $7370: $fa $83 $df
	add		a			; $7373: $87
	add		l			; $7374: $85
	ld		l, a			; $7375: $6f
	ld		a, c			; $7376: $79
	ld		c, (hl)			; $7377: $4e
	ld		($ff00+c), a		; $7378: $e2
	dec		c			; $7379: $0d
	pop		de			; $737a: $d1
	ld		a, $0b			; $737b: $3e $0b
	or		e			; $737d: $b3
	ld		e, a			; $737e: $5f
	ld		a, (de)			; $737f: $1a
	ld		($ff00+c), a		; $7380: $e2
	inc		hl			; $7381: $23
	ld		c, (hl)			; $7382: $4e
	ld		hl, $df87		; $7383: $21 $87 $df
	ld		a, ($df83)		; $7386: $fa $83 $df
	add		l			; $7389: $85
	ld		l, a			; $738a: $6f
	ld		a, (hl)			; $738b: $7e
	ld		b, a			; $738c: $47
	cpl					; $738d: $2f
	ld		e, a			; $738e: $5f
	ldh		a, (R_NR51)		; $738f: $f0 $25
	and		e			; $7391: $a3
	swap		e			; $7392: $cb $33
	and		e			; $7394: $a3
	or		b			; $7395: $b0
	ldh		(R_NR51), a		; $7396: $e0 $25
	pop		hl			; $7398: $e1
	dec		c			; $7399: $0d
	ld		a, l			; $739a: $7d
	ld		($ff00+c), a		; $739b: $e2
	inc		c			; $739c: $0c
	ld		a, h			; $739d: $7c
	ld		($ff00+c), a		; $739e: $e2
	jr		func_73a2			; $739f: $18 $01
func_73a1:
	pop		hl			; $73a1: $e1
func_73a2:
	ld		a, ($df83)		; $73a2: $fa $83 $df
	ld		b, a			; $73a5: $47
	jp		_nextSoundChannelAfterHchanged			; $73a6: $c3 $29 $72

func_73a9:
	set		2, l			; $73a9: $cb $d5
	ld		(hl), c			; $73ab: $71
	inc		l			; $73ac: $2c
	ld		(hl), $80		; $73ad: $36 $80
	inc		l			; $73af: $2c
	ld		e, (hl)			; $73b0: $5e
	inc		l			; $73b1: $2c
	ld		d, (hl)			; $73b2: $56
	ld		a, $0d			; $73b3: $3e $0d
	xor		l			; $73b5: $ad
	ld		l, a			; $73b6: $6f
	ld		a, (de)			; $73b7: $1a
	ld		(hl), a			; $73b8: $77
	inc		de			; $73b9: $13
	inc		l			; $73ba: $2c
	ld		(hl), e			; $73bb: $73
	inc		l			; $73bc: $2c
	ld		(hl), d			; $73bd: $72
	ld		a, (de)			; $73be: $1a
	inc		l			; $73bf: $2c
	sub		(hl)			; $73c0: $96
	jr		nc, +			; $73c1: $30 $02
	ld		a, $08			; $73c3: $3e $08
+
	ld		b, a			; $73c5: $47
	ld		de, $df8f		; $73c6: $11 $8f $df
	ld		a, ($df83)		; $73c9: $fa $83 $df
	add		e			; $73cc: $83
	ld		e, a			; $73cd: $5f
	ld		a, b			; $73ce: $78
	ld		(de), a			; $73cf: $12
	dec		l			; $73d0: $2d
	res		2, l			; $73d1: $cb $95
	bit		7, (hl)			; $73d3: $cb $7e
	jr		nz, func_73a2			; $73d5: $20 $cb
	ldh		(R_NR42), a		; $73d7: $e0 $21
	ld		hl, $df87		; $73d9: $21 $87 $df
	ld		a, ($df83)		; $73dc: $fa $83 $df
	add		l			; $73df: $85
	ld		l, a			; $73e0: $6f
	ld		a, (hl)			; $73e1: $7e
	ld		b, a			; $73e2: $47
	cpl					; $73e3: $2f
	ld		e, a			; $73e4: $5f
	ldh		a, (R_NR51)		; $73e5: $f0 $25
	and		e			; $73e7: $a3
	swap		e			; $73e8: $cb $33
	and		e			; $73ea: $a3
	or		b			; $73eb: $b0
	ldh		(R_NR51), a		; $73ec: $e0 $25
	ld		a, c			; $73ee: $79
	ldh		(R_NR43), a		; $73ef: $e0 $22
	; restart sound 4
	ld		a, $80			; $73f1: $3e $80
	ldh		(R_NR44), a		; $73f3: $e0 $23
	jr		func_73a2			; $73f5: $18 $ab

; idx is low nybble of sound byte if high nybble is $e or $f
soundByteFxTable:
	.dw soundByteF0
	.dw soundByteF1
	.dw soundByteF2
	.dw soundByteF3
	.dw soundByteF4
	.dw soundByteF5
	.dw soundByteF6
	.dw soundByteF7
	.dw soundByteF8
	.dw soundByteF9
	.dw soundByteFA
	.dw soundByteFB
	.dw soundByteFC
	.dw soundByteFD
	.dw soundByteFE
	.dw soundByteFD ; stub

;;
; skip and process next sound byte
; @param	de 		current addr of sound channel byte being read - 1
; @param	stack	$dfx9
soundByteFE:
	pop		hl			; $7417: $e1
	jp		processNextSoundByte			; $7418: $c3 $86 $72

;;
; stores 2 bytes from table data_76fa, indexed by next byte read, into $dfxe/f
; @param	de 		current addr of sound channel byte being read
; @param	stack	$dfx9
soundByteF0:
	inc		de			; $741b: $13
	ld		a, (de)			; $741c: $1a
	add		a			; $741d: $87
	ld		hl, data_76fa		; $741e: $21 $fa $76
	ld		c, a			; $7421: $4f
	ld		b, $00			; $7422: $06 $00
	add		hl, bc			; $7424: $09
	ld		c, l			; $7425: $4d
	ld		b, h			; $7426: $44
	; bc = address of data in data_76fa, hl = $dfx9
	pop		hl			; $7427: $e1
	set		2, l			; $7428: $cb $d5
	inc		l			; $742a: $2c
	; hl = $dfxe
	ld		a, (bc)			; $742b: $0a
	ld		(hl), a			; $742c: $77
	inc		bc			; $742d: $03
	inc		l			; $742e: $2c
	ld		a, (bc)			; $742f: $0a
	ld		(hl), a			; $7430: $77
	res		1, l			; $7431: $cb $8d
	res		2, l			; $7433: $cb $95
	jp		processNextSoundByte			; $7435: $c3 $86 $72

;;
; stores next byte in $dfxb
; @param	de 		current addr of sound channel byte being read
; @param	stack	$dfx9
soundByteF1:
	inc		de			; $7438: $13
	ld		a, (de)			; $7439: $1a
	pop		hl			; $743a: $e1
	set		1, l			; $743b: $cb $cd
	ld		(hl), a			; $743d: $77
	res		1, l			; $743e: $cb $8d
	jp		processNextSoundByte			; $7440: $c3 $86 $72

;; Stores next sound byte in $dfx5
; @param	de 		current addr of sound channel byte being read
; @param	stack	$dfx9
soundByteF2:
	inc		de			; $7443: $13
	pop		hl			; $7444: $e1
	ld		a, $0c			; $7445: $3e $0c
	xor		l			; $7447: $ad
	ld		l, a			; $7448: $6f
	; hl = $dfx5
	ld		a, (de)			; $7449: $1a
	ld		(hl), a			; $744a: $77
	ld		a, $0c			; $744b: $3e $0c
	xor		l			; $744d: $ad
	ld		l, a			; $744e: $6f
	jp		processNextSoundByte			; $744f: $c3 $86 $72

;;
; Stores next sound byte in $dfx7
; @param	de 		current addr of sound channel byte being read
; @param	stack	$dfx9
soundByteF3:
	inc		de			; $7452: $13
	pop		hl			; $7453: $e1
	dec		l			; $7454: $2d
	dec		l			; $7455: $2d
	ld		a, (de)			; $7456: $1a
	ld		(hl), a			; $7457: $77
	inc		l			; $7458: $2c
	inc		l			; $7459: $2c
	jp		processNextSoundByte			; $745a: $c3 $86 $72

; TODO:
; @param	de 		current addr of sound channel byte being read
; @param	stack	$dfx9
soundByteF4:
	inc		de			; $745d: $13
	ld		a, ($df83)		; $745e: $fa $83 $df
	ld		c, a			; $7461: $4f
	add		a			; $7462: $87
	add		c			; $7463: $81
	; a = sound channel idx * 3?
	ld		hl, $dfa7		; $7464: $21 $a7 $df
	add		l			; $7467: $85
	ld		l, a			; $7468: $6f
	ld		a, (de)			; $7469: $1a
	ld		(hl), a			; $746a: $77
	inc		l			; $746b: $2c
	ld		(hl), e			; $746c: $73
	inc		l			; $746d: $2c
	ld		(hl), d			; $746e: $72
	pop		hl			; $746f: $e1
	jp		processNextSoundByte			; $7470: $c3 $86 $72

; TODO: waits based on timer value set from sound byte f4
; @param	de 		current addr of sound channel byte being read
; @param	stack	$dfx9
soundByteF5:
	ld		a, ($df83)		; $7473: $fa $83 $df
	ld		c, a			; $7476: $4f
	add		a			; $7477: $87
	add		c			; $7478: $81
	ld		hl, $dfa7		; $7479: $21 $a7 $df
	add		l			; $747c: $85
	ld		l, a			; $747d: $6f
	dec		(hl)			; $747e: $35
	jr		z, +			; $747f: $28 $04
	inc		l			; $7481: $2c
	ld		e, (hl)			; $7482: $5e
	inc		l			; $7483: $2c
	ld		d, (hl)			; $7484: $56
+
	pop		hl			; $7485: $e1
	jp		processNextSoundByte			; $7486: $c3 $86 $72

;;
; Next 2 bytes point to a block of sound data to "call", byte $f7 "returns"
; @param	de 		current addr of sound channel byte being read
; @param	stack	$dfx9
soundByteF6:
	ld		a, ($df83)		; $7489: $fa $83 $df
	add		a			; $748c: $87
	ld		hl, $df97		; $748d: $21 $97 $df
	add		l			; $7490: $85
	ld		l, a			; $7491: $6f
	inc		de			; $7492: $13
	ld		a, (de)			; $7493: $1a
	ld		c, a			; $7494: $4f
	inc		de			; $7495: $13
	ld		a, (de)			; $7496: $1a
	ld		(hl), e			; $7497: $73
	ld		e, c			; $7498: $59
	inc		l			; $7499: $2c
	ld		(hl), d			; $749a: $72
	ld		d, a			; $749b: $57
	pop		hl			; $749c: $e1
	jp		func_7287			; $749d: $c3 $87 $72

;;
; Used with above
; @param	de 		current addr of sound channel byte being read
; @param	stack	$dfx9
soundByteF7:
	ld		a, ($df83)		; $74a0: $fa $83 $df
	add		a			; $74a3: $87
	ld		hl, $df97		; $74a4: $21 $97 $df
	add		l			; $74a7: $85
	ld		l, a			; $74a8: $6f
	ld		e, (hl)			; $74a9: $5e
	inc		l			; $74aa: $2c
	ld		d, (hl)			; $74ab: $56
	pop		hl			; $74ac: $e1
	jp		processNextSoundByte			; $74ad: $c3 $86 $72

;;
; next 2 bytes denotes address of next sound byte to read
; @param	de 		current addr of sound channel byte being read - 1
; @param	stack	$dfx9
soundByteF8:
	inc		de			; $74b0: $13
	ld		a, (de)			; $74b1: $1a
	ld		c, a			; $74b2: $4f
	inc		de			; $74b3: $13
	ld		a, (de)			; $74b4: $1a
	ld		e, c			; $74b5: $59
	ld		d, a			; $74b6: $57
	pop		hl			; $74b7: $e1
	jp		func_7287			; $74b8: $c3 $87 $72

;;
; Stores next sound byte into $dfx6
; @param	de 		current addr of sound channel byte being read - 1
; @param	stack	$dfx9
soundByteF9:
	inc		de			; $74bb: $13
	pop		hl			; $74bc: $e1
	dec		l			; $74bd: $2d
	dec		l			; $74be: $2d
	dec		l			; $74bf: $2d
	ld		a, (de)			; $74c0: $1a
	ld		(hl), a			; $74c1: $77
	inc		l			; $74c2: $2c
	inc		l			; $74c3: $2c
	inc		l			; $74c4: $2c
	jp		processNextSoundByte			; $74c5: $c3 $86 $72

; TODO:
; if this is sound, we store byte after FA into sound mode 1 sweep
; @param	de 		current addr of sound channel byte being read - 1
; @param	stack	$dfx9
soundByteFA:
	pop		hl			; $74c8: $e1
	inc		de			; $74c9: $13
	ld		a, (de)			; $74ca: $1a
	ld		c, a			; $74cb: $4f
	ld		a, ($df83)		; $74cc: $fa $83 $df
	and		a			; $74cf: $a7
	jr		z, @music1			; $74d0: $28 $06
	ld		a, c			; $74d2: $79
	ldh		(R_NR10), a		; $74d3: $e0 $10
	jp		processNextSoundByte			; $74d5: $c3 $86 $72

@music1:
	ld		a, c			; $74d8: $79
	ld		($df84), a		; $74d9: $ea $84 $df
	dec		l			; $74dc: $2d
	res		3, l			; $74dd: $cb $9d
	set		2, (hl)			; $74df: $cb $d6
	; hl = $dfx4, if bit 7 is 0, put next sound byte into R_NR10
	bit		7, (hl)			; $74e1: $cb $7e
	jp		nz, +		; $74e3: $c2 $e8 $74
	ldh		(R_NR10), a		; $74e6: $e0 $10
+
	set		3, l			; $74e8: $cb $dd
	inc		l			; $74ea: $2c
	jp		processNextSoundByte			; $74eb: $c3 $86 $72

; TODO:
; if sound, put byte after FB into sound mode 1 sweep register
; @param	de 		current addr of sound channel byte being read - 1
; @param	stack	$dfx9
soundByteFB:
	pop		hl			; $74ee: $e1
	ld		a, ($df83)		; $74ef: $fa $83 $df
	and		a			; $74f2: $a7
	jr		z, @music1			; $74f3: $28 $06
	xor		a			; $74f5: $af
	ldh		(R_NR10), a		; $74f6: $e0 $10
	jp		processNextSoundByte			; $74f8: $c3 $86 $72
	
@music1:
	xor		a			; $74fb: $af
	ld		($df84), a		; $74fc: $ea $84 $df
	dec		l			; $74ff: $2d
	res		3, l			; $7500: $cb $9d
	bit		7, (hl)			; $7502: $cb $7e
	res		2, (hl)			; $7504: $cb $96
	jp		nz, +		; $7506: $c2 $0c $75
	xor		a			; $7509: $af
	ldh		(R_NR10), a		; $750a: $e0 $10
+
	set		3, l			; $750c: $cb $dd
	inc		l			; $750e: $2c
	jp		processNextSoundByte			; $750f: $c3 $86 $72

; TODO:
; @param	de 		current addr of sound channel byte being read - 1
; @param	stack	$dfx9
soundByteFC:
	ld		a, ($df83)		; $7512: $fa $83 $df
	cp		$02			; $7515: $fe $02
	jr		z, func_7532			; $7517: $28 $19
	ld		hl, $df85		; $7519: $21 $85 $df
	inc		de			; $751c: $13
	ld		a, (de)			; $751d: $1a
	ldi		(hl), a			; $751e: $22
	ld		c, a			; $751f: $4f
	inc		de			; $7520: $13
	ld		a, (de)			; $7521: $1a
	ld		(hl), a			; $7522: $77
	ld		b, a			; $7523: $47
	pop		hl			; $7524: $e1
	add		sp, -$02			; $7525: $e8 $fe
	dec		l			; $7527: $2d
	res		3, l			; $7528: $cb $9d
	bit		7, (hl)			; $752a: $cb $7e
	jr		func_753b			; $752c: $18 $0d

; Unused?
func_752e:
	ld		l, c			; $752e: $69
	ld		h, b			; $752f: $60
	jr		func_7538			; $7530: $18 $06

; @param	de		current addr of sound byte being read (from FC)
func_7532:
	inc		de			; $7532: $13
	ld		a, (de)			; $7533: $1a
	inc		de			; $7534: $13
	ld		l, a			; $7535: $6f
	ld		a, (de)			; $7536: $1a
	ld		h, a			; $7537: $67
func_7538:
	call		func_753f			; $7538: $cd $3f $75
func_753b:
	pop		hl			; $753b: $e1
	jp		processNextSoundByte			; $753c: $c3 $86 $72

; @param	hl		soundData_772a
func_753f:
	; clear first byte in wave pattern ram
	xor		a			; $753f: $af
	ldh		(R_NR30), a		; $7540: $e0 $1a
	ld		b, $10			; $7542: $06 $10
	ld		c, $30			; $7544: $0e $30
-
	ldi		a, (hl)			; $7546: $2a
	ld		($ff00+c), a		; $7547: $e2
	inc		c			; $7548: $0c
	dec		b			; $7549: $05
	jr		nz, -			; $754a: $20 $fa
	ld		a, $80			; $754c: $3e $80
	ldh		(R_NR30), a		; $754e: $e0 $1a
	ld		a, ($df83)		; $7550: $fa $83 $df
	ret					; $7553: $c9

; TODO:
; @param	de 		current addr of sound channel byte being read - 1
; @param	stack	$dfx9
soundByteFD:
	pop		hl			; $7554: $e1
	dec		hl			; $7555: $2b
	res		3, l			; $7556: $cb $9d
	res		0, (hl)			; $7558: $cb $86
	ld		a, ($df83)		; $755a: $fa $83 $df
	cp		$04			; $755d: $fe $04
	jr		nc, func_757b			; $755f: $30 $1a
	bit		7, (hl)			; $7561: $cb $7e
	jr		nz, func_7574			; $7563: $20 $0f
func_7565:
	ld		hl, data_7fe0		; $7565: $21 $e0 $7f
	add		a			; $7568: $87
	add		l			; $7569: $85
	ld		l, a			; $756a: $6f
	ld		c, (hl)			; $756b: $4e
	ld		a, $08			; $756c: $3e $08
	ld		($ff00+c), a		; $756e: $e2
	inc		hl			; $756f: $23
	ld		c, (hl)			; $7570: $4e
	swap		a			; $7571: $cb $37
	ld		($ff00+c), a		; $7573: $e2
func_7574:
	ld		a, ($df83)		; $7574: $fa $83 $df
	ld		b, a			; $7577: $47
	jp		_nextSoundChannelAfterHchanged			; $7578: $c3 $29 $72
func_757b:
	res		6, l			; $757b: $cb $b5
	res		7, (hl)			; $757d: $cb $be
	bit		0, (hl)			; $757f: $cb $46
	ld		a, ($df83)		; $7581: $fa $83 $df
	jr		z, func_7565			; $7584: $28 $df
	cp		$04			; $7586: $fe $04
	jr		nz, ++			; $7588: $20 $0a
	xor		a			; $758a: $af
	bit		2, (hl)			; $758b: $cb $56
	jr		z, +			; $758d: $28 $03
	ld		a, ($df84)		; $758f: $fa $84 $df
+
	ldh		(R_NR10), a		; $7592: $e0 $10
++
	ld		a, ($df83)		; $7594: $fa $83 $df
	res		2, a			; $7597: $cb $97
	ld		($df83), a		; $7599: $ea $83 $df
	ld		de, $df8f		; $759c: $11 $8f $df
	add		e			; $759f: $83
	ld		e, a			; $75a0: $5f
	push		hl			; $75a1: $e5
	ld		a, ($df83)		; $75a2: $fa $83 $df
	cp		$02			; $75a5: $fe $02
	call		z, func_75df		; $75a7: $cc $df $75
	ld		hl, $df87		; $75aa: $21 $87 $df
	add		l			; $75ad: $85
	ld		l, a			; $75ae: $6f
	ld		a, (hl)			; $75af: $7e
	ld		b, a			; $75b0: $47
	cpl					; $75b1: $2f
	ld		c, a			; $75b2: $4f
	ldh		a, (R_NR51)		; $75b3: $f0 $25
	and		c			; $75b5: $a1
	swap		c			; $75b6: $cb $31
	and		c			; $75b8: $a1
	or		b			; $75b9: $b0
	ldh		(R_NR51), a		; $75ba: $e0 $25
	ld		hl, data_7fe0		; $75bc: $21 $e0 $7f
	ld		a, ($df83)		; $75bf: $fa $83 $df
	add		a			; $75c2: $87
	add		l			; $75c3: $85
	ld		l, a			; $75c4: $6f
	ld		c, (hl)			; $75c5: $4e
	ld		a, (de)			; $75c6: $1a
	ld		($ff00+c), a		; $75c7: $e2
	inc		hl			; $75c8: $23
	ld		c, (hl)			; $75c9: $4e
	dec		c			; $75ca: $0d
	pop		hl			; $75cb: $e1
	set		2, l			; $75cc: $cb $d5
	set		3, l			; $75ce: $cb $dd
	ld		a, (hl)			; $75d0: $7e
	ld		($ff00+c), a		; $75d1: $e2
	inc		l			; $75d2: $2c
	inc		c			; $75d3: $0c
	ld		a, (hl)			; $75d4: $7e
	ld		($ff00+c), a		; $75d5: $e2
	ld		a, ($df83)		; $75d6: $fa $83 $df
	set		2, a			; $75d9: $cb $d7
	ld		b, a			; $75db: $47
	jp		_nextSoundChannelAfterHchanged			; $75dc: $c3 $29 $72


func_75df:
	ld		hl, $df85		; $75df: $21 $85 $df
	ldi		a, (hl)			; $75e2: $2a
	ld		h, (hl)			; $75e3: $66
	ld		l, a			; $75e4: $6f
	jp		func_753f			; $75e5: $c3 $3f $75


data_75e8:
	inc		l			; $75e8: $2c
	nop					; $75e9: $00
	sbc		l			; $75ea: $9d
	nop					; $75eb: $00
	rlca					; $75ec: $07
	ld		bc, $016b		; $75ed: $01 $6b $01
	ret					; $75f0: $c9
	ld		bc, $0223		; $75f1: $01 $23 $02
	ld		(hl), a			; $75f4: $77
	ld		(bc), a			; $75f5: $02
	rst		$0			; $75f6: $c7
	ld		(bc), a			; $75f7: $02
	ld		(de), a			; $75f8: $12
	inc		bc			; $75f9: $03
	ld		e, b			; $75fa: $58
	inc		bc			; $75fb: $03
	sbc		e			; $75fc: $9b
	inc		bc			; $75fd: $03
	jp		c, $1603		; $75fe: $da $03 $16
	inc		b			; $7601: $04
	ld		c, (hl)			; $7602: $4e
	inc		b			; $7603: $04
	add		e			; $7604: $83
	inc		b			; $7605: $04
	or		l			; $7606: $b5
	inc		b			; $7607: $04
	push		hl			; $7608: $e5
	inc		b			; $7609: $04
	ld		de, $3b05		; $760a: $11 $05 $3b
	dec		b			; $760d: $05
	ld		h, e			; $760e: $63
	dec		b			; $760f: $05
	adc		c			; $7610: $89
	dec		b			; $7611: $05
	xor		h			; $7612: $ac
	dec		b			; $7613: $05
	adc		$05			; $7614: $ce $05
.db $ed
	dec		b			; $7617: $05
	dec		bc			; $7618: $0b
	ld		b, $27			; $7619: $06 $27
	ld		b, $42			; $761b: $06 $42
	ld		b, $5b			; $761d: $06 $5b
	ld		b, $72			; $761f: $06 $72
	ld		b, $89			; $7621: $06 $89
	ld		b, $9e			; $7623: $06 $9e
	ld		b, $b2			; $7625: $06 $b2
	ld		b, $c4			; $7627: $06 $c4
	ld		b, $d6			; $7629: $06 $d6
	ld		b, $e7			; $762b: $06 $e7
	ld		b, $f7			; $762d: $06 $f7
	ld		b, $06			; $762f: $06 $06
	rlca					; $7631: $07
	inc		d			; $7632: $14
	rlca					; $7633: $07
	ld		hl, $2d07		; $7634: $21 $07 $2d
	rlca					; $7637: $07
	add		hl, sp			; $7638: $39
	rlca					; $7639: $07
	ld		b, h			; $763a: $44
	rlca					; $763b: $07
	ld		c, a			; $763c: $4f
	rlca					; $763d: $07
	ld		e, c			; $763e: $59
	rlca					; $763f: $07
	ld		h, d			; $7640: $62
	rlca					; $7641: $07
	ld		l, e			; $7642: $6b
	rlca					; $7643: $07
	ld		(hl), e			; $7644: $73
	rlca					; $7645: $07
	ld		a, e			; $7646: $7b
	rlca					; $7647: $07
	add		e			; $7648: $83
	rlca					; $7649: $07
	adc		d			; $764a: $8a
	rlca					; $764b: $07
	sub		b			; $764c: $90
	rlca					; $764d: $07
	sub		a			; $764e: $97
	rlca					; $764f: $07
	sbc		l			; $7650: $9d
	rlca					; $7651: $07
	and		d			; $7652: $a2
	rlca					; $7653: $07
	and		a			; $7654: $a7
	rlca					; $7655: $07
	xor		h			; $7656: $ac
	rlca					; $7657: $07
	or		c			; $7658: $b1
	rlca					; $7659: $07
	or		(hl)			; $765a: $b6
	rlca					; $765b: $07
	cp		d			; $765c: $ba
	rlca					; $765d: $07
	cp		(hl)			; $765e: $be
	rlca					; $765f: $07
	pop		bc			; $7660: $c1
	rlca					; $7661: $07
	push		bc			; $7662: $c5
	rlca					; $7663: $07
	ret		z			; $7664: $c8
	rlca					; $7665: $07
	rlc		a			; $7666: $cb $07
	adc		$07			; $7668: $ce $07
	pop		de			; $766a: $d1
	rlca					; $766b: $07
	call		nc, $d607		; $766c: $d4 $07 $d6
	rlca					; $766f: $07
	reti					; $7670: $d9
	rlca					; $7671: $07
.db $db
	rlca					; $7673: $07
.db $dd
	rlca					; $7675: $07
	rst		$18			; $7676: $df
	rlca					; $7677: $07
	pop		hl			; $7678: $e1
	rlca					; $7679: $07
	ld		($ff00+c), a		; $767a: $e2
	rlca					; $767b: $07
.db $e4
	rlca					; $767d: $07
	and		$07			; $767e: $e6 $07
	rst		$20			; $7680: $e7
	rlca					; $7681: $07
	jp		hl			; $7682: $e9
	rlca					; $7683: $07
	ld		($eb07), a		; $7684: $ea $07 $eb
	rlca					; $7687: $07
.db $ec
	rlca					; $7689: $07
.db $ed
	rlca					; $768b: $07
	xor		$07			; $768c: $ee $07
	rst		$28			; $768e: $ef
	rlca					; $768f: $07

soundChannelPointers:
	.dw soundStub
	.dw sound01
	.dw sound02
	.dw sound03
	.dw sound04
	.dw sound05
	.dw soundStub
	.dw soundStub
	.dw sound08
	.dw sound09
	.dw sound0a
	.dw sound0b
	.dw sound0c
	.dw sound0d
	.dw sound0e
	.dw sound0f
	.dw sound10
	.dw sound11
	.dw sound12
	.dw sound13
	.dw soundStub

data_76ba:
	nop					; $76ba: $00
	ld		bc, $0302		; $76bb: $01 $02 $03
	inc		b			; $76be: $04
	ld		b, $08			; $76bf: $06 $08
	inc		c			; $76c1: $0c
	stop					; $76c2: $10
	jr		$20			; $76c3: $18 $20
	jr		nc, $40			; $76c5: $30 $40
	ld		h, b			; $76c7: $60
	add		b			; $76c8: $80
	ret		nz			; $76c9: $c0
	nop					; $76ca: $00
	nop					; $76cb: $00
	nop					; $76cc: $00
	nop					; $76cd: $00
	dec		b			; $76ce: $05
	rlca					; $76cf: $07
	ld		a, (bc)			; $76d0: $0a
	rrca					; $76d1: $0f
	inc		d			; $76d2: $14
	ld		e, $28			; $76d3: $1e $28
	inc		a			; $76d5: $3c
	ld		d, b			; $76d6: $50
	ld		a, b			; $76d7: $78
	and		b			; $76d8: $a0
	ldh		a, (R_P1)		; $76d9: $f0 $00
	nop					; $76db: $00
	nop					; $76dc: $00
	nop					; $76dd: $00
	ld		b, $09			; $76de: $06 $09
	inc		c			; $76e0: $0c
	ld		(de), a			; $76e1: $12
	jr		$24			; $76e2: $18 $24
	jr		nc, $48			; $76e4: $30 $48
	ld		h, b			; $76e6: $60
	sub		b			; $76e7: $90
	ret		nz			; $76e8: $c0
	nop					; $76e9: $00
	nop					; $76ea: $00
	nop					; $76eb: $00
	nop					; $76ec: $00
	nop					; $76ed: $00
	rlca					; $76ee: $07
	nop					; $76ef: $00
	ld		c, $15			; $76f0: $0e $15
	inc		e			; $76f2: $1c
	ldi		a, (hl)			; $76f3: $2a
	jr		c, $54			; $76f4: $38 $54
	ld		(hl), b			; $76f6: $70
	xor		b			; $76f7: $a8
	ldh		(R_P1), a		; $76f8: $e0 $00


data_76fa:
	.dw data_770a
	.dw data_770c
	.dw data_770e
	.dw data_7710
	.dw data_7714
	.dw data_7716
	.dw data_7718
	.dw data_7718
data_770a:
	.db $ff $f0
data_770c:
	.db $ff $20
data_770e:
	.db $ff $f4
data_7710:
	.db $01 $f0
data_7712: ; Unused
	.db $ff $08
data_7714:
	.db $ff $f7
data_7716:
	.db $ff $f2
data_7718:
	.db $ff $08


; Unused?
data_771a:
.db $ff $ff
	rst		$38			; $771c: $ff
	rst		$38			; $771d: $ff
	rst		$38			; $771e: $ff
	rst		$38			; $771f: $ff
	rst		$38			; $7720: $ff
	rst		$38			; $7721: $ff
	nop					; $7722: $00
	nop					; $7723: $00
	nop					; $7724: $00
	nop					; $7725: $00
	nop					; $7726: $00
	nop					; $7727: $00
	nop					; $7728: $00
	nop					; $7729: $00

soundData_772a:
	ld		bc, $4523		; $772a: $01 $23 $45
	ld		h, a			; $772d: $67
	adc		c			; $772e: $89
	xor		e			; $772f: $ab
	call		$feef			; $7730: $cd $ef $fe
	call		c, $98ba		; $7733: $dc $ba $98
	halt					; $7736: $76
	ld		d, h			; $7737: $54
	ldd		(hl), a			; $7738: $32
	stop					; $7739: $10


	ld		(bc), a			; $773a: $02
	ld		b, (hl)			; $773b: $46
	adc		d			; $773c: $8a
	adc		$ff			; $773d: $ce $ff
	rst		$38			; $773f: $ff
	rst		$38			; $7740: $ff
	rst		$38			; $7741: $ff
.db $fd
	cp		c			; $7743: $b9
	ld		(hl), l			; $7744: $75
	ld		sp, $0000		; $7745: $31 $00 $00
	nop					; $7748: $00
	nop					; $7749: $00

.include "audio/group1.s"

.include "audio/group2.s"

.include "audio/group3.s"

; Unused sound data?
data_7e1b:
	and		h			; $7e1b: $a4
.db $f4
	inc		b			; $7e1d: $04
	ret		nz			; $7e1e: $c0
	jr		z, -$3c			; $7e1f: $28 $c4
	inc		h			; $7e21: $24
	ret		nz			; $7e22: $c0
	rra					; $7e23: $1f
	ret		z			; $7e24: $c8
	inc		h			; $7e25: $24
	push		af			; $7e26: $f5
.db $f4
	inc		b			; $7e28: $04
	ret		nz			; $7e29: $c0
	add		hl, hl			; $7e2a: $29
	call		nz, $c024		; $7e2b: $c4 $24 $c0
	ld		hl, $24c8		; $7e2e: $21 $c8 $24
	push		af			; $7e31: $f5
.db $f4
	inc		b			; $7e33: $04
	ret		nz			; $7e34: $c0
	dec		hl			; $7e35: $2b
	call		nz, $c026		; $7e36: $c4 $26 $c0
	inc		hl			; $7e39: $23
	ret		z			; $7e3a: $c8
	ld		h, $f5			; $7e3b: $26 $f5
	rst_playSound

data_7e3e:
	ldh		a, (R_SB)		; $7e3e: $f0 $01
.db $fc
	ldi		a, (hl)			; $7e41: $2a
	ld		(hl), a			; $7e42: $77
	ret		nz			; $7e43: $c0
	and		h			; $7e44: $a4
	inc		de			; $7e45: $13
	ld		d, h			; $7e46: $54
	inc		de			; $7e47: $13
	ld		d, h			; $7e48: $54
	inc		d			; $7e49: $14
	ld		d, h			; $7e4a: $54
	inc		d			; $7e4b: $14
	ld		d, h			; $7e4c: $54
	dec		d			; $7e4d: $15
	ld		d, h			; $7e4e: $54
	dec		d			; $7e4f: $15
	ld		d, h			; $7e50: $54
	ld		d, $54			; $7e51: $16 $54
	ld		d, $54			; $7e53: $16 $54
	rla					; $7e55: $17
	ld		d, h			; $7e56: $54
	ld		d, h			; $7e57: $54
	ld		d, h			; $7e58: $54
	xor		b			; $7e59: $a8
	inc		de			; $7e5a: $13
	and		h			; $7e5b: $a4
	ld		d, h			; $7e5c: $54
	ld		d, h			; $7e5d: $54
	inc		de			; $7e5e: $13
	ld		d, h			; $7e5f: $54
	dec		d			; $7e60: $15
	ld		d, h			; $7e61: $54
	rla					; $7e62: $17
	ld		d, h			; $7e63: $54
	and		h			; $7e64: $a4
	or		$89			; $7e65: $f6 $89
	ld		a, (hl)			; $7e67: $7e
	inc		de			; $7e68: $13
	ld		d, h			; $7e69: $54
	inc		d			; $7e6a: $14
	ld		d, h			; $7e6b: $54
	dec		d			; $7e6c: $15
	ld		d, h			; $7e6d: $54
	ld		d, $54			; $7e6e: $16 $54
	rla					; $7e70: $17
	ld		d, h			; $7e71: $54
	jr		$54			; $7e72: $18 $54
	add		hl, de			; $7e74: $19
	ld		d, h			; $7e75: $54
	ld		a, (de)			; $7e76: $1a
	ld		d, h			; $7e77: $54
	or		$89			; $7e78: $f6 $89
	ld		a, (hl)			; $7e7a: $7e
	inc		h			; $7e7b: $24
	ld		d, h			; $7e7c: $54
	rra					; $7e7d: $1f
	ld		d, h			; $7e7e: $54
	ld		hl, $2354		; $7e7f: $21 $54 $23
	ld		d, h			; $7e82: $54
	inc		h			; $7e83: $24
	ld		d, h			; $7e84: $54
	ld		d, h			; $7e85: $54
	ld		d, h			; $7e86: $54
	jr		-$01			; $7e87: $18 $ff

; Unused?
data_7e89:
.db $f4
	ld		(bc), a			; $7e8a: $02
	jr		$54			; $7e8b: $18 $54
	rra					; $7e8d: $1f
	ld		d, h			; $7e8e: $54
	add		e			; $7e8f: $83
	jr		$54			; $7e90: $18 $54
	jr		$54			; $7e92: $18 $54
	and		h			; $7e94: $a4
	rra					; $7e95: $1f
	ld		d, h			; $7e96: $54
	push		af			; $7e97: $f5
.db $f4
	ld		(bc), a			; $7e99: $02
	jr		$54			; $7e9a: $18 $54
	dec		e			; $7e9c: $1d
	ld		d, h			; $7e9d: $54
	add		e			; $7e9e: $83
	jr		$54			; $7e9f: $18 $54
	jr		$54			; $7ea1: $18 $54
	and		h			; $7ea3: $a4
	dec		e			; $7ea4: $1d
	ld		d, h			; $7ea5: $54
	push		af			; $7ea6: $f5
.db $f4
	ld		(bc), a			; $7ea8: $02
	ld		a, (de)			; $7ea9: $1a
	ld		d, h			; $7eaa: $54
	rra					; $7eab: $1f
	ld		d, h			; $7eac: $54
	add		e			; $7ead: $83
	ld		a, (de)			; $7eae: $1a
	ld		d, h			; $7eaf: $54
	ld		a, (de)			; $7eb0: $1a
	ld		d, h			; $7eb1: $54
	and		h			; $7eb2: $a4
	rra					; $7eb3: $1f
	ld		d, h			; $7eb4: $54
	push		af			; $7eb5: $f5
	rst_playSound

.include "audio/group4.s"

data_7fe0:
	ld		(de), a			; $7fe0: $12
	inc		d			; $7fe1: $14
	rla					; $7fe2: $17
	add		hl, de			; $7fe3: $19
	inc		e			; $7fe4: $1c
	ld		e, $21			; $7fe5: $1e $21
	inc		hl			; $7fe7: $23
	ld		(de), a			; $7fe8: $12
	inc		d			; $7fe9: $14
	rla					; $7fea: $17
	add		hl, de			; $7feb: $19
	inc		e			; $7fec: $1c
	ld		e, $21			; $7fed: $1e $21
	inc		hl			; $7fef: $23

data_7ff0:
	.db $11 $22 $44 $88
	.db $10 $20 $40 $80
	.db $01 $02 $04 $08
	.db $00 $00 $00 $00
