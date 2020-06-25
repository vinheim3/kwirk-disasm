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
	ld		a, ($c2be)		; $2e5d: $fa $be $c2
	and		a			; $2e60: $a7
	jr		nz, +			; $2e61: $20 $05
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
	.dw $2ec2
	.dw $2ef2
	.dw $2f22
	.dw $2f52
	.dw $2f82
	.dw $2fb2
	.dw $2fe2
	.dw $3012
	.dw $3042
	.dw $3072
	.dw $30a2
	.dw $30d2
	.dw $3102
	.dw $3132

data_2e92:
	rst		$38			; $2e92: $ff
	nop					; $2e93: $00
	sub		h			; $2e94: $94
	jr		nz, -$67			; $2e95: $20 $99
	jr		nz, -$01			; $2e97: $20 $ff
	nop					; $2e99: $00
	and		(hl)			; $2e9a: $a6
	jr		nz, -$60			; $2e9b: $20 $a0
	nop					; $2e9d: $00
	rst		$38			; $2e9e: $ff
	nop					; $2e9f: $00
	and		e			; $2ea0: $a3
	add		b			; $2ea1: $80
	and		c			; $2ea2: $a1
	add		b			; $2ea3: $80
	rst		$38			; $2ea4: $ff
	nop					; $2ea5: $00
	rst		$38			; $2ea6: $ff
	nop					; $2ea7: $00
	rst		$38			; $2ea8: $ff
	nop					; $2ea9: $00
	rst		$38			; $2eaa: $ff
	nop					; $2eab: $00
	sub		h			; $2eac: $94
	jr		nz, -$6f			; $2ead: $20 $91
	jr		nz, -$01			; $2eaf: $20 $ff
	nop					; $2eb1: $00
	sub		a			; $2eb2: $97
	nop					; $2eb3: $00
	sub		h			; $2eb4: $94
	ld		b, b			; $2eb5: $40
	rst		$38			; $2eb6: $ff
	nop					; $2eb7: $00
	rst		$38			; $2eb8: $ff
	nop					; $2eb9: $00
	rst		$38			; $2eba: $ff
	nop					; $2ebb: $00
	rst		$38			; $2ebc: $ff
	nop					; $2ebd: $00
	rst		$38			; $2ebe: $ff
	nop					; $2ebf: $00
	rst		$38			; $2ec0: $ff
	nop					; $2ec1: $00

data_2ec2:
	rst		$38			; $2ec2: $ff
	nop					; $2ec3: $00
	rst		$38			; $2ec4: $ff
	nop					; $2ec5: $00
	rst		$38			; $2ec6: $ff
	nop					; $2ec7: $00
	rst		$38			; $2ec8: $ff
	nop					; $2ec9: $00
	and		l			; $2eca: $a5
	jr		nz, -$6c			; $2ecb: $20 $94
	nop					; $2ecd: $00
	rst		$38			; $2ece: $ff
	nop					; $2ecf: $00
	and		b			; $2ed0: $a0
	jr		nz, -$65			; $2ed1: $20 $9b
	jr		nz, -$01			; $2ed3: $20 $ff
	nop					; $2ed5: $00
	and		c			; $2ed6: $a1
	and		b			; $2ed7: $a0
	sbc		l			; $2ed8: $9d
	and		b			; $2ed9: $a0
	rst		$38			; $2eda: $ff
	nop					; $2edb: $00
	rst		$38			; $2edc: $ff
	nop					; $2edd: $00
	rst		$38			; $2ede: $ff
	nop					; $2edf: $00
	rst		$38			; $2ee0: $ff
	nop					; $2ee1: $00
	sub		a			; $2ee2: $97
	ld		b, b			; $2ee3: $40
	sub		h			; $2ee4: $94
	nop					; $2ee5: $00
	rst		$38			; $2ee6: $ff
	nop					; $2ee7: $00
	sub		h			; $2ee8: $94
	ld		h, b			; $2ee9: $60
	sub		c			; $2eea: $91
	ld		h, b			; $2eeb: $60
	rst		$38			; $2eec: $ff
	nop					; $2eed: $00
	rst		$38			; $2eee: $ff
	nop					; $2eef: $00
	rst		$38			; $2ef0: $ff
	nop					; $2ef1: $00

