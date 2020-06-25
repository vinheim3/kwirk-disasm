; Big kwirk in menu screen
bigKwirkLayoutData:
	.db $60 $61 $62 $63 $aa
	.db $64 $65 $66 $67 $aa
	.db $68 $69 $6a $6b $aa
	.db $6c $6d $6e $6f $aa
	.db $70 $71 $72 $73
	.db $bb

; Including TM
; not including $aa and $bb tiles (replaced by blank, ie $ff)
kwirkLogoLayoutData:
	.db $90 $91 $92 $93 $94 $95 $96 $97 $98 $99 $9a $9b $9c
	; tm logo
	.db $28 $29 $aa

	.db $a0 $a1 $a2 $a3 $a4 $a5 $a6 $a7 $a8 $a9 $ff $ab $ac $aa
	.db $b0 $b1 $b2 $b3 $b4 $b5 $b6 $b7 $b8 $b9 $ba $ff $bc
	.db $bb

pushStartButtonLayoutData:
	.asc "PUSH START BUTTON"
	.db $bb

atlusLtdLayoutData:
	.db $80 $81 $82 $83 ; c 1989
	.db $22 $23 $24 $25 $26 $27 $37 ; atlas ltd
	.db $bb

licensedByNintendoLayoutData:
	.db $84 $85 $86 $87 $88 $89 $8a $8b $8c $8d $8e $8f
	.db $bb

; including TM
acclaimLogoLayoutData:
	.db $ff $ff

.bank 1 slot 1
.org $0

	.db $ff $52 $53 $54 $55 $56 $57
	; tm logo
	.db $28 $29
	.db $aa
	.db $ff $ff $e1 $e2 $e3 $e4 $e5 $e6 $e7
	.db $bb

acclaimEntRowLayoutData:
	.db $2a $2b $2c ; TM &
	.db $80 $81 $82 $83 ; c 1989
	.db $2e $2f $30 $31 $32 $33 $34 $35 ; acclaim ent
	.db $36 $37
	.db $bb


roomLayoutData_4026:
	.db $74 $75 $75 $75 $76 $aa
	.db $77 $18 $0e $14 $7c $75 $75 $75 $75 $76 $74 $75 $75 $75 $75 $75 $75 $75 $75 $76 $aa
	.db $77 $ff $ff $ff $ff $ff $11 $0c $12 $78 $77 $0c $08 $0d $ff $3c $e0 $3c $3c $78 $aa
	.db $79 $7a $7a $7a $7a $7a $7a $7a $7a $7b $79 $7a $7a $7a $7a $7a $7a $7a $7a $7b
	.db $bb

roomLayoutData_406b:
	.db $74 $75 $75 $75 $75 $75 $75 $75 $75 $76 $74 $75 $75 $75 $75 $75 $75 $76 $aa
	.db $77 $12 $02 $0e $11 $04 $ff $ff $ff $78 $77 $01 $0e $0d $14 $12 $ff $78 $aa
	.db $77 $ff $ff $ff $ff $ff $ff $3c $ff $78 $77 $ff $3e $3c $3c $3c $ff $78 $aa
	.db $79 $7a $7a $7a $7a $7a $7a $7a $7a $7b $79 $7a $7a $7a $7a $7a $7a $7b
	.db $bb

oppRoomsLayoutData:
	.db $74 $75 $75 $75 $75 $75 $75 $75 $75 $76 $aa
	.db $77 $ff $ff $ff $ff $ff $11 $0c $12 $78 $aa
	.db $77 $0e $0f $0f $7d $7a $7a $7a $7a $7b $aa
	.db $79 $7a $7a $7a $7b
	.db $bb

roomLayoutData_40de:
	.db $74 $75 $75 $75 $75 $75 $75 $75 $75 $76 $aa
	.db $77 $87 $88 $88 $88 $88 $88 $88 $89 $78 $aa
	.db $77 $87 $88 $88 $88 $88 $88 $88 $89 $78 $aa
	.db $79 $7a $7a $7a $7a $7a $7a $7a $7a $7b
	.db $bb

roomLayoutData_410a:
	.db $74 $75 $75 $75 $75 $75 $75 $75 $75 $76 $aa
	.db $77 $87 $88 $88 $88 $88 $88 $88 $89 $78 $aa
	.db $77 $ff $ff $ff $ff $ff $11 $0c $12 $78 $aa
	.db $79 $7a $7a $7a $7a $7a $7a $7a $7a $7b
	.db $bb