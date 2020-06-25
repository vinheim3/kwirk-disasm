; f6: jump to the given address, and save return point
.macro mu_call
	.db $f6
	.dw \1
.endm

; f7: return to the above point
.macro mu_ret
	.db $f7
.endm

; f8: jump to the given address
.macro mu_goto
	.db $f8
	.dw \1
.endm