data_2ef2:
	rst		$38			; $2ef2: $ff
	nop					; $2ef3: $00
	rst		$38			; $2ef4: $ff
	nop					; $2ef5: $00
	rst		$38			; $2ef6: $ff
	nop					; $2ef7: $00
	sub		h			; $2ef8: $94
	jr		nz, -$5b			; $2ef9: $20 $a5
	nop					; $2efb: $00
	rst		$38			; $2efc: $ff
	nop					; $2efd: $00
	sbc		e			; $2efe: $9b
	nop					; $2eff: $00
	and		b			; $2f00: $a0
	nop					; $2f01: $00
	rst		$38			; $2f02: $ff
	nop					; $2f03: $00
	sbc		l			; $2f04: $9d
	add		b			; $2f05: $80
	and		c			; $2f06: $a1
	add		b			; $2f07: $80
	rst		$38			; $2f08: $ff
	nop					; $2f09: $00
	rst		$38			; $2f0a: $ff
	nop					; $2f0b: $00
	rst		$38			; $2f0c: $ff
	nop					; $2f0d: $00
	rst		$38			; $2f0e: $ff
	nop					; $2f0f: $00
	sub		h			; $2f10: $94
	jr		nz, -$69			; $2f11: $20 $97
	ld		h, b			; $2f13: $60
	rst		$38			; $2f14: $ff
	nop					; $2f15: $00
	sub		c			; $2f16: $91
	ld		b, b			; $2f17: $40
	sub		h			; $2f18: $94
	ld		b, b			; $2f19: $40
	rst		$38			; $2f1a: $ff
	nop					; $2f1b: $00
	rst		$38			; $2f1c: $ff
	nop					; $2f1d: $00
	rst		$38			; $2f1e: $ff
	nop					; $2f1f: $00
	rst		$38			; $2f20: $ff
	nop					; $2f21: $00

data_2f22:
	sbc		c			; $2f22: $99
	nop					; $2f23: $00
	sub		h			; $2f24: $94
	nop					; $2f25: $00
	rst		$38			; $2f26: $ff
	nop					; $2f27: $00
	and		b			; $2f28: $a0
	jr		nz, -$5a			; $2f29: $20 $a6
	nop					; $2f2b: $00
	rst		$38			; $2f2c: $ff
	nop					; $2f2d: $00
	and		c			; $2f2e: $a1
	and		b			; $2f2f: $a0
	and		e			; $2f30: $a3
	add		b			; $2f31: $80
	rst		$38			; $2f32: $ff
	nop					; $2f33: $00
	rst		$38			; $2f34: $ff
	nop					; $2f35: $00
	rst		$38			; $2f36: $ff
	nop					; $2f37: $00
	rst		$38			; $2f38: $ff
	nop					; $2f39: $00
	sub		c			; $2f3a: $91
	nop					; $2f3b: $00
	sub		h			; $2f3c: $94
	nop					; $2f3d: $00
	rst		$38			; $2f3e: $ff
	nop					; $2f3f: $00
	sub		h			; $2f40: $94
	ld		h, b			; $2f41: $60
	sub		a			; $2f42: $97
	jr		nz, -$01			; $2f43: $20 $ff
	nop					; $2f45: $00
	rst		$38			; $2f46: $ff
	nop					; $2f47: $00
	rst		$38			; $2f48: $ff
	nop					; $2f49: $00
	rst		$38			; $2f4a: $ff
	nop					; $2f4b: $00
	rst		$38			; $2f4c: $ff
	nop					; $2f4d: $00
	rst		$38			; $2f4e: $ff
	nop					; $2f4f: $00
	rst		$38			; $2f50: $ff
	nop					; $2f51: $00

data_2f52:
	rst		$38			; $2f52: $ff
	nop					; $2f53: $00
	sub		h			; $2f54: $94
	jr		nz, -$67			; $2f55: $20 $99
	jr		nz, -$01			; $2f57: $20 $ff
	nop					; $2f59: $00
	sbc		a			; $2f5a: $9f
	jr		nz, -$66			; $2f5b: $20 $9a
	nop					; $2f5d: $00
	rst		$38			; $2f5e: $ff
	nop					; $2f5f: $00
	and		b			; $2f60: $a0
	jr		nz, -$65			; $2f61: $20 $9b
	jr		nz, -$01			; $2f63: $20 $ff
	nop					; $2f65: $00
	and		c			; $2f66: $a1
	and		b			; $2f67: $a0
	sbc		l			; $2f68: $9d
	and		b			; $2f69: $a0
	rst		$38			; $2f6a: $ff
	nop					; $2f6b: $00
	sub		h			; $2f6c: $94
	jr		nz, -$6f			; $2f6d: $20 $91
	jr		nz, -$01			; $2f6f: $20 $ff
	nop					; $2f71: $00
	sub		l			; $2f72: $95
	jr		nz, -$58			; $2f73: $20 $a8
	jr		nz, -$01			; $2f75: $20 $ff
	nop					; $2f77: $00
	sub		h			; $2f78: $94
	ld		h, b			; $2f79: $60
	sub		c			; $2f7a: $91
	ld		h, b			; $2f7b: $60
	rst		$38			; $2f7c: $ff
	nop					; $2f7d: $00
	rst		$38			; $2f7e: $ff
	nop					; $2f7f: $00
	rst		$38			; $2f80: $ff
	nop					; $2f81: $00

data_2f82:
	rst		$38			; $2f82: $ff
	nop					; $2f83: $00
	rst		$38			; $2f84: $ff
	nop					; $2f85: $00
	rst		$38			; $2f86: $ff
	nop					; $2f87: $00
	sub		h			; $2f88: $94
	jr		nz, -$57			; $2f89: $20 $a9
	nop					; $2f8b: $00
	sub		h			; $2f8c: $94
	nop					; $2f8d: $00
	sbc		e			; $2f8e: $9b
	nop					; $2f8f: $00
	sbc		h			; $2f90: $9c
	nop					; $2f91: $00
	sbc		e			; $2f92: $9b
	jr		nz, -$63			; $2f93: $20 $9d
	add		b			; $2f95: $80
	sbc		(hl)			; $2f96: $9e
	add		b			; $2f97: $80
	sbc		l			; $2f98: $9d
	and		b			; $2f99: $a0
	rst		$38			; $2f9a: $ff
	nop					; $2f9b: $00
	rst		$38			; $2f9c: $ff
	nop					; $2f9d: $00
	rst		$38			; $2f9e: $ff
	nop					; $2f9f: $00
	sub		h			; $2fa0: $94
	jr		nz, -$57			; $2fa1: $20 $a9
	nop					; $2fa3: $00
	sub		h			; $2fa4: $94
	nop					; $2fa5: $00
	sub		c			; $2fa6: $91
	ld		b, b			; $2fa7: $40
	sub		d			; $2fa8: $92
	ld		b, b			; $2fa9: $40
	sub		c			; $2faa: $91
	ld		h, b			; $2fab: $60
	rst		$38			; $2fac: $ff
	nop					; $2fad: $00
	rst		$38			; $2fae: $ff
	nop					; $2faf: $00
	rst		$38			; $2fb0: $ff
	nop					; $2fb1: $00

data_2fb2:
	sbc		c			; $2fb2: $99
	nop					; $2fb3: $00
	sub		h			; $2fb4: $94
	nop					; $2fb5: $00
	rst		$38			; $2fb6: $ff
	nop					; $2fb7: $00
	sbc		d			; $2fb8: $9a
	jr		nz, -$61			; $2fb9: $20 $9f
	nop					; $2fbb: $00
	rst		$38			; $2fbc: $ff
	nop					; $2fbd: $00
	sbc		e			; $2fbe: $9b
	nop					; $2fbf: $00
	and		b			; $2fc0: $a0
	nop					; $2fc1: $00
	rst		$38			; $2fc2: $ff
	nop					; $2fc3: $00
	sbc		l			; $2fc4: $9d
	add		b			; $2fc5: $80
	and		c			; $2fc6: $a1
	add		b			; $2fc7: $80
	rst		$38			; $2fc8: $ff
	nop					; $2fc9: $00
	sub		c			; $2fca: $91
	nop					; $2fcb: $00
	sub		h			; $2fcc: $94
	nop					; $2fcd: $00
	rst		$38			; $2fce: $ff
	nop					; $2fcf: $00
	xor		b			; $2fd0: $a8
	nop					; $2fd1: $00
	sub		l			; $2fd2: $95
	nop					; $2fd3: $00
	rst		$38			; $2fd4: $ff
	nop					; $2fd5: $00
	sub		c			; $2fd6: $91
	ld		b, b			; $2fd7: $40
	sub		h			; $2fd8: $94
	ld		b, b			; $2fd9: $40
	rst		$38			; $2fda: $ff
	nop					; $2fdb: $00
	rst		$38			; $2fdc: $ff
	nop					; $2fdd: $00
	rst		$38			; $2fde: $ff
	nop					; $2fdf: $00
	rst		$38			; $2fe0: $ff
	nop					; $2fe1: $00

data_2fe2:
	sbc		c			; $2fe2: $99
	nop					; $2fe3: $00
	sub		d			; $2fe4: $92
	nop					; $2fe5: $00
	sbc		c			; $2fe6: $99
	jr		nz, -$60			; $2fe7: $20 $a0
	jr		nz, -$5e			; $2fe9: $20 $a2
	nop					; $2feb: $00
	and		b			; $2fec: $a0
	nop					; $2fed: $00
	and		c			; $2fee: $a1
	and		b			; $2fef: $a0
	and		e			; $2ff0: $a3
	add		b			; $2ff1: $80
	and		c			; $2ff2: $a1
	add		b			; $2ff3: $80
	rst		$38			; $2ff4: $ff
	nop					; $2ff5: $00
	rst		$38			; $2ff6: $ff
	nop					; $2ff7: $00
	rst		$38			; $2ff8: $ff
	nop					; $2ff9: $00
	sub		c			; $2ffa: $91
	nop					; $2ffb: $00
	sub		d			; $2ffc: $92
	nop					; $2ffd: $00
	sub		c			; $2ffe: $91
	jr		nz, -$6c			; $2fff: $20 $94
	ld		h, b			; $3001: $60
	xor		c			; $3002: $a9
	ld		b, b			; $3003: $40
	sub		h			; $3004: $94
	ld		b, b			; $3005: $40
	rst		$38			; $3006: $ff
	nop					; $3007: $00
	rst		$38			; $3008: $ff
	nop					; $3009: $00
	rst		$38			; $300a: $ff
	nop					; $300b: $00
	rst		$38			; $300c: $ff
	nop					; $300d: $00
	rst		$38			; $300e: $ff
	nop					; $300f: $00
	rst		$38			; $3010: $ff
	nop					; $3011: $00

data_3012:
	rst		$38			; $3012: $ff
	nop					; $3013: $00
	sub		h			; $3014: $94
	jr		nz, -$67			; $3015: $20 $99
	jr		nz, -$6c			; $3017: $20 $94
	jr		nz, -$6a			; $3019: $20 $96
	nop					; $301b: $00
	sbc		d			; $301c: $9a
	nop					; $301d: $00
	sbc		e			; $301e: $9b
	nop					; $301f: $00
	sbc		h			; $3020: $9c
	nop					; $3021: $00
	sbc		e			; $3022: $9b
	jr		nz, -$63			; $3023: $20 $9d
	add		b			; $3025: $80
	sbc		(hl)			; $3026: $9e
	add		b			; $3027: $80
	sbc		l			; $3028: $9d
	and		b			; $3029: $a0
	rst		$38			; $302a: $ff
	nop					; $302b: $00
	sub		h			; $302c: $94
	jr		nz, -$6f			; $302d: $20 $91
	jr		nz, -$6c			; $302f: $20 $94
	jr		nz, -$6a			; $3031: $20 $96
	nop					; $3033: $00
	xor		b			; $3034: $a8
	jr		nz, -$6f			; $3035: $20 $91
	ld		b, b			; $3037: $40
	sub		d			; $3038: $92
	ld		b, b			; $3039: $40
	sub		c			; $303a: $91
	ld		h, b			; $303b: $60
	rst		$38			; $303c: $ff
	nop					; $303d: $00
	rst		$38			; $303e: $ff
	nop					; $303f: $00
	rst		$38			; $3040: $ff
	nop					; $3041: $00

data_3042:
	sbc		c			; $3042: $99
	nop					; $3043: $00
	sub		h			; $3044: $94
	nop					; $3045: $00
	rst		$38			; $3046: $ff
	nop					; $3047: $00
	sbc		d			; $3048: $9a
	jr		nz, -$6a			; $3049: $20 $96
	jr		nz, -$6c			; $304b: $20 $94
	nop					; $304d: $00
	sbc		e			; $304e: $9b
	nop					; $304f: $00
	sbc		h			; $3050: $9c
	nop					; $3051: $00
	sbc		e			; $3052: $9b
	jr		nz, -$63			; $3053: $20 $9d
	add		b			; $3055: $80
	sbc		(hl)			; $3056: $9e
	add		b			; $3057: $80
	sbc		l			; $3058: $9d
	and		b			; $3059: $a0
	sub		c			; $305a: $91
	nop					; $305b: $00
	sub		h			; $305c: $94
	nop					; $305d: $00
	rst		$38			; $305e: $ff
	nop					; $305f: $00
	xor		b			; $3060: $a8
	nop					; $3061: $00
	sub		(hl)			; $3062: $96
	jr		nz, -$6c			; $3063: $20 $94
	nop					; $3065: $00
	sub		c			; $3066: $91
	ld		b, b			; $3067: $40
	sub		d			; $3068: $92
	ld		b, b			; $3069: $40
	sub		c			; $306a: $91
	ld		h, b			; $306b: $60
	rst		$38			; $306c: $ff
	nop					; $306d: $00
	rst		$38			; $306e: $ff
	nop					; $306f: $00
	rst		$38			; $3070: $ff
	nop					; $3071: $00

data_3072:
	sbc		c			; $3072: $99
	nop					; $3073: $00
	sub		d			; $3074: $92
	nop					; $3075: $00
	sbc		c			; $3076: $99
	jr		nz, -$66			; $3077: $20 $9a
	jr		nz, -$5c			; $3079: $20 $a4
	nop					; $307b: $00
	and		b			; $307c: $a0
	nop					; $307d: $00
	sbc		e			; $307e: $9b
	nop					; $307f: $00
	and		b			; $3080: $a0
	nop					; $3081: $00
	and		c			; $3082: $a1
	add		b			; $3083: $80
	sbc		l			; $3084: $9d
	add		b			; $3085: $80
	and		c			; $3086: $a1
	add		b			; $3087: $80
	rst		$38			; $3088: $ff
	nop					; $3089: $00
	sub		c			; $308a: $91
	nop					; $308b: $00
	sub		d			; $308c: $92
	nop					; $308d: $00
	sub		c			; $308e: $91
	jr		nz, -$58			; $308f: $20 $a8
	nop					; $3091: $00
	sub		(hl)			; $3092: $96
	ld		h, b			; $3093: $60
	sub		h			; $3094: $94
	ld		b, b			; $3095: $40
	sub		c			; $3096: $91
	ld		b, b			; $3097: $40
	sub		h			; $3098: $94
	ld		b, b			; $3099: $40
	rst		$38			; $309a: $ff
	nop					; $309b: $00
	rst		$38			; $309c: $ff
	nop					; $309d: $00
	rst		$38			; $309e: $ff
	nop					; $309f: $00
	rst		$38			; $30a0: $ff
	nop					; $30a1: $00

data_30a2:
	sbc		c			; $30a2: $99
	nop					; $30a3: $00
	sub		d			; $30a4: $92
	nop					; $30a5: $00
	sbc		c			; $30a6: $99
	jr		nz, -$60			; $30a7: $20 $a0
	jr		nz, -$5c			; $30a9: $20 $a4
	jr		nz, -$66			; $30ab: $20 $9a
	nop					; $30ad: $00
	and		c			; $30ae: $a1
	and		b			; $30af: $a0
	and		b			; $30b0: $a0
	jr		nz, -$65			; $30b1: $20 $9b
	jr		nz, -$01			; $30b3: $20 $ff
	nop					; $30b5: $00
	and		c			; $30b6: $a1
	and		b			; $30b7: $a0
	sbc		l			; $30b8: $9d
	and		b			; $30b9: $a0
	sub		c			; $30ba: $91
	nop					; $30bb: $00
	sub		d			; $30bc: $92
	nop					; $30bd: $00
	sub		c			; $30be: $91
	jr		nz, -$6c			; $30bf: $20 $94
	ld		h, b			; $30c1: $60
	sub		(hl)			; $30c2: $96
	ld		b, b			; $30c3: $40
	xor		b			; $30c4: $a8
	jr		nz, -$01			; $30c5: $20 $ff
	nop					; $30c7: $00
	sub		h			; $30c8: $94
	ld		h, b			; $30c9: $60
	sub		c			; $30ca: $91
	ld		h, b			; $30cb: $60
	rst		$38			; $30cc: $ff
	nop					; $30cd: $00
	rst		$38			; $30ce: $ff
	nop					; $30cf: $00
	rst		$38			; $30d0: $ff
	nop					; $30d1: $00

data_30d2:
	sbc		c			; $30d2: $99
	nop					; $30d3: $00
	sub		d			; $30d4: $92
	nop					; $30d5: $00
	sbc		c			; $30d6: $99
	jr		nz, -$66			; $30d7: $20 $9a
	jr		nz, -$6d			; $30d9: $20 $93
	nop					; $30db: $00
	sbc		d			; $30dc: $9a
	nop					; $30dd: $00
	sbc		e			; $30de: $9b
	nop					; $30df: $00
	sbc		h			; $30e0: $9c
	nop					; $30e1: $00
	sbc		e			; $30e2: $9b
	jr		nz, -$63			; $30e3: $20 $9d
	add		b			; $30e5: $80
	sbc		(hl)			; $30e6: $9e
	add		b			; $30e7: $80
	sbc		l			; $30e8: $9d
	and		b			; $30e9: $a0
	sub		c			; $30ea: $91
	nop					; $30eb: $00
	sub		d			; $30ec: $92
	nop					; $30ed: $00
	sub		c			; $30ee: $91
	jr		nz, -$58			; $30ef: $20 $a8
	nop					; $30f1: $00
	sub		e			; $30f2: $93
	nop					; $30f3: $00
	xor		b			; $30f4: $a8
	jr		nz, -$6f			; $30f5: $20 $91
	ld		b, b			; $30f7: $40
	sub		d			; $30f8: $92
	ld		b, b			; $30f9: $40
	sub		c			; $30fa: $91
	ld		h, b			; $30fb: $60
	rst		$38			; $30fc: $ff
	nop					; $30fd: $00
	rst		$38			; $30fe: $ff
	nop					; $30ff: $00
	rst		$38			; $3100: $ff
	nop					; $3101: $00

data_3102:
	rst		$38			; $3102: $ff
	nop					; $3103: $00
	sub		h			; $3104: $94
	jr		nz, -$67			; $3105: $20 $99
	jr		nz, -$6c			; $3107: $20 $94
	jr		nz, -$59			; $3109: $20 $a7
	nop					; $310b: $00
	and		b			; $310c: $a0
	nop					; $310d: $00
	sbc		e			; $310e: $9b
	nop					; $310f: $00
	and		b			; $3110: $a0
	nop					; $3111: $00
	and		c			; $3112: $a1
	add		b			; $3113: $80
	sbc		l			; $3114: $9d
	add		b			; $3115: $80
	and		c			; $3116: $a1
	add		b			; $3117: $80
	rst		$38			; $3118: $ff
	nop					; $3119: $00
	rst		$38			; $311a: $ff
	nop					; $311b: $00
	sub		h			; $311c: $94
	jr		nz, -$6f			; $311d: $20 $91
	jr		nz, -$6c			; $311f: $20 $94
	jr		nz, -$68			; $3121: $20 $98
	nop					; $3123: $00
	sub		h			; $3124: $94
	ld		b, b			; $3125: $40
	sub		c			; $3126: $91
	ld		b, b			; $3127: $40
	sub		h			; $3128: $94
	ld		b, b			; $3129: $40
	rst		$38			; $312a: $ff
	nop					; $312b: $00
	rst		$38			; $312c: $ff
	nop					; $312d: $00
	rst		$38			; $312e: $ff
	nop					; $312f: $00
	rst		$38			; $3130: $ff
	nop					; $3131: $00

data_3132:
	sbc		c			; $3132: $99
	nop					; $3133: $00
	sub		h			; $3134: $94
	nop					; $3135: $00
	rst		$38			; $3136: $ff
	nop					; $3137: $00
	and		b			; $3138: $a0
	jr		nz, -$59			; $3139: $20 $a7
	jr		nz, -$6c			; $313b: $20 $94
	nop					; $313d: $00
	and		c			; $313e: $a1
	and		b			; $313f: $a0
	and		b			; $3140: $a0
	jr		nz, -$65			; $3141: $20 $9b
	jr		nz, -$01			; $3143: $20 $ff
	nop					; $3145: $00
	and		c			; $3146: $a1
	and		b			; $3147: $a0
	sbc		l			; $3148: $9d
	and		b			; $3149: $a0
	sub		c			; $314a: $91
	nop					; $314b: $00
	sub		h			; $314c: $94
	nop					; $314d: $00
	rst		$38			; $314e: $ff
	nop					; $314f: $00
	sub		h			; $3150: $94
	ld		h, b			; $3151: $60
	sbc		b			; $3152: $98
	jr		nz, -$6c			; $3153: $20 $94
	nop					; $3155: $00
	rst		$38			; $3156: $ff
	nop					; $3157: $00
	sub		h			; $3158: $94
	ld		h, b			; $3159: $60
	sub		c			; $315a: $91
	ld		h, b			; $315b: $60
	rst		$38			; $315c: $ff
	nop					; $315d: $00
	rst		$38			; $315e: $ff
	nop					; $315f: $00
	rst		$38			; $3160: $ff
	nop					; $3161: $00
