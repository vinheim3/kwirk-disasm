; disassembled by gbdisasm https://github.com/MegaLoler/gbdisasm
; written by megaloler/aardbei <megaloler9000@gmail.com>
; dissasembly of file "kwirk.gb"

.include "include/rominfo.s"
.include "include/macros.s"
.include "include/gfxDataMacros.s"
.include "include/musicMacros.s"
.include "include/constants.s"
.include "include/hram.s"
.include "include/wram.s"

.bank 0 slot 0
.org $0

; rst/interrupt vector tablema

; rst_jumpTable
	jp		rst_jumpTable_body


.org $30

;;
; @param	b		sound to play
; queues 2 sounds (1 music + 1 sound effect)
; if wNumSoundsToLoad = 0, store b in wNumSoundsToLoad+1
; if wNumSoundsToLoad = 1, store b in wNumSoundsToLoad+2
; inc wNumSoundsToLoad
; rst_playSound
	ld		hl, wNumSoundsToLoad
	ld		a, (hl)
	inc		a
	cp		$03
	ret		nc
	ld		(hl), a
	add		l
	ld		l, a
	ld		(hl), b
	ret


.org $40

; VBlank interrupt
	jp		vblankInterrupt


.org $48

; LCD interrupt
	reti


.org $50

; Timer interrupt
	reti


.org $58

; Serial interrupt
	jp		serialInterrupt


.org $60

; Joypad interrupt
	reti


.org $100

; cartridge header
; program entry
	nop
	jp		begin

.org $150

; end of cartridge header
begin:
	call		blankScreenDuringVBlankPeriod
	ld		sp, wStackTop
	call		copyOamDmaFunction
	ld		a, $ff
	call		fill1stBgMap

	; clear all wram
	ld		bc, $2000
	ld		hl, $c000
-
	xor		a
	ldi		(hl), a
	dec		bc
	ld		a, b
	or		c
	jr		nz, -

	ld		a, $9c			; $016b: $3e $9c
	ldh		(R_BGP), a		; $016d: $e0 $47
	ldh		(R_OBP0), a		; $016f: $e0 $48

	ld		a, $9c			; $0171: $3e $9c
	ldh		(R_OBP1), a		; $0173: $e0 $49

	ld		a, $09			; $0175: $3e $09
	ldh		(R_IE), a		; $0177: $e0 $ff
	ldh		(<hFF93), a		; $0179: $e0 $93

	ld		a, $01			; $017b: $3e $01
	ld		($cf3d), a		; $017d: $ea $3d $cf

	ld		a, $83			; $0180: $3e $83
	ldh		(R_LCDC), a		; $0182: $e0 $40

	ld		a, $0a			; $0184: $3e $0a
	ld		(wc37d), a		; $0186: $ea $7d $c3
	ld		(wc37e), a		; $0189: $ea $7e $c3
	ei					; $018c: $fb
func_018d:
	xor		a			; $018d: $af
	ld		(wcf49), a		; $018e: $ea $49 $cf
	ld		($cf3e), a		; $0191: $ea $3e $cf
	ld		(wcf3a), a		; $0194: $ea $3a $cf
	call		initSoundRegisters			; $0197: $cd $af $71
	ld		sp, wStackTop		; $019a: $31 $ff $dc
	xor		a			; $019d: $af
	ld		($ceff), a		; $019e: $ea $ff $ce
	ldh		(R_SB), a		; $01a1: $e0 $01
	ldh		(R_SC), a		; $01a3: $e0 $02
	ld		(wcf3c), a		; $01a5: $ea $3c $cf
	ld		(wcf39), a		; $01a8: $ea $39 $cf
	ld		(wGameMode), a		; $01ab: $ea $b8 $c2
	ld		($c378), a		; $01ae: $ea $78 $c3
	ld		($c379), a		; $01b1: $ea $79 $c3
	ld		(wcf01), a		; $01b4: $ea $01 $cf
	ld		(wcf02), a		; $01b7: $ea $02 $cf
	ld		(wcf46), a		; $01ba: $ea $46 $cf
	ld		a, $01			; $01bd: $3e $01
	ld		($cf3d), a		; $01bf: $ea $3d $cf
	call		clear1st100bytesOfWram			; $01c2: $cd $81 $1f
	call		func_01f9			; $01c5: $cd $f9 $01
	call		vramLoad_titleScreen_menu			; $01c8: $cd $07 $02
	jp		initTitleScreen			; $01cb: $c3 $bc $02

loadSelectGameScreen:
	call		resetSerialTransfer
	ld		sp, wStackTop
	call		vramLoad_mainGameTiles
	call		startSerialTransfer
	jp		gotoGameSelectMenu

loadLevelNormally:
	ld		a, $83			; $01dd: $3e $83
	ldh		(R_LCDC), a		; $01df: $e0 $40
loadLevelForDemoScenes:
	call		clear1st100bytesOfWram			; $01e1: $cd $81 $1f
	call		func_01f9			; $01e4: $cd $f9 $01
loadLevelFromRedo:
	call		loadAllLevelData			; $01e7: $cd $37 $09
	call		func_1a64			; $01ea: $cd $64 $1a
	call		vramLoad_mainGameTiles			; $01ed: $cd $51 $02
	call		loadInGameMenu			; $01f0: $cd $c4 $1b
	call		func_1be0			; $01f3: $cd $e0 $1b
	call		func_0eb6			; $01f6: $cd $b6 $0e
func_01f9:
	xor		a			; $01f9: $af
	ld		bc, ROOM_WIDTH*ROOM_HEIGHT		; $01fa: $01 $68 $01
	ld		hl, wRoomObjects		; $01fd: $21 $00 $c1
	; clear room objects
	call		setA_bcTimesToHl			; $0200: $cd $27 $2c
	call		func_1b8d			; $0203: $cd $8d $1b
	ret					; $0206: $c9

vramLoad_titleScreen_menu:
	call		blankScreenDuringVBlankPeriod
	call		vramLoad_ascii_logo

	ld		hl, gfx_heart
	ld		de, VRAM_BLOCK1+$500
	ld		bc, $0010
	call		copyMemoryBc

	ld		hl, gfx_brick
	ld		de, VRAM_BLOCK1+$4f0
	ld		bc, $0010
	call		copyMemoryBc

	ld		hl, gfx_kwirk_logo
	ld		de, VRAM_BLOCK1
	ld		bc, $0400
	call		copyMemoryBc

	; and gfx_medium_kwirks
	ld		hl, gfx_big_kwirk_pipe
	ld		de, VRAM_BLOCK0+$400
	ld		bc, $0400
	call		copyMemoryBc

	jr		vramLoad_bottomHalfOfLogo_bigKwirk

turnOnSpriteBgWindowDisplays:
	; lcd, sprite and bg operational
	ld		a, $83
	ldh		(R_LCDC), a
	ret

vramLoad_ascii_logo:
	ld		hl, gfx_ascii
	ld		de, VRAM_BLOCK2
	ld		bc, $0400
	call		copyMemoryBc_0AfterEachByte
	ret

vramLoad_mainGameTiles:
	call		blankScreenDuringVBlankPeriod

	; and medium_kwirks and sprites
	ld		hl, gfx_big_kwirk_pipe
	ld		de, VRAM_BLOCK0+$200
	ld		bc, $0c00
	call		copyMemoryBc

	ld		hl, gfx_logo_borders
	ld		de, VRAM_BLOCK1+$600
	ld		bc, $0100
	call		copyMemoryBc_0AfterEachByte

	ld		hl, gfx_lines
	ld		de, VRAM_BLOCK1+$6a0
	ld		bc, $0058
	call		copyMemoryBc_0BeforeEachByte

	jr		vramLoad_bigKwirkAndPipes

vramLoad_mostGraphicsForLevelClearScreen:
	call		blankScreenDuringVBlankPeriod

	ld		hl, gfx_kwirk_logo
	ld		de, VRAM_BLOCK0
	ld		bc, $1000
	call		copyMemoryBc

vramLoad_bottomHalfOfLogo_bigKwirk:
	ld		hl, gfx_logo_borders
	ld		de, VRAM_BLOCK1+$600
	ld		bc, $0078
	call		copyMemoryBc_0AfterEachByte

vramLoad_bigKwirkAndPipes:
	ld		hl, gfx_big_kwirk_pipe
	ld		de, VRAM_BLOCK2+$600
	ld		bc, $0200
	call		copyMemoryBc

	jp		turnOnSpriteBgWindowDisplays

;;
; for 2-tone tiles, each byte using colours %00 or %10
copyMemoryBc_0AfterEachByte:
	ldi		a, (hl)
	ld		(de), a
	inc		de
	xor		a
	ld		(de), a
	inc		de
	dec		bc
	ld		a, b
	or		c
	jr		nz, copyMemoryBc_0AfterEachByte
	ret

;;
; for 2-tone tiles, each byte using colours %00 or 01
copyMemoryBc_0BeforeEachByte:
	xor		a
	ld		(de), a
	inc		de
	ldi		a, (hl)
	ld		(de), a
	inc		de
	dec		bc
	ld		a, b
	or		c
	jr		nz, copyMemoryBc_0BeforeEachByte
	ret

initTitleScreen:
	xor		a			; $02bc: $af
	ld		(wIsDemoScenes), a		; $02bd: $ea $43 $cf
	ld		($c2ed), a		; $02c0: $ea $ed $c2
	ld		(wcf48), a		; $02c3: $ea $48 $cf
	ld		a, $0a			; $02c6: $3e $0a
	ld		(wNumberOfRandomRoomsForDifficulty), a		; $02c8: $ea $b9 $c2
	ld		(wc2ba), a		; $02cb: $ea $ba $c2
	ld		b, MUS_TITLESCREEN			; $02ce: $06 $05
	rst_playSound
	call		blankScreenDuringVBlankPeriod			; $02d1: $cd $07 $2c
	ld		a, $cf			; $02d4: $3e $cf
	call		fill1stBgMap			; $02d6: $cd $38 $2c

	; clear bg room tiles
	ld		hl, $9800		; $02d9: $21 $00 $98
	ldbc ROOM_WIDTH, ROOM_HEIGHT		; $02dc: $01 $12 $14
-
	ld		a, $ff			; $02df: $3e $ff
	ldi		(hl), a			; $02e1: $22
	dec		b			; $02e2: $05
	jr		nz, -			; $02e3: $20 $fa
	ld		b, $14			; $02e5: $06 $14
	ld		de, $000c		; $02e7: $11 $0c $00
	add		hl, de			; $02ea: $19
	dec		c			; $02eb: $0d
	jr		nz, -			; $02ec: $20 $f1

	ld		a, $ff			; $02ee: $3e $ff
	ldh		(<hKeysPressed), a		; $02f0: $e0 $8b
	ldh		(<hNewKeysPressed), a		; $02f2: $e0 $8c
	call		enableLCD			; $02f4: $cd $20 $2c

	; Kwirk Logo
	ld		hl, $9843		; $02f7: $21 $43 $98
	ld		de, kwirkLogoLayoutData		; $02fa: $11 $a7 $3f
	call		loadBGTileMapData			; $02fd: $cd $d4 $3a
	; The following 2 here because $aa and $bb are codes used in tile loading
	call		waitUntilHBlankJustStarted			; $0300: $cd $74 $1f
	ld		a, $aa			; $0303: $3e $aa
	ld		($986d), a		; $0305: $ea $6d $98
	call		waitUntilHBlankJustStarted			; $0308: $cd $74 $1f
	ld		a, $bb			; $030b: $3e $bb
	ld		($988e), a		; $030d: $ea $8e $98

	ld		hl, $9901		; $0310: $21 $01 $99
	ld		de, pushStartButtonLayoutData		; $0313: $11 $d3 $3f
	call		loadBGTileMapData			; $0316: $cd $d4 $3a

	ld		hl, $9a02		; $0319: $21 $02 $9a
	ld		de, atlusLtdLayoutData		; $031c: $11 $e5 $3f
	call		loadBGTileMapData			; $031f: $cd $d4 $3a

	ld		hl, $9964		; $0322: $21 $64 $99
	ld		de, licensedByNintendoLayoutData		; $0325: $11 $f1 $3f
	call		loadBGTileMapData			; $0328: $cd $d4 $3a

	ld		hl, $9984		; $032b: $21 $84 $99
	ld		de, acclaimLogoLayoutData		; $032e: $11 $fe $3f
	call		loadBGTileMapData			; $0331: $cd $d4 $3a

	ld		hl, $99e2		; $0334: $21 $e2 $99
	ld		de, acclaimEntRowLayoutData		; $0337: $11 $14 $40
	call		loadBGTileMapData			; $033a: $cd $d4 $3a

	xor		a			; $033d: $af
	ld		($c381), a		; $033e: $ea $81 $c3
	ld		a, $01			; $0341: $3e $01
	ld		(wcf3a), a		; $0343: $ea $3a $cf
	call		serialTransferByte9f_copy			; $0346: $cd $b1 $03
-
	ld		a, ($c2ed)		; $0349: $fa $ed $c2
	cp		$17			; $034c: $fe $17
	jp		z, loadDemoScenes		; $034e: $ca $1e $70
func_0351:
	ld		a, (wIsDemoScenes)		; $0351: $fa $43 $cf
	and		a			; $0354: $a7
	jp		nz, initTitleScreen		; $0355: $c2 $bc $02
	ld		a, (wcf42)		; $0358: $fa $42 $cf
	and		a			; $035b: $a7
	jr		nz, func_0382			; $035c: $20 $24
	call		func_381c			; $035e: $cd $1c $38
	ld		a, ($c381)		; $0361: $fa $81 $c3
	cpl					; $0364: $2f
	ld		($c381), a		; $0365: $ea $81 $c3
	call		pollInput			; $0368: $cd $45 $2b
	ldh		a, (<hNewKeysPressed)		; $036b: $f0 $8c
	bit		BTN_BIT_START, a			; $036d: $cb $5f
	jr		z, -			; $036f: $28 $d8
	jr		initGameLoadSelectGameScreen			; $0371: $18 $14

clearScreenAndBGMap:
	call		enableLCD
	call		blankScreenDuringVBlankPeriod
	ld		a, $ff
	call		fill1stBgMap
	call		enableLCD
	ret

func_0382:
	ld		a, GAMEMODE_VS_MODE			; $0382: $3e $02
	ld		(wGameMode), a		; $0384: $ea $b8 $c2
initGameLoadSelectGameScreen:
	call		clear1st100bytesOfWram
	call		clearScreenAndBGMap
	jp		loadSelectGameScreen

func_0390:
	xor		a			; $0390: $af
	ld		(wcf3a), a		; $0391: $ea $3a $cf
	ld		a, (wcf3c)		; $0394: $fa $3c $cf
	and		a			; $0397: $a7
	jr		z, func_03a6			; $0398: $28 $0c
	call		func_381c			; $039a: $cd $1c $38
	ld		a, $04			; $039d: $3e $04
	ld		(wcf3a), a		; $039f: $ea $3a $cf
	call		func_3512			; $03a2: $cd $12 $35
	ret					; $03a5: $c9
func_03a6:
	ld		a, $04			; $03a6: $3e $04
	ld		(wcf3a), a		; $03a8: $ea $3a $cf
	ld		a, $ee			; $03ab: $3e $ee
	call		func_3507			; $03ad: $cd $07 $35
	ret					; $03b0: $c9


serialTransferByte9f_copy:
	ld		hl, SC		; $03b1: $21 $02 $ff
	res		7, (hl)			; $03b4: $cb $be
	ld		a, $9f			; $03b6: $3e $9f
	ldh		(R_SB), a		; $03b8: $e0 $01
	res		0, (hl)			; $03ba: $cb $86
	set		7, (hl)			; $03bc: $cb $fe
	ret					; $03be: $c9

func_03bf:
	ld		a, (wcf3c)		; $03bf: $fa $3c $cf
	and		a			; $03c2: $a7
	ret		z			; $03c3: $c8
	ld		a, $01			; $03c4: $3e $01
	ldh		(R_IE), a		; $03c6: $e0 $ff
	xor		a			; $03c8: $af
	ld		(wcf3a), a		; $03c9: $ea $3a $cf
	call		func_381c			; $03cc: $cd $1c $38
	ld		a, $09			; $03cf: $3e $09
	ldh		(R_IE), a		; $03d1: $e0 $ff
	ret					; $03d3: $c9

func_03d4:
	ld		a, GAMEMODE_VS_MODE			; $03d4: $3e $02
	ld		(wGameMode), a		; $03d6: $ea $b8 $c2
	jp		difficultyOptionsScreen			; $03d9: $c3 $bc $04

func_03dc:
	call		doALoop6000Times			; $03dc: $cd $d9 $06
	call		serialTransferByte9f			; $03df: $cd $f0 $03
	xor		a			; $03e2: $af
	ld		(wc375), a		; $03e3: $ea $75 $c3
	ld		(wcf42), a		; $03e6: $ea $42 $cf
	ld		a, $01			; $03e9: $3e $01
	ld		(wcf3c), a		; $03eb: $ea $3c $cf
	jr		gameSelectMenu			; $03ee: $18 $1d

serialTransferByte9f:
	ld		hl, SC
	res		7, (hl)
	ld		a, $9f
	ldh		(R_SB), a
	res		0, (hl)
	set		7, (hl)
	ret

gotoGameSelectMenu:
	ld		b, MUS_LEVEL_SELECT_MENU			; $03fe: $06 $03
	rst_playSound
	ld		a, (wc37d)		; $0401: $fa $7d $c3
	ld		(wNumberOfRandomRoomsForDifficulty), a		; $0404: $ea $b9 $c2
	ld		a, (wc37e)		; $0407: $fa $7e $c3
	ld		(wc2ba), a		; $040a: $ea $ba $c2

gameSelectMenu:
	; $ee set to $cf2d - $c310
	ld		a, $ee			; $040d: $3e $ee
	ld		b, $14			; $040f: $06 $14
	ld		hl, $c2fd		; $0411: $21 $fd $c2
-
	ldi		(hl), a			; $0414: $22
	dec		b			; $0415: $05
	jr		nz, -			; $0416: $20 $fc

-
	call		serialTransferByte9f			; $0418: $cd $f0 $03
	call		clear1st100bytesOfWram			; $041b: $cd $81 $1f
	ld		a, $01			; $041e: $3e $01
	ld		(wcf3a), a		; $0420: $ea $3a $cf
	ld		($cf3d), a		; $0423: $ea $3d $cf
	xor		a			; $0426: $af
	ld		(wcf48), a		; $0427: $ea $48 $cf
	ld		($c2bd), a		; $042a: $ea $bd $c2
	ld		($c378), a		; $042d: $ea $78 $c3
	ld		($c379), a		; $0430: $ea $79 $c3
	ld		(wcf39), a		; $0433: $ea $39 $cf
	ld		a, (wcf42)		; $0436: $fa $42 $cf
	and		a			; $0439: $a7
	jp		nz, difficultyOptionsScreen		; $043a: $c2 $bc $04
	call		doALoop6000Times			; $043d: $cd $d9 $06

	ld		de, gameOptionsLayoutData
	ld		hl, $9904
	call		loadLevelSelectTiles_andLayoutData

	; cursor pointer details
	ld		hl, $9944		; $0449: $21 $44 $99
	ld		de, $0040		; $044c: $11 $40 $00
	ld		bc, $0002		; $044f: $01 $02 $00
	ld		a, $02			; $0452: $3e $02
	ld		($cf13), a		; $0454: $ea $13 $cf
	ld		a, $ab			; $0457: $3e $ab
	call		loadCursorData			; $0459: $cd $9b $2c

	ld		a, $01			; $045c: $3e $01
	ld		(wcf3a), a		; $045e: $ea $3a $cf
	ld		a, (wMenuOptionSelected)		; $0461: $fa $19 $cf
	cp		$f0			; $0464: $fe $f0
	jp		z, func_03d4		; $0466: $ca $d4 $03
	cp		$ff			; $0469: $fe $ff
	jr		z, -			; $046b: $28 $ab

	ld		(wGameMode), a		; $046d: $ea $b8 $c2
	cp		GAMEMODE_VS_MODE			; $0470: $fe $02
	jr		nz, gotoDifficultyOptionsScreen			; $0472: $20 $37
	ld		hl, SC		; $0474: $21 $02 $ff
	res		7, (hl)			; $0477: $cb $be
	ld		a, $9f			; $0479: $3e $9f
	ldh		(R_SB), a		; $047b: $e0 $01
	res		0, (hl)			; $047d: $cb $86
	set		7, (hl)			; $047f: $cb $fe
	di					; $0481: $f3
	ld		a, $66			; $0482: $3e $66
	ld		(wc375), a		; $0484: $ea $75 $c3
	ld		hl, SC		; $0487: $21 $02 $ff
	res		7, (hl)			; $048a: $cb $be
	ei					; $048c: $fb
	call		func_3283			; $048d: $cd $83 $32
	ld		a, (wcf39)		; $0490: $fa $39 $cf
	and		a			; $0493: $a7
	jp		z, func_03dc		; $0494: $ca $dc $03
	ld		a, $01			; $0497: $3e $01
	ld		(wcf3c), a		; $0499: $ea $3c $cf
	ld		(wcf48), a		; $049c: $ea $48 $cf
	call		func_3512			; $049f: $cd $12 $35
	ld		a, (wcf05)		; $04a2: $fa $05 $cf
	and		a			; $04a5: $a7
	jp		nz, func_03dc		; $04a6: $c2 $dc $03
	jr		difficultyOptionsScreen			; $04a9: $18 $11

gotoDifficultyOptionsScreen:
	xor		a			; $04ab: $af
	ld		($cf3d), a		; $04ac: $ea $3d $cf
	ld		a, $01			; $04af: $3e $01
	ld		(wcf3c), a		; $04b1: $ea $3c $cf
	ld		hl, SC		; $04b4: $21 $02 $ff
	res		7, (hl)			; $04b7: $cb $be
	xor		a			; $04b9: $af
	ldh		(R_SB), a		; $04ba: $e0 $01

difficultyOptionsScreen:
	call		func_03bf			; $04bc: $cd $bf $03
	call		clear1st100bytesOfWram			; $04bf: $cd $81 $1f
	xor		a			; $04c2: $af
	ld		(wcf3a), a		; $04c3: $ea $3a $cf
	ld		($cf3e), a		; $04c6: $ea $3e $cf
	ld		(wcf42), a		; $04c9: $ea $42 $cf
	ld		(wc2bb), a		; $04cc: $ea $bb $c2
	ld		(wc2bc), a		; $04cf: $ea $bc $c2
	ld		de, difficultyOptionsLayoutData		; $04d2: $11 $a5 $07
	ld		hl, $9902		; $04d5: $21 $02 $99
	call		loadLevelSelectTiles_andLayoutData			; $04d8: $cd $ce $06
	ld		hl, $9942		; $04db: $21 $42 $99
	ld		de, $0040		; $04de: $11 $40 $00
	ld		b, $00			; $04e1: $06 $00
	ld		c, $02			; $04e3: $0e $02
	ld		a, $02			; $04e5: $3e $02
	ld		($cf13), a		; $04e7: $ea $13 $cf
	ld		a, $ab			; $04ea: $3e $ab
	call		loadCursorData			; $04ec: $cd $9b $2c
	ld		a, (wMenuOptionSelected)		; $04ef: $fa $19 $cf
	cp		$ff			; $04f2: $fe $ff
	jp		z, func_03dc		; $04f4: $ca $dc $03
	ld		(wDifficulty), a		; $04f7: $ea $c0 $c2
	ld		a, (wGameMode)		; $04fa: $fa $b8 $c2
	cp		GAMEMODE_GOING_UP			; $04fd: $fe $00
	jp		z, floorOptionsScreen		; $04ff: $ca $05 $05
	jp		func_059a			; $0502: $c3 $9a $05


floorOptionsScreen:
	call		func_03bf			; $0505: $cd $bf $03
	ld		a, $01			; $0508: $3e $01
	ld		(wcf3c), a		; $050a: $ea $3c $cf
	call		doALoop6000Times			; $050d: $cd $d9 $06
	ld		de, floorOptionsLayoutData		; $0510: $11 $e4 $07
	ld		hl, $9903		; $0513: $21 $03 $99
	call		loadLevelSelectTiles_andLayoutData			; $0516: $cd $ce $06

	; cursor details
	ld		hl, $9943		; $0519: $21 $43 $99
	ld		de, $0720		; $051c: $11 $20 $07
	ld		b, $01			; $051f: $06 $01
	ld		c, $04			; $0521: $0e $04
	ld		a, $04			; $0523: $3e $04
	ld		($cf13), a		; $0525: $ea $13 $cf
	ld		a, $ab			; $0528: $3e $ab
	call		loadCursorData			; $052a: $cd $9b $2c

	ld		a, (wMenuOptionSelected)		; $052d: $fa $19 $cf
	cp		$ff			; $0530: $fe $ff
	jr		z, difficultyOptionsScreen			; $0532: $28 $88

	push		af
	ld		a, (wDifficulty)
	ld		hl, 10
	call		hlTimesEqualsA
	pop		af
	add		l
	ld		(wRoomIndex), a

displayViewOptionsScreen:
	call		func_03bf			; $0543: $cd $bf $03
	ld		a, (wNumberOfRandomRoomsForDifficulty)		; $0546: $fa $b9 $c2
	ld		(wc37d), a		; $0549: $ea $7d $c3
	ld		a, (wc2ba)		; $054c: $fa $ba $c2
	ld		(wc37e), a		; $054f: $ea $7e $c3
	call		doALoop6000Times			; $0552: $cd $d9 $06

	ld		de, displayViewOptionsLayoutData		; $0555: $11 $73 $07
	ld		hl, $9902		; $0558: $21 $02 $99
	call		loadLevelSelectTiles_andLayoutData			; $055b: $cd $ce $06

	; cursor details
	ld		hl, $9942		; $055e: $21 $42 $99
	ld		de, $0040		; $0561: $11 $40 $00
	ld		b, $00			; $0564: $06 $00
	ld		c, $01			; $0566: $0e $01
	ld		a, $01			; $0568: $3e $01
	ld		($cf13), a		; $056a: $ea $13 $cf
	ld		a, $ab			; $056d: $3e $ab
	call		loadCursorData			; $056f: $cd $9b $2c

	xor		a			; $0572: $af
	ld		(wcf3a), a		; $0573: $ea $3a $cf
	ld		(wIsDiagonalView), a		; $0576: $ea $be $c2

	ld		a, (wMenuOptionSelected)		; $0579: $fa $19 $cf
	cp		$ff			; $057c: $fe $ff
	jp		z, @pressedBack		; $057e: $ca $8c $05
	and		a			; $0581: $a7
	jp		nz, func_05ef		; $0582: $c2 $ef $05
	inc		a			; $0585: $3c
	ld		(wIsDiagonalView), a		; $0586: $ea $be $c2
	jp		func_05ef			; $0589: $c3 $ef $05

@pressedBack:
	ld		a, (wGameMode)		; $058c: $fa $b8 $c2
	and		a			; $058f: $a7
	jp		z, floorOptionsScreen		; $0590: $ca $05 $05
	cp		$01			; $0593: $fe $01
	jr		z, func_059a			; $0595: $28 $03
	jp		contestOptionsScreen			; $0597: $c3 $b4 $05

func_059a:
	call		func_03bf			; $059a: $cd $bf $03
	xor		a			; $059d: $af
	ld		(wcf3a), a		; $059e: $ea $3a $cf
	call		func_3ba5			; $05a1: $cd $a5 $3b
	ld		a, (wMenuOptionSelected)		; $05a4: $fa $19 $cf
	cp		$ff			; $05a7: $fe $ff
	jp		z, difficultyOptionsScreen		; $05a9: $ca $bc $04
	ld		a, (wGameMode)		; $05ac: $fa $b8 $c2
	cp		GAMEMODE_HEADING_OUT			; $05af: $fe $01
	jp		z, displayViewOptionsScreen		; $05b1: $ca $43 $05

contestOptionsScreen:
	call		func_03bf			; $05b4: $cd $bf $03
	call		doALoop6000Times			; $05b7: $cd $d9 $06
	ld		de, contestOptionsLayoutData		; $05ba: $11 $39 $08
	ld		hl, $9903		; $05bd: $21 $03 $99
	call		loadLevelSelectTiles_andLayoutData			; $05c0: $cd $ce $06

	ld		hl, $9943		; $05c3: $21 $43 $99
	ld		de, $0020		; $05c6: $11 $20 $00
	ld		b, $00			; $05c9: $06 $00
	ld		c, $04			; $05cb: $0e $04
	ld		a, $04			; $05cd: $3e $04
	ld		($cf13), a		; $05cf: $ea $13 $cf
	ld		a, $ab			; $05d2: $3e $ab
	call		loadCursorData			; $05d4: $cd $9b $2c

	ld		a, (wMenuOptionSelected)		; $05d7: $fa $19 $cf
	cp		$ff			; $05da: $fe $ff
	jp		z, func_059a		; $05dc: $ca $9a $05
	sla		a			; $05df: $cb $27
	inc		a			; $05e1: $3c
	ld		($c2bd), a		; $05e2: $ea $bd $c2
	xor		a			; $05e5: $af
	ld		($c378), a		; $05e6: $ea $78 $c3
	ld		($c379), a		; $05e9: $ea $79 $c3
	jp		displayViewOptionsScreen			; $05ec: $c3 $43 $05
func_05ef:
	xor		a			; $05ef: $af
	ld		(wcf3a), a		; $05f0: $ea $3a $cf
	ld		($cf45), a		; $05f3: $ea $45 $cf
	ld		a, (wGameMode)		; $05f6: $fa $b8 $c2
	cp		GAMEMODE_HEADING_OUT			; $05f9: $fe $01
	jr		nz, func_0606			; $05fb: $20 $09
	ldh		a, (<hKeysPressed)		; $05fd: $f0 $8b
	and		BTN_SELECT|BTN_LEFT			; $05ff: $e6 $24
	cp		BTN_SELECT|BTN_LEFT			; $0601: $fe $24
	call		z, populateListOfRandomLevelsBasedOnDifficulty		; $0603: $cc $a9 $3e
func_0606:
	xor		a			; $0606: $af
	ld		(wcf42), a		; $0607: $ea $42 $cf
	cpl					; $060a: $2f
	ld		($cf44), a		; $060b: $ea $44 $cf
	ld		a, (wcf3c)		; $060e: $fa $3c $cf
	and		a			; $0611: $a7
	jr		z, +			; $0612: $28 $03
	call		func_381c			; $0614: $cd $1c $38
+
	call		func_03bf			; $0617: $cd $bf $03
	call		func_3d1d			; $061a: $cd $1d $3d
	xor		a			; $061d: $af
	ld		(wcf3a), a		; $061e: $ea $3a $cf
	ld		a, (wMenuOptionSelected)		; $0621: $fa $19 $cf
	cp		$ff			; $0624: $fe $ff
	jp		z, displayViewOptionsScreen		; $0626: $ca $43 $05
	and		a			; $0629: $a7
	jp		nz, returnToGameScreen		; $062a: $c2 $67 $15
	xor		a			; $062d: $af
	ld		($cf44), a		; $062e: $ea $44 $cf
	ld		hl, $c0ec		; $0631: $21 $ec $c0
	ld		bc, $0190		; $0634: $01 $90 $01
	ld		a, $00			; $0637: $3e $00
	call		setA_bcTimesToHl			; $0639: $cd $27 $2c
	ld		a, (wGameMode)		; $063c: $fa $b8 $c2
	and		a			; $063f: $a7
	jr		z, func_066e			; $0640: $28 $2c
	ld		a, ($cf45)		; $0642: $fa $45 $cf
	and		a			; $0645: $a7
	jr		nz, func_066e			; $0646: $20 $26
	ld		a, ($c2ec)		; $0648: $fa $ec $c2
	ld		(wc377), a		; $064b: $ea $77 $c3
	ld		a, (wGameMode)		; $064e: $fa $b8 $c2
	cp		GAMEMODE_VS_MODE			; $0651: $fe $02
	call		z, func_0390		; $0653: $cc $90 $03
	ld		a, (wGameMode)		; $0656: $fa $b8 $c2
	cp		GAMEMODE_HEADING_OUT			; $0659: $fe $01
	jr		nz, +			; $065b: $20 $03
	ld		(wcf3c), a		; $065d: $ea $3c $cf
+
	call		setFFtoAllListOfRandomRooms			; $0660: $cd $e6 $06
	ld		a, $ff			; $0663: $3e $ff
	ld		(wCurrentLevelIdxInListOfRandomLevels), a		; $0665: $ea $74 $c3
	call		func_31e7			; $0668: $cd $e7 $31
	call		getNextRoomIndexForScrollingLevel			; $066b: $cd $74 $06
func_066e:
	call		func_1aff			; $066e: $cd $ff $1a
	jp		loadLevelNormally			; $0671: $c3 $dd $01


getNextRoomIndexForScrollingLevel:
	ld		a, (wIsDemoScenes)
	and		a
	jr		nz, @getDemoSceneRooms

	; call for non-demo scrolling rooms
	call		getNextRoomIndexListOfRandomLevels
	
@getRandomRoomsTableIdxFromRoomIndex:
	call		getScrollingLevel1stRoomIdxAndRangeOfRoomsBasedOnDifficulty
	ld		b, a
	ld		a, (wRoomIndex)
	add		b
	ld		(wRoomIndex), a
	ret
	
@getDemoSceneRooms:
	ld		hl, demoSceneRooms
	ld		a, (wCurrentDemoSceneRoomIdx)
	call		addAToHl
	ld		a, (hl)
	ld		(wRoomIndex), a
	xor		a
	ld		(wDifficulty), a
	ld		a, (wCurrentDemoSceneRoomIdx)
	inc		a
	ld		(wCurrentDemoSceneRoomIdx), a
	xor		a
	ld		(wRandomRoomIsFlippedVertically), a
	jr		@getRandomRoomsTableIdxFromRoomIndex
	
loadLevelSelectTiles:
	call		blankScreenDuringVBlankPeriod
	; Bricks in background
	ld		a, $cf
	call		fill1stBgMap
	call		enableLCD

	ld		hl, $98c0
	ld		de, $140b
	call		loadPipesAndBlankTilesInside

	ld		hl, $9807
	ld		de, $0607
	call		loadPipesAndBlankTilesInside

	ld		hl, $9828
	ld		de, bigKwirkLayoutData
	call		loadBGTileMapData
	ret
	
loadLevelSelectTiles_andLayoutData:
	push		hl
	push		de
	call		loadLevelSelectTiles
	pop		de
	pop		hl
	call		loadBGTileMapData
	ret
	
doALoop6000Times:
	push		bc
	push		af
	ld		bc, $6000
-
	dec		bc
	ld		a, b
	or		c
	jr		nz, -
	pop		af
	pop		bc
	ret

setFFtoAllListOfRandomRooms:
	ld		hl, wListOfRandomLevels
	ld		bc, 30
	ld		a, $ff
	call		setA_bcTimesToHl
	ret

getNextRoomIndexListOfRandomLevels:
	ld		a, (wCurrentLevelIdxInListOfRandomLevels)
	inc		a
	ld		(wCurrentLevelIdxInListOfRandomLevels), a

	ld		e, a
	ld		d, $00
	ld		hl, wListOfRandomLevels
	add		hl, de
	ld		a, (hl)
	ld		(wRoomIndex), a
	xor		a
	ld		(wRandomRoomIsFlippedVertically), a
	call		getNextRandomNumber
	and		$01
	ld		(wRandomRoomIsFlippedVertically), a
	ret

levelSetCleared:
	call		drawLevelClearScreen
	ld		hl, BG_MAP1+$86
	ld		a, (wDifficulty)
	cp		DIFFICULTY_HARD
	jr		z, @hardDifficultyCleared
	ld		de, awesomeLevelClearedLayoutData
	call		loadBGTileMapData

	ld		a, (wDifficulty)
	inc		a
	ld		(wDifficulty), a
	or		$f0
	ld		hl, BG_MAP1+$cd
	call		drawDigitAtHl
	ret
@hardDifficultyCleared:
	ld		hl, BG_MAP1+$85
	ld		de, excellentLayoutData
	call		loadBGTileMapData
	xor		a
	ld		(wDifficulty), a
	ret
	
.include "layouts/group1.s"

.include "code/levelLoading.s"

func_0eb6:
	call		initSoundRegisters			; $0eb6: $cd $af $71
	call		func_7000			; $0eb9: $cd $00 $70
	xor		a			; $0ebc: $af
	ld		($cf47), a		; $0ebd: $ea $47 $cf
	ld		a, (wGameMode)		; $0ec0: $fa $b8 $c2
	and		a			; $0ec3: $a7
	jr		z, +			; $0ec4: $28 $24
	ld		a, $f0			; $0ec6: $3e $f0
	ld		($c1b3), a		; $0ec8: $ea $b3 $c1
	ld		a, (wNumberOfRandomRoomsForDifficulty)		; $0ecb: $fa $b9 $c2
	call		get2DigitsToDrawFromNonBCD_A			; $0ece: $cd $12 $21
	ld		hl, $9a03		; $0ed1: $21 $03 $9a
	call		draw2DigitsAtHl			; $0ed4: $cd $5d $20
	ld		a, (wGameMode)		; $0ed7: $fa $b8 $c2
	cp		GAMEMODE_VS_MODE			; $0eda: $fe $02
	jr		nz, +			; $0edc: $20 $0c
	ld		a, (wc2ba)		; $0ede: $fa $ba $c2
	call		get2DigitsToDrawFromNonBCD_A			; $0ee1: $cd $12 $21
	ld		hl, $9823		; $0ee4: $21 $23 $98
	call		draw2DigitsAtHl			; $0ee7: $cd $5d $20
+
	ld		a, (wGameMode)		; $0eea: $fa $b8 $c2
	cp		GAMEMODE_VS_MODE			; $0eed: $fe $02
	jr		nz, ++			; $0eef: $20 $17
	ld		a, (wcf3c)		; $0ef1: $fa $3c $cf
	and		a			; $0ef4: $a7
	jr		nz, +			; $0ef5: $20 $0c
	ld		a, (wc2bb)		; $0ef7: $fa $bb $c2
	ldh		(R_SB), a		; $0efa: $e0 $01
	ld		hl, SC		; $0efc: $21 $02 $ff
	res		0, (hl)			; $0eff: $cb $86
	set		7, (hl)			; $0f01: $cb $fe
+
	ld		a, $08			; $0f03: $3e $08
	ld		(wcf3a), a		; $0f05: $ea $3a $cf
++
	call		func_15f7			; $0f08: $cd $f7 $15
	call		func_1445			; $0f0b: $cd $45 $14
	ld		a, (wGameMode)		; $0f0e: $fa $b8 $c2
	and		a			; $0f11: $a7
	jr		nz, func_0f19			; $0f12: $20 $05
	ld		b, SND_01			; $0f14: $06 $01
	rst_playSound
	jr		func_0f38			; $0f17: $18 $1f
func_0f19:
	ld		b, SND_02			; $0f19: $06 $02
	rst_playSound
	xor		a			; $0f1c: $af
	ld		(wcf01), a		; $0f1d: $ea $01 $cf
	call		func_1dd9			; $0f20: $cd $d9 $1d
	ld		b, $65			; $0f23: $06 $65
-
	call		waitUntilVBlankHandled_andXorCf39			; $0f25: $cd $d2 $0f
	dec		b			; $0f28: $05
	jr		nz, -			; $0f29: $20 $fa
	xor		a			; $0f2b: $af
	ld		($c2ec), a		; $0f2c: $ea $ec $c2
	ld		($c2ee), a		; $0f2f: $ea $ee $c2
	ld		($c2ed), a		; $0f32: $ea $ed $c2
	ld		($c2ef), a		; $0f35: $ea $ef $c2
func_0f38:
	call		func_1400			; $0f38: $cd $00 $14
func_0f3b:
	xor		a			; $0f3b: $af
	ld		($ceff), a		; $0f3c: $ea $ff $ce
	ld		a, (wGameMode)		; $0f3f: $fa $b8 $c2
	and		a			; $0f42: $a7
	jr		z, ++			; $0f43: $28 $14
	cp		GAMEMODE_VS_MODE			; $0f45: $fe $02
	jr		nz, +			; $0f47: $20 $00
+
	ld		hl, $9a0e		; $0f49: $21 $0e $9a
	call		func_207d			; $0f4c: $cd $7d $20
	ld		a, (wGameMode)		; $0f4f: $fa $b8 $c2
	cp		GAMEMODE_HEADING_OUT			; $0f52: $fe $01
	jr		nz, ++			; $0f54: $20 $03
	call		func_3162			; $0f56: $cd $62 $31
++
	ld		a, ($c2e6)		; $0f59: $fa $e6 $c2
	dec		a			; $0f5c: $3d
	ld		($c2e6), a		; $0f5d: $ea $e6 $c2
	ld		a, ($cf34)		; $0f60: $fa $34 $cf
	and		a			; $0f63: $a7
	jr		nz, func_0f9c			; $0f64: $20 $36
	ld		a, (wIsDemoScenes)		; $0f66: $fa $43 $cf
	and		a			; $0f69: $a7
	jr		nz, func_0f7d			; $0f6a: $20 $11
	call		pollInput			; $0f6c: $cd $45 $2b
	ld		a, (wGameMode)		; $0f6f: $fa $b8 $c2
	and		a			; $0f72: $a7
	jr		nz, @scrollingLevelProcessAInput			; $0f73: $20 $05
	call		checkAorSelectPressedInGame			; $0f75: $cd $89 $10
	jr		func_0f7d			; $0f78: $18 $03
@scrollingLevelProcessAInput:
	call		func_10ae			; $0f7a: $cd $ae $10
func_0f7d:
	call		handleInGameMovement			; $0f7d: $cd $e5 $10
	ld		a, ($c2d2)		; $0f80: $fa $d2 $c2
	and		a			; $0f83: $a7
	jr		z, func_0fa6			; $0f84: $28 $20
	call		func_11ab			; $0f86: $cd $ab $11
	ld		a, ($cf31)		; $0f89: $fa $31 $cf
	and		a			; $0f8c: $a7
	jr		z, func_0fa6			; $0f8d: $28 $17
	ld		a, ($cf35)		; $0f8f: $fa $35 $cf
	cp		$03			; $0f92: $fe $03
	jr		z, func_0f9c			; $0f94: $28 $06
	call		func_2890			; $0f96: $cd $90 $28
	call		func_2514			; $0f99: $cd $14 $25
func_0f9c:
	ld		a, ($cf35)		; $0f9c: $fa $35 $cf
	and		a			; $0f9f: $a7
	call		nz, func_1268		; $0fa0: $c4 $68 $12
	call		func_1274			; $0fa3: $cd $74 $12
func_0fa6:
	call		func_138c			; $0fa6: $cd $8c $13
	ld		a, ($cf34)		; $0fa9: $fa $34 $cf
	and		a			; $0fac: $a7
	jr		nz, func_0fcb			; $0fad: $20 $1c
	ld		a, (wGameMode)		; $0faf: $fa $b8 $c2
	and		a			; $0fb2: $a7
	jr		z, func_0fba			; $0fb3: $28 $05
	call		func_168f			; $0fb5: $cd $8f $16
	jr		func_0fc3			; $0fb8: $18 $09
func_0fba:
	call		func_165c			; $0fba: $cd $5c $16
	ld		a, ($cf32)		; $0fbd: $fa $32 $cf
	and		a			; $0fc0: $a7
	jr		z, func_0fcb			; $0fc1: $28 $08
func_0fc3:
	call		func_169b			; $0fc3: $cd $9b $16
	ld		a, ($cf33)		; $0fc6: $fa $33 $cf
	and		a			; $0fc9: $a7
	ret		nz			; $0fca: $c0
func_0fcb:
	halt					; $0fcb: $76
	call		waitUntilVBlankHandled_andXorCf39			; $0fcc: $cd $d2 $0f
	jp		func_0f3b			; $0fcf: $c3 $3b $0f

waitUntilVBlankHandled_andXorCf39:
	ei					; $0fd2: $fb
	ldh		a, (<hVBlankHandled)		; $0fd3: $f0 $91
	and		a			; $0fd5: $a7
	jr		z, waitUntilVBlankHandled_andXorCf39			; $0fd6: $28 $fa
	xor		a			; $0fd8: $af
	ldh		(<hVBlankHandled), a		; $0fd9: $e0 $91
	ld		(wcf39), a		; $0fdb: $ea $39 $cf
	ret					; $0fde: $c9

vblankInterrupt:
	di					; $0fdf: $f3
	push		af			; $0fe0: $f5
	push		bc			; $0fe1: $c5
	push		de			; $0fe2: $d5
	push		hl			; $0fe3: $e5
	call		copyOamDmaFunction			; $0fe4: $cd $86 $2b
	call		hOamFunc			; $0fe7: $cd $80 $ff
	call		playSounds			; $0fea: $cd $27 $72
	ld		a, $01			; $0fed: $3e $01
	ldh		(<hVBlankHandled), a		; $0fef: $e0 $91
	ld		a, ($c2ec)		; $0ff1: $fa $ec $c2
	inc		a			; $0ff4: $3c
	ld		($c2ec), a		; $0ff5: $ea $ec $c2
	cp		$3c			; $0ff8: $fe $3c
	jr		nz, ++			; $0ffa: $20 $27
	xor		a			; $0ffc: $af
	ld		($c2ec), a		; $0ffd: $ea $ec $c2
	ld		a, ($c2ef)		; $1000: $fa $ef $c2
	inc		a			; $1003: $3c
	jr		z, +			; $1004: $28 $03
	ld		($c2ef), a		; $1006: $ea $ef $c2
+
	ld		a, ($c2ed)		; $1009: $fa $ed $c2
	add		$01			; $100c: $c6 $01
	daa					; $100e: $27
	ld		($c2ed), a		; $100f: $ea $ed $c2
	cp		$60			; $1012: $fe $60
	jr		nz, ++			; $1014: $20 $0d
	xor		a			; $1016: $af
	ld		($c2ed), a		; $1017: $ea $ed $c2
	ld		a, ($c2ee)		; $101a: $fa $ee $c2
	add		$01			; $101d: $c6 $01
	daa					; $101f: $27
	ld		($c2ee), a		; $1020: $ea $ee $c2
++
	ld		a, ($c2ee)		; $1023: $fa $ee $c2
	cp		$60			; $1026: $fe $60
	jr		c, +			; $1028: $38 $09
	ld		a, $60			; $102a: $3e $60
	ld		($c2ee), a		; $102c: $ea $ee $c2
	xor		a			; $102f: $af
	ld		($c2ed), a		; $1030: $ea $ed $c2
+
	ld		a, (wcf46)		; $1033: $fa $46 $cf
	and		a			; $1036: $a7
	jp		nz, func_03_3537		; $1037: $c2 $37 $35
	ld		a, (wcf48)		; $103a: $fa $48 $cf
	and		a			; $103d: $a7
	jp		nz, func_3521		; $103e: $c2 $21 $35
	ld		a, (wIsDemoScenes)		; $1041: $fa $43 $cf
	and		a			; $1044: $a7
	jr		z, +			; $1045: $28 $0c
	ld		(wcf3a), a		; $1047: $ea $3a $cf
	ld		a, (wcf49)		; $104a: $fa $49 $cf
	and		a			; $104d: $a7
	jr		nz, +			; $104e: $20 $03
	call		serialTransferByte9f_copy			; $1050: $cd $b1 $03
+
	ld		a, (wcf3a)		; $1053: $fa $3a $cf
	bit		0, a			; $1056: $cb $47
	jp		nz, func_3556		; $1058: $c2 $56 $35
	bit		1, a			; $105b: $cb $4f
	jp		nz, func_35c7		; $105d: $c2 $c7 $35
	bit		2, a			; $1060: $cb $57
	jp		nz, func_3600		; $1062: $c2 $00 $36
	bit		3, a			; $1065: $cb $5f
	jp		nz, func_35e4		; $1067: $c2 $e4 $35
	bit		4, a			; $106a: $cb $67
	jp		nz, func_357d		; $106c: $c2 $7d $35
	bit		5, a			; $106f: $cb $6f
	jp		nz, func_35a5		; $1071: $c2 $a5 $35
	bit		6, a			; $1074: $cb $77
	jp		nz, func_3617		; $1076: $c2 $17 $36
	bit		7, a			; $1079: $cb $7f
	jp		nz, func_3637		; $107b: $c2 $37 $36
func_107e:
	ld		a, $01			; $107e: $3e $01
	ld		(wcf39), a		; $1080: $ea $39 $cf
func_1083:
	pop		hl			; $1083: $e1
	pop		de			; $1084: $d1
	pop		bc			; $1085: $c1
	pop		af			; $1086: $f1
	ei					; $1087: $fb
	reti					; $1088: $d9

checkAorSelectPressedInGame:
	ldh		a, (<hKeysPressed)		; $1089: $f0 $8b
	bit		BTN_BIT_A, a			; $108b: $cb $47
	call		nz, displayInGameMenu		; $108d: $c4 $9f $14
	ld		a, (wNumCharacters)		; $1090: $fa $d0 $c2
	cp		$01			; $1093: $fe $01
	ret		z			; $1095: $c8
	ldh		a, (<hKeysPressed)		; $1096: $f0 $8b
	bit		BTN_BIT_SELECT, a			; $1098: $cb $57
	jr		z, +			; $109a: $28 $0c
	ld		a, ($cf34)		; $109c: $fa $34 $cf
	and		a			; $109f: $a7
	jr		nz, +			; $10a0: $20 $06
	ld		b, SND_NEXT_CHARACTER			; $10a2: $06 $0e
	rst_playSound
	call		func_1400			; $10a5: $cd $00 $14
+
	ld		a, $03			; $10a8: $3e $03
	ld		($cf35), a		; $10aa: $ea $35 $cf
	ret					; $10ad: $c9

; is only purpose to process when A is pressed in scrolling level
func_10ae:
	ld		a, (wIsDemoScenes)		; $10ae: $fa $43 $cf
	and		a			; $10b1: $a7
	ret		nz			; $10b2: $c0
	ldh		a, (<hKeysPressed)		; $10b3: $f0 $8b
	bit		BTN_BIT_A, a			; $10b5: $cb $47
	ret		z			; $10b7: $c8
	ld		b, SND_RESET_STAGE_IN_SCROLLING_LEVEL			; $10b8: $06 $13
	rst_playSound
	ld		a, $80			; $10bb: $3e $80
	ld		(wcf41), a		; $10bd: $ea $41 $cf
	call		loadAllLevelData			; $10c0: $cd $37 $09
	call		func_1a64			; $10c3: $cd $64 $1a
	ld		a, $f0			; $10c6: $3e $f0
	ld		($c1b3), a		; $10c8: $ea $b3 $c1
	ld		hl, $c178		; $10cb: $21 $78 $c1
	ld		bc, $0078		; $10ce: $01 $78 $00
	call		func_1b8d			; $10d1: $cd $8d $1b
	ld		hl, $c178		; $10d4: $21 $78 $c1
	ld		bc, $0078		; $10d7: $01 $78 $00
	call		func_1b8d			; $10da: $cd $8d $1b
	call		func_1445			; $10dd: $cd $45 $14
	call		func_1400			; $10e0: $cd $00 $14
	ret					; $10e3: $c9

justRet:
	ret					; $10e4: $c9


handleInGameMovement:
	ld		a, (wIsDemoScenes)
	and		a
	jp		nz, getKeyPressedForDemoScenes
	
	call		waitUntilVBlankHandled_andXorCf39
	call		pollInput
	push		bc
	call		justRet
	pop		bc
	
_handleMovementFromKeysPressed:
	ldh		a, (<hKeysPressed)		; $10f7: $f0 $8b
	and		BTN_RIGHT|BTN_LEFT|BTN_UP|BTN_DOWN			; $10f9: $e6 $f0
	jr		nz, +			; $10fb: $20 $04
	xor		a			; $10fd: $af
	ld		($cf47), a		; $10fe: $ea $47 $cf
+
	bit		7, a			; $1101: $cb $7f
	jr		z, func_110e			; $1103: $28 $09
	ld		b, $03			; $1105: $06 $03
	ld		a, $01			; $1107: $3e $01
	ld		($c2e9), a		; $1109: $ea $e9 $c2
	jr		func_1149			; $110c: $18 $3b
func_110e:
	ldh		a, (<hKeysPressed)		; $110e: $f0 $8b
	bit		BTN_BIT_UP, a			; $1110: $cb $77
	jr		z, func_111d			; $1112: $28 $09
	ld		b, $01			; $1114: $06 $01
	ld		a, $ff			; $1116: $3e $ff
	ld		($c2e9), a		; $1118: $ea $e9 $c2
	jr		func_1149			; $111b: $18 $2c
func_111d:
	ldh		a, (<hKeysPressed)		; $111d: $f0 $8b
	bit		BTN_BIT_LEFT, a			; $111f: $cb $6f
	jr		z, func_1134			; $1121: $28 $11
	ld		b, $04			; $1123: $06 $04
	ld		a, $ff			; $1125: $3e $ff
	ld		($c2e8), a		; $1127: $ea $e8 $c2
	ld		a, ($c2d3)		; $112a: $fa $d3 $c2
	and		$df			; $112d: $e6 $df
	ld		($c2d3), a		; $112f: $ea $d3 $c2
	jr		func_1149			; $1132: $18 $15
func_1134:
	ldh		a, (<hKeysPressed)		; $1134: $f0 $8b
	bit		BTN_BIT_RIGHT, a			; $1136: $cb $67
	jr		z, func_1149			; $1138: $28 $0f
	ld		b, $02			; $113a: $06 $02
	ld		a, $01			; $113c: $3e $01
	ld		($c2e8), a		; $113e: $ea $e8 $c2
	ld		a, ($c2d3)		; $1141: $fa $d3 $c2
	or		$20			; $1144: $f6 $20
	ld		($c2d3), a		; $1146: $ea $d3 $c2
func_1149:
	ld		a, ($c2d2)		; $1149: $fa $d2 $c2
	cp		b			; $114c: $b8
	ret		z			; $114d: $c8
	ld		a, b			; $114e: $78
	ld		($c2d2), a		; $114f: $ea $d2 $c2
	ld		hl, data_3f28		; $1152: $21 $28 $3f
	ld		a, ($c2d1)		; $1155: $fa $d1 $c2
	add		a			; $1158: $87
	add		a			; $1159: $87
	call		addAToHl			; $115a: $cd $6b $24
	ld		a, (wIsDiagonalView)		; $115d: $fa $be $c2
	and		a			; $1160: $a7
	jr		nz, func_1164			; $1161: $20 $01
	ret					; $1163: $c9
func_1164:
	ld		a, ($c2d2)		; $1164: $fa $d2 $c2
	and		a			; $1167: $a7
	jr		z, func_11aa			; $1168: $28 $40
	dec		a			; $116a: $3d
	call		addAToHl			; $116b: $cd $6b $24
	ld		a, (wIsDiagonalView)		; $116e: $fa $be $c2
	and		a			; $1171: $a7
	jr		z, func_119e			; $1172: $28 $2a
	push		hl			; $1174: $e5
	ld		b, $00			; $1175: $06 $00
	call		func_1ccb			; $1177: $cd $cb $1c
	ld		hl, $0088		; $117a: $21 $88 $00
	add		hl, de			; $117d: $19
	ld		a, (de)			; $117e: $1a
	add		$08			; $117f: $c6 $08
	ldi		(hl), a			; $1181: $22
	inc		de			; $1182: $13
	ld		a, (de)			; $1183: $1a
	ldi		(hl), a			; $1184: $22
	ld		a, ($c2d2)		; $1185: $fa $d2 $c2
	cp		$01			; $1188: $fe $01
	jr		z, func_1194			; $118a: $28 $08
	cp		$03			; $118c: $fe $03
	jr		z, func_1194			; $118e: $28 $04
	ld		a, $7f			; $1190: $3e $7f
	jr		func_1196			; $1192: $18 $02
func_1194:
	ld		a, $7d			; $1194: $3e $7d
func_1196:
	ldi		(hl), a			; $1196: $22
	ld		a, ($c2d3)		; $1197: $fa $d3 $c2
	or		$80			; $119a: $f6 $80
	ld		(hl), a			; $119c: $77
	pop		hl			; $119d: $e1
func_119e:
	ld		b, $02			; $119e: $06 $02
	call		func_1ccb			; $11a0: $cd $cb $1c
	ld		a, (hl)			; $11a3: $7e
	ld		(de), a			; $11a4: $12
	inc		de			; $11a5: $13
	ld		a, ($c2d3)		; $11a6: $fa $d3 $c2
	ld		(de), a			; $11a9: $12
func_11aa:
	ret					; $11aa: $c9

func_11ab:
	call		func_1ca8			; $11ab: $cd $a8 $1c
	ld		a, ($c2d2)		; $11ae: $fa $d2 $c2
	dec		a			; $11b1: $3d
	jr		z, func_11be			; $11b2: $28 $0a
	dec		a			; $11b4: $3d
	jr		z, func_11ca			; $11b5: $28 $13
	dec		a			; $11b7: $3d
	jr		z, func_11c4			; $11b8: $28 $0a
	dec		a			; $11ba: $3d
	jr		z, func_11cd			; $11bb: $28 $10
	ret					; $11bd: $c9
func_11be:
	ld		de, -$14		; $11be: $11 $ec $ff
	add		hl, de			; $11c1: $19
	jr		func_11ce			; $11c2: $18 $0a
func_11c4:
	ld		de, $0014		; $11c4: $11 $14 $00
	add		hl, de			; $11c7: $19
	jr		func_11ce			; $11c8: $18 $04
func_11ca:
	inc		hl			; $11ca: $23
	jr		func_11ce			; $11cb: $18 $01
func_11cd:
	dec		hl			; $11cd: $2b
func_11ce:
	ld		a, (hl)			; $11ce: $7e
	and		$f0			; $11cf: $e6 $f0
	ld		($c2cf), a		; $11d1: $ea $cf $c2
	cp		$f0			; $11d4: $fe $f0
	jr		z, func_1247			; $11d6: $28 $6f
	cp		$e0			; $11d8: $fe $e0
	jr		z, func_1247			; $11da: $28 $6b
	cp		$a0			; $11dc: $fe $a0
	jr		z, func_1247			; $11de: $28 $67
	cp		$c0			; $11e0: $fe $c0
	jr		z, func_1247			; $11e2: $28 $63
	cp		$90			; $11e4: $fe $90
	jr		z, func_1247			; $11e6: $28 $5f
	cp		$50			; $11e8: $fe $50
	jr		z, func_1247			; $11ea: $28 $5b
	cp		$40			; $11ec: $fe $40
	call		z, func_212c		; $11ee: $cc $2c $21
	cp		$80			; $11f1: $fe $80
	call		z, func_22f0		; $11f3: $cc $f0 $22
	ld		a, ($cf35)		; $11f6: $fa $35 $cf
	and		a			; $11f9: $a7
	jp		z, func_1247		; $11fa: $ca $47 $12
	cp		$03			; $11fd: $fe $03
	jr		z, +			; $11ff: $28 $0e
	ld		a, (wGameMode)		; $1201: $fa $b8 $c2
	and		a			; $1204: $a7
	jr		nz, +			; $1205: $20 $08
	call		func_1f8d			; $1207: $cd $8d $1f
	ld		a, $01			; $120a: $3e $01
	ld		($cf37), a		; $120c: $ea $37 $cf
+
	ldh		a, (<hKeysPressed)		; $120f: $f0 $8b
	bit		BTN_BIT_B, a			; $1211: $cb $4f
	jr		z, func_1222			; $1213: $28 $0d
	ld		a, ($cf47)		; $1215: $fa $47 $cf
	and		a			; $1218: $a7
	jr		z, func_121d			; $1219: $28 $02
	jr		func_1250			; $121b: $18 $33
func_121d:
	ld		a, $01			; $121d: $3e $01
	ld		($cf47), a		; $121f: $ea $47 $cf
func_1222:
	ld		a, (wIsDemoScenes)		; $1222: $fa $43 $cf
	and		a			; $1225: $a7
	jr		nz, func_123e			; $1226: $20 $16
	ld		a, ($cf35)		; $1228: $fa $35 $cf
	cp		$01			; $122b: $fe $01
	jr		nz, func_1233			; $122d: $20 $04
	ld		b, SND_0a			; $122f: $06 $0a
	jr		func_123d			; $1231: $18 $0a
func_1233:
	cp		$02			; $1233: $fe $02
	jr		nz, func_123b			; $1235: $20 $04
	ld		b, SND_0c			; $1237: $06 $0c
	jr		func_123d			; $1239: $18 $02
func_123b:
	ld		b, SND_08			; $123b: $06 $08
func_123d:
	rst_playSound
func_123e:
	ld		a, $01			; $123e: $3e $01
	ld		($cf34), a		; $1240: $ea $34 $cf
	ld		($cf31), a		; $1243: $ea $31 $cf
	ret					; $1246: $c9
func_1247:
	ld		a, (wIsDemoScenes)		; $1247: $fa $43 $cf
	and		a			; $124a: $a7
	jr		nz, func_1250			; $124b: $20 $03
	ld		b, SND_09			; $124d: $06 $09
	rst_playSound
func_1250:
	xor		a			; $1250: $af
	ld		($cf34), a		; $1251: $ea $34 $cf
	ld		($cf31), a		; $1254: $ea $31 $cf
	ld		($c2e8), a		; $1257: $ea $e8 $c2
	ld		($c2e9), a		; $125a: $ea $e9 $c2
	ld		a, $03			; $125d: $3e $03
	ld		($cf35), a		; $125f: $ea $35 $cf
	ld		a, $01			; $1262: $3e $01
	ld		($c2ce), a		; $1264: $ea $ce $c2
	ret					; $1267: $c9

func_1268:
	ld		a, ($cf35)		; $1268: $fa $35 $cf
	dec		a			; $126b: $3d
	call		z, func_292c		; $126c: $cc $2c $29
	dec		a			; $126f: $3d
	call		z, func_2949		; $1270: $cc $49 $29
	ret					; $1273: $c9

func_1274:
	ld		a, ($cf31)		; $1274: $fa $31 $cf
	and		a			; $1277: $a7
	jr		z, +			; $1278: $28 $05
	ld		a, $01			; $127a: $3e $01
	ld		($cf34), a		; $127c: $ea $34 $cf
+
	ld		hl, $c2dc		; $127f: $21 $dc $c2
	ld		a, ($c2d1)		; $1282: $fa $d1 $c2
	sla		a			; $1285: $cb $27
	call		addAToHl			; $1287: $cd $6b $24
	ld		a, ($c2ce)		; $128a: $fa $ce $c2
	cp		$01			; $128d: $fe $01
	jr		z, +			; $128f: $28 $10
	ld		a, ($c2e8)		; $1291: $fa $e8 $c2
	sla		a			; $1294: $cb $27
	ld		($c2e8), a		; $1296: $ea $e8 $c2
	ld		a, ($c2e9)		; $1299: $fa $e9 $c2
	sla		a			; $129c: $cb $27
	ld		($c2e9), a		; $129e: $ea $e9 $c2
+
	ld		a, ($c2e8)		; $12a1: $fa $e8 $c2
	add		(hl)			; $12a4: $86
	ld		(hl), a			; $12a5: $77
	ld		b, a			; $12a6: $47
	inc		hl			; $12a7: $23
	ld		a, ($c2e9)		; $12a8: $fa $e9 $c2
	add		(hl)			; $12ab: $86
	ld		(hl), a			; $12ac: $77
	ld		c, a			; $12ad: $4f
	push		bc			; $12ae: $c5
	ld		b, $02			; $12af: $06 $02
	call		func_1ccb			; $12b1: $cd $cb $1c
	pop		bc			; $12b4: $c1
	ld		a, (de)			; $12b5: $1a
	ld		d, a			; $12b6: $57
	ld		a, ($c2d3)		; $12b7: $fa $d3 $c2
	ld		e, a			; $12ba: $5f
	ld		a, ($c2d1)		; $12bb: $fa $d1 $c2
	call		store_c_b_d_e_in_c000plus4a			; $12be: $cd $f1 $24
	ld		a, (wIsDiagonalView)		; $12c1: $fa $be $c2
	and		a			; $12c4: $a7
	jr		z, +			; $12c5: $28 $10
	ld		b, $00			; $12c7: $06 $00
	call		func_1ccb			; $12c9: $cd $cb $1c
	ld		hl, $0088		; $12cc: $21 $88 $00
	add		hl, de			; $12cf: $19
	ld		a, (de)			; $12d0: $1a
	add		$08			; $12d1: $c6 $08
	ldi		(hl), a			; $12d3: $22
	inc		de			; $12d4: $13
	ld		a, (de)			; $12d5: $1a
	ldi		(hl), a			; $12d6: $22
+
	ld		a, ($c2ce)		; $12d7: $fa $ce $c2
	cp		$01			; $12da: $fe $01
	jr		z, +			; $12dc: $28 $10
	ld		a, ($c2e8)		; $12de: $fa $e8 $c2
	sra		a			; $12e1: $cb $2f
	ld		($c2e8), a		; $12e3: $ea $e8 $c2
	ld		a, ($c2e9)		; $12e6: $fa $e9 $c2
	sra		a			; $12e9: $cb $2f
	ld		($c2e9), a		; $12eb: $ea $e9 $c2
+
	ld		a, ($c2e7)		; $12ee: $fa $e7 $c2
	dec		a			; $12f1: $3d
	ld		($c2e7), a		; $12f2: $ea $e7 $c2
	jr		nz, func_1347			; $12f5: $20 $50
	call		func_1348			; $12f7: $cd $48 $13
	ld		a, $08			; $12fa: $3e $08
	ld		($c2e7), a		; $12fc: $ea $e7 $c2
	ld		a, ($c2ce)		; $12ff: $fa $ce $c2
	cp		$02			; $1302: $fe $02
	jr		nz, +			; $1304: $20 $03
	call		func_1348			; $1306: $cd $48 $13
+
	ld		a, ($cf35)		; $1309: $fa $35 $cf
	cp		$01			; $130c: $fe $01
	call		z, func_288c		; $130e: $cc $8c $28
	cp		$02			; $1311: $fe $02
	call		z, func_288c		; $1313: $cc $8c $28
	call		func_29aa			; $1316: $cd $aa $29
	call		func_299b			; $1319: $cd $9b $29
	xor		a			; $131c: $af
	ld		($c2e8), a		; $131d: $ea $e8 $c2
	ld		($c2e9), a		; $1320: $ea $e9 $c2
	ld		($cf34), a		; $1323: $ea $34 $cf
	ld		a, $03			; $1326: $3e $03
	ld		($cf35), a		; $1328: $ea $35 $cf
	ld		a, $08			; $132b: $3e $08
	ld		($c2e7), a		; $132d: $ea $e7 $c2
	ld		a, $01			; $1330: $3e $01
	ld		($c2ce), a		; $1332: $ea $ce $c2
	ld		a, ($c2ea)		; $1335: $fa $ea $c2
	add		$01			; $1338: $c6 $01
	daa					; $133a: $27
	ld		($c2ea), a		; $133b: $ea $ea $c2
	ld		a, ($c2eb)		; $133e: $fa $eb $c2
	adc		$00			; $1341: $ce $00
	daa					; $1343: $27
	ld		($c2eb), a		; $1344: $ea $eb $c2
func_1347:
	ret					; $1347: $c9

func_1348:
	ld		hl, $c2d4		; $1348: $21 $d4 $c2
	ld		a, ($c2d1)		; $134b: $fa $d1 $c2
	sla		a			; $134e: $cb $27
	ld		e, a			; $1350: $5f
	ld		d, $00			; $1351: $16 $00
	add		hl, de			; $1353: $19
	ld		e, l			; $1354: $5d
	ld		d, h			; $1355: $54
	ld		a, (de)			; $1356: $1a
	ld		l, a			; $1357: $6f
	inc		de			; $1358: $13
	ld		a, (de)			; $1359: $1a
	ld		h, a			; $135a: $67
	dec		de			; $135b: $1b
	push		de			; $135c: $d5
	ld		a, ($c2e8)		; $135d: $fa $e8 $c2
	and		a			; $1360: $a7
	jr		z, func_1371			; $1361: $28 $0e
	cp		$01			; $1363: $fe $01
	jr		nz, func_136d			; $1365: $20 $06
	ld		e, a			; $1367: $5f
	ld		d, $00			; $1368: $16 $00
	add		hl, de			; $136a: $19
	jr		func_1371			; $136b: $18 $04
func_136d:
	ld		de, -$01		; $136d: $11 $ff $ff
	add		hl, de			; $1370: $19
func_1371:
	ld		a, ($c2e9)		; $1371: $fa $e9 $c2
	and		a			; $1374: $a7
	jr		z, func_1385			; $1375: $28 $0e
	cp		$01			; $1377: $fe $01
	jr		nz, func_1381			; $1379: $20 $06
	ld		de, $0014		; $137b: $11 $14 $00
	add		hl, de			; $137e: $19
	jr		func_1385			; $137f: $18 $04
func_1381:
	ld		de, -$14		; $1381: $11 $ec $ff
	add		hl, de			; $1384: $19
func_1385:
	pop		de			; $1385: $d1
	ld		a, l			; $1386: $7d
	ld		(de), a			; $1387: $12
	inc		de			; $1388: $13
	ld		a, h			; $1389: $7c
	ld		(de), a			; $138a: $12
	ret					; $138b: $c9

func_138c:
	ld		b, $02			; $138c: $06 $02
	call		func_1ccb			; $138e: $cd $cb $1c
	ld		a, ($c2e6)		; $1391: $fa $e6 $c2
	cp		$04			; $1394: $fe $04
	ret		nz			; $1396: $c0
	ldh		a, (R_OBP1)		; $1397: $f0 $49
	cp		$9c			; $1399: $fe $9c
	jr		nz, func_13a1			; $139b: $20 $04
	ld		a, $ac			; $139d: $3e $ac
	jr		func_13a3			; $139f: $18 $02
func_13a1:
	ldh		a, (R_OBP0)		; $13a1: $f0 $48
func_13a3:
	ldh		(R_OBP1), a		; $13a3: $e0 $49
	ld		a, $08			; $13a5: $3e $08
	ld		($c2e6), a		; $13a7: $ea $e6 $c2
	ld		a, (wIsDiagonalView)		; $13aa: $fa $be $c2
	and		a			; $13ad: $a7
	jr		z, func_13f1			; $13ae: $28 $41
	ld		hl, $0088		; $13b0: $21 $88 $00
	add		hl, de			; $13b3: $19
	ld		a, (hl)			; $13b4: $7e
	cp		$7d			; $13b5: $fe $7d
	jr		nz, func_13cb			; $13b7: $20 $12
	inc		hl			; $13b9: $23
	ld		a, (hl)			; $13ba: $7e
	bit		5, a			; $13bb: $cb $6f
	jr		nz, func_13c5			; $13bd: $20 $06
	set		5, a			; $13bf: $cb $ef
	ld		(hl), a			; $13c1: $77
	dec		hl			; $13c2: $2b
	jr		func_13db			; $13c3: $18 $16
func_13c5:
	res		5, a			; $13c5: $cb $af
	ld		(hl), a			; $13c7: $77
	dec		hl			; $13c8: $2b
	jr		func_13db			; $13c9: $18 $10
func_13cb:
	ld		a, (hl)			; $13cb: $7e
	cp		$7f			; $13cc: $fe $7f
	jr		nz, func_13d4			; $13ce: $20 $04
	ld		a, $7e			; $13d0: $3e $7e
	jr		func_13da			; $13d2: $18 $06
func_13d4:
	cp		$7e			; $13d4: $fe $7e
	jr		nz, func_13da			; $13d6: $20 $02
	ld		a, $7f			; $13d8: $3e $7f
func_13da:
	ld		(hl), a			; $13da: $77
func_13db:
	ld		de, -$02		; $13db: $11 $fe $ff
	add		hl, de			; $13de: $19
	push		hl			; $13df: $e5
	ld		de, -$88		; $13e0: $11 $78 $ff
	add		hl, de			; $13e3: $19
	ld		a, (hl)			; $13e4: $7e
	and		$01			; $13e5: $e6 $01
	jr		nz, func_13ed			; $13e7: $20 $04
	dec		(hl)			; $13e9: $35
	pop		hl			; $13ea: $e1
	dec		(hl)			; $13eb: $35
	ret					; $13ec: $c9
func_13ed:
	inc		(hl)			; $13ed: $34
	pop		hl			; $13ee: $e1
	inc		(hl)			; $13ef: $34
	ret					; $13f0: $c9
func_13f1:
	ld		h, d			; $13f1: $62
	ld		l, e			; $13f2: $6b
	ld		de, -$02		; $13f3: $11 $fe $ff
	add		hl, de			; $13f6: $19
	ld		a, (hl)			; $13f7: $7e
	and		$01			; $13f8: $e6 $01
	jr		nz, func_13fe			; $13fa: $20 $02
	dec		(hl)			; $13fc: $35
	ret					; $13fd: $c9
func_13fe:
	inc		(hl)			; $13fe: $34
	ret					; $13ff: $c9

func_1400:
	call		func_1ca8			; $1400: $cd $a8 $1c
	ld		a, (hl)			; $1403: $7e
	and		$f0			; $1404: $e6 $f0
	cp		$10			; $1406: $fe $10
	jr		z, +			; $1408: $28 $06
	ld		a, ($c2d1)		; $140a: $fa $d1 $c2
	or		$c0			; $140d: $f6 $c0
	ld		(hl), a			; $140f: $77
+
	ld		a, ($c2d1)		; $1410: $fa $d1 $c2
	inc		a			; $1413: $3c
	cp		$04			; $1414: $fe $04
	jr		nz, +			; $1416: $20 $01
	xor		a			; $1418: $af
+
	ld		($c2d1), a		; $1419: $ea $d1 $c2
	call		func_1cbc			; $141c: $cd $bc $1c
	ld		a, (hl)			; $141f: $7e
	and		a			; $1420: $a7
	jr		z, func_1400			; $1421: $28 $dd
	ld		b, $00			; $1423: $06 $00
	call		func_1ccb			; $1425: $cd $cb $1c
	ld		b, $fd			; $1428: $06 $fd
	ld		c, $0a			; $142a: $0e $0a
-
	ld		a, (de)			; $142c: $1a
	add		b			; $142d: $80
	ld		(de), a			; $142e: $12
	ld		a, b			; $142f: $78
	cpl					; $1430: $2f
	inc		a			; $1431: $3c
	ld		b, a			; $1432: $47
	call		waitUntilVBlankHandled_andXorCf39			; $1433: $cd $d2 $0f
	call		waitUntilVBlankHandled_andXorCf39			; $1436: $cd $d2 $0f
	call		waitUntilVBlankHandled_andXorCf39			; $1439: $cd $d2 $0f
	dec		c			; $143c: $0d
	jr		nz, -			; $143d: $20 $ed
	call		func_1ca8			; $143f: $cd $a8 $1c
	xor		a			; $1442: $af
	ld		(hl), a			; $1443: $77
	ret					; $1444: $c9

func_1445:
	ld		hl, $c2dc		; $1445: $21 $dc $c2
	ld		b, $00			; $1448: $06 $00
func_144a:
	push		bc			; $144a: $c5
	ld		a, b			; $144b: $78
	ld		($cf1a), a		; $144c: $ea $1a $cf
	push		af			; $144f: $f5
	push		hl			; $1450: $e5
	ld		a, (wIsDiagonalView)		; $1451: $fa $be $c2
	and		a			; $1454: $a7
	jr		nz, func_1461			; $1455: $20 $0a
	ld		hl, data_3f38		; $1457: $21 $38 $3f
	ld		a, b			; $145a: $78
	add		a			; $145b: $87
	ld		de, $0000		; $145c: $11 $00 $00
	jr		func_146a			; $145f: $18 $09
func_1461:
	ld		hl, data_3f28		; $1461: $21 $28 $3f
	ld		a, b			; $1464: $78
	add		a			; $1465: $87
	add		a			; $1466: $87
	ld		de, $0002		; $1467: $11 $02 $00
func_146a:
	call		addAToHl			; $146a: $cd $6b $24
	add		hl, de			; $146d: $19
	ld		a, (hl)			; $146e: $7e
	ld		d, a			; $146f: $57
	pop		hl			; $1470: $e1
	ldi		a, (hl)			; $1471: $2a
	ld		b, a			; $1472: $47
	ldi		a, (hl)			; $1473: $2a
	ld		c, a			; $1474: $4f
	ld		e, $00			; $1475: $1e $00
	pop		af			; $1477: $f1
	call		store_c_b_d_e_in_c000plus4a			; $1478: $cd $f1 $24
	ld		a, (wIsDiagonalView)		; $147b: $fa $be $c2
	and		a			; $147e: $a7
	jr		z, +			; $147f: $28 $0f
	ld		de, $7d80		; $1481: $11 $80 $7d
	ld		a, c			; $1484: $79
	add		$08			; $1485: $c6 $08
	ld		c, a			; $1487: $4f
	ld		a, ($cf1a)		; $1488: $fa $1a $cf
	add		$22			; $148b: $c6 $22
	call		store_c_b_d_e_in_c000plus4a			; $148d: $cd $f1 $24
+
	pop		bc			; $1490: $c1
	inc		b			; $1491: $04
	ld		a, b			; $1492: $78
	cp		$04			; $1493: $fe $04
	jr		nz, func_144a			; $1495: $20 $b3
	call		waitUntilVBlankHandled_andXorCf39			; $1497: $cd $d2 $0f
	xor		a			; $149a: $af
	ld		($c2d2), a		; $149b: $ea $d2 $c2
	ret					; $149e: $c9

displayInGameMenu:
	ld		b, SND_OPEN_INGAME_MENU			; $149f: $06 $0f
	rst_playSound
	ld		a, $ff			; $14a2: $3e $ff
	ld		($c002), a		; $14a4: $ea $02 $c0
	ld		($c006), a		; $14a7: $ea $06 $c0
	ld		($c00a), a		; $14aa: $ea $0a $c0
	ld		($c00e), a		; $14ad: $ea $0e $c0
	ld		($c088), a		; $14b0: $ea $88 $c0
	ld		($c08c), a		; $14b3: $ea $8c $c0
	ld		($c090), a		; $14b6: $ea $90 $c0
	ld		($c094), a		; $14b9: $ea $94 $c0
	ld		a, (meOam)		; $14bc: $fa $9e $c0
	ld		(wMeOamTempStorage), a		; $14bf: $ea $24 $cf
	ld		a, (stairsOam)		; $14c2: $fa $9a $c0
	ld		(wStairsOamTempStorage), a		; $14c5: $ea $25 $cf
	ld		a, $ff			; $14c8: $3e $ff
	ld		(stairsOam), a		; $14ca: $ea $9a $c0
	ld		(meOam), a		; $14cd: $ea $9e $c0
	ld		a, $a5			; $14d0: $3e $a5
	ldh		(R_WX), a		; $14d2: $e0 $4b
	ld		a, $10			; $14d4: $3e $10
	ldh		(R_WY), a		; $14d6: $e0 $4a
	ld		a, $e3			; $14d8: $3e $e3
	ldh		(R_LCDC), a		; $14da: $e0 $40

	; draw level 1+
	ld		a, (wDifficulty)		; $14dc: $fa $c0 $c2
	inc		a			; $14df: $3c
	call		get2DigitsToDrawFromNonBCD_A			; $14e0: $cd $12 $21
	ld		hl, BG_MAP2+$45		; $14e3: $21 $45 $9c
	call		draw2DigitsAtHl			; $14e6: $cd $5d $20

	; draw floor
	ld		a, (wRoomIndex)		; $14e9: $fa $bf $c2
	call		aEqualsADiv10Plus1			; $14ec: $cd $5a $15
	ld		hl, BG_MAP2+$85		; $14ef: $21 $85 $9c
	call		draw2DigitsAtHl			; $14f2: $cd $5d $20

	call		waitUntilHBlankJustStarted			; $14f5: $cd $74 $1f
	ld		a, $1d			; $14f8: $3e $1d
	ld		(BG_MAP2+$45), a		; $14fa: $ea $45 $9c
-
	call		waitUntilVBlankHandled_andXorCf39			; $14fd: $cd $d2 $0f
	ldh		a, (R_WX)		; $1500: $f0 $4b
	sub		$02			; $1502: $d6 $02
	ldh		(R_WX), a		; $1504: $e0 $4b
	cp		$5f			; $1506: $fe $5f
	jr		nz, -			; $1508: $20 $f3
	
	; menu scrolled in enough
	; cursor details
	ld		hl, $9d21		; $150a: $21 $21 $9d
	ld		de, $0040		; $150d: $11 $40 $00
	ld		bc, $0001		; $1510: $01 $01 $00
	ld		a, ($cf37)		; $1513: $fa $37 $cf
	add		c			; $1516: $81
	ld		c, a			; $1517: $4f
	ld		($cf13), a		; $1518: $ea $13 $cf
	ld		a, $ab			; $151b: $3e $ab
	call		loadCursorData			; $151d: $cd $9b $2c
	
	ld		a, (wMenuOptionSelected)		; $1520: $fa $19 $cf
	cp		$ff			; $1523: $fe $ff
	jr		z, @backToGame			; $1525: $28 $0b
	and		a			; $1527: $a7
	jp		z, @redoLevel		; $1528: $ca $53 $15
	dec		a			; $152b: $3d
	jr		z, returnToGameScreen			; $152c: $28 $39
	dec		a			; $152e: $3d
	call		z, undoGameStep		; $152f: $cc $e8 $1f

@backToGame:
	call		waitUntilVBlankHandled_andXorCf39
	ldh		a, (R_WX)
	add		$04
	ldh		(R_WX), a
	cp		$a7
	jr		nz, @backToGame

	; menu scrolled out
	ld		a, $c3			; $153f: $3e $c3
	ldh		(R_LCDC), a		; $1541: $e0 $40
	call		func_1445			; $1543: $cd $45 $14
	ld		a, (wMeOamTempStorage)		; $1546: $fa $24 $cf
	ld		(meOam), a		; $1549: $ea $9e $c0
	ld		a, (wStairsOamTempStorage)		; $154c: $fa $25 $cf
	ld		(stairsOam), a		; $154f: $ea $9a $c0
	ret					; $1552: $c9

@redoLevel:
	ld		a, $c3			; $1553: $3e $c3
	ldh		(R_LCDC), a		; $1555: $e0 $40
	jp		loadLevelFromRedo			; $1557: $c3 $e7 $01

aEqualsADiv10Plus1:
	ld		l, a			; $155a: $6f
	ld		h, $00			; $155b: $26 $00
	ld		a, 10			; $155d: $3e $0a
	call		hlDivModA			; $155f: $cd $2b $1f
	inc		a			; $1562: $3c
	call		get2DigitsToDrawFromNonBCD_A			; $1563: $cd $12 $21
	ret					; $1566: $c9

returnToGameScreen:
	ld		a, ($c2ed)		; $1567: $fa $ed $c2
	ld		($cf26), a		; $156a: $ea $26 $cf
	ld		a, ($c2ee)		; $156d: $fa $ee $c2
	ld		($cf27), a		; $1570: $ea $27 $cf
	ld		a, $c3			; $1573: $3e $c3
	ldh		(R_LCDC), a		; $1575: $e0 $40
	ld		b, MUS_LEVEL_SELECT_MENU			; $1577: $06 $03
	rst_playSound
	ld		hl, $9903		; $157a: $21 $03 $99
	ld		de, returnToGameOptionsLayoutData		; $157d: $11 $b6 $08
	call		loadLevelSelectTiles_andLayoutData			; $1580: $cd $ce $06

	ld		de, selectFloorLayoutData		; $1583: $11 $e2 $08
	ld		a, (wGameMode)		; $1586: $fa $b8 $c2
	and		a			; $1589: $a7
	jr		z, +			; $158a: $28 $03
	ld		de, selectCourseLayoutData		; $158c: $11 $ef $08
+
	ld		hl, $9943		; $158f: $21 $43 $99
	call		loadBGTileMapData			; $1592: $cd $d4 $3a
	ld		hl, $9902		; $1595: $21 $02 $99
	ld		de, $0040		; $1598: $11 $40 $00
	ld		bc, $0003		; $159b: $01 $03 $00
	ld		a, $03			; $159e: $3e $03
	ld		($cf13), a		; $15a0: $ea $13 $cf
	ld		a, $ab			; $15a3: $3e $ab
	call		loadCursorData			; $15a5: $cd $9b $2c
	
	ld		a, (wMenuOptionSelected)		; $15a8: $fa $19 $cf
	cp		$ff			; $15ab: $fe $ff
	jr		nz, func_15b1			; $15ad: $20 $02
	jr		func_15c6			; $15af: $18 $15
func_15b1:
	and		a			; $15b1: $a7
	jr		z, func_15c6			; $15b2: $28 $12
	push		af			; $15b4: $f5
	xor		a			; $15b5: $af
	ld		($c378), a		; $15b6: $ea $78 $c3
	ld		($c379), a		; $15b9: $ea $79 $c3
	pop		af			; $15bc: $f1
	dec		a			; $15bd: $3d
	jr		z, func_15eb			; $15be: $28 $2b
	dec		a			; $15c0: $3d
	jr		z, func_15e8			; $15c1: $28 $25
	jp		gotoGameSelectMenu			; $15c3: $c3 $fe $03
func_15c6:
	ld		a, ($cf44)		; $15c6: $fa $44 $cf
	and		a			; $15c9: $a7
	jr		z, func_15cf			; $15ca: $28 $03
	jp		func_05ef			; $15cc: $c3 $ef $05
func_15cf:
	ld		a, ($cf26)		; $15cf: $fa $26 $cf
	ld		($c2ed), a		; $15d2: $ea $ed $c2
	ld		a, ($cf27)		; $15d5: $fa $27 $cf
	ld		($c2ee), a		; $15d8: $ea $ee $c2
	xor		a			; $15db: $af
	ld		($cf44), a		; $15dc: $ea $44 $cf
	call		func_1aff			; $15df: $cd $ff $1a
	ld		b, SND_01			; $15e2: $06 $01
	rst_playSound
	jp		displayInGameMenu@backToGame			; $15e5: $c3 $32 $15
func_15e8:
	jp		difficultyOptionsScreen			; $15e8: $c3 $bc $04
func_15eb:
	ld		a, (wGameMode)		; $15eb: $fa $b8 $c2
	and		a			; $15ee: $a7
	jr		nz, func_15f4			; $15ef: $20 $03
	jp		floorOptionsScreen			; $15f1: $c3 $05 $05
func_15f4:
	jp		func_059a			; $15f4: $c3 $9a $05

func_15f7:
	ld		a, $03			; $15f7: $3e $03
	ld		($cf35), a		; $15f9: $ea $35 $cf
	xor		a			; $15fc: $af
	ld		($cf3f), a		; $15fd: $ea $3f $cf
	ld		(wcf41), a		; $1600: $ea $41 $cf
	ld		($ceda), a		; $1603: $ea $da $ce
	ld		($cedb), a		; $1606: $ea $db $ce
	ld		($c37f), a		; $1609: $ea $7f $c3
	ld		($c380), a		; $160c: $ea $80 $c3
	ld		($c2fb), a		; $160f: $ea $fb $c2
	ld		($c2fc), a		; $1612: $ea $fc $c2
	ld		($c2ec), a		; $1615: $ea $ec $c2
	ld		($c2ed), a		; $1618: $ea $ed $c2
	ld		($c2ee), a		; $161b: $ea $ee $c2
	ld		($c2ef), a		; $161e: $ea $ef $c2
	ld		($c2ea), a		; $1621: $ea $ea $c2
	ld		($c2eb), a		; $1624: $ea $eb $c2
	ld		($c2f1), a		; $1627: $ea $f1 $c2
	ld		($c2f2), a		; $162a: $ea $f2 $c2
	ld		($cf37), a		; $162d: $ea $37 $cf
	ld		($c2cf), a		; $1630: $ea $cf $c2
	ld		($cf34), a		; $1633: $ea $34 $cf
	ld		($cf31), a		; $1636: $ea $31 $cf
	ld		($cf32), a		; $1639: $ea $32 $cf
	ld		($cf33), a		; $163c: $ea $33 $cf
	ld		($c2e8), a		; $163f: $ea $e8 $c2
	ld		($c2e9), a		; $1642: $ea $e9 $c2
	ld		($c2d3), a		; $1645: $ea $d3 $c2
	ld		a, $01			; $1648: $3e $01
	ld		($c2ce), a		; $164a: $ea $ce $c2
	ld		(wc2bb), a		; $164d: $ea $bb $c2
	ld		(wc2bc), a		; $1650: $ea $bc $c2
	ld		a, $08			; $1653: $3e $08
	ld		($c2e6), a		; $1655: $ea $e6 $c2
	ld		($c2e7), a		; $1658: $ea $e7 $c2
	ret					; $165b: $c9

func_165c:
	ld		a, ($c2cf)		; $165c: $fa $cf $c2
	cp		$10			; $165f: $fe $10
	ret		nz			; $1661: $c0
	ld		b, SND_12			; $1662: $06 $12
	rst_playSound
	ld		a, $01			; $1665: $3e $01
	ld		($cf32), a		; $1667: $ea $32 $cf
	ld		b, $00			; $166a: $06 $00
	call		func_1ccb			; $166c: $cd $cb $1c
	xor		a			; $166f: $af
	ld		(de), a			; $1670: $12
	inc		de			; $1671: $13
	ld		(de), a			; $1672: $12
	ld		hl, $0088		; $1673: $21 $88 $00
	add		hl, de			; $1676: $19
	ld		(hl), a			; $1677: $77
	call		func_1cbc			; $1678: $cd $bc $1c
	xor		a			; $167b: $af
	ldi		(hl), a			; $167c: $22
	ldi		(hl), a			; $167d: $22
	ld		a, (wNumCharacters)		; $167e: $fa $d0 $c2
	dec		a			; $1681: $3d
	ld		(wNumCharacters), a		; $1682: $ea $d0 $c2
	jr		z, +			; $1685: $28 $03
	call		func_1400			; $1687: $cd $00 $14
+
	xor		a			; $168a: $af
	ld		($c2cf), a		; $168b: $ea $cf $c2
	ret					; $168e: $c9

func_168f:
	call		func_1cbc			; $168f: $cd $bc $1c
	ld		a, (hl)			; $1692: $7e
	cp		$08			; $1693: $fe $08
	ret		nz			; $1695: $c0
	xor		a			; $1696: $af
	ld		(wNumCharacters), a		; $1697: $ea $d0 $c2
	ret					; $169a: $c9

func_169b:
	ld		a, (wNumCharacters)		; $169b: $fa $d0 $c2
	and		a			; $169e: $a7
	jp		nz, func_178a		; $169f: $c2 $8a $17
	ld		a, ($c2ed)		; $16a2: $fa $ed $c2
	ld		($cf1b), a		; $16a5: $ea $1b $cf
	ld		a, ($c2ee)		; $16a8: $fa $ee $c2
	ld		($cf1c), a		; $16ab: $ea $1c $cf
	ld		a, $01			; $16ae: $3e $01
	ld		($cf33), a		; $16b0: $ea $33 $cf
	ld		a, (wGameMode)		; $16b3: $fa $b8 $c2
	and		a			; $16b6: $a7
	jr		z, func_16d3			; $16b7: $28 $1a
	ld		a, (wc2bb)		; $16b9: $fa $bb $c2
	inc		a			; $16bc: $3c
	ld		(wc2bb), a		; $16bd: $ea $bb $c2
	ld		a, (wc2bb)		; $16c0: $fa $bb $c2
	ld		b, a			; $16c3: $47
	ld		a, (wNumberOfRandomRoomsForDifficulty)		; $16c4: $fa $b9 $c2
	add		$01			; $16c7: $c6 $01
	cp		b			; $16c9: $b8
	jr		nz, func_16d3			; $16ca: $20 $07
	xor		a			; $16cc: $af
	ld		(wcf3a), a		; $16cd: $ea $3a $cf
	jp		func_36a5			; $16d0: $c3 $a5 $36
func_16d3:
	call		func_1792			; $16d3: $cd $92 $17
	ld		a, (wRoomIndex)		; $16d6: $fa $bf $c2
	inc		a			; $16d9: $3c
	cp		30			; $16da: $fe $1e
	jr		nz, +			; $16dc: $20 $01
	xor		a			; $16de: $af
+
	ld		(wRoomIndex), a		; $16df: $ea $bf $c2
	pop		hl			; $16e2: $e1
	ld		b, MUS_LEVEL_SELECT_MENU			; $16e3: $06 $03
	rst_playSound

	call		drawLevelClearScreen			; $16e6: $cd $f7 $39
	ld		de, levelClearScreenLayoutData		; $16e9: $11 $85 $08
	ld		hl, $9863		; $16ec: $21 $63 $98
	call		loadBGTileMapData			; $16ef: $cd $d4 $3a

	ld		a, (wDifficulty)		; $16f2: $fa $c0 $c2
	inc		a			; $16f5: $3c
	or		$f0			; $16f6: $f6 $f0
	ld		hl, $98aa		; $16f8: $21 $aa $98
	call		drawDigitAtHl			; $16fb: $cd $6a $20

	ld		a, (wRoomIndex)		; $16fe: $fa $bf $c2
	ld		h, $00			; $1701: $26 $00
	ld		l, a			; $1703: $6f
	ld		a, 10			; $1704: $3e $0a
	call		hlDivModA			; $1706: $cd $2b $1f
	and		a			; $1709: $a7
	jr		nz, +			; $170a: $20 $02
	ld		a, 10			; $170c: $3e $0a
+
	call		get2DigitsToDrawFromNonBCD_A			; $170e: $cd $12 $21
	ld		($cf15), a		; $1711: $ea $15 $cf
	ld		hl, $98af		; $1714: $21 $af $98
	call		draw2DigitsAtHl			; $1717: $cd $5d $20

	ld		a, ($cf1b)		; $171a: $fa $1b $cf
	ld		($c2ed), a		; $171d: $ea $ed $c2
	ld		a, ($cf1c)		; $1720: $fa $1c $cf
	ld		($c2ee), a		; $1723: $ea $ee $c2
	ld		hl, $98ea		; $1726: $21 $ea $98
	call		func_207d			; $1729: $cd $7d $20
	ld		hl, $992b		; $172c: $21 $2b $99
	call		func_208e			; $172f: $cd $8e $20
	ld		a, $40			; $1732: $3e $40
	ld		(wcf3a), a		; $1734: $ea $3a $cf
	xor		a			; $1737: $af
	ld		(wcf40), a		; $1738: $ea $40 $cf
	ld		($c381), a		; $173b: $ea $81 $c3
-
	ld		hl, data_3a33		; $173e: $21 $33 $3a
	ld		bc, $0018		; $1741: $01 $18 $00
	ld		a, ($c381)		; $1744: $fa $81 $c3
	call		func_3b88			; $1747: $cd $88 $3b
	call		func_381c			; $174a: $cd $1c $38
	ld		a, ($c381)		; $174d: $fa $81 $c3
	cpl					; $1750: $2f
	and		$01			; $1751: $e6 $01
	ld		($c381), a		; $1753: $ea $81 $c3
	ld		a, (wcf40)		; $1756: $fa $40 $cf
	and		a			; $1759: $a7
	jr		z, -			; $175a: $28 $e2
	call		func_01f9			; $175c: $cd $f9 $01
	ld		a, ($cf15)		; $175f: $fa $15 $cf
	cp		$10			; $1762: $fe $10
	jr		nz, +			; $1764: $20 $0d
	xor		a			; $1766: $af
	ld		(wcf40), a		; $1767: $ea $40 $cf
	call		clear1st100bytesOfWram			; $176a: $cd $81 $1f
	call		levelSetCleared			; $176d: $cd $11 $07
	call		func_3754			; $1770: $cd $54 $37
+
	xor		a			; $1773: $af
	ld		(wcf40), a		; $1774: $ea $40 $cf
	ld		a, (wRoomIndex)		; $1777: $fa $bf $c2
	and		a			; $177a: $a7
	jr		z, func_1786			; $177b: $28 $09
	call		clear1st100bytesOfWram			; $177d: $cd $81 $1f
	call		vramLoad_mainGameTiles			; $1780: $cd $51 $02
	jp		func_0606			; $1783: $c3 $06 $06
func_1786:
	di					; $1786: $f3
	jp		begin			; $1787: $c3 $50 $01

func_178a:
	xor		a			; $178a: $af
	ld		($cf32), a		; $178b: $ea $32 $cf
	ld		($cf33), a		; $178e: $ea $33 $cf
	ret					; $1791: $c9

func_1792:
	ld		a, (wGameMode)
	and		a
	jr		z, flashLevelOnStairsLevelClear

	; is non-stairs level - scroll through to left?
	call		getNextRoomIndexForScrollingLevel			; gets next level?
	call		loadAllLevelData
	call		func_1cdd			; draws screen details?
	call		func_1a64			; $17a1: $cd $64 $1a
	pop		hl			; $17a4: $e1
	call		func_1445			; $17a5: $cd $45 $14
	call		func_1400			; $17a8: $cd $00 $14
	xor		a			; $17ab: $af
	ld		($c2ef), a		; $17ac: $ea $ef $c2
	jp		func_0fcb			; $17af: $c3 $cb $0f

; Unused?
	ret					; $17b2: $c9


flashLevelOnStairsLevelClear:
	ld		b, MUS_LEVEL_JUST_CLEARED			; $17b3: $06 $04
	rst_playSound
	ldh		a, (R_BGP)		; $17b6: $f0 $47
	ld		b, a			; $17b8: $47
	ld		c, $09			; $17b9: $0e $09
-
	xor		a			; $17bb: $af
	ldh		(R_BGP), a		; $17bc: $e0 $47
	call		waitUntil_0a_VBlanksHandled			; $17be: $cd $d3 $17

	ld		a, b			; $17c1: $78
	ldh		(R_BGP), a		; $17c2: $e0 $47
	call		waitUntil_0a_VBlanksHandled			; $17c4: $cd $d3 $17
	dec		c			; $17c7: $0d
	jr		nz, -			; $17c8: $20 $f1

	ld		a, $ff			; $17ca: $3e $ff
	ld		(meOam), a		; $17cc: $ea $9e $c0
	ld		(stairsOam), a		; $17cf: $ea $9a $c0
	ret					; $17d2: $c9

waitUntil_0a_VBlanksHandled:
	ld		d, $0a			; $17d3: $16 $0a
-
	call		waitUntilVBlankHandled_andXorCf39			; $17d5: $cd $d2 $0f
	dec		d			; $17d8: $15
	jr		nz, -			; $17d9: $20 $fa
	ret					; $17db: $c9


func_17dc:
	ld		a, (wGameMode)		; $17dc: $fa $b8 $c2
	cp		GAMEMODE_HEADING_OUT			; $17df: $fe $01
	jr		nz, func_184c			; $17e1: $20 $69

	; is scrolling level
	call		drawLevelClearScreen			; $17e3: $cd $f7 $39
	ld		de, roomLayoutData_1a36		; $17e6: $11 $36 $1a
	ld		hl, $98a5		; $17e9: $21 $a5 $98
	call		loadBGTileMapData			; $17ec: $cd $d4 $3a

	ld		hl, $98ad		; $17ef: $21 $ad $98
	call		func_3d8c			; $17f2: $cd $8c $3d
	ld		a, (wIsDemoScenes)		; $17f5: $fa $43 $cf
	and		a			; $17f8: $a7
	jr		z, +			; $17f9: $28 $04
	xor		a			; $17fb: $af
	ld		(wDifficulty), a		; $17fc: $ea $c0 $c2
+
	ld		a, (wIsDemoScenes)		; $17ff: $fa $43 $cf
	and		a			; $1802: $a7
	jr		z, +			; $1803: $28 $05
	ld		a, $05			; $1805: $3e $05
	ld		(wNumberOfRandomRoomsForDifficulty), a		; $1807: $ea $b9 $c2
+
	ld		hl, $98e7		; $180a: $21 $e7 $98
	call		func_3df0			; $180d: $cd $f0 $3d
	ld		a, (wIsDemoScenes)		; $1810: $fa $43 $cf
	and		a			; $1813: $a7
	jr		z, +			; $1814: $28 $05
	ld		a, $76			; $1816: $3e $76
	ld		($c2f1), a		; $1818: $ea $f1 $c2
+
	ld		hl, $9926		; $181b: $21 $26 $99
	call		func_20ad			; $181e: $cd $ad $20
	ld		hl, $9982		; $1821: $21 $82 $99
	ld		de, roomLayoutData_1a49		; $1824: $11 $49 $1a
	call		loadBGTileMapData			; $1827: $cd $d4 $3a
	call		func_18a3			; $182a: $cd $a3 $18
	ld		a, ($cef1)		; $182d: $fa $f1 $ce
	and		a			; $1830: $a7
	jr		z, func_1841			; $1831: $28 $0e
	cp		$04			; $1833: $fe $04
	jr		nz, func_183c			; $1835: $20 $05
	ld		de, roomLayoutData_1a1e		; $1837: $11 $1e $1a
	jr		func_1844			; $183a: $18 $08
func_183c:
	ld		de, roomLayoutData_1a12		; $183c: $11 $12 $1a
	jr		func_1844			; $183f: $18 $03
func_1841:
	ld		de, roomLayoutData_1a2a		; $1841: $11 $2a $1a
func_1844:
	ld		hl, $9865		; $1844: $21 $65 $98
	call		loadBGTileMapData			; $1847: $cd $d4 $3a
	jr		func_18a2			; $184a: $18 $56
func_184c:
	; stairs level
	ld		hl, $9866		; $184c: $21 $66 $98
	call		drawLevelClearScreen			; $184f: $cd $f7 $39

	ld		de, data_70db		; $1852: $11 $db $70
	ld		hl, $98e5		; $1855: $21 $e5 $98
	call		loadBGTileMapData			; $1858: $cd $d4 $3a
	ld		de, roomLayoutData_1a55		; $185b: $11 $55 $1a
	ld		hl, $98a3		; $185e: $21 $a3 $98
	call		loadBGTileMapData			; $1861: $cd $d4 $3a
	ld		hl, $98aa		; $1864: $21 $aa $98
	call		func_3d8c			; $1867: $cd $8c $3d
	ld		hl, $98ac		; $186a: $21 $ac $98
	scf					; $186d: $37
	call		func_3df0			; $186e: $cd $f0 $3d
	ld		a, ($cf3f)		; $1871: $fa $3f $cf
	and		a			; $1874: $a7
	jr		nz, func_1885			; $1875: $20 $0e
	ld		de, data_70c8		; $1877: $11 $c8 $70
	ld		a, ($cf1f)		; $187a: $fa $1f $cf
	and		a			; $187d: $a7
	jr		z, func_1891			; $187e: $28 $11
	ld		de, data_70ee		; $1880: $11 $ee $70
	jr		func_1891			; $1883: $18 $0c
func_1885:
	ld		de, data_70d1		; $1885: $11 $d1 $70
	ld		a, ($cf1f)		; $1888: $fa $1f $cf
	and		a			; $188b: $a7
	jr		z, func_1891			; $188c: $28 $03
	ld		de, data_70e4		; $188e: $11 $e4 $70
func_1891:
	ld		hl, $9866		; $1891: $21 $66 $98
	call		loadBGTileMapData			; $1894: $cd $d4 $3a
	ld		hl, $98ed		; $1897: $21 $ed $98
	ld		a, $ca			; $189a: $3e $ca
	ld		($cf0b), a		; $189c: $ea $0b $cf
	call		func_19bc			; $189f: $cd $bc $19
func_18a2:
	ret					; $18a2: $c9

func_18a3:
	ld		a, (wIsDemoScenes)		; $18a3: $fa $43 $cf
	and		a			; $18a6: $a7
	jr		z, func_18e2			; $18a7: $28 $39
	ld		hl, $cedf		; $18a9: $21 $df $ce
	ld		de, $cef2		; $18ac: $11 $f2 $ce
	ld		b, $0c			; $18af: $06 $0c
-
	ldi		a, (hl)			; $18b1: $2a
	ld		(de), a			; $18b2: $12
	inc		de			; $18b3: $13
	dec		b			; $18b4: $05
	jr		nz, -			; $18b5: $20 $fa
	ld		hl, data_1937		; $18b7: $21 $37 $19
	ld		de, $cedf		; $18ba: $11 $df $ce
	ld		b, $04			; $18bd: $06 $04
-
	ldi		a, (hl)			; $18bf: $2a
	ld		(de), a			; $18c0: $12
	inc		de			; $18c1: $13
	ldi		a, (hl)			; $18c2: $2a
	ld		(de), a			; $18c3: $12
	inc		de			; $18c4: $13
	ld		a, $0a			; $18c5: $3e $0a
	ld		(de), a			; $18c7: $12
	inc		de			; $18c8: $13
	dec		b			; $18c9: $05
	jr		nz, -			; $18ca: $20 $f3
	ld		hl, $cedf		; $18cc: $21 $df $ce
	call		func_1975			; $18cf: $cd $75 $19
	ld		de, $cedf		; $18d2: $11 $df $ce
	ld		hl, $cef2		; $18d5: $21 $f2 $ce
	ld		b, $0c			; $18d8: $06 $0c
-
	ldi		a, (hl)			; $18da: $2a
	ld		(de), a			; $18db: $12
	inc		de			; $18dc: $13
	dec		b			; $18dd: $05
	jr		nz, -			; $18de: $20 $fa
	jr		func_1936			; $18e0: $18 $54
func_18e2:
	xor		a			; $18e2: $af
	ld		($cef1), a		; $18e3: $ea $f1 $ce
	ld		a, ($c2f2)		; $18e6: $fa $f2 $c2
	ld		b, a			; $18e9: $47
	ld		($ceeb), a		; $18ea: $ea $eb $ce
	ld		a, ($c2f1)		; $18ed: $fa $f1 $c2
	ld		($ceec), a		; $18f0: $ea $ec $ce
	or		b			; $18f3: $b0
	jr		z, func_1930			; $18f4: $28 $3a
	ld		a, (wNumberOfRandomRoomsForDifficulty)		; $18f6: $fa $b9 $c2
	ld		($ceed), a		; $18f9: $ea $ed $ce
	ld		b, $04			; $18fc: $06 $04
	ld		hl, $cee8		; $18fe: $21 $e8 $ce
	ld		de, $ceeb		; $1901: $11 $eb $ce
func_1904:
	push		bc			; $1904: $c5
	ld		a, (hl)			; $1905: $7e
	ld		b, a			; $1906: $47
	ld		a, (de)			; $1907: $1a
	sub		b			; $1908: $90
	jr		c, func_191e			; $1909: $38 $13
	jr		z, func_1912			; $190b: $28 $05
	call		func_193f			; $190d: $cd $3f $19
	jr		func_191e			; $1910: $18 $0c
func_1912:
	inc		de			; $1912: $13
	inc		hl			; $1913: $23
	ldd		a, (hl)			; $1914: $3a
	ld		b, a			; $1915: $47
	ld		a, (de)			; $1916: $1a
	dec		de			; $1917: $1b
	sub		b			; $1918: $90
	jr		c, func_191e			; $1919: $38 $03
	call		func_193f			; $191b: $cd $3f $19
func_191e:
	pop		bc			; $191e: $c1
	ld		a, ($cef1)		; $191f: $fa $f1 $ce
	and		a			; $1922: $a7
	jr		z, func_1930			; $1923: $28 $0b
	dec		b			; $1925: $05
	jr		z, func_1930			; $1926: $28 $08
	dec		de			; $1928: $1b
	dec		de			; $1929: $1b
	dec		de			; $192a: $1b
	dec		hl			; $192b: $2b
	dec		hl			; $192c: $2b
	dec		hl			; $192d: $2b
	jr		func_1904			; $192e: $18 $d4
func_1930:
	ld		hl, $cedf		; $1930: $21 $df $ce
	call		func_1975			; $1933: $cd $75 $19
func_1936:
	ret					; $1936: $c9

data_1937:
	ld		(bc), a			; $1937: $02
	nop					; $1938: $00
	ld		bc, $0180		; $1939: $01 $80 $01
	ld		d, b			; $193c: $50
.db $01 $00

func_193f:
	push bc
	push		de			; $1940: $d5
	push		hl			; $1941: $e5
	ld		a, ($cef1)		; $1942: $fa $f1 $ce
	inc		a			; $1945: $3c
	ld		($cef1), a		; $1946: $ea $f1 $ce
	push		hl			; $1949: $e5
	push		de			; $194a: $d5
	ld		h, d			; $194b: $62
	ld		l, e			; $194c: $6b
	ld		c, $03			; $194d: $0e $03
	ld		de, $ceee		; $194f: $11 $ee $ce
-
	ldi		a, (hl)			; $1952: $2a
	ld		(de), a			; $1953: $12
	inc		de			; $1954: $13
	dec		c			; $1955: $0d
	jr		nz, -			; $1956: $20 $fa
	ld		b, $03			; $1958: $06 $03
	pop		de			; $195a: $d1
	pop		hl			; $195b: $e1
	push		hl			; $195c: $e5
	push		de			; $195d: $d5
-
	ldi		a, (hl)			; $195e: $2a
	ld		(de), a			; $195f: $12
	inc		de			; $1960: $13
	dec		b			; $1961: $05
	jr		nz, -			; $1962: $20 $fa
	pop		de			; $1964: $d1
	pop		hl			; $1965: $e1
	ld		de, $ceee		; $1966: $11 $ee $ce
	ld		b, $03			; $1969: $06 $03
-
	ld		a, (de)			; $196b: $1a
	ldi		(hl), a			; $196c: $22
	inc		de			; $196d: $13
	dec		b			; $196e: $05
	jr		nz, -			; $196f: $20 $fa
	pop		hl			; $1971: $e1
	pop		de			; $1972: $d1
	pop		bc			; $1973: $c1
	ret					; $1974: $c9

func_1975:
	ld		de, $9984		; $1975: $11 $84 $99
	ld		hl, $cedf		; $1978: $21 $df $ce
	ld		b, $04			; $197b: $06 $04
-
	push		bc			; $197d: $c5
	ldi		a, (hl)			; $197e: $2a
	ld		b, a			; $197f: $47
	ldi		a, (hl)			; $1980: $2a
	push		hl			; $1981: $e5
	ld		c, a			; $1982: $4f
	ld		h, d			; $1983: $62
	ld		l, e			; $1984: $6b
	call		func_19b0			; $1985: $cd $b0 $19
	pop		hl			; $1988: $e1
	ldi		a, (hl)			; $1989: $2a
	and		a			; $198a: $a7
	push		hl			; $198b: $e5
	push		af			; $198c: $f5
	ld		a, e			; $198d: $7b
	add		$08			; $198e: $c6 $08
	ld		l, a			; $1990: $6f
	ld		h, d			; $1991: $62
	pop		af			; $1992: $f1
	and		a			; $1993: $a7
	jr		z, +			; $1994: $28 $10
	call		func_3df3			; $1996: $cd $f3 $3d
	ld		a, e			; $1999: $7b
	add		$0b			; $199a: $c6 $0b
	ld		l, a			; $199c: $6f
	ld		h, d			; $199d: $62
	push		de			; $199e: $d5
	ld		de, roomLayoutData_1a51		; $199f: $11 $51 $1a
	call		loadBGTileMapData			; $19a2: $cd $d4 $3a
	pop		de			; $19a5: $d1
+
	pop		hl			; $19a6: $e1
	ld		a, e			; $19a7: $7b
	add		$20			; $19a8: $c6 $20
	ld		e, a			; $19aa: $5f
	pop		bc			; $19ab: $c1
	dec		b			; $19ac: $05
	jr		nz, -			; $19ad: $20 $ce
	ret					; $19af: $c9

func_19b0:
	ld		a, b			; $19b0: $78
	ld		($c2f2), a		; $19b1: $ea $f2 $c2
	ld		a, c			; $19b4: $79
	ld		($c2f1), a		; $19b5: $ea $f1 $c2
	call		func_20ad			; $19b8: $cd $ad $20
	ret					; $19bb: $c9

func_19bc:
	ld		d, h			; $19bc: $54
	ld		e, l			; $19bd: $5d
	push		hl			; $19be: $e5
	ld		a, ($c2bd)		; $19bf: $fa $bd $c2
	ld		l, a			; $19c2: $6f
	ld		h, $00			; $19c3: $26 $00
	ld		a, $02			; $19c5: $3e $02
	call		hlDivModA			; $19c7: $cd $2b $1f
	inc		l			; $19ca: $2c
	ld		b, l			; $19cb: $45
	ld		a, l			; $19cc: $7d
	ld		(wCursorOriginX), a		; $19cd: $ea $07 $cf
	pop		hl			; $19d0: $e1
	ld		c, $02			; $19d1: $0e $02
	call		func_1a08			; $19d3: $cd $08 $1a
	ld		h, d			; $19d6: $62
	ld		l, e			; $19d7: $6b
	ld		a, $40			; $19d8: $3e $40
	call		addAToHl			; $19da: $cd $6b $24
	ld		a, (wCursorOriginX)		; $19dd: $fa $07 $cf
	ld		b, a			; $19e0: $47
	dec		c			; $19e1: $0d
	call		nz, func_1a08		; $19e2: $c4 $08 $1a
	ld		a, ($c379)		; $19e5: $fa $79 $c3
	ld		h, d			; $19e8: $62
	ld		l, e			; $19e9: $6b
	ld		c, $02			; $19ea: $0e $02
--
	and		a			; $19ec: $a7
	jr		z, +			; $19ed: $28 $0b
	ld		b, a			; $19ef: $47
-
	call		waitUntilHBlankJustStarted			; $19f0: $cd $74 $1f
	ld		a, ($cf0b)		; $19f3: $fa $0b $cf
	ldd		(hl), a			; $19f6: $32
	dec		b			; $19f7: $05
	jr		nz, -			; $19f8: $20 $f6
+
	ld		h, d			; $19fa: $62
	ld		l, e			; $19fb: $6b
	ld		a, $40			; $19fc: $3e $40
	call		addAToHl			; $19fe: $cd $6b $24
	ld		a, ($c378)		; $1a01: $fa $78 $c3
	dec		c			; $1a04: $0d
	jr		nz, --			; $1a05: $20 $e5
	ret					; $1a07: $c9

func_1a08:
	call		waitUntilHBlankJustStarted			; $1a08: $cd $74 $1f
	ld		a, $46			; $1a0b: $3e $46
	ldd		(hl), a			; $1a0d: $32
	dec		b			; $1a0e: $05
	jr		nz, func_1a08			; $1a0f: $20 $f7
	ret					; $1a11: $c9

.include "layouts/group2.s"

func_1a64:
	xor		a			; $1a64: $af
	ld		b, $10			; $1a65: $06 $10
	ld		hl, $c2d4		; $1a67: $21 $d4 $c2
	; clear $c2d4 - $c2e3
-
	ldi		(hl), a			; $1a6a: $22
	dec		b			; $1a6b: $05
	jr		nz, -			; $1a6c: $20 $fc
	ld		($c2d1), a		; $1a6e: $ea $d1 $c2
	ld		(wNumCharacters), a		; $1a71: $ea $d0 $c2
	ld		hl, wRoomObjects		; $1a74: $21 $00 $c1
	ld		bc, ROOM_WIDTH*ROOM_HEIGHT		; $1a77: $01 $68 $01
func_1a7a:
	ld		a, (hl)			; $1a7a: $7e
	push		bc			; $1a7b: $c5
	ld		de, $c2d4		; $1a7c: $11 $d4 $c2
	ld		bc, $c2dc		; $1a7f: $01 $dc $c2
	cp		OBJ_KWIRK			; $1a82: $fe $c0
	jr		nz, +			; $1a84: $20 $05
	call		func_1aea			; $1a86: $cd $ea $1a
	jr		func_1ab0			; $1a89: $18 $25

+
	inc		de			; $1a8b: $13
	inc		de			; $1a8c: $13
	inc		bc			; $1a8d: $03
	inc		bc			; $1a8e: $03
	cp		OBJ_EDDIE_EGGPLANT			; $1a8f: $fe $c1
	jr		nz, +			; $1a91: $20 $05
	call		func_1aea			; $1a93: $cd $ea $1a
	jr		func_1ab0			; $1a96: $18 $18

+
	inc		de			; $1a98: $13
	inc		de			; $1a99: $13
	inc		bc			; $1a9a: $03
	inc		bc			; $1a9b: $03
	cp		OBJ_PEPPER_PETE			; $1a9c: $fe $c2
	jr		nz, +			; $1a9e: $20 $05
	call		func_1aea			; $1aa0: $cd $ea $1a
	jr		func_1ab0			; $1aa3: $18 $0b

+
	inc		de			; $1aa5: $13
	inc		de			; $1aa6: $13
	inc		bc			; $1aa7: $03
	inc		bc			; $1aa8: $03
	cp		OBJ_CURLY_CARROT			; $1aa9: $fe $c3
	jr		nz, +			; $1aab: $20 $18
	call		func_1aea			; $1aad: $cd $ea $1a
func_1ab0:
	ld		a, l			; $1ab0: $7d
	ld		(de), a			; $1ab1: $12
	ldh		(<hFF90), a		; $1ab2: $e0 $90
	ld		a, h			; $1ab4: $7c
	inc		de			; $1ab5: $13
	ld		(de), a			; $1ab6: $12
	ldh		(<hFF8F), a		; $1ab7: $e0 $8f
	call		func_1af7			; $1ab9: $cd $f7 $1a
	ldh		a, (<hFF8E)		; $1abc: $f0 $8e
	ld		(bc), a			; $1abe: $02
	ldh		a, (<hFF8D)		; $1abf: $f0 $8d
	inc		bc			; $1ac1: $03
	ld		(bc), a			; $1ac2: $02
	jr		@specialObjectProcessed			; $1ac3: $18 $17

+
	cp		OBJ_STAIRS			; $1ac5: $fe $10
	jr		nz, @specialObjectProcessed			; $1ac7: $20 $13
	ld		a, l			; $1ac9: $7d
	ldh		(<hFF90), a		; $1aca: $e0 $90
	ld		a, h			; $1acc: $7c
	ldh		(<hFF8F), a		; $1acd: $e0 $8f
	call		func_1af7			; $1acf: $cd $f7 $1a
	ldh		a, (<hFF8E)		; $1ad2: $f0 $8e
	ld		($c2e4), a		; $1ad4: $ea $e4 $c2
	ldh		a, (<hFF8D)		; $1ad7: $f0 $8d
	ld		($c2e5), a		; $1ad9: $ea $e5 $c2

@specialObjectProcessed:
	pop		bc			; $1adc: $c1
	inc		hl			; $1add: $23
	dec		bc			; $1ade: $0b
	ld		a, c			; $1adf: $79
	and		a			; $1ae0: $a7
	jp		nz, func_1a7a		; $1ae1: $c2 $7a $1a
	ld		a, b			; $1ae4: $78
	and		a			; $1ae5: $a7
	jp		nz, func_1a7a		; $1ae6: $c2 $7a $1a
	ret					; $1ae9: $c9
func_1aea:
	ld		a, $03			; $1aea: $3e $03
	ld		($c2d1), a		; $1aec: $ea $d1 $c2
	ld		a, (wNumCharacters)		; $1aef: $fa $d0 $c2
	inc		a			; $1af2: $3c
	ld		(wNumCharacters), a		; $1af3: $ea $d0 $c2
	ret					; $1af6: $c9
func_1af7:
	push		bc			; $1af7: $c5
	push		hl			; $1af8: $e5
	call		func_2bcb			; $1af9: $cd $cb $2b

func_1afc:
	pop		hl			; $1afc: $e1
	pop		bc			; $1afd: $c1
	ret					; $1afe: $c9

; scroll lines into level?
func_1aff:
	ld		hl, $c0ff		; $1aff: $21 $ff $c0
	ld		a, l			; $1b02: $7d
	ld		($cf1b), a		; $1b03: $ea $1b $cf
	ld		a, h			; $1b06: $7c
	ld		($cf1c), a		; $1b07: $ea $1c $cf
	ld		a, $01			; $1b0a: $3e $01
	ld		c, a			; $1b0c: $4f
	ld		($cf1d), a		; $1b0d: $ea $1d $cf
	ld		a, $09			; $1b10: $3e $09
	ld		b, a			; $1b12: $47
	ld		($cf1e), a		; $1b13: $ea $1e $cf
--
	ld		a, ($cf1b)		; $1b16: $fa $1b $cf
	ld		l, a			; $1b19: $6f
	ld		a, ($cf1c)		; $1b1a: $fa $1c $cf
	ld		h, a			; $1b1d: $67
	ld		a, ($cf1d)		; $1b1e: $fa $1d $cf
	ld		c, a			; $1b21: $4f
	ld		a, ($cf1e)		; $1b22: $fa $1e $cf
	ld		b, a			; $1b25: $47
-
	push		hl			; $1b26: $e5
	ld		e, c			; $1b27: $59
	ld		d, $00			; $1b28: $16 $00
	add		hl, de			; $1b2a: $19
	ld		a, (hl)			; $1b2b: $7e
	call		func_2731			; $1b2c: $cd $31 $27
	push		af			; $1b2f: $f5
	call		func_1ba3			; $1b30: $cd $a3 $1b
	call		waitUntilHBlankJustStarted			; $1b33: $cd $74 $1f
	pop		af			; $1b36: $f1
	ld		(de), a			; $1b37: $12
	pop		hl			; $1b38: $e1
	ld		de, $0029		; $1b39: $11 $29 $00
	add		hl, de			; $1b3c: $19
	ld		a, c			; $1b3d: $79
	cpl					; $1b3e: $2f
	inc		a			; $1b3f: $3c
	ld		e, a			; $1b40: $5f
	ld		d, $ff			; $1b41: $16 $ff
	add		hl, de			; $1b43: $19
	ld		a, (hl)			; $1b44: $7e
	call		func_2731			; $1b45: $cd $31 $27
	push		af			; $1b48: $f5
	call		func_1ba3			; $1b49: $cd $a3 $1b
	call		waitUntilHBlankJustStarted			; $1b4c: $cd $74 $1f
	pop		af			; $1b4f: $f1
	ld		(de), a			; $1b50: $12
	ld		e, c			; $1b51: $59
	dec		e			; $1b52: $1d
	ld		d, $00			; $1b53: $16 $00
	add		hl, de			; $1b55: $19
	dec		b			; $1b56: $05
	jr		z, +			; $1b57: $28 $03
	dec		c			; $1b59: $0d
	jr		nz, -			; $1b5a: $20 $ca
+
	call		waitUntilVBlankHandled_andXorCf39			; $1b5c: $cd $d2 $0f
	call		waitUntilVBlankHandled_andXorCf39			; $1b5f: $cd $d2 $0f
	ld		a, ($cf1d)		; $1b62: $fa $1d $cf
	inc		a			; $1b65: $3c
	cp		$15			; $1b66: $fe $15
	jr		nz, +			; $1b68: $20 $1e
	ld		a, ($cf1e)		; $1b6a: $fa $1e $cf
	dec		a			; $1b6d: $3d
	ld		($cf1e), a		; $1b6e: $ea $1e $cf
	ret		z			; $1b71: $c8
	ld		a, ($cf1b)		; $1b72: $fa $1b $cf
	ld		l, a			; $1b75: $6f
	ld		a, ($cf1c)		; $1b76: $fa $1c $cf
	ld		h, a			; $1b79: $67
	ld		de, $0028		; $1b7a: $11 $28 $00
	add		hl, de			; $1b7d: $19
	ld		a, l			; $1b7e: $7d
	ld		($cf1b), a		; $1b7f: $ea $1b $cf
	ld		a, h			; $1b82: $7c
	ld		($cf1c), a		; $1b83: $ea $1c $cf
	ld		a, $14			; $1b86: $3e $14
+
	ld		($cf1d), a		; $1b88: $ea $1d $cf
	jr		--			; $1b8b: $18 $89


; @param	hl		eg wRoomObjects
; @param	bc		eg size of data
func_1b8d:
	push		bc			; $1b8d: $c5
	ld		a, (hl)			; $1b8e: $7e
	call		func_2731			; $1b8f: $cd $31 $27
	push		af			; $1b92: $f5
	call		func_1ba3			; $1b93: $cd $a3 $1b
	call		waitUntilHBlankJustStarted			; $1b96: $cd $74 $1f
	pop		af			; $1b99: $f1
	ld		(de), a			; $1b9a: $12
	inc		hl			; $1b9b: $23
	pop		bc			; $1b9c: $c1
	dec		bc			; $1b9d: $0b
	ld		a, b			; $1b9e: $78
	or		c			; $1b9f: $b1
	jr		nz, func_1b8d			; $1ba0: $20 $eb
	ret					; $1ba2: $c9

func_1ba3:
	push		hl			; $1ba3: $e5
	push		bc			; $1ba4: $c5
	ld		a, h			; $1ba5: $7c
	sub		$c1			; $1ba6: $d6 $c1
	ld		h, a			; $1ba8: $67
	ld		a, $14			; $1ba9: $3e $14
	call		hlDivModA			; $1bab: $cd $2b $1f
	ld		b, $05			; $1bae: $06 $05
-
	sla		l			; $1bb0: $cb $25
	rl		h			; $1bb2: $cb $14
	dec		b			; $1bb4: $05
	jr		nz, -			; $1bb5: $20 $f9
	ld		e, a			; $1bb7: $5f
	ld		d, $00			; $1bb8: $16 $00
	add		hl, de			; $1bba: $19
	ld		de, $9800		; $1bbb: $11 $00 $98
	add		hl, de			; $1bbe: $19
	ld		d, h			; $1bbf: $54
	ld		e, l			; $1bc0: $5d
	pop		bc			; $1bc1: $c1
	pop		hl			; $1bc2: $e1
	ret					; $1bc3: $c9

loadInGameMenu:
	ld		hl, BG_MAP2
	ld		de, $0907
	call		loadPipesAndBlankTilesInside

	ld		hl, BG_MAP2+$e0
	ld		de, $0909
	call		loadPipesAndBlankTilesInside

	ld		de, inGameMenuOptionsLayoutData
	ld		hl, BG_MAP2+$42
	call		loadBGTileMapData
	ret

func_1be0:
	call		clear1st100bytesOfWram			; $1be0: $cd $81 $1f
	call		func_1aff			; $1be3: $cd $ff $1a
	ld		a, (wGameMode)		; $1be6: $fa $b8 $c2
	and		a			; $1be9: $a7
	jr		nz, func_1c21			; $1bea: $20 $35
	ld		hl, $c098		; $1bec: $21 $98 $c0
	ld		a, ($c2e5)		; $1bef: $fa $e5 $c2
	ldi		(hl), a			; $1bf2: $22
	ld		a, ($c2e4)		; $1bf3: $fa $e4 $c2
	ldi		(hl), a			; $1bf6: $22
	inc		hl			; $1bf7: $23
	inc		hl			; $1bf8: $23
	push		af			; $1bf9: $f5
	ld		a, ($c2e5)		; $1bfa: $fa $e5 $c2
	add		$08			; $1bfd: $c6 $08
	ldi		(hl), a			; $1bff: $22
	pop		af			; $1c00: $f1
	ldi		(hl), a			; $1c01: $22
	ld		hl, stairsOam		; $1c02: $21 $9a $c0
	ld		a, (wIsDiagonalView)		; $1c05: $fa $be $c2
	ld		de, data_3f01		; $1c08: $11 $01 $3f
	sla		a			; $1c0b: $cb $27
	add		e			; $1c0d: $83
	ld		e, a			; $1c0e: $5f
	ld		a, $00			; $1c0f: $3e $00
	adc		d			; $1c11: $8a
	ld		d, a			; $1c12: $57
	ld		a, (de)			; $1c13: $1a
	ldi		(hl), a			; $1c14: $22
	ld		a, $10			; $1c15: $3e $10
	ldi		(hl), a			; $1c17: $22
	inc		de			; $1c18: $13
	ld		a, (de)			; $1c19: $1a
	inc		hl			; $1c1a: $23
	inc		hl			; $1c1b: $23
	ldi		(hl), a			; $1c1c: $22
	ld		a, $90			; $1c1d: $3e $90
	ld		(hl), a			; $1c1f: $77
	ret					; $1c20: $c9
func_1c21:
	push		af			; $1c21: $f5
	call		func_1c2d			; $1c22: $cd $2d $1c
	pop		af			; $1c25: $f1
	dec		a			; $1c26: $3d
	jr		z, func_1c37			; $1c27: $28 $0e
	dec		a			; $1c29: $3d
	jr		z, func_1c4a			; $1c2a: $28 $1e
	ret					; $1c2c: $c9

func_1c2d:
	ld		hl, $99c0		; $1c2d: $21 $c0 $99
	ld		de, roomLayoutData_4026		; $1c30: $11 $26 $40
	call		loadBGTileMapData			; $1c33: $cd $d4 $3a
	ret					; $1c36: $c9
func_1c37:
	ld		hl, $99c0		; $1c37: $21 $c0 $99
	ld		de, roomLayoutData_410a		; $1c3a: $11 $0a $41
	call		loadBGTileMapData			; $1c3d: $cd $d4 $3a
	ld		hl, $9801		; $1c40: $21 $01 $98
	ld		de, roomLayoutData_406b		; $1c43: $11 $6b $40
	call		loadBGTileMapData			; $1c46: $cd $d4 $3a
	ret					; $1c49: $c9
func_1c4a:
	ld		hl, $9800		; $1c4a: $21 $00 $98
	ld		de, oppRoomsLayoutData		; $1c4d: $11 $b7 $40
	call		loadBGTileMapData			; $1c50: $cd $d4 $3a
	ld		hl, $980a		; $1c53: $21 $0a $98
	ld		de, roomLayoutData_40de		; $1c56: $11 $de $40
	call		loadBGTileMapData			; $1c59: $cd $d4 $3a
	ret					; $1c5c: $c9

; Unused?
func_1c5d:
	push		hl			; $1c5d: $e5
	push		de			; $1c5e: $d5
	push		bc			; $1c5f: $c5
	ldh		a, (<hFF8D)		; $1c60: $f0 $8d
	sub		$10			; $1c62: $d6 $10
	srl		a			; $1c64: $cb $3f
	srl		a			; $1c66: $cb $3f
	srl		a			; $1c68: $cb $3f
	ld		de, $0000		; $1c6a: $11 $00 $00
	ld		e, a			; $1c6d: $5f
	ld		hl, wRoomObjects		; $1c6e: $21 $00 $c1
	ld		c, $02			; $1c71: $0e $02
--
	ld		b, $02			; $1c73: $06 $02
-
	sla		e			; $1c75: $cb $23
	rl		d			; $1c77: $cb $12
	dec		b			; $1c79: $05
	jr		nz, -			; $1c7a: $20 $f9
	add		hl, de			; $1c7c: $19
	dec		c			; $1c7d: $0d
	jr		nz, --			; $1c7e: $20 $f3
	ldh		a, (<hFF8E)		; $1c80: $f0 $8e
	sub		$08			; $1c82: $d6 $08
	srl		a			; $1c84: $cb $3f
	srl		a			; $1c86: $cb $3f
	srl		a			; $1c88: $cb $3f
	ld		de, $0000		; $1c8a: $11 $00 $00
	ld		e, a			; $1c8d: $5f
	add		hl, de			; $1c8e: $19
	ld		a, h			; $1c8f: $7c
	ldh		(<hFF8F), a		; $1c90: $e0 $8f
	ld		a, l			; $1c92: $7d
	ldh		(<hFF90), a		; $1c93: $e0 $90
	pop		bc			; $1c95: $c1
	pop		de			; $1c96: $d1
	pop		hl			; $1c97: $e1
	ret					; $1c98: $c9

; Unused?
func_1c99:
	ld		a, ($c2d1)		; $1c99: $fa $d1 $c2
	ld		hl, $c2d4		; $1c9c: $21 $d4 $c2
	sla		a			; $1c9f: $cb $27
	push		de			; $1ca1: $d5
	ld		e, a			; $1ca2: $5f
	ld		d, $00			; $1ca3: $16 $00
	add		hl, de			; $1ca5: $19
	pop		de			; $1ca6: $d1
	ret					; $1ca7: $c9

func_1ca8:
	ld		a, ($c2d1)		; $1ca8: $fa $d1 $c2
	ld		de, $c2d4		; $1cab: $11 $d4 $c2
	sla		a			; $1cae: $cb $27
	add		e			; $1cb0: $83
	ld		e, a			; $1cb1: $5f
	ld		a, $00			; $1cb2: $3e $00
	adc		d			; $1cb4: $8a
	ld		d, a			; $1cb5: $57
	ld		a, (de)			; $1cb6: $1a
	ld		l, a			; $1cb7: $6f
	inc		de			; $1cb8: $13
	ld		a, (de)			; $1cb9: $1a
	ld		h, a			; $1cba: $67
	ret					; $1cbb: $c9

func_1cbc:
	ld		a, ($c2d1)		; $1cbc: $fa $d1 $c2
	ld		hl, $c2dc		; $1cbf: $21 $dc $c2
	sla		a			; $1cc2: $cb $27
	push		de			; $1cc4: $d5
	ld		e, a			; $1cc5: $5f
	ld		d, $00			; $1cc6: $16 $00
	add		hl, de			; $1cc8: $19
	pop		de			; $1cc9: $d1
	ret					; $1cca: $c9

func_1ccb:
	; de += 4*$cd21 + b
	ld		a, ($c2d1)		; $1ccb: $fa $d1 $c2
	ld		de, wOam		; $1cce: $11 $00 $c0
	sla		a			; $1cd1: $cb $27
	sla		a			; $1cd3: $cb $27
	add		b			; $1cd5: $80
	add		e			; $1cd6: $83
	ld		e, a			; $1cd7: $5f
	ld		a, $00			; $1cd8: $3e $00
	adc		d			; $1cda: $8a
	ld		d, a			; $1cdb: $57
	ret					; $1cdc: $c9

; draws in-game screen details for scrolling level?
func_1cdd:
	ld		b, SND_12			; $1cdd: $06 $12
	rst_playSound

	; TODO: redundant check? this is only called by 1 function that checks this
	ld		a, (wGameMode)		; $1ce0: $fa $b8 $c2
	cp		GAMEMODE_HEADING_OUT			; $1ce3: $fe $01
	jr		nz, +			; $1ce5: $20 $03
	; scrolling level
	call		func_20b2			; $1ce7: $cd $b2 $20
+
	ld		a, (wc2bb)		; $1cea: $fa $bb $c2
	ld		b, a			; $1ced: $47
	ld		a, (wNumberOfRandomRoomsForDifficulty)		; $1cee: $fa $b9 $c2
	sub		b			; $1cf1: $90
	inc		a			; $1cf2: $3c
	call		get2DigitsToDrawFromNonBCD_A			; $1cf3: $cd $12 $21
	ld		hl, $9a03		; $1cf6: $21 $03 $9a
	call		draw2DigitsAtHl			; $1cf9: $cd $5d $20
	call		func_3693			; $1cfc: $cd $93 $36
	ld		hl, $c177		; $1cff: $21 $77 $c1
	ld		a, l			; $1d02: $7d
	ld		($c2f6), a		; $1d03: $ea $f6 $c2
	ld		a, h			; $1d06: $7c
	ld		($c2f7), a		; $1d07: $ea $f7 $c2
	ld		hl, $c27c		; $1d0a: $21 $7c $c2
	ld		b, $0c			; $1d0d: $06 $0c
-
	ld		a, $d8			; $1d0f: $3e $d8
	ldi		(hl), a			; $1d11: $22
	dec		b			; $1d12: $05
	jr		nz, -			; $1d13: $20 $fa
	ld		hl, $c288		; $1d15: $21 $88 $c2
	ld		bc, $000c		; $1d18: $01 $0c $00
	ld		a, $ff			; $1d1b: $3e $ff
	push		af			; $1d1d: $f5
	ld		a, (wIsDiagonalView)		; $1d1e: $fa $be $c2
	and		a			; $1d21: $a7
	jr		z, func_1d29			; $1d22: $28 $05
	pop		af			; $1d24: $f1
	ld		a, $fb			; $1d25: $3e $fb
	jr		func_1d2a			; $1d27: $18 $01
func_1d29:
	pop		af			; $1d29: $f1
func_1d2a:
	call		setA_bcTimesToHl			; $1d2a: $cd $27 $2c
	ld		a, $02			; $1d2d: $3e $02
	ld		($c2f9), a		; $1d2f: $ea $f9 $c2
	ld		a, $0c			; $1d32: $3e $0c
	ld		($c2f8), a		; $1d34: $ea $f8 $c2
	ld		hl, $98f4		; $1d37: $21 $f4 $98
	call		func_283c			; $1d3a: $cd $3c $28
	call		waitUntilVBlankHandled_andXorCf39			; $1d3d: $cd $d2 $0f
	ld		c, $80			; $1d40: $0e $80
	xor		a			; $1d42: $af
	ld		($cf1f), a		; $1d43: $ea $1f $cf
func_1d46:
	ld		a, (wIsDemoScenes)		; $1d46: $fa $43 $cf
	and		a			; $1d49: $a7
	call		nz, resetSerialTransfer		; $1d4a: $c4 $11 $70
	ldh		a, (R_SCX)		; $1d4d: $f0 $43
	push		af			; $1d4f: $f5
	di					; $1d50: $f3
-
	ldh		a, (R_LY)		; $1d51: $f0 $44
	cp		$28			; $1d53: $fe $28
	jr		z, func_1d59			; $1d55: $28 $02
	jr		-			; $1d57: $18 $f8
func_1d59:
	ld		a, ($cf1f)		; $1d59: $fa $1f $cf
	sub		$02			; $1d5c: $d6 $02
	ld		($cf1f), a		; $1d5e: $ea $1f $cf
	ldh		(R_SCX), a		; $1d61: $e0 $43
	ld		($ceff), a		; $1d63: $ea $ff $ce
	ei					; $1d66: $fb
	and		$07			; $1d67: $e6 $07
	jr		nz, +			; $1d69: $20 $20
	push		bc			; $1d6b: $c5
	ld		a, $01			; $1d6c: $3e $01
	ld		($c2f8), a		; $1d6e: $ea $f8 $c2
	ld		a, $08			; $1d71: $3e $08
	ld		($c2f9), a		; $1d73: $ea $f9 $c2
	call		func_26e2			; $1d76: $cd $e2 $26
	ld		a, ($c2f6)		; $1d79: $fa $f6 $c2
	ld		l, a			; $1d7c: $6f
	ld		a, ($c2f7)		; $1d7d: $fa $f7 $c2
	ld		h, a			; $1d80: $67
	dec		hl			; $1d81: $2b
	ld		a, l			; $1d82: $7d
	ld		($c2f6), a		; $1d83: $ea $f6 $c2
	ld		a, h			; $1d86: $7c
	ld		($c2f7), a		; $1d87: $ea $f7 $c2
	pop		bc			; $1d8a: $c1
+
	ld		b, $01			; $1d8b: $06 $01
	call		func_1ccb			; $1d8d: $cd $cb $1c
	ld		h, d			; $1d90: $62
	ld		l, e			; $1d91: $6b
	ld		a, (hl)			; $1d92: $7e
	add		$02			; $1d93: $c6 $02
	cp		$9a			; $1d95: $fe $9a
	jr		z, +			; $1d97: $28 $06
	ld		(hl), a			; $1d99: $77
	ld		de, $0088		; $1d9a: $11 $88 $00
	add		hl, de			; $1d9d: $19
	ld		(hl), a			; $1d9e: $77
+
	di					; $1d9f: $f3
-
	ldh		a, (R_LY)		; $1da0: $f0 $44
	cp		$68			; $1da2: $fe $68
	jr		z, func_1da8			; $1da4: $28 $02
	jr		-			; $1da6: $18 $f8
func_1da8:
	pop		af			; $1da8: $f1
	ldh		(R_SCX), a		; $1da9: $e0 $43
	ei					; $1dab: $fb
	ld		hl, $9a0e		; $1dac: $21 $0e $9a
	call		func_207d			; $1daf: $cd $7d $20
	call		waitUntilVBlankHandled_andXorCf39			; $1db2: $cd $d2 $0f
	dec		c			; $1db5: $0d
	jp		nz, func_1d46		; $1db6: $c2 $46 $1d
	xor		a			; $1db9: $af
	ld		($ceff), a		; $1dba: $ea $ff $ce
	ld		hl, $c178		; $1dbd: $21 $78 $c1
	ld		bc, $0078		; $1dc0: $01 $78 $00
	call		func_1b8d			; $1dc3: $cd $8d $1b
	ld		hl, $9a0e		; $1dc6: $21 $0e $9a
	call		func_207d			; $1dc9: $cd $7d $20
	call		func_7000			; $1dcc: $cd $00 $70
	call		func_1dd9			; $1dcf: $cd $d9 $1d
	ld		hl, $9a0e		; $1dd2: $21 $0e $9a
	call		func_207d			; $1dd5: $cd $7d $20
	ret					; $1dd8: $c9

func_1dd9:
	ld		b, $03			; $1dd9: $06 $03
	ld		de, $0000		; $1ddb: $11 $00 $00
	ld		a, (wIsDiagonalView)		; $1dde: $fa $be $c2
	and		a			; $1de1: $a7
	jr		z, +			; $1de2: $28 $05

	; is diagonal view
	ld		b, $04			; $1de4: $06 $04
	ld		de, $0003		; $1de6: $11 $03 $00
+
	ld		hl, data_4136		; $1de9: $21 $36 $41
	add		hl, de			; $1dec: $19
	ld		de, $c010		; $1ded: $11 $10 $c0
	ld		a, $50			; $1df0: $3e $50
	ld		(de), a			; $1df2: $12
	inc		de			; $1df3: $13
	ld		a, $a0			; $1df4: $3e $a0
	ld		(de), a			; $1df6: $12
	inc		de			; $1df7: $13
	inc		de			; $1df8: $13
	xor		a			; $1df9: $af
	ld		(de), a			; $1dfa: $12
	dec		de			; $1dfb: $1b
--
	ldi		a, (hl)			; $1dfc: $2a
	ld		(de), a			; $1dfd: $12
	ld		c, $0f			; $1dfe: $0e $0f
-
	call		waitUntilVBlankHandled_andXorCf39			; $1e00: $cd $d2 $0f
	dec		c			; $1e03: $0d
	jr		nz, -			; $1e04: $20 $fa
	dec		b			; $1e06: $05
	jr		nz, --			; $1e07: $20 $f3
	ld		a, $f0			; $1e09: $3e $f0
	ld		($c1b3), a		; $1e0b: $ea $b3 $c1
	call		waitUntilHBlankJustStarted			; $1e0e: $cd $74 $1f
	ld		a, $d0			; $1e11: $3e $d0
	ld		($9913), a		; $1e13: $ea $13 $99
	call		waitUntilHBlankJustStarted			; $1e16: $cd $74 $1f
	ld		a, $d0			; $1e19: $3e $d0
	ld		($9913), a		; $1e1b: $ea $13 $99
	ret					; $1e1e: $c9

func_1e1f:
	ld		($cf21), a		; $1e1f: $ea $21 $cf
	ld		a, ($c380)		; $1e22: $fa $80 $c3
	dec		a			; $1e25: $3d
	ld		($c380), a		; $1e26: $ea $80 $c3
	and		a			; $1e29: $a7
	ret		z			; $1e2a: $c8
	ld		a, ($c380)		; $1e2b: $fa $80 $c3
	ld		b, a			; $1e2e: $47
	ld		a, ($c37f)		; $1e2f: $fa $7f $c3
	cp		b			; $1e32: $b8
	jr		nz, func_1e39			; $1e33: $20 $04
	ld		a, $10			; $1e35: $3e $10
	jr		func_1e73			; $1e37: $18 $3a

func_1e39:
	ld		hl, 1600		; $1e39: $21 $40 $06
	ld		a, ($c37f)		; $1e3c: $fa $7f $c3
	call		hlDivModA			; $1e3f: $cd $2b $1f
	ld		a, 100			; $1e42: $3e $64
	call		hlDivModA			; $1e44: $cd $2b $1f
	ld		b, a			; $1e47: $47
	ld		a, ($c380)		; $1e48: $fa $80 $c3
	call		hlTimesEqualsA			; $1e4b: $cd $4d $1f
	push		hl			; $1e4e: $e5
	ld		l, b			; $1e4f: $68
	ld		h, $00			; $1e50: $26 $00
	ld		a, ($c380)		; $1e52: $fa $80 $c3
	call		hlTimesEqualsA			; $1e55: $cd $4d $1f
	ld		a, $64			; $1e58: $3e $64
	call		hlDivModA			; $1e5a: $cd $2b $1f
	push		hl			; $1e5d: $e5
	add		$32			; $1e5e: $c6 $32
	ld		l, a			; $1e60: $6f
	ld		h, $00			; $1e61: $26 $00
	ld		a, $64			; $1e63: $3e $64
	call		hlDivModA			; $1e65: $cd $2b $1f
	ld		e, l			; $1e68: $5d
	ld		d, $00			; $1e69: $16 $00
	pop		hl			; $1e6b: $e1
	add		hl, de			; $1e6c: $19
	ld		e, l			; $1e6d: $5d
	ld		d, $00			; $1e6e: $16 $00
	pop		hl			; $1e70: $e1
	add		hl, de			; $1e71: $19
	ld		a, l			; $1e72: $7d
func_1e73:
	ld		($cf22), a		; $1e73: $ea $22 $cf
	ld		hl, $982b		; $1e76: $21 $2b $98
	ld		a, (wGameMode)		; $1e79: $fa $b8 $c2
	cp		GAMEMODE_HEADING_OUT			; $1e7c: $fe $01
	jr		nz, +			; $1e7e: $20 $03
	ld		hl, $99c1		; $1e80: $21 $c1 $99
+
	ld		de, $0008		; $1e83: $11 $08 $00
	add		hl, de			; $1e86: $19
	ld		a, ($cf21)		; $1e87: $fa $21 $cf
	sla		a			; $1e8a: $cb $27
	sla		a			; $1e8c: $cb $27
	sla		a			; $1e8e: $cb $27
	sla		a			; $1e90: $cb $27
	sla		a			; $1e92: $cb $27
	ld		e, a			; $1e94: $5f
	add		hl, de			; $1e95: $19
	ld		a, ($cf22)		; $1e96: $fa $22 $cf
	and		a			; $1e99: $a7
	jp		z, func_1f26		; $1e9a: $ca $26 $1f
	cpl					; $1e9d: $2f
	inc		a			; $1e9e: $3c
	sra		a			; $1e9f: $cb $2f
	ld		e, a			; $1ea1: $5f
	ld		d, $ff			; $1ea2: $16 $ff
	add		hl, de			; $1ea4: $19
	ld		a, l			; $1ea5: $7d
	ld		($c2fb), a		; $1ea6: $ea $fb $c2
	ld		a, h			; $1ea9: $7c
	ld		($c2fc), a		; $1eaa: $ea $fc $c2
	ld		a, ($cf22)		; $1ead: $fa $22 $cf
	bit		0, a			; $1eb0: $cb $47
	jr		z, func_1eb8			; $1eb2: $28 $04
	ld		a, $dd			; $1eb4: $3e $dd
	jr		func_1eba			; $1eb6: $18 $02
func_1eb8:
	ld		a, $85			; $1eb8: $3e $85
func_1eba:
	push		af			; $1eba: $f5
	ld		a, ($cf22)		; $1ebb: $fa $22 $cf
	cp		$0f			; $1ebe: $fe $0f
	jr		c, func_1ec6			; $1ec0: $38 $04
	pop		af			; $1ec2: $f1
	dec		a			; $1ec3: $3d
	jr		func_1ec7			; $1ec4: $18 $01
func_1ec6:
	pop		af			; $1ec6: $f1
func_1ec7:
	push		af			; $1ec7: $f5
	ld		a, $01			; $1ec8: $3e $01
	ldh		(R_IE), a		; $1eca: $e0 $ff
	call		waitUntilHBlankJustStarted			; $1ecc: $cd $74 $1f
	pop		af			; $1ecf: $f1
	ld		(hl), a			; $1ed0: $77
	push		af			; $1ed1: $f5
	call		waitUntilHBlankJustStarted			; $1ed2: $cd $74 $1f
	pop		af			; $1ed5: $f1
	ldi		(hl), a			; $1ed6: $22
	ld		a, $09			; $1ed7: $3e $09
	ldh		(R_IE), a		; $1ed9: $e0 $ff
	ld		a, ($cf22)		; $1edb: $fa $22 $cf
	ld		b, a			; $1ede: $47
	dec		b			; $1edf: $05
	sra		b			; $1ee0: $cb $28
	jr		z, func_1efd			; $1ee2: $28 $19
-
	dec		b			; $1ee4: $05
	jr		z, func_1efd			; $1ee5: $28 $16
	ld		a, $01			; $1ee7: $3e $01
	ldh		(R_IE), a		; $1ee9: $e0 $ff
	call		waitUntilHBlankJustStarted			; $1eeb: $cd $74 $1f
	ld		a, $85			; $1eee: $3e $85
	ld		(hl), a			; $1ef0: $77
	call		waitUntilHBlankJustStarted			; $1ef1: $cd $74 $1f
	ld		a, $85			; $1ef4: $3e $85
	ldi		(hl), a			; $1ef6: $22
	ld		a, $09			; $1ef7: $3e $09
	ldh		(R_IE), a		; $1ef9: $e0 $ff
	jr		-			; $1efb: $18 $e7
func_1efd:
	ld		a, ($cf22)		; $1efd: $fa $22 $cf
	cp		$03			; $1f00: $fe $03
	jr		nc, func_1f12			; $1f02: $30 $0e
	ld		a, INT_VBLANK			; $1f04: $3e $01
	ldh		(R_IE), a		; $1f06: $e0 $ff
	dec		hl			; $1f08: $2b
	call		waitUntilHBlankJustStarted			; $1f09: $cd $74 $1f
	inc		(hl)			; $1f0c: $34
	ld		a, INT_VBLANK|INT_SERIAL			; $1f0d: $3e $09
	ldh		(R_IE), a		; $1f0f: $e0 $ff
	ret					; $1f11: $c9

func_1f12:
	ld		a, INT_VBLANK			; $1f12: $3e $01
	ldh		(R_IE), a		; $1f14: $e0 $ff
	call		waitUntilHBlankJustStarted			; $1f16: $cd $74 $1f
	ld		a, $86			; $1f19: $3e $86
	ld		(hl), a			; $1f1b: $77
	call		waitUntilHBlankJustStarted			; $1f1c: $cd $74 $1f
	ld		a, $86			; $1f1f: $3e $86
	ld		(hl), a			; $1f21: $77
	ld		a, INT_VBLANK|INT_SERIAL			; $1f22: $3e $09
	ldh		(R_IE), a		; $1f24: $e0 $ff
func_1f26:
	ld		a, INT_VBLANK|INT_SERIAL			; $1f26: $3e $09
	ldh		(R_IE), a		; $1f28: $e0 $ff
	ret					; $1f2a: $c9

;;
; @param[out]	a		hl / a
; @param[out]	l		hl % a
hlDivModA:
	push		bc			; $1f2b: $c5
	push		de			; $1f2c: $d5
	ld		c, $10			; $1f2d: $0e $10
	ld		b, a			; $1f2f: $47
	xor		a			; $1f30: $af
	ld		d, a			; $1f31: $57
	rl		l			; $1f32: $cb $15
	rl		h			; $1f34: $cb $14
-
	rl		d			; $1f36: $cb $12
	ld		a, b			; $1f38: $78
	cp		d			; $1f39: $ba
	jr		z, +			; $1f3a: $28 $02
	jr		nc, ++			; $1f3c: $30 $04
+
	; a <= d
	ld		a, d			; $1f3e: $7a
	sub		b			; $1f3f: $90
	ld		d, a			; $1f40: $57
	scf					; $1f41: $37
++
	rl		l			; $1f42: $cb $15
	rl		h			; $1f44: $cb $14
	dec		c			; $1f46: $0d
	jr		nz, -			; $1f47: $20 $ed
	ld		a, d			; $1f49: $7a
	pop		de			; $1f4a: $d1
	pop		bc			; $1f4b: $c1
	ret					; $1f4c: $c9


hlTimesEqualsA:
	push		de			; $1f4d: $d5
	push		bc			; $1f4e: $c5
	ld		e, l			; $1f4f: $5d
	ld		d, h			; $1f50: $54
	ld		hl, $0000		; $1f51: $21 $00 $00
-
	; unset carry flag
	scf					; $1f54: $37
	ccf					; $1f55: $3f

	rra					; $1f56: $1f
	jr		nc, +			; $1f57: $30 $01
	; every bit of a rotated into carry flag, add original hl
	add		hl, de			; $1f59: $19
+
	sla		e			; $1f5a: $cb $23
	rl		d			; $1f5c: $cb $12
	and		a			; $1f5e: $a7
	jr		nz, -			; $1f5f: $20 $f3
	pop		bc			; $1f61: $c1
	pop		de			; $1f62: $d1
	ret					; $1f63: $c9

func_1f64:
	push		af			; $1f64: $f5
	push		de			; $1f65: $d5
	ld		a, ($c2f8)		; $1f66: $fa $f8 $c2
	ld		e, a			; $1f69: $5f
	ld		a, $14			; $1f6a: $3e $14
	sub		e			; $1f6c: $93
	ld		e, a			; $1f6d: $5f
	ld		d, $00			; $1f6e: $16 $00
	add		hl, de			; $1f70: $19
	pop		de			; $1f71: $d1
	pop		af			; $1f72: $f1
	ret					; $1f73: $c9


waitUntilHBlankJustStarted:
-
	ldh		a, (R_STAT)		; $1f74: $f0 $41
	bit		1, a			; $1f76: $cb $4f
	jr		z, -			; $1f78: $28 $fa
-
	ldh		a, (R_STAT)		; $1f7a: $f0 $41
	and		$03			; $1f7c: $e6 $03
	ret		z			; $1f7e: $c8
	jr		-			; $1f7f: $18 $f9


; clears wOam and $c0a0-$c0ff
clear1st100bytesOfWram:
	ld		hl, wOam		; $1f81: $21 $00 $c0
	ld		bc, $00ff		; $1f84: $01 $ff $00
	ld		a, $00			; $1f87: $3e $00
	call		setA_bcTimesToHl			; $1f89: $cd $27 $2c
	ret					; $1f8c: $c9

func_1f8d:
	ld		a, ($cedb)		; $1f8d: $fa $db $ce
	inc		a			; $1f90: $3c
	cp		$09			; $1f91: $fe $09
	jr		nz, +			; $1f93: $20 $01
	dec		a			; $1f95: $3d
+
	ld		($cedb), a		; $1f96: $ea $db $ce
	ld		a, ($ceda)		; $1f99: $fa $da $ce
	ld		hl, $c382		; $1f9c: $21 $82 $c3
	call		addAToHl			; $1f9f: $cd $6b $24
	ld		a, ($c2d1)		; $1fa2: $fa $d1 $c2
	ld		(hl), a			; $1fa5: $77
	call		func_1ca8			; $1fa6: $cd $a8 $1c
	ld		e, l			; $1fa9: $5d
	ld		d, h			; $1faa: $54
	ld		a, ($ceda)		; $1fab: $fa $da $ce
	sla		a			; $1fae: $cb $27
	ld		hl, $c38a		; $1fb0: $21 $8a $c3
	call		addAToHl			; $1fb3: $cd $6b $24
	ld		a, e			; $1fb6: $7b
	ldi		(hl), a			; $1fb7: $22
	ld		a, d			; $1fb8: $7a
	ld		(hl), a			; $1fb9: $77
	ld		hl, ROOM_WIDTH*ROOM_HEIGHT		; $1fba: $21 $68 $01
	ld		a, ($ceda)		; $1fbd: $fa $da $ce
	call		hlTimesEqualsA			; $1fc0: $cd $4d $1f
	ld		de, $c39a		; $1fc3: $11 $9a $c3
	add		hl, de			; $1fc6: $19
	ld		e, l			; $1fc7: $5d
	ld		d, h			; $1fc8: $54
	ld		hl, wRoomObjects		; $1fc9: $21 $00 $c1
	ld		bc, ROOM_WIDTH*ROOM_HEIGHT		; $1fcc: $01 $68 $01
	call		copyMemoryBc			; $1fcf: $cd $47 $2c
	ld		a, ($ceda)		; $1fd2: $fa $da $ce
	inc		a			; $1fd5: $3c
	cp		$08			; $1fd6: $fe $08
	jr		nz, +			; $1fd8: $20 $01
	xor		a			; $1fda: $af
+
	ld		($ceda), a		; $1fdb: $ea $da $ce
	ld		de, backLayoutData		; $1fde: $11 $55 $41
	ld		hl, $9da2		; $1fe1: $21 $a2 $9d
	
loadBGTileMapData_2:
	call		loadBGTileMapData			; $1fe4: $cd $d4 $3a
	ret					; $1fe7: $c9

undoGameStep:
	ld		a, ($cf37)		; $1fe8: $fa $37 $cf
	and		a			; $1feb: $a7
	ret		z			; $1fec: $c8
	ld		a, ($ceda)		; $1fed: $fa $da $ce
	dec		a			; $1ff0: $3d
	cp		$ff			; $1ff1: $fe $ff
	jr		nz, +			; $1ff3: $20 $02
	ld		a, $07			; $1ff5: $3e $07
+
	ld		($ceda), a		; $1ff7: $ea $da $ce
	ld		hl, ROOM_WIDTH*ROOM_HEIGHT		; $1ffa: $21 $68 $01
	call		hlTimesEqualsA			; $1ffd: $cd $4d $1f
	ld		de, $c39a		; $2000: $11 $9a $c3
	add		hl, de			; $2003: $19
	ld		de, wRoomObjects		; $2004: $11 $00 $c1
	ld		bc, ROOM_WIDTH*ROOM_HEIGHT		; $2007: $01 $68 $01
	call		copyMemoryBc			; $200a: $cd $47 $2c
	ld		hl, $c38a		; $200d: $21 $8a $c3
	ld		a, ($ceda)		; $2010: $fa $da $ce
	sla		a			; $2013: $cb $27
	call		addAToHl			; $2015: $cd $6b $24
	ldi		a, (hl)			; $2018: $2a
	ld		e, a			; $2019: $5f
	ld		a, (hl)			; $201a: $7e
	ld		d, a			; $201b: $57
	ld		hl, $c382		; $201c: $21 $82 $c3
	ld		a, ($ceda)		; $201f: $fa $da $ce
	call		addAToHl			; $2022: $cd $6b $24
	ld		a, (hl)			; $2025: $7e
	push		af			; $2026: $f5
	ld		($c2d1), a		; $2027: $ea $d1 $c2
	or		$c0			; $202a: $f6 $c0
	ld		(de), a			; $202c: $12
	call		func_1a64			; $202d: $cd $64 $1a
	ld		hl, wRoomObjects		; $2030: $21 $00 $c1
	ld		bc, ROOM_WIDTH*ROOM_HEIGHT		; $2033: $01 $68 $01
	call		func_1b8d			; $2036: $cd $8d $1b
	pop		af			; $2039: $f1
	dec		a			; $203a: $3d
	cp		$ff			; $203b: $fe $ff
	jr		nz, +			; $203d: $20 $02
	ld		a, $03			; $203f: $3e $03
+
	ld		($c2d1), a		; $2041: $ea $d1 $c2
	call		func_1400			; $2044: $cd $00 $14
	ld		a, ($cedb)		; $2047: $fa $db $ce
	dec		a			; $204a: $3d
	ld		($cedb), a		; $204b: $ea $db $ce
	and		a			; $204e: $a7
	ret		nz			; $204f: $c0
	xor		a			; $2050: $af
	ld		($cf37), a		; $2051: $ea $37 $cf
	
	; clear out undo step
	ld		de, fourBlankSpacesLayoutData		; $2054: $11 $5a $41
	ld		hl, $9d82		; $2057: $21 $82 $9d
	jp		loadBGTileMapData_2			; $205a: $c3 $e4 $1f


;;
; @param	hl		address in tilemap for 2 bytes of data
; @param	a		ascii digits to put in vram
;					byte 1 is upper nybble+$3c (or $ff if $f)
;					byte 2 is lower nybble+$3c (or $ff if $f)
draw2DigitsAtHl:
	push		af
	push		af
	swap		a
	call		drawDigitAtHl
	pop		af
	call		drawDigitAtHl
	pop		af
	ret

;;
; Will store $ff in tilemap if lower nybble is $f
; Otherwise will place the ascii digit (lower nybble+$3c)
; @param	hl		tilemap location
; @param	a		value whose lower nybble to place there
drawDigitAtHl:
	and		$0f
	cp		$0f
	jr		z, @lowerNybbleIsF
	add		$3c
-
	push		af
	call		waitUntilHBlankJustStarted
	pop		af
	ldi		(hl), a
	ret
@lowerNybbleIsF:
	ld		a, $ff
	jr		-

func_207d:
	ld		a, ($c2ee)		; $207d: $fa $ee $c2
	call		get2DigitsToDrawFromBCD_A			; $2080: $cd $28 $21
	call		draw2DigitsAtHl			; $2083: $cd $5d $20
	inc		hl			; $2086: $23
	ld		a, ($c2ed)		; $2087: $fa $ed $c2
	call		draw2DigitsAtHl			; $208a: $cd $5d $20
	ret					; $208d: $c9

func_208e:
	push		bc			; $208e: $c5
	ld		a, ($c2eb)		; $208f: $fa $eb $c2
	call		get2DigitsToDrawFromBCD_A			; $2092: $cd $28 $21
	cp		$f0			; $2095: $fe $f0
	jr		nz, +			; $2097: $20 $02
	ld		a, $ff			; $2099: $3e $ff
+
	ld		b, a			; $209b: $47
	call		draw2DigitsAtHl			; $209c: $cd $5d $20
	ld		a, ($c2ea)		; $209f: $fa $ea $c2
	inc		b			; $20a2: $04
	jr		nz, +			; $20a3: $20 $03
	call		get2DigitsToDrawFromBCD_A			; $20a5: $cd $28 $21
+
	call		draw2DigitsAtHl			; $20a8: $cd $5d $20
	pop		bc			; $20ab: $c1
	ret					; $20ac: $c9

func_20ad:
	ld		a, ($c2f2)		; $20ad: $fa $f2 $c2
	jr		func_20ca			; $20b0: $18 $18

func_20b2:
	ld		a, ($c2f0)		; $20b2: $fa $f0 $c2
	ld		b, a			; $20b5: $47
	ld		a, ($c2f1)		; $20b6: $fa $f1 $c2
	add		b			; $20b9: $80
	daa					; $20ba: $27
	ld		($c2f1), a		; $20bb: $ea $f1 $c2
	ld		a, ($c2f2)		; $20be: $fa $f2 $c2
	adc		$00			; $20c1: $ce $00
	daa					; $20c3: $27
	ld		($c2f2), a		; $20c4: $ea $f2 $c2
	ld		hl, $9843		; $20c7: $21 $43 $98
func_20ca:
	push		af			; $20ca: $f5
	ld		a, $01			; $20cb: $3e $01
	ld		($cf38), a		; $20cd: $ea $38 $cf
	pop		af			; $20d0: $f1
	call		func_20f0			; $20d1: $cd $f0 $20
	ld		a, ($c2f1)		; $20d4: $fa $f1 $c2
	call		func_20f0			; $20d7: $cd $f0 $20
	xor		a			; $20da: $af
	call		func_20f0			; $20db: $cd $f0 $20
	dec		hl			; $20de: $2b
	dec		hl			; $20df: $2b
	ld		a, ($c2f1)		; $20e0: $fa $f1 $c2
	ld		b, a			; $20e3: $47
	ld		a, ($c2f2)		; $20e4: $fa $f2 $c2
	or		b			; $20e7: $b0
	jr		nz, +			; $20e8: $20 $05
	ld		a, $f0			; $20ea: $3e $f0
	call		draw2DigitsAtHl			; $20ec: $cd $5d $20
+
	ret					; $20ef: $c9

func_20f0:
	ld		b, a			; $20f0: $47
	ld		a, ($cf38)		; $20f1: $fa $38 $cf
	and		a			; $20f4: $a7
	jr		z, func_210d			; $20f5: $28 $16
	ld		a, b			; $20f7: $78
	and		$f0			; $20f8: $e6 $f0
	jr		nz, func_2109			; $20fa: $20 $0d
	ld		a, b			; $20fc: $78
	or		$f0			; $20fd: $f6 $f0
	ld		b, a			; $20ff: $47
	and		$0f			; $2100: $e6 $0f
	jr		nz, func_2109			; $2102: $20 $05
	ld		a, $ff			; $2104: $3e $ff
	ld		b, a			; $2106: $47
	jr		func_210d			; $2107: $18 $04
func_2109:
	xor		a			; $2109: $af
	ld		($cf38), a		; $210a: $ea $38 $cf
func_210d:
	ld		a, b			; $210d: $78
	call		draw2DigitsAtHl			; $210e: $cd $5d $20
	ret					; $2111: $c9


;;
; @param[out]	a		if there was a remainder, return nybbles div/mod
;						else, return nybbles $f/mod
get2DigitsToDrawFromNonBCD_A:
	push		bc
	push		hl
	ld		l, a
	ld		h, $00
	ld		a, 10
	call		hlDivModA
	swap		l
	or		l
-
	cp		$10
	jr		nc, +
	or		$f0
+
	pop		hl
	pop		bc
	ret
get2DigitsToDrawFromBCD_A:
	push		bc
	push		hl
	jr		-

; checks 4 tiles around current position
func_212c:
	ld		a, $01			; $212c: $3e $01
	ld		($c2f8), a		; $212e: $ea $f8 $c2
	ld		($c2f9), a		; $2131: $ea $f9 $c2
	call		func_1ca8			; $2134: $cd $a8 $1c
	ld		a, ($c2d2)		; $2137: $fa $d2 $c2
	cp		$01			; $213a: $fe $01
	jr		nz, func_2158			; $213c: $20 $1a
	call		subtract14FromHl_storeIntoA			; $213e: $cd $ba $21
	call		func_21d1			; $2141: $cd $d1 $21
	call		storeHlIntoCf08_7			; $2144: $cd $2f $22
	call		func_2215			; $2147: $cd $15 $22
	call		hlEqualsCursorOriginalPosition			; $214a: $cd $41 $22
	call		func_21fb			; $214d: $cd $fb $21
	call		storeHlIntoC2f7_6			; $2150: $cd $63 $22
	call		func_226c			; $2153: $cd $6c $22
	jr		func_21b0			; $2156: $18 $58
func_2158:
	cp		$02			; $2158: $fe $02
	jr		nz, func_2176			; $215a: $20 $1a
	call		getTileToRightOfCurrent			; $215c: $cd $ce $21
	call		storeHlIntoCf08_7			; $215f: $cd $2f $22
	call		func_21e1			; $2162: $cd $e1 $21
	call		hlEqualsCursorOriginalPosition			; $2165: $cd $41 $22
	call		func_21d1			; $2168: $cd $d1 $21
	call		storeHlIntoC2f7_6			; $216b: $cd $63 $22
	call		func_2215			; $216e: $cd $15 $22
	call		func_22bd			; $2171: $cd $bd $22
	jr		func_21b0			; $2174: $18 $3a
func_2176:
	cp		$03			; $2176: $fe $03
	jr		nz, func_2194			; $2178: $20 $1a
	call		getTileBelowCurrent			; $217a: $cd $c4 $21
	call		storeHlIntoCf08_7			; $217d: $cd $2f $22
	call		func_21fb			; $2180: $cd $fb $21
	call		storeHlIntoC2f7_6			; $2183: $cd $63 $22
	call		hlEqualsCursorOriginalPosition			; $2186: $cd $41 $22
	call		func_2215			; $2189: $cd $15 $22
	call		func_21e1			; $218c: $cd $e1 $21
	call		func_2287			; $218f: $cd $87 $22
	jr		func_21b0			; $2192: $18 $1c
func_2194:
	cp		$04			; $2194: $fe $04
	jr		nz, func_21b0			; $2196: $20 $18
	call		getTileToLeftOfCurrent			; $2198: $cd $cb $21
	call		func_21fb			; $219b: $cd $fb $21
	call		storeHlIntoCf08_7			; $219e: $cd $2f $22
	call		func_21e1			; $21a1: $cd $e1 $21
	call		hlEqualsCursorOriginalPosition			; $21a4: $cd $41 $22
	call		func_21d1			; $21a7: $cd $d1 $21
	call		storeHlIntoC2f7_6			; $21aa: $cd $63 $22
	call		func_22a2			; $21ad: $cd $a2 $22
func_21b0:
	cp		$01			; $21b0: $fe $01
	jr		z, +			; $21b2: $28 $02
	ld		a, $00			; $21b4: $3e $00
+
	ld		($cf35), a		; $21b6: $ea $35 $cf
	ret					; $21b9: $c9

subtract14FromHl_storeIntoA:
	ld		a, l
	sub		$14
	ld		l, a
	ld		a, h
	sbc		$00
	ld		h, a
	ld		a, (hl)
	ret

getTileBelowCurrent:
	ld		a, $14
	call		addAToHl
	ld		a, (hl)
	ret

getTileToLeftOfCurrent:
	dec		hl
	ld		a, (hl)
	ret

getTileToRightOfCurrent:
	inc		hl
	ld		a, (hl)
	ret

; @param	hl
func_21d1:
	ld		a, (hl)			; $21d1: $7e
	and		$0f			; $21d2: $e6 $0f
	cp		$08			; $21d4: $fe $08
	jr		c, @done			; $21d6: $38 $08
	call		incc2f9			; $21d8: $cd $53 $22
	call		subtract14FromHl_storeIntoA			; $21db: $cd $ba $21
	jr		func_21d1			; $21de: $18 $f1
@done:
	ret					; $21e0: $c9

func_21e1:
	ld		c, $08			; $21e1: $0e $08
	ld		a, (hl)			; $21e3: $7e
	and		$0f			; $21e4: $e6 $0f
	ld		b, a			; $21e6: $47
	ld		de, data_22d8		; $21e7: $11 $d8 $22
-
	ld		a, (de)			; $21ea: $1a
	cp		b			; $21eb: $b8
	jr		z, @done			; $21ec: $28 $0c
	inc		de			; $21ee: $13
	dec		c			; $21ef: $0d
	jr		nz, -			; $21f0: $20 $f8
	call		incc2f9			; $21f2: $cd $53 $22
	call		getTileBelowCurrent			; $21f5: $cd $c4 $21
	jr		func_21e1			; $21f8: $18 $e7
@done:
	ret					; $21fa: $c9

func_21fb:
	ld		c, $08			; $21fb: $0e $08
	ld		a, (hl)			; $21fd: $7e
	and		$0f			; $21fe: $e6 $0f
	ld		b, a			; $2200: $47
	ld		de, data_22e0		; $2201: $11 $e0 $22
-
	ld		a, (de)			; $2204: $1a
	cp		b			; $2205: $b8
	jr		z, @done			; $2206: $28 $0c
	inc		de			; $2208: $13
	dec		c			; $2209: $0d
	jr		nz, -			; $220a: $20 $f8
	call		incc2f8			; $220c: $cd $5b $22
	call		getTileToLeftOfCurrent			; $220f: $cd $cb $21
	jr		func_21fb			; $2212: $18 $e7
@done:
	ret					; $2214: $c9

func_2215:
	ld		c, $08			; $2215: $0e $08
	ld		a, (hl)			; $2217: $7e
	and		$0f			; $2218: $e6 $0f
	ld		b, a			; $221a: $47
	ld		de, data_22e8		; $221b: $11 $e8 $22
-
	ld		a, (de)			; $221e: $1a
	cp		b			; $221f: $b8
	jr		z, @done			; $2220: $28 $0c
	inc		de			; $2222: $13
	dec		c			; $2223: $0d
	jr		nz, -			; $2224: $20 $f8
	call		incc2f8			; $2226: $cd $5b $22
	call		getTileToRightOfCurrent			; $2229: $cd $ce $21
	jr		func_2215			; $222c: $18 $e7
@done:
	ret					; $222e: $c9

storeHlIntoCf08_7:
	ld		a, l			; $222f: $7d
	ld		(wCursorOriginX), a		; $2230: $ea $07 $cf
	ld		a, h			; $2233: $7c
	ld		(wCursorOriginY), a		; $2234: $ea $08 $cf
	ret					; $2237: $c9

storeHlIntoCf0a_9:
	ld		a, l			; $2238: $7d
	ld		($cf09), a		; $2239: $ea $09 $cf
	ld		a, h			; $223c: $7c
	ld		($cf0a), a		; $223d: $ea $0a $cf
	ret					; $2240: $c9

hlEqualsCursorOriginalPosition:
	ld		a, (wCursorOriginX)		; $2241: $fa $07 $cf
	ld		l, a			; $2244: $6f
	ld		a, (wCursorOriginY)		; $2245: $fa $08 $cf
	ld		h, a			; $2248: $67
	ret					; $2249: $c9

readHlFromCf0a_9:
	ld		a, ($cf09)		; $224a: $fa $09 $cf
	ld		l, a			; $224d: $6f
	ld		a, ($cf0a)		; $224e: $fa $0a $cf
	ld		h, a			; $2251: $67
	ret					; $2252: $c9

incc2f9:
	ld		a, ($c2f9)		; $2253: $fa $f9 $c2
	inc		a			; $2256: $3c
	ld		($c2f9), a		; $2257: $ea $f9 $c2
	ret					; $225a: $c9

incc2f8:
	ld		a, ($c2f8)		; $225b: $fa $f8 $c2
	inc		a			; $225e: $3c
	ld		($c2f8), a		; $225f: $ea $f8 $c2
	ret					; $2262: $c9

storeHlIntoC2f7_6:
	ld		a, l			; $2263: $7d
	ld		($c2f6), a		; $2264: $ea $f6 $c2
	ld		a, h			; $2267: $7c
	ld		($c2f7), a		; $2268: $ea $f7 $c2
	ret					; $226b: $c9

func_226c:
	ld		a, ($c2f8)		; $226c: $fa $f8 $c2
	ld		b, a			; $226f: $47
	call		subtract14FromHl_storeIntoA			; $2270: $cd $ba $21
-
	and		$f0			; $2273: $e6 $f0
	and		a			; $2275: $a7
	jr		z, +			; $2276: $28 $04
	cp		$e0			; $2278: $fe $e0
	jr		nz, func_2286			; $227a: $20 $0a
+
	dec		b			; $227c: $05
	jr		z, func_2284			; $227d: $28 $05
	call		getTileToRightOfCurrent			; $227f: $cd $ce $21
	jr		-			; $2282: $18 $ef
func_2284:
	ld		a, $01			; $2284: $3e $01
func_2286:
	ret					; $2286: $c9

func_2287:
	ld		a, ($c2f8)		; $2287: $fa $f8 $c2
	ld		b, a			; $228a: $47
	call		getTileBelowCurrent			; $228b: $cd $c4 $21
-
	and		$f0			; $228e: $e6 $f0
	and		a			; $2290: $a7
	jr		z, +			; $2291: $28 $04
	cp		$e0			; $2293: $fe $e0
	jr		nz, func_22a1			; $2295: $20 $0a
+
	dec		b			; $2297: $05
	jr		z, func_229f			; $2298: $28 $05
	call		getTileToLeftOfCurrent			; $229a: $cd $cb $21
	jr		-			; $229d: $18 $ef
func_229f:
	ld		a, $01			; $229f: $3e $01
func_22a1:
	ret					; $22a1: $c9

func_22a2:
	ld		a, ($c2f9)		; $22a2: $fa $f9 $c2
	ld		b, a			; $22a5: $47
	call		getTileToLeftOfCurrent			; $22a6: $cd $cb $21
-
	and		$f0			; $22a9: $e6 $f0
	and		a			; $22ab: $a7
	jr		z, +			; $22ac: $28 $04
	cp		$e0			; $22ae: $fe $e0
	jr		nz, func_22bc			; $22b0: $20 $0a
+
	dec		b			; $22b2: $05
	jr		z, func_22ba			; $22b3: $28 $05
	call		getTileBelowCurrent			; $22b5: $cd $c4 $21
	jr		-			; $22b8: $18 $ef
func_22ba:
	ld		a, $01			; $22ba: $3e $01
func_22bc:
	ret					; $22bc: $c9

func_22bd:
	ld		a, ($c2f9)		; $22bd: $fa $f9 $c2
	ld		b, a			; $22c0: $47
	call		getTileToRightOfCurrent			; $22c1: $cd $ce $21
-
	and		$f0			; $22c4: $e6 $f0
	and		a			; $22c6: $a7
	jr		z, +			; $22c7: $28 $04
	cp		$e0			; $22c9: $fe $e0
	jr		nz, func_22d7			; $22cb: $20 $0a
+
	dec		b			; $22cd: $05
	jr		z, func_22d5			; $22ce: $28 $05
	call		getTileBelowCurrent			; $22d0: $cd $c4 $21
	jr		-			; $22d3: $18 $ef
func_22d5:
	ld		a, $01			; $22d5: $3e $01
func_22d7:
	ret					; $22d7: $c9

data_22d8:
	nop					; $22d8: $00
	ld		bc, $0504		; $22d9: $01 $04 $05
	ld		($0c09), sp		; $22dc: $08 $09 $0c
	dec		c			; $22df: $0d

data_22e0:
	nop					; $22e0: $00
	ld		bc, $0302		; $22e1: $01 $02 $03
	ld		($0a09), sp		; $22e4: $08 $09 $0a
	dec		bc			; $22e7: $0b

data_22e8:
	nop					; $22e8: $00
	ld		(bc), a			; $22e9: $02
	inc		b			; $22ea: $04
	ld		b, $08			; $22eb: $06 $08
	ld		a, (bc)			; $22ed: $0a
	inc		c			; $22ee: $0c
.db $0e

func_22f0:
	ld		a, $03
	ld		($c2f8), a		; $22f2: $ea $f8 $c2
	ld		($c2f9), a		; $22f5: $ea $f9 $c2
	xor		a			; $22f8: $af
	ld		($cf35), a		; $22f9: $ea $35 $cf
	ld		a, $01			; $22fc: $3e $01
	ld		($c2ce), a		; $22fe: $ea $ce $c2
	call		func_1ca8			; $2301: $cd $a8 $1c
	call		storeHlIntoCf08_7			; $2304: $cd $2f $22
	ld		a, ($c2d2)		; $2307: $fa $d2 $c2
	cp		$01			; $230a: $fe $01
	jr		nz, func_232a			; $230c: $20 $1c
	call		subtract14FromHl_storeIntoA			; $230e: $cd $ba $21
	cp		$82			; $2311: $fe $82
	jp		z, func_2468		; $2313: $ca $68 $24
	cp		$81			; $2316: $fe $81
	jr		nz, func_2322			; $2318: $20 $08
	ld		e, $04			; $231a: $1e $04
	call		getTileToLeftOfCurrent			; $231c: $cd $cb $21
	ld		d, a			; $231f: $57
	jr		func_2389			; $2320: $18 $67
func_2322:
	ld		e, $06			; $2322: $1e $06
	call		getTileToRightOfCurrent			; $2324: $cd $ce $21
	ld		d, a			; $2327: $57
	jr		func_2389			; $2328: $18 $5f
func_232a:
	cp		$02			; $232a: $fe $02
	jr		nz, func_234a			; $232c: $20 $1c
	call		getTileToRightOfCurrent			; $232e: $cd $ce $21
	cp		$83			; $2331: $fe $83
	jp		z, func_2468		; $2333: $ca $68 $24
	cp		$80			; $2336: $fe $80
	jr		nz, func_2342			; $2338: $20 $08
	ld		e, $00			; $233a: $1e $00
	call		getTileBelowCurrent			; $233c: $cd $c4 $21
	ld		d, a			; $233f: $57
	jr		func_2389			; $2340: $18 $47
func_2342:
	ld		e, $06			; $2342: $1e $06
	call		subtract14FromHl_storeIntoA			; $2344: $cd $ba $21
	ld		d, a			; $2347: $57
	jr		func_2389			; $2348: $18 $3f
func_234a:
	cp		$03			; $234a: $fe $03
	jr		nz, func_236a			; $234c: $20 $1c
	call		getTileBelowCurrent			; $234e: $cd $c4 $21
	cp		$80			; $2351: $fe $80
	jp		z, func_2468		; $2353: $ca $68 $24
	cp		$81			; $2356: $fe $81
	jr		nz, func_2362			; $2358: $20 $08
	ld		e, $02			; $235a: $1e $02
	call		getTileToLeftOfCurrent			; $235c: $cd $cb $21
	ld		d, a			; $235f: $57
	jr		func_2389			; $2360: $18 $27
func_2362:
	ld		e, $00			; $2362: $1e $00
	call		getTileToRightOfCurrent			; $2364: $cd $ce $21
	ld		d, a			; $2367: $57
	jr		func_2389			; $2368: $18 $1f
func_236a:
	cp		$04			; $236a: $fe $04
	jp		nz, func_2468		; $236c: $c2 $68 $24
	call		getTileToLeftOfCurrent			; $236f: $cd $cb $21
	cp		$81			; $2372: $fe $81
	jp		z, func_2468		; $2374: $ca $68 $24
	cp		$80			; $2377: $fe $80
	jr		nz, func_2383			; $2379: $20 $08
	ld		e, $02			; $237b: $1e $02
	call		getTileBelowCurrent			; $237d: $cd $c4 $21
	ld		d, a			; $2380: $57
	jr		func_2389			; $2381: $18 $06
func_2383:
	ld		e, $04			; $2383: $1e $04
	call		subtract14FromHl_storeIntoA			; $2385: $cd $ba $21
	ld		d, a			; $2388: $57
func_2389:
	call		subtract14FromHl_storeIntoA			; $2389: $cd $ba $21
	call		getTileToLeftOfCurrent			; $238c: $cd $cb $21
	ld		a, l			; $238f: $7d
	ld		($c2f6), a		; $2390: $ea $f6 $c2
	ld		a, h			; $2393: $7c
	ld		($c2f7), a		; $2394: $ea $f7 $c2
	ld		bc, $0008		; $2397: $01 $08 $00
func_239a:
	ld		a, (hl)			; $239a: $7e
	and		a			; $239b: $a7
	jr		z, +			; $239c: $28 $04
	cp		$e0			; $239e: $fe $e0
	jr		nz, func_23a6			; $23a0: $20 $04
+
	srl		b			; $23a2: $cb $38
	jr		func_23a9			; $23a4: $18 $03
func_23a6:
	scf					; $23a6: $37
	rr		b			; $23a7: $cb $18
func_23a9:
	ld		a, c			; $23a9: $79
	dec		a			; $23aa: $3d
	ld		c, a			; $23ab: $4f
	cp		$06			; $23ac: $fe $06
	jr		c, func_23b5			; $23ae: $38 $05
	call		getTileToRightOfCurrent			; $23b0: $cd $ce $21
	jr		func_239a			; $23b3: $18 $e5
func_23b5:
	cp		$04			; $23b5: $fe $04
	jr		c, func_23be			; $23b7: $38 $05
	call		getTileBelowCurrent			; $23b9: $cd $c4 $21
	jr		func_239a			; $23bc: $18 $dc
func_23be:
	cp		$02			; $23be: $fe $02
	jr		c, func_23c7			; $23c0: $38 $05
	call		getTileToLeftOfCurrent			; $23c2: $cd $cb $21
	jr		func_239a			; $23c5: $18 $d3
func_23c7:
	and		a			; $23c7: $a7
	jr		z, func_23cf			; $23c8: $28 $05
	call		subtract14FromHl_storeIntoA			; $23ca: $cd $ba $21
	jr		func_239a			; $23cd: $18 $cb
func_23cf:
	ld		hl, data_2472		; $23cf: $21 $72 $24
	ld		a, e			; $23d2: $7b
	call		addAToHl			; $23d3: $cd $6b $24
	ld		a, (hl)			; $23d6: $7e
	ld		c, a			; $23d7: $4f
	ld		a, ($c2d2)		; $23d8: $fa $d2 $c2
	sub		c			; $23db: $91
	cp		$03			; $23dc: $fe $03
	jr		nz, +			; $23de: $20 $02
	dec		a			; $23e0: $3d
	dec		a			; $23e1: $3d
+
	ld		c, a			; $23e2: $4f
	ld		a, d			; $23e3: $7a
	push		af			; $23e4: $f5
	ld		hl, data_24ea		; $23e5: $21 $ea $24
	ld		a, e			; $23e8: $7b
	call		addAToHl			; $23e9: $cd $6b $24
	ld		a, (hl)			; $23ec: $7e
	ld		d, a			; $23ed: $57
	ld		a, ($c2d2)		; $23ee: $fa $d2 $c2
	sub		d			; $23f1: $92
	jr		z, +			; $23f2: $28 $02
	ld		a, $01			; $23f4: $3e $01
+
	ld		(wExtraMenuColumns), a		; $23f6: $ea $11 $cf
	pop		af			; $23f9: $f1
	and		$0f			; $23fa: $e6 $0f
	push		af			; $23fc: $f5
	ld		hl, data_24db		; $23fd: $21 $db $24
	call		addAToHl			; $2400: $cd $6b $24
	ld		a, (hl)			; $2403: $7e
	ld		d, a			; $2404: $57
	ld		a, ($c2d2)		; $2405: $fa $d2 $c2
-
	srl		d			; $2408: $cb $3a
	dec		a			; $240a: $3d
	jr		z, func_240f			; $240b: $28 $02
	jr		-			; $240d: $18 $f9
func_240f:
	jr		nc, +			; $240f: $30 $05
	ld		a, $02			; $2411: $3e $02
	ld		($c2ce), a		; $2413: $ea $ce $c2
+
	cp		$02			; $2416: $fe $02
	jr		nz, func_2451			; $2418: $20 $37
	call		hlEqualsCursorOriginalPosition			; $241a: $cd $41 $22
	ld		a, ($c2d2)		; $241d: $fa $d2 $c2
	cp		$01			; $2420: $fe $01
	jr		nz, func_242c			; $2422: $20 $08
	call		subtract14FromHl_storeIntoA			; $2424: $cd $ba $21
	call		subtract14FromHl_storeIntoA			; $2427: $cd $ba $21
	jr		func_244a			; $242a: $18 $1e
func_242c:
	cp		$02			; $242c: $fe $02
	jr		nz, func_2438			; $242e: $20 $08
	call		getTileToRightOfCurrent			; $2430: $cd $ce $21
	call		getTileToRightOfCurrent			; $2433: $cd $ce $21
	jr		func_244a			; $2436: $18 $12
func_2438:
	cp		$03			; $2438: $fe $03
	jr		nz, func_2444			; $243a: $20 $08
	call		getTileBelowCurrent			; $243c: $cd $c4 $21
	call		getTileBelowCurrent			; $243f: $cd $c4 $21
	jr		func_244a			; $2442: $18 $06
func_2444:
	call		getTileToLeftOfCurrent			; $2444: $cd $cb $21
	call		getTileToLeftOfCurrent			; $2447: $cd $cb $21
func_244a:
	cp		$e0			; $244a: $fe $e0
	jr		nz, func_2451			; $244c: $20 $03
	pop		af			; $244e: $f1
	jr		func_2468			; $244f: $18 $17
func_2451:
	pop		af			; $2451: $f1
	ld		hl, data_2479		; $2452: $21 $79 $24
	call		addAToHl			; $2455: $cd $6b $24
	ld		a, (hl)			; $2458: $7e
	call		addAToHl			; $2459: $cd $6b $24
	call		addCandEToHl			; $245c: $cd $69 $24
	ld		a, (hl)			; $245f: $7e
	and		b			; $2460: $a0
	jr		nz, func_2468			; $2461: $20 $05
	ld		a, $02			; $2463: $3e $02
	ld		($cf35), a		; $2465: $ea $35 $cf
func_2468:
	ret					; $2468: $c9

addCandEToHl:
	ld		a, c			; $2469: $79
	add		e			; $246a: $83
addAToHl:
	add		l			; $246b: $85
	ld		l, a			; $246c: $6f
	ld		a, h			; $246d: $7c
	adc		$00			; $246e: $ce $00
	ld		h, a			; $2470: $67
	ret					; $2471: $c9

data_2472:
	ld		(bc), a			; $2472: $02
	nop					; $2473: $00
	inc		bc			; $2474: $03
	nop					; $2475: $00
	ld		bc, $0100		; $2476: $01 $00 $01

data_2479:
	.db data_2488-CADDR
	.db data_2488-CADDR
	.db data_2488-CADDR
	.db data_2488-CADDR
	.db data_2490-CADDR
	.db data_2495-CADDR
	.db data_249d-CADDR
	.db data_24a5-CADDR
	.db data_24ac-CADDR
	.db data_24b4-CADDR
	.db data_24bc-CADDR
	.db data_24c4-CADDR
	.db data_24d3-CADDR
	.db data_24cb-CADDR
	.db data_24cb-CADDR

data_2488:
	inc		c			; $2488: $0c
	ld		h, b			; $2489: $60
	jr		nc, -$7f			; $248a: $30 $81
	ld		b, $c0			; $248c: $06 $c0
	inc		bc			; $248e: $03
.db $18

data_2490:
.db $34
	nop					; $2491: $00
	jr		nc, -$7f			; $2492: $30 $81
	add		l			; $2494: $85

data_2495:
	nop					; $2495: $00
	nop					; $2496: $00
	ret		nc			; $2497: $d0
	nop					; $2498: $00
	ld		b, $c0			; $2499: $06 $c0
	nop					; $249b: $00
.db $16

data_249d:
.db $00
	ld		e, b			; $249e: $58
	nop					; $249f: $00
	nop					; $24a0: $00
	nop					; $24a1: $00
	ld		b, e			; $24a2: $43
	inc		bc			; $24a3: $03
.db $18

data_24a5:
.db $0c
	ld		h, b			; $24a6: $60
	nop					; $24a7: $00
	ld		h, c			; $24a8: $61
	nop					; $24a9: $00
	nop					; $24aa: $00
	dec		c			; $24ab: $0d

data_24ac:
	call		nc, $d000		; $24ac: $d4 $00 $d0
	sub		c			; $24af: $91
	add		l			; $24b0: $85
	call		nz, $9500		; $24b1: $c4 $00 $95

data_24b4:
	nop					; $24b4: $00
	ld		d, (hl)			; $24b5: $56
	ld		d, e			; $24b6: $53
	nop					; $24b7: $00
	ld		b, (hl)			; $24b8: $46
	ld		b, e			; $24b9: $43
	inc		de			; $24ba: $13
.db $16

data_24bc:
.db $4c
	ld		e, b			; $24bd: $58
	nop					; $24be: $00
	ld		e, c			; $24bf: $59
	nop					; $24c0: $00
	ld		c, l			; $24c1: $4d
	dec		c			; $24c2: $0d
	add		hl, de			; $24c3: $19

data_24c4:
	inc		(hl)			; $24c4: $34
	ld		h, h			; $24c5: $64
	ld		sp, $6561		; $24c6: $31 $61 $65
	nop					; $24c9: $00
	dec		(hl)			; $24ca: $35

data_24cb:
	call		z, $3366		; $24cb: $cc $66 $33
	sbc		c			; $24ce: $99
	ld		h, (hl)			; $24cf: $66
	call		z, $9933		; $24d0: $cc $33 $99

data_24d3:
	ld		d, h			; $24d3: $54
	ld		d, h			; $24d4: $54
	ld		d, c			; $24d5: $51
	ld		d, c			; $24d6: $51
	ld		b, l			; $24d7: $45
	ld		b, l			; $24d8: $45
	dec		d			; $24d9: $15
	dec		d			; $24da: $15

data_24db:
	nop					; $24db: $00
	nop					; $24dc: $00
	nop					; $24dd: $00
	nop					; $24de: $00
	inc		c			; $24df: $0c
	add		hl, bc			; $24e0: $09
	inc		bc			; $24e1: $03
	ld		b, $0d			; $24e2: $06 $0d
	dec		bc			; $24e4: $0b
	rlca					; $24e5: $07
	ld		c, $0f			; $24e6: $0e $0f
	nop					; $24e8: $00
	nop					; $24e9: $00

data_24ea:
	inc		bc			; $24ea: $03
	nop					; $24eb: $00
	inc		b			; $24ec: $04
	nop					; $24ed: $00
	ld		bc, $0200		; $24ee: $01 $00 $02

; probably the 4 bytes for an oam sprite
store_c_b_d_e_in_c000plus4a:
	push		af			; $24f1: $f5
	push		bc			; $24f2: $c5
	push		de			; $24f3: $d5
	push		hl			; $24f4: $e5

	push		de			; $24f5: $d5
	ld		de, $0000		; $24f6: $11 $00 $00
	ld		hl, wOam		; $24f9: $21 $00 $c0
	ld		e, a			; $24fc: $5f
	sla		e			; $24fd: $cb $23
	rl		d			; $24ff: $cb $12
	sla		e			; $2501: $cb $23
	rl		d			; $2503: $cb $12
	add		hl, de			; $2505: $19
	pop		de			; $2506: $d1

	ld		a, c			; $2507: $79
	ldi		(hl), a			; $2508: $22
	ld		a, b			; $2509: $78
	ldi		(hl), a			; $250a: $22
	ld		a, d			; $250b: $7a
	ldi		(hl), a			; $250c: $22
	ld		a, e			; $250d: $7b
	ldi		(hl), a			; $250e: $22

	pop		hl			; $250f: $e1
	pop		de			; $2510: $d1
	pop		bc			; $2511: $c1
	pop		af			; $2512: $f1
	ret					; $2513: $c9


func_2514:
	ld		a, ($c2f6)		; $2514: $fa $f6 $c2
	ld		l, a			; $2517: $6f
	ld		a, ($c2f7)		; $2518: $fa $f7 $c2
	ld		h, a			; $251b: $67
	ld		de, $c29a		; $251c: $11 $9a $c2
	ld		a, ($cf35)		; $251f: $fa $35 $cf
	cp		$02			; $2522: $fe $02
	jp		z, func_2542		; $2524: $ca $42 $25
	ld		a, ($c2f9)		; $2527: $fa $f9 $c2
	ld		c, a			; $252a: $4f
--
	ld		a, ($c2f8)		; $252b: $fa $f8 $c2
	ld		b, a			; $252e: $47
-
	call		func_25bf			; $252f: $cd $bf $25
	inc		de			; $2532: $13
	inc		hl			; $2533: $23
	dec		b			; $2534: $05
	jp		nz, -		; $2535: $c2 $2f $25
	call		func_1f64			; $2538: $cd $64 $1f
	dec		c			; $253b: $0d
	jp		nz, --		; $253c: $c2 $2b $25
	jp		func_25de			; $253f: $c3 $de $25
func_2542:
	ld		a, ($c2f9)		; $2542: $fa $f9 $c2
	ld		c, a			; $2545: $4f
--
	ld		a, ($c2f8)		; $2546: $fa $f8 $c2
	ld		b, a			; $2549: $47
-
	ld		a, (hl)			; $254a: $7e
	ld		(de), a			; $254b: $12
	inc		de			; $254c: $13
	inc		hl			; $254d: $23
	dec		b			; $254e: $05
	jp		nz, -		; $254f: $c2 $4a $25
	call		func_1f64			; $2552: $cd $64 $1f
	dec		c			; $2555: $0d
	jp		nz, --		; $2556: $c2 $46 $25
	ld		a, ($c2f6)		; $2559: $fa $f6 $c2
	ld		l, a			; $255c: $6f
	ld		a, ($c2f7)		; $255d: $fa $f7 $c2
	ld		h, a			; $2560: $67
	ld		bc, $0015		; $2561: $01 $15 $00
	add		hl, bc			; $2564: $09
	ld		a, (hl)			; $2565: $7e
	push		af			; $2566: $f5
	xor		a			; $2567: $af
	ld		(hl), a			; $2568: $77
	pop		af			; $2569: $f1
	and		$0f			; $256a: $e6 $0f
	ld		de, data_3f7f		; $256c: $11 $7f $3f
	add		e			; $256f: $83
	ld		e, a			; $2570: $5f
	ld		a, $00			; $2571: $3e $00
	adc		d			; $2573: $8a
	ld		d, a			; $2574: $57
	ld		a, (de)			; $2575: $1a
	ld		b, a			; $2576: $47
	push		hl			; $2577: $e5
	sla		b			; $2578: $cb $20
	call		c, func_25a6		; $257a: $dc $a6 $25
	pop		hl			; $257d: $e1
	push		hl			; $257e: $e5
	sla		b			; $257f: $cb $20
	call		c, func_259e		; $2581: $dc $9e $25
	pop		hl			; $2584: $e1
	push		hl			; $2585: $e5
	sla		b			; $2586: $cb $20
	call		c, func_25b1		; $2588: $dc $b1 $25
	pop		hl			; $258b: $e1
	push		hl			; $258c: $e5
	sla		b			; $258d: $cb $20
	call		c, func_2596		; $258f: $dc $96 $25
	pop		hl			; $2592: $e1
	jp		func_25bc			; $2593: $c3 $bc $25

func_2596:
	dec		hl			; $2596: $2b
	ld		de, $c29d		; $2597: $11 $9d $c2
	call		func_25bf			; $259a: $cd $bf $25
	ret					; $259d: $c9

func_259e:
	inc		hl			; $259e: $23
	ld		de, $c29f		; $259f: $11 $9f $c2
	call		func_25bf			; $25a2: $cd $bf $25
	ret					; $25a5: $c9

func_25a6:
	ld		de, -$14		; $25a6: $11 $ec $ff
	add		hl, de			; $25a9: $19
	ld		de, $c29b		; $25aa: $11 $9b $c2
	call		func_25bf			; $25ad: $cd $bf $25
	ret					; $25b0: $c9

func_25b1:
	ld		de, $0014		; $25b1: $11 $14 $00
	add		hl, de			; $25b4: $19
	ld		de, $c2a1		; $25b5: $11 $a1 $c2
	call		func_25bf			; $25b8: $cd $bf $25
	ret					; $25bb: $c9

func_25bc:
	jp		func_25de			; $25bc: $c3 $de $25

func_25bf:
	push		bc			; $25bf: $c5
	ld		a, (hl)			; $25c0: $7e
	and		$f0			; $25c1: $e6 $f0
	cp		$50			; $25c3: $fe $50
	jr		z, func_25d4			; $25c5: $28 $0d
	cp		$90			; $25c7: $fe $90
	jr		z, func_25d4			; $25c9: $28 $09
	cp		$e0			; $25cb: $fe $e0
	jr		z, func_25d7			; $25cd: $28 $08
	ld		a, (hl)			; $25cf: $7e
	ld		b, $00			; $25d0: $06 $00
	jr		func_25d9			; $25d2: $18 $05
func_25d4:
	ld		a, (hl)			; $25d4: $7e
	sub		$10			; $25d5: $d6 $10
func_25d7:
	ld		b, $e0			; $25d7: $06 $e0
func_25d9:
	ld		(de), a			; $25d9: $12
	ld		a, b			; $25da: $78
	ld		(hl), a			; $25db: $77
	pop		bc			; $25dc: $c1
	ret					; $25dd: $c9

func_25de:
	call		func_26e2			; $25de: $cd $e2 $26
	ld		a, ($c2f6)		; $25e1: $fa $f6 $c2
	ld		l, a			; $25e4: $6f
	ld		a, ($c2f7)		; $25e5: $fa $f7 $c2
	ld		h, a			; $25e8: $67
	ld		a, ($cf35)		; $25e9: $fa $35 $cf
	cp		$02			; $25ec: $fe $02
	jr		z, func_263d			; $25ee: $28 $4d
	ld		a, ($c2d2)		; $25f0: $fa $d2 $c2
	dec		a			; $25f3: $3d
	jr		z, func_2600			; $25f4: $28 $0a
	dec		a			; $25f6: $3d
	jr		z, func_2605			; $25f7: $28 $0c
	dec		a			; $25f9: $3d
	jr		z, func_260a			; $25fa: $28 $0e
	dec		a			; $25fc: $3d
	jr		z, func_260f			; $25fd: $28 $10
	ret					; $25ff: $c9
func_2600:
	ld		de, -$14		; $2600: $11 $ec $ff
	jr		func_2612			; $2603: $18 $0d
func_2605:
	ld		de, $0001		; $2605: $11 $01 $00
	jr		func_2612			; $2608: $18 $08
func_260a:
	ld		de, $0014		; $260a: $11 $14 $00
	jr		func_2612			; $260d: $18 $03
func_260f:
	ld		de, -$01		; $260f: $11 $ff $ff
func_2612:
	add		hl, de			; $2612: $19
	ld		a, l			; $2613: $7d
	ld		($c2f6), a		; $2614: $ea $f6 $c2
	ld		a, h			; $2617: $7c
	ld		($c2f7), a		; $2618: $ea $f7 $c2
	ld		a, ($c2f6)		; $261b: $fa $f6 $c2
	ld		l, a			; $261e: $6f
	ld		a, ($c2f7)		; $261f: $fa $f7 $c2
	ld		h, a			; $2622: $67
	ld		de, $c29a		; $2623: $11 $9a $c2
	ld		a, ($c2f9)		; $2626: $fa $f9 $c2
	ld		c, a			; $2629: $4f
--
	ld		a, ($c2f8)		; $262a: $fa $f8 $c2
	ld		b, a			; $262d: $47
-
	call		func_26cd			; $262e: $cd $cd $26
	ldi		(hl), a			; $2631: $22
	inc		de			; $2632: $13
	dec		b			; $2633: $05
	jr		nz, -			; $2634: $20 $f8
	call		func_1f64			; $2636: $cd $64 $1f
	dec		c			; $2639: $0d
	jr		nz, --			; $263a: $20 $ee
	ret					; $263c: $c9
func_263d:
	ld		de, $0015		; $263d: $11 $15 $00
	add		hl, de			; $2640: $19
	push		hl			; $2641: $e5
	ld		de, $c29e		; $2642: $11 $9e $c2
	ld		a, (wExtraMenuColumns)		; $2645: $fa $11 $cf
	and		a			; $2648: $a7
	jr		z, func_2651			; $2649: $28 $06
	ld		a, (de)			; $264b: $1a
	ld		hl, data_3f61		; $264c: $21 $61 $3f
	jr		func_2654			; $264f: $18 $03
func_2651:
	ld		hl, data_3f70		; $2651: $21 $70 $3f
func_2654:
	ld		a, (de)			; $2654: $1a
	and		$0f			; $2655: $e6 $0f
	push		de			; $2657: $d5
	and		$0f			; $2658: $e6 $0f
	ld		e, a			; $265a: $5f
	ld		d, $00			; $265b: $16 $00
	add		hl, de			; $265d: $19
	pop		de			; $265e: $d1
	ld		a, (hl)			; $265f: $7e
	ld		(de), a			; $2660: $12
	and		$0f			; $2661: $e6 $0f
	ld		hl, data_3f7f		; $2663: $21 $7f $3f
	ld		e, a			; $2666: $5f
	ld		d, $00			; $2667: $16 $00
	add		hl, de			; $2669: $19
	ld		a, (hl)			; $266a: $7e
	ld		b, a			; $266b: $47
	pop		hl			; $266c: $e1
	ld		de, $c29e		; $266d: $11 $9e $c2
	ld		a, (de)			; $2670: $1a
	ld		(hl), a			; $2671: $77
	push		hl			; $2672: $e5
	sla		b			; $2673: $cb $20
	call		c, func_268f		; $2675: $dc $8f $26
	pop		hl			; $2678: $e1
	push		hl			; $2679: $e5
	sla		b			; $267a: $cb $20
	call		c, func_26b1		; $267c: $dc $b1 $26
	pop		hl			; $267f: $e1
	push		hl			; $2680: $e5
	sla		b			; $2681: $cb $20
	call		c, func_26a0		; $2683: $dc $a0 $26
	pop		hl			; $2686: $e1
	push		hl			; $2687: $e5
	sla		b			; $2688: $cb $20
	call		c, func_26bf		; $268a: $dc $bf $26
	pop		hl			; $268d: $e1
	ret					; $268e: $c9

func_268f:
	ld		de, -$14		; $268f: $11 $ec $ff
	add		hl, de			; $2692: $19
	ld		a, (hl)			; $2693: $7e
	cp		$e0			; $2694: $fe $e0
	jr		nz, func_269c			; $2696: $20 $04
	ld		a, $90			; $2698: $3e $90
	ld		(hl), a			; $269a: $77
	ret					; $269b: $c9
func_269c:
	ld		a, $80			; $269c: $3e $80
	ld		(hl), a			; $269e: $77
	ret					; $269f: $c9

func_26a0
	ld		de, $0014		; $26a0: $11 $14 $00
	add		hl, de			; $26a3: $19
	ld		a, (hl)			; $26a4: $7e
	cp		$e0			; $26a5: $fe $e0
	jr		nz, func_26ad			; $26a7: $20 $04
	ld		a, $92			; $26a9: $3e $92
	ld		(hl), a			; $26ab: $77
	ret					; $26ac: $c9
func_26ad:
	ld		a, $82			; $26ad: $3e $82
	ld		(hl), a			; $26af: $77
	ret					; $26b0: $c9

func_26b1:
	inc		hl			; $26b1: $23
	ld		a, (hl)			; $26b2: $7e
	cp		$e0			; $26b3: $fe $e0
	jr		nz, func_26bb			; $26b5: $20 $04
	ld		a, $91			; $26b7: $3e $91
	ld		(hl), a			; $26b9: $77
	ret					; $26ba: $c9
func_26bb:
	ld		a, $81			; $26bb: $3e $81
	ld		(hl), a			; $26bd: $77
	ret					; $26be: $c9

func_26bf:
	dec		hl			; $26bf: $2b
	ld		a, (hl)			; $26c0: $7e
	cp		$e0			; $26c1: $fe $e0
	jr		nz, func_26c9			; $26c3: $20 $04
	ld		a, $93			; $26c5: $3e $93
	ld		(hl), a			; $26c7: $77
	ret					; $26c8: $c9
func_26c9:
	ld		a, $83			; $26c9: $3e $83
	ld		(hl), a			; $26cb: $77
	ret					; $26cc: $c9

func_26cd:
	ld		a, (hl)			; $26cd: $7e
	cp		$e0			; $26ce: $fe $e0
	jr		nz, func_26e0			; $26d0: $20 $0e
	ld		a, (de)			; $26d2: $1a
	and		a			; $26d3: $a7
	jr		z, func_26dd			; $26d4: $28 $07
	cp		$e0			; $26d6: $fe $e0
	jr		z, func_26dd			; $26d8: $28 $03
	add		$10			; $26da: $c6 $10
	ret					; $26dc: $c9
func_26dd:
	ld		a, $e0			; $26dd: $3e $e0
	ret					; $26df: $c9
func_26e0:
	ld		a, (de)			; $26e0: $1a
	ret					; $26e1: $c9

func_26e2:
	ld		a, (wIsDiagonalView)		; $26e2: $fa $be $c2
	and		a			; $26e5: $a7
	jr		z, +			; $26e6: $28 $07
	ld		a, ($c2f9)		; $26e8: $fa $f9 $c2
	inc		a			; $26eb: $3c
	ld		($c2f9), a		; $26ec: $ea $f9 $c2
+
	ld		a, ($c2f6)		; $26ef: $fa $f6 $c2
	ld		l, a			; $26f2: $6f
	ld		a, ($c2f7)		; $26f3: $fa $f7 $c2
	ld		h, a			; $26f6: $67
	ld		de, $c27c		; $26f7: $11 $7c $c2
	ld		a, ($c2f9)		; $26fa: $fa $f9 $c2
	ld		c, a			; $26fd: $4f
--
	ld		a, ($c2f8)		; $26fe: $fa $f8 $c2
	ld		b, a			; $2701: $47
-
	ld		a, (hl)			; $2702: $7e
	call		func_2731			; $2703: $cd $31 $27
	ld		(de), a			; $2706: $12
	inc		de			; $2707: $13
	inc		hl			; $2708: $23
	dec		b			; $2709: $05
	jr		nz, -			; $270a: $20 $f6
	call		func_1f64			; $270c: $cd $64 $1f
	dec		c			; $270f: $0d
	jr		nz, --			; $2710: $20 $ec
	ld		de, $c27c		; $2712: $11 $7c $c2
	ld		a, ($c2f6)		; $2715: $fa $f6 $c2
	ld		l, a			; $2718: $6f
	ld		a, ($c2f7)		; $2719: $fa $f7 $c2
	ld		h, a			; $271c: $67
	call		func_286b			; $271d: $cd $6b $28
	call		func_283c			; $2720: $cd $3c $28
	ld		a, (wIsDiagonalView)		; $2723: $fa $be $c2
	and		a			; $2726: $a7
	jr		z, +			; $2727: $28 $07
	ld		a, ($c2f9)		; $2729: $fa $f9 $c2
	dec		a			; $272c: $3d
	ld		($c2f9), a		; $272d: $ea $f9 $c2
+
	ret					; $2730: $c9

func_2731:
	push		bc			; $2731: $c5
	push		de			; $2732: $d5
	push		hl			; $2733: $e5
	push		af			; $2734: $f5
	and		$f0			; $2735: $e6 $f0
	cp		$10			; $2737: $fe $10
	jr		nz, +			; $2739: $20 $03
	pop		af			; $273b: $f1
	xor		a			; $273c: $af
	push		af			; $273d: $f5
+
	ld		a, l			; $273e: $7d
	ld		($cf09), a		; $273f: $ea $09 $cf
	ld		a, h			; $2742: $7c
	ld		($cf0a), a		; $2743: $ea $0a $cf
	pop		af			; $2746: $f1
	cp		$e0			; $2747: $fe $e0
	jp		z, func_27c4		; $2749: $ca $c4 $27
	ld		(wCursorOriginX), a		; $274c: $ea $07 $cf
	and		$f0			; $274f: $e6 $f0
	cp		$c0			; $2751: $fe $c0
	jr		nz, +			; $2753: $20 $04
	xor		a			; $2755: $af
	ld		(wCursorOriginX), a		; $2756: $ea $07 $cf
+
	ld		a, (wCursorOriginX)		; $2759: $fa $07 $cf
	ld		hl, data_3edf		; $275c: $21 $df $3e
	swap		a			; $275f: $cb $37
	and		$0f			; $2761: $e6 $0f
	ld		e, a			; $2763: $5f
	ld		d, $00			; $2764: $16 $00
	sla		e			; $2766: $cb $23
	rl		d			; $2768: $cb $12
	add		hl, de			; $276a: $19
	ldi		a, (hl)			; $276b: $2a
	ld		(wCursorOriginY), a		; $276c: $ea $08 $cf
	ld		a, (hl)			; $276f: $7e
	ld		h, a			; $2770: $67
	ld		a, (wCursorOriginY)		; $2771: $fa $08 $cf
	ld		l, a			; $2774: $6f
	ld		a, (wCursorOriginX)		; $2775: $fa $07 $cf
	and		$0f			; $2778: $e6 $0f
	ld		e, a			; $277a: $5f
	ld		d, $00			; $277b: $16 $00
	add		hl, de			; $277d: $19
	push		hl			; $277e: $e5
	ld		a, (wIsDiagonalView)		; $277f: $fa $be $c2
	and		a			; $2782: $a7
	jr		z, func_27b7			; $2783: $28 $32
	ld		a, ($cf09)		; $2785: $fa $09 $cf
	ld		l, a			; $2788: $6f
	ld		a, ($cf0a)		; $2789: $fa $0a $cf
	ld		h, a			; $278c: $67
	ld		a, (hl)			; $278d: $7e
	and		$f0			; $278e: $e6 $f0
	cp		$10			; $2790: $fe $10
	jr		z, +			; $2792: $28 $08
	cp		$c0			; $2794: $fe $c0
	jr		z, +			; $2796: $28 $04
	cp		$00			; $2798: $fe $00
	jr		nz, func_27b7			; $279a: $20 $1b
+
	ld		de, -$14		; $279c: $11 $ec $ff
	add		hl, de			; $279f: $19
	ld		a, (hl)			; $27a0: $7e
	and		$f0			; $27a1: $e6 $f0
	cp		$00			; $27a3: $fe $00
	jr		z, func_27b7			; $27a5: $28 $10
	cp		$10			; $27a7: $fe $10
	jr		z, func_27b7			; $27a9: $28 $0c
	cp		$c0			; $27ab: $fe $c0
	jr		z, func_27b7			; $27ad: $28 $08
	cp		$e0			; $27af: $fe $e0
	jr		z, func_27bd			; $27b1: $28 $0a
	ld		a, $fb			; $27b3: $3e $fb
	jr		func_27bf			; $27b5: $18 $08
func_27b7:
	pop		hl			; $27b7: $e1
	ld		a, (hl)			; $27b8: $7e
	pop		hl			; $27b9: $e1
	pop		de			; $27ba: $d1
	pop		bc			; $27bb: $c1
	ret					; $27bc: $c9
func_27bd:
	ld		a, $fb			; $27bd: $3e $fb
func_27bf:
	pop		hl			; $27bf: $e1
func_27c0:
	pop		hl			; $27c0: $e1
	pop		de			; $27c1: $d1
	pop		bc			; $27c2: $c1
	ret					; $27c3: $c9
func_27c4:
	ld		de, -$14		; $27c4: $11 $ec $ff
	add		hl, de			; $27c7: $19
	ld		a, (hl)			; $27c8: $7e
	and		$f0			; $27c9: $e6 $f0
	cp		$e0			; $27cb: $fe $e0
	jr		z, func_27d9			; $27cd: $28 $0a
	cp		$50			; $27cf: $fe $50
	jr		z, func_27d9			; $27d1: $28 $06
	cp		$90			; $27d3: $fe $90
	jr		z, func_27d9			; $27d5: $28 $02
	jr		func_27de			; $27d7: $18 $05
func_27d9:
	ld		a, (data_3f60)		; $27d9: $fa $60 $3f
	jr		func_27c0			; $27dc: $18 $e2
func_27de:
	ld		c, $01			; $27de: $0e $01
	and		$f0			; $27e0: $e6 $f0
	cp		$00			; $27e2: $fe $00
	jr		z, +			; $27e4: $28 $0a
	cp		$10			; $27e6: $fe $10
	jr		z, +			; $27e8: $28 $06
	cp		$c0			; $27ea: $fe $c0
	jr		z, +			; $27ec: $28 $02
	ld		c, $02			; $27ee: $0e $02
+
	ld		a, ($cf09)		; $27f0: $fa $09 $cf
	ld		l, a			; $27f3: $6f
	ld		a, ($cf0a)		; $27f4: $fa $0a $cf
	ld		h, a			; $27f7: $67
	ld		b, $00			; $27f8: $06 $00
	inc		hl			; $27fa: $23
	ld		a, (hl)			; $27fb: $7e
	and		$f0			; $27fc: $e6 $f0
	cp		$e0			; $27fe: $fe $e0
	jr		z, func_280c			; $2800: $28 $0a
	cp		$50			; $2802: $fe $50
	jr		z, func_280c			; $2804: $28 $06
	cp		$90			; $2806: $fe $90
	jr		z, func_280c			; $2808: $28 $02
	jr		func_280e			; $280a: $18 $02
func_280c:
	set		0, b			; $280c: $cb $c0
func_280e:
	dec		hl			; $280e: $2b
	dec		hl			; $280f: $2b
	ld		a, (hl)			; $2810: $7e
	and		$f0			; $2811: $e6 $f0
	cp		$e0			; $2813: $fe $e0
	jr		z, func_2821			; $2815: $28 $0a
	cp		$50			; $2817: $fe $50
	jr		z, func_2821			; $2819: $28 $06
	cp		$90			; $281b: $fe $90
	jr		z, func_2821			; $281d: $28 $02
	jr		func_2823			; $281f: $18 $02
func_2821:
	set		1, b			; $2821: $cb $c8
func_2823:
	ld		a, (wIsDiagonalView)		; $2823: $fa $be $c2
	and		a			; $2826: $a7
	jr		nz, +			; $2827: $20 $02
	ld		c, $00			; $2829: $0e $00
+
	ld		hl, data_3f54		; $282b: $21 $54 $3f
	ld		de, $0000		; $282e: $11 $00 $00
	ld		e, b			; $2831: $58
	add		hl, de			; $2832: $19
	sla		c			; $2833: $cb $21
	sla		c			; $2835: $cb $21
	ld		e, c			; $2837: $59
	add		hl, de			; $2838: $19
	ld		a, (hl)			; $2839: $7e
	jr		func_27c0			; $283a: $18 $84

func_283c:
	ld		de, $c27c		; $283c: $11 $7c $c2
	ld		a, ($c2f9)		; $283f: $fa $f9 $c2
	ld		c, a			; $2842: $4f
--
	ld		a, ($c2f8)		; $2843: $fa $f8 $c2
	ld		b, a			; $2846: $47
-
	ld		a, (de)			; $2847: $1a
	inc		de			; $2848: $13
	push		af			; $2849: $f5
	ld		a, $01			; $284a: $3e $01
	ldh		(R_IE), a		; $284c: $e0 $ff
	call		waitUntilHBlankJustStarted			; $284e: $cd $74 $1f
	pop		af			; $2851: $f1
	ldi		(hl), a			; $2852: $22
	ld		a, $09			; $2853: $3e $09
	ldh		(R_IE), a		; $2855: $e0 $ff
	dec		b			; $2857: $05
	jr		nz, -			; $2858: $20 $ed
	push		de			; $285a: $d5
	ld		a, ($c2f8)		; $285b: $fa $f8 $c2
	ld		e, a			; $285e: $5f
	ld		a, $20			; $285f: $3e $20
	sub		e			; $2861: $93
	ld		e, a			; $2862: $5f
	ld		d, $00			; $2863: $16 $00
	add		hl, de			; $2865: $19
	pop		de			; $2866: $d1
	dec		c			; $2867: $0d
	jr		nz, --			; $2868: $20 $d9
	ret					; $286a: $c9

func_286b:
	ld		de, wRoomObjects		; $286b: $11 $00 $c1
	ld		a, l			; $286e: $7d
	sub		e			; $286f: $93
	ld		l, a			; $2870: $6f
	ld		a, h			; $2871: $7c
	sbc		d			; $2872: $9a
	ld		h, a			; $2873: $67
	ld		a, $14			; $2874: $3e $14
	call		hlDivModA			; $2876: $cd $2b $1f
	ld		b, $05			; $2879: $06 $05
-
	rl		l			; $287b: $cb $15
	rl		h			; $287d: $cb $14
	dec		b			; $287f: $05
	jr		nz, -			; $2880: $20 $f9
	ld		de, $0000		; $2882: $11 $00 $00
	ld		e, a			; $2885: $5f
	add		hl, de			; $2886: $19
	ld		de, BG_MAP1		; $2887: $11 $00 $98
	add		hl, de			; $288a: $19
	ret					; $288b: $c9

func_288c:
	call		func_26e2			; $288c: $cd $e2 $26
	ret					; $288f: $c9

func_2890:
	ld		a, ($cf35)		; $2890: $fa $35 $cf
	and		a			; $2893: $a7
	ret		z			; $2894: $c8
	ld		a, (wIsDiagonalView)		; $2895: $fa $be $c2
	and		a			; $2898: $a7
	jr		z, +			; $2899: $28 $07
	ld		a, ($c2f9)		; $289b: $fa $f9 $c2
	inc		a			; $289e: $3c
	ld		($c2f9), a		; $289f: $ea $f9 $c2
+
	ld		a, ($c2f6)		; $28a2: $fa $f6 $c2
	ld		l, a			; $28a5: $6f
	ldh		(<hFF90), a		; $28a6: $e0 $90
	ld		a, ($c2f7)		; $28a8: $fa $f7 $c2
	ld		h, a			; $28ab: $67
	ldh		(<hFF8F), a		; $28ac: $e0 $8f
	call		func_2bcb			; $28ae: $cd $cb $2b
	ldh		a, (<hFF8E)		; $28b1: $f0 $8e
	ld		($cf1f), a		; $28b3: $ea $1f $cf
	ld		a, $04			; $28b6: $3e $04
	ld		($cf1d), a		; $28b8: $ea $1d $cf
	ld		a, ($c2f9)		; $28bb: $fa $f9 $c2
	ld		c, a			; $28be: $4f
func_28bf:
	ld		a, ($c2f8)		; $28bf: $fa $f8 $c2
	ld		b, a			; $28c2: $47
func_28c3:
	ld		a, c			; $28c3: $79
	cp		$01			; $28c4: $fe $01
	jr		z, func_2915			; $28c6: $28 $4d
func_28c8:
	xor		a			; $28c8: $af
	ld		e, a			; $28c9: $5f
	ld		a, (hl)			; $28ca: $7e
	call		func_2731			; $28cb: $cd $31 $27
func_28ce:
	ld		d, a			; $28ce: $57
	push		bc			; $28cf: $c5
	push		af			; $28d0: $f5
	ldh		a, (<hFF8E)		; $28d1: $f0 $8e
	ld		b, a			; $28d3: $47
	ldh		a, (<hFF8D)		; $28d4: $f0 $8d
	ld		c, a			; $28d6: $4f
	pop		af			; $28d7: $f1
	cp		$fb			; $28d8: $fe $fb
	jr		nz, +			; $28da: $20 $03
	ld		a, $80			; $28dc: $3e $80
	ld		e, a			; $28de: $5f
+
	ld		a, ($cf1d)		; $28df: $fa $1d $cf
	call		store_c_b_d_e_in_c000plus4a			; $28e2: $cd $f1 $24
	inc		a			; $28e5: $3c
	ld		($cf1d), a		; $28e6: $ea $1d $cf
	ldh		a, (<hFF8E)		; $28e9: $f0 $8e
	add		$08			; $28eb: $c6 $08
	ldh		(<hFF8E), a		; $28ed: $e0 $8e
	pop		bc			; $28ef: $c1
	inc		hl			; $28f0: $23
	dec		b			; $28f1: $05
	jr		nz, func_28c3			; $28f2: $20 $cf
	ld		a, ($cf1f)		; $28f4: $fa $1f $cf
	ldh		(<hFF8E), a		; $28f7: $e0 $8e
	ldh		a, (<hFF8D)		; $28f9: $f0 $8d
	add		$08			; $28fb: $c6 $08
	ldh		(<hFF8D), a		; $28fd: $e0 $8d
	call		func_1f64			; $28ff: $cd $64 $1f
	dec		c			; $2902: $0d
	jr		nz, func_28bf			; $2903: $20 $ba
	call		waitUntilVBlankHandled_andXorCf39			; $2905: $cd $d2 $0f
	ld		a, (wIsDiagonalView)		; $2908: $fa $be $c2
	and		a			; $290b: $a7
	ret		z			; $290c: $c8
	ld		a, ($c2f9)		; $290d: $fa $f9 $c2
	dec		a			; $2910: $3d
	ld		($c2f9), a		; $2911: $ea $f9 $c2
	ret					; $2914: $c9
func_2915:
	ld		a, (wIsDiagonalView)		; $2915: $fa $be $c2
	and		a			; $2918: $a7
	jr		z, func_28c8			; $2919: $28 $ad
	ld		a, ($cf35)		; $291b: $fa $35 $cf
	cp		$01			; $291e: $fe $01
	jr		z, func_2928			; $2920: $28 $06
	xor		a			; $2922: $af
	call		func_2731			; $2923: $cd $31 $27
	jr		func_28ce			; $2926: $18 $a6
func_2928:
	ld		a, $fb			; $2928: $3e $fb
	jr		func_28ce			; $292a: $18 $a2

func_292c:
	ld		de, $c010		; $292c: $11 $10 $c0
	ld		a, ($c2e8)		; $292f: $fa $e8 $c2
	ld		b, a			; $2932: $47
	ld		a, ($c2e9)		; $2933: $fa $e9 $c2
	ld		c, a			; $2936: $4f
	ld		l, $1f			; $2937: $2e $1f
-
	ld		a, (de)			; $2939: $1a
	and		a			; $293a: $a7
	ret		z			; $293b: $c8
	dec		l			; $293c: $2d
	ret		z			; $293d: $c8
	add		c			; $293e: $81
	ld		(de), a			; $293f: $12
	inc		de			; $2940: $13
	ld		a, (de)			; $2941: $1a
	add		b			; $2942: $80
	ld		(de), a			; $2943: $12
	inc		de			; $2944: $13
	inc		de			; $2945: $13
	inc		de			; $2946: $13
	jr		-			; $2947: $18 $f0

func_2949:
	ld		a, ($c2e7)		; $2949: $fa $e7 $c2
	cp		$07			; $294c: $fe $07
	jr		z, func_2957			; $294e: $28 $07
	cp		$04			; $2950: $fe $04
	ret		nz			; $2952: $c0
	call		func_2890			; $2953: $cd $90 $28
	ret					; $2956: $c9
func_2957:
	ld		a, ($c2f6)		; $2957: $fa $f6 $c2
	ld		l, a			; $295a: $6f
	ld		a, ($c2f7)		; $295b: $fa $f7 $c2
	ld		h, a			; $295e: $67
	ld		de, $0015		; $295f: $11 $15 $00
	add		hl, de			; $2962: $19
	ld		a, (wExtraMenuColumns)		; $2963: $fa $11 $cf
	and		a			; $2966: $a7
	jr		nz, func_296c			; $2967: $20 $03
	ld		a, (hl)			; $2969: $7e
	jr		func_2979			; $296a: $18 $0d
func_296c:
	ld		a, (hl)			; $296c: $7e
	ld		de, data_3f70		; $296d: $11 $70 $3f
	and		$0f			; $2970: $e6 $0f
	add		e			; $2972: $83
	ld		e, a			; $2973: $5f
	ld		a, $00			; $2974: $3e $00
	adc		d			; $2976: $8a
	ld		d, a			; $2977: $57
	ld		a, (de)			; $2978: $1a
func_2979:
	call		func_2e4e			; $2979: $cd $4e $2e
	ld		b, $09			; $297c: $06 $09
	ld		a, (wIsDiagonalView)		; $297e: $fa $be $c2
	and		a			; $2981: $a7
	jr		z, +			; $2982: $28 $02
	ld		b, $0c			; $2984: $06 $0c
+
	ld		hl, $c012		; $2986: $21 $12 $c0
	ld		de, $c27c		; $2989: $11 $7c $c2
-
	ld		a, (de)			; $298c: $1a
	inc		de			; $298d: $13
	ldi		(hl), a			; $298e: $22
	ld		a, (de)			; $298f: $1a
	inc		de			; $2990: $13
	ldi		(hl), a			; $2991: $22
	inc		hl			; $2992: $23
	inc		hl			; $2993: $23
	dec		b			; $2994: $05
	jr		nz, -			; $2995: $20 $f5
	call		waitUntilVBlankHandled_andXorCf39			; $2997: $cd $d2 $0f
	ret					; $299a: $c9

func_299b:
	ld		de, $c010		; $299b: $11 $10 $c0
	ld		b, $1e			; $299e: $06 $1e
	xor		a			; $29a0: $af
-
	ld		(de), a			; $29a1: $12
	inc		de			; $29a2: $13
	inc		de			; $29a3: $13
	inc		de			; $29a4: $13
	inc		de			; $29a5: $13
	dec		b			; $29a6: $05
	jr		nz, -			; $29a7: $20 $f8
	ret					; $29a9: $c9

func_29aa:
	ld		a, ($cf35)		; $29aa: $fa $35 $cf
	cp		$01			; $29ad: $fe $01
	ret		nz			; $29af: $c0
	ld		a, ($c2f6)		; $29b0: $fa $f6 $c2
	ld		l, a			; $29b3: $6f
	ld		a, ($c2f7)		; $29b4: $fa $f7 $c2
	ld		h, a			; $29b7: $67
	ld		a, ($c2f9)		; $29b8: $fa $f9 $c2
	ld		c, a			; $29bb: $4f
--
	ld		a, ($c2f8)		; $29bc: $fa $f8 $c2
	ld		b, a			; $29bf: $47
-
	ldi		a, (hl)			; $29c0: $2a
	and		$f0			; $29c1: $e6 $f0
	cp		$50			; $29c3: $fe $50
	ret		nz			; $29c5: $c0
	dec		b			; $29c6: $05
	jr		nz, -			; $29c7: $20 $f7
	call		func_1f64			; $29c9: $cd $64 $1f
	dec		c			; $29cc: $0d
	jr		nz, --			; $29cd: $20 $ed
	ld		b, SND_0b			; $29cf: $06 $0b
	rst_playSound
	ld		a, ($c2f6)		; $29d2: $fa $f6 $c2
	ld		l, a			; $29d5: $6f
	ld		a, ($c2f7)		; $29d6: $fa $f7 $c2
	ld		h, a			; $29d9: $67
	ld		a, ($c2f9)		; $29da: $fa $f9 $c2
	ld		c, a			; $29dd: $4f
--
	ld		a, ($c2f8)		; $29de: $fa $f8 $c2
	ld		b, a			; $29e1: $47
	xor		a			; $29e2: $af
-
	ldi		(hl), a			; $29e3: $22
	dec		b			; $29e4: $05
	jr		nz, -			; $29e5: $20 $fc
	call		func_1f64			; $29e7: $cd $64 $1f
	dec		c			; $29ea: $0d
	jr		nz, --			; $29eb: $20 $f1
	call		func_26e2			; $29ed: $cd $e2 $26
	ld		hl, $c2f9		; $29f0: $21 $f9 $c2
	inc		(hl)			; $29f3: $34
	ld		a, (wIsDiagonalView)		; $29f4: $fa $be $c2
	inc		a			; $29f7: $3c
	ld		e, a			; $29f8: $5f
	ld		($cf1b), a		; $29f9: $ea $1b $cf
----
	push		de			; $29fc: $d5
	ld		d, $08			; $29fd: $16 $08
---
	call		waitUntilVBlankHandled_andXorCf39			; $29ff: $cd $d2 $0f
	dec		d			; $2a02: $15
	jr		nz, ---			; $2a03: $20 $fa
	ld		a, ($c2f9)		; $2a05: $fa $f9 $c2
	ld		c, a			; $2a08: $4f
	ld		de, $c012		; $2a09: $11 $12 $c0
	ld		hl, $c29a		; $2a0c: $21 $9a $c2
--
	ld		a, ($c2f8)		; $2a0f: $fa $f8 $c2
	ld		b, a			; $2a12: $47
-
	push		bc			; $2a13: $c5
	ldi		a, (hl)			; $2a14: $2a
	call		func_2a65			; $2a15: $cd $65 $2a
	ld		(de), a			; $2a18: $12
	inc		de			; $2a19: $13
	ld		a, b			; $2a1a: $78
	ld		(de), a			; $2a1b: $12
	inc		de			; $2a1c: $13
	inc		de			; $2a1d: $13
	inc		de			; $2a1e: $13
	pop		bc			; $2a1f: $c1
	dec		b			; $2a20: $05
	jr		nz, -			; $2a21: $20 $f0
	dec		c			; $2a23: $0d
	jr		nz, --			; $2a24: $20 $e9
	pop		de			; $2a26: $d1
	dec		e			; $2a27: $1d
	ld		a, e			; $2a28: $7b
	ld		($cf1b), a		; $2a29: $ea $1b $cf
	and		a			; $2a2c: $a7
	jr		nz, ----			; $2a2d: $20 $cd
	ld		d, $0a			; $2a2f: $16 $0a
-
	call		waitUntilVBlankHandled_andXorCf39			; $2a31: $cd $d2 $0f
	dec		d			; $2a34: $15
	jr		nz, -			; $2a35: $20 $fa
	ld		a, (wIsDiagonalView)		; $2a37: $fa $be $c2
	and		a			; $2a3a: $a7
	jr		z, +			; $2a3b: $28 $04
	ld		hl, $c2f9		; $2a3d: $21 $f9 $c2
	dec		(hl)			; $2a40: $35
+
	ld		a, ($c2f9)		; $2a41: $fa $f9 $c2
	inc		a			; $2a44: $3c
	ld		($c2f9), a		; $2a45: $ea $f9 $c2
	ld		a, ($c2f6)		; $2a48: $fa $f6 $c2
	ld		l, a			; $2a4b: $6f
	ld		a, ($c2f7)		; $2a4c: $fa $f7 $c2
	ld		h, a			; $2a4f: $67
	dec		hl			; $2a50: $2b
	ld		a, l			; $2a51: $7d
	ld		($c2f6), a		; $2a52: $ea $f6 $c2
	ld		a, h			; $2a55: $7c
	ld		($c2f7), a		; $2a56: $ea $f7 $c2
	ld		a, ($c2f8)		; $2a59: $fa $f8 $c2
	inc		a			; $2a5c: $3c
	inc		a			; $2a5d: $3c
	ld		($c2f8), a		; $2a5e: $ea $f8 $c2
	call		func_26e2			; $2a61: $cd $e2 $26
	ret					; $2a64: $c9

func_2a65:
	push		hl			; $2a65: $e5
	push		de			; $2a66: $d5
	ld		($cf1c), a		; $2a67: $ea $1c $cf
	ld		hl, data_2ad5		; $2a6a: $21 $d5 $2a
	ld		a, (wIsDiagonalView)		; $2a6d: $fa $be $c2
	and		a			; $2a70: $a7
	jr		z, +			; $2a71: $28 $08
	ld		a, c			; $2a73: $79
	cp		$01			; $2a74: $fe $01
	jr		z, func_2a9e			; $2a76: $28 $26
	ld		hl, data_2af5		; $2a78: $21 $f5 $2a
+
	ld		a, ($cf1b)		; $2a7b: $fa $1b $cf
	dec		a			; $2a7e: $3d
	sla		a			; $2a7f: $cb $27
	sla		a			; $2a81: $cb $27
	sla		a			; $2a83: $cb $27
	sla		a			; $2a85: $cb $27
	sla		a			; $2a87: $cb $27
	call		addAToHl			; $2a89: $cd $6b $24
	ld		a, ($cf1c)		; $2a8c: $fa $1c $cf
	and		$0f			; $2a8f: $e6 $0f
	sla		a			; $2a91: $cb $27
	ld		e, a			; $2a93: $5f
	ld		d, $00			; $2a94: $16 $00
func_2a96:
	add		hl, de			; $2a96: $19
	inc		hl			; $2a97: $23
	ldd		a, (hl)			; $2a98: $3a
	ld		b, a			; $2a99: $47
	ld		a, (hl)			; $2a9a: $7e
	pop		de			; $2a9b: $d1
	pop		hl			; $2a9c: $e1
	ret					; $2a9d: $c9

func_2a9e:
	ld		a, ($c2f8)		; $2a9e: $fa $f8 $c2
	cp		$01			; $2aa1: $fe $01
	jr		nz, func_2aaa			; $2aa3: $20 $05
	ld		de, $0000		; $2aa5: $11 $00 $00
	jr		func_2ac2			; $2aa8: $18 $18
func_2aaa:
	ld		a, b			; $2aaa: $78
	cp		$01			; $2aab: $fe $01
	jr		nz, func_2ab4			; $2aad: $20 $05
	ld		de, $0002		; $2aaf: $11 $02 $00
	jr		func_2ac2			; $2ab2: $18 $0e
func_2ab4:
	ld		a, ($c2f8)		; $2ab4: $fa $f8 $c2
	cp		b			; $2ab7: $b8
	jr		nz, func_2abf			; $2ab8: $20 $05
	ld		de, $0004		; $2aba: $11 $04 $00
	jr		func_2ac2			; $2abd: $18 $03
func_2abf:
	ld		de, $0006		; $2abf: $11 $06 $00
func_2ac2:
	ld		hl, data_2b35		; $2ac2: $21 $35 $2b
	add		hl, de			; $2ac5: $19
	ld		a, ($cf1b)		; $2ac6: $fa $1b $cf
	dec		a			; $2ac9: $3d
	sla		a			; $2aca: $cb $27
	sla		a			; $2acc: $cb $27
	sla		a			; $2ace: $cb $27
	ld		e, a			; $2ad0: $5f
	ld		d, $00			; $2ad1: $16 $00
	jr		func_2a96			; $2ad3: $18 $c1

data_2ad5:
.db $f4
	nop					; $2ad6: $00
.db $eb
	jr		nz, -$16			; $2ad8: $20 $ea
	nop					; $2ada: $00
	xor		$40			; $2adb: $ee $40
.db $eb
	nop					; $2ade: $00
.db $ed
	nop					; $2ae0: $00
	xor		$60			; $2ae1: $ee $60
	rst		$28			; $2ae3: $ef
	ld		b, b			; $2ae4: $40
	ld		($ee40), a		; $2ae5: $ea $40 $ee
	nop					; $2ae8: $00
	ldh		a, (R_P1)		; $2ae9: $f0 $00
.db $ec
	jr		nz, -$12			; $2aec: $20 $ee
	jr		nz, -$11			; $2aee: $20 $ef
	nop					; $2af0: $00
.db $ec
	nop					; $2af2: $00
	rst		$38			; $2af3: $ff
	nop					; $2af4: $00

data_2af5:
	di					; $2af5: $f3
	nop					; $2af6: $00
	pop		af			; $2af7: $f1
	nop					; $2af8: $00
	di					; $2af9: $f3
	nop					; $2afa: $00
	pop		af			; $2afb: $f1
	nop					; $2afc: $00
	pop		af			; $2afd: $f1
	jr		nz, -$0e			; $2afe: $20 $f2
	nop					; $2b00: $00
	pop		af			; $2b01: $f1
	jr		nz, -$0e			; $2b02: $20 $f2
	nop					; $2b04: $00
	ldh		a, (R_P1)		; $2b05: $f0 $00
.db $ec
	jr		nz, -$10			; $2b08: $20 $f0
	nop					; $2b0a: $00
.db $ec
	jr		nz, -$14			; $2b0c: $20 $ec
	nop					; $2b0e: $00
	rst		$38			; $2b0f: $ff
	nop					; $2b10: $00
.db $ec
	nop					; $2b12: $00
	rst		$38			; $2b13: $ff
	nop					; $2b14: $00
	adc		(hl)			; $2b15: $8e
	nop					; $2b16: $00
	adc		d			; $2b17: $8a
	nop					; $2b18: $00
	adc		(hl)			; $2b19: $8e
	nop					; $2b1a: $00
	adc		d			; $2b1b: $8a
	nop					; $2b1c: $00
	adc		d			; $2b1d: $8a
	jr		nz, -$75			; $2b1e: $20 $8b
	nop					; $2b20: $00
	adc		d			; $2b21: $8a
	jr		nz, -$75			; $2b22: $20 $8b
	nop					; $2b24: $00
	ret					; $2b25: $c9
	nop					; $2b26: $00
	rlc		b			; $2b27: $cb $00
	ret					; $2b29: $c9
	nop					; $2b2a: $00
	rlc		b			; $2b2b: $cb $00
	call		z, $bf00		; $2b2d: $cc $00 $bf
	nop					; $2b30: $00
	call		z, $bf00		; $2b31: $cc $00 $bf
	nop					; $2b34: $00

data_2b35:
	di					; $2b35: $f3
	ret		nz			; $2b36: $c0
	pop		af			; $2b37: $f1
	ldh		($f1), a		; $2b38: $e0 $f1
	ret		nz			; $2b3a: $c0
.db $f2
	ret		nz			; $2b3c: $c0
	adc		a			; $2b3d: $8f
	add		b			; $2b3e: $80
	adc		h			; $2b3f: $8c
	and		b			; $2b40: $a0
	adc		h			; $2b41: $8c
	add		b			; $2b42: $80
	adc		l			; $2b43: $8d
	add		b			; $2b44: $80

pollInput:
	ld		a, $20			; $2b45: $3e $20
	ldh		(R_P1), a		; $2b47: $e0 $00
	ldh		a, (R_P1)		; $2b49: $f0 $00
	ldh		a, (R_P1)		; $2b4b: $f0 $00
	ldh		a, (R_P1)		; $2b4d: $f0 $00
	ldh		a, (R_P1)		; $2b4f: $f0 $00
	ldh		a, (R_P1)		; $2b51: $f0 $00
	ldh		a, (R_P1)		; $2b53: $f0 $00
	cpl					; $2b55: $2f
	and		$0f			; $2b56: $e6 $0f
	swap		a			; $2b58: $cb $37
	ld		b, a			; $2b5a: $47
	ld		a, $10			; $2b5b: $3e $10
	ldh		(R_P1), a		; $2b5d: $e0 $00
	ldh		a, (R_P1)		; $2b5f: $f0 $00
	ldh		a, (R_P1)		; $2b61: $f0 $00
	ldh		a, (R_P1)		; $2b63: $f0 $00
	ldh		a, (R_P1)		; $2b65: $f0 $00
	ldh		a, (R_P1)		; $2b67: $f0 $00
	ldh		a, (R_P1)		; $2b69: $f0 $00
	ldh		a, (R_P1)		; $2b6b: $f0 $00
	ldh		a, (R_P1)		; $2b6d: $f0 $00
	ldh		a, (R_P1)		; $2b6f: $f0 $00
	ldh		a, (R_P1)		; $2b71: $f0 $00
	cpl					; $2b73: $2f
	and		$0f			; $2b74: $e6 $0f
	or		b			; $2b76: $b0
	ld		c, a			; $2b77: $4f
	ldh		a, (<hKeysPressed)		; $2b78: $f0 $8b
	xor		c			; $2b7a: $a9
	and		c			; $2b7b: $a1
	ldh		(<hNewKeysPressed), a		; $2b7c: $e0 $8c
	ld		a, c			; $2b7e: $79
	ldh		(<hKeysPressed), a		; $2b7f: $e0 $8b
	ld		a, $30			; $2b81: $3e $30
	ldh		(R_P1), a		; $2b83: $e0 $00
	ret					; $2b85: $c9

copyOamDmaFunction:
	ld		c, <hOamFunc			; $2b86: $0e $80
	ld		b, _oamDmaFunctionEnd-_oamDmaFunction			; $2b88: $06 $0a
	ld		hl, _oamDmaFunction		; $2b8a: $21 $94 $2b
-
	ldi		a, (hl)			; $2b8d: $2a
	ld		($ff00+c), a		; $2b8e: $e2
	inc		c			; $2b8f: $0c
	dec		b			; $2b90: $05
	jr		nz, -			; $2b91: $20 $fa
	ret					; $2b93: $c9

_oamDmaFunction:
	ld		a, >wOam			; $2b94: $3e $c0
	ldh		(R_DMA), a		; $2b96: $e0 $46
	ld		a, $28			; $2b98: $3e $28
-
	dec		a			; $2b9a: $3d
	jr		nz, -			; $2b9b: $20 $fd
	ret					; $2b9d: $c9
_oamDmaFunctionEnd:


; Unused?
func_2b9e:
	ldh		a, (<hFF8D)		; $2b9e: $f0 $8d
	sub		$10			; $2ba0: $d6 $10
	srl		a			; $2ba2: $cb $3f
	srl		a			; $2ba4: $cb $3f
	srl		a			; $2ba6: $cb $3f
	ld		de, $0000		; $2ba8: $11 $00 $00
	ld		e, a			; $2bab: $5f
	ld		hl, $9800		; $2bac: $21 $00 $98
	ld		b, $20			; $2baf: $06 $20
-
	add		hl, de			; $2bb1: $19
	dec		b			; $2bb2: $05
	jr		nz, -			; $2bb3: $20 $fc
	ldh		a, (<hFF8E)		; $2bb5: $f0 $8e
	sub		$08			; $2bb7: $d6 $08
	srl		a			; $2bb9: $cb $3f
	srl		a			; $2bbb: $cb $3f
	srl		a			; $2bbd: $cb $3f
	ld		de, $0000		; $2bbf: $11 $00 $00
	ld		e, a			; $2bc2: $5f
	add		hl, de			; $2bc3: $19
	ld		a, h			; $2bc4: $7c
	ldh		(<hFF8F), a		; $2bc5: $e0 $8f
	ld		a, l			; $2bc7: $7d
	ldh		(<hFF90), a		; $2bc8: $e0 $90
	ret					; $2bca: $c9


func_2bcb:
	ldh		a, (<hFF90)		; $2bcb: $f0 $90
	ld		e, a			; $2bcd: $5f
	ldh		a, (<hFF8F)		; $2bce: $f0 $8f
	sub		>$c000			; $2bd0: $d6 $c0
	ld		d, a			; $2bd2: $57
	ld		bc, $0000		; $2bd3: $01 $00 $00
	ld		a, e			; $2bd6: $7b
--
	cp		ROOM_WIDTH			; $2bd7: $fe $14
	jr		c, +			; $2bd9: $38 $07
-
	inc		bc			; $2bdb: $03
	sub		ROOM_WIDTH			; $2bdc: $d6 $14
	scf					; $2bde: $37
	ccf					; $2bdf: $3f
	jr		--			; $2be0: $18 $f5
+
	dec		d			; $2be2: $15
	jr		nz, -			; $2be3: $20 $f6
	sla		a			; $2be5: $cb $27
	sla		a			; $2be7: $cb $27
	sla		a			; $2be9: $cb $27
	add		$08			; $2beb: $c6 $08
	ldh		(<hFF8E), a		; $2bed: $e0 $8e
	ld		a, c			; $2bef: $79
	sla		a			; $2bf0: $cb $27
	sla		a			; $2bf2: $cb $27
	sla		a			; $2bf4: $cb $27
	add		$10			; $2bf6: $c6 $10
	ldh		(<hFF8D), a		; $2bf8: $e0 $8d
	ret					; $2bfa: $c9


rst_jumpTable_body:
	add		a			; $2bfb: $87
	pop		hl			; $2bfc: $e1
	ld		e, a			; $2bfd: $5f
	ld		d, $00			; $2bfe: $16 $00
	add		hl, de			; $2c00: $19
	ld		e, (hl)			; $2c01: $5e
	inc		hl			; $2c02: $23
	ld		d, (hl)			; $2c03: $56
	push		de			; $2c04: $d5
	pop		hl			; $2c05: $e1
	jp		hl			; $2c06: $e9

blankScreenDuringVBlankPeriod:
	ldh		a, (R_IE)		; $2c07: $f0 $ff
	ldh		(<hFF92), a		; $2c09: $e0 $92

	res		BIT_VBLANK, a			; $2c0b: $cb $87
	ldh		(R_IE), a		; $2c0d: $e0 $ff
-
	ldh		a, (R_LY)		; $2c0f: $f0 $44
	cp		$91			; $2c11: $fe $91
	jr		c, -			; $2c13: $38 $fa
	; in vlank period, reset bit 7 (blank screen)
	ldh		a, (R_LCDC)		; $2c15: $f0 $40
	and		$7f			; $2c17: $e6 $7f
	ldh		(R_LCDC), a		; $2c19: $e0 $40

	ldh		a, (<hFF92)		; $2c1b: $f0 $92
	ldh		(R_IE), a		; $2c1d: $e0 $ff
	ret					; $2c1f: $c9

enableLCD:
	ldh		a, (R_LCDC)		; $2c20: $f0 $40
	set		7, a			; $2c22: $cb $ff
	ldh		(R_LCDC), a		; $2c24: $e0 $40
	ret					; $2c26: $c9

;;
; @param	a		value to copy
; @param	bc		# of bytes
; @param	hl		where to copy to
setA_bcTimesToHl:
	push		af			; $2c27: $f5
	push		bc			; $2c28: $c5
	push		de			; $2c29: $d5
	push		hl			; $2c2a: $e5
	ld		e, a			; $2c2b: $5f
-
	ld		a, e			; $2c2c: $7b
	ldi		(hl), a			; $2c2d: $22
	dec		bc			; $2c2e: $0b
	ld		a, c			; $2c2f: $79
	or		b			; $2c30: $b0
	jr		nz, -			; $2c31: $20 $f9
	pop		hl			; $2c33: $e1
	pop		de			; $2c34: $d1
	pop		bc			; $2c35: $c1
	pop		af			; $2c36: $f1
	ret					; $2c37: $c9

;;
; @param	a		value to fill all of bg map 1
fill1stBgMap:
	ld		hl, $9bff		; $2c38: $21 $ff $9b
	ld		bc, $0400		; $2c3b: $01 $00 $04
	ld		e, a			; $2c3e: $5f
-
	ld		a, e			; $2c3f: $7b
	ldd		(hl), a			; $2c40: $32
	dec		bc			; $2c41: $0b
	ld		a, b			; $2c42: $78
	or		c			; $2c43: $b1
	jr		nz, -			; $2c44: $20 $f9
	ret					; $2c46: $c9

;;
; @param	hl		source
; @param	de		destination
; @param	bc		number of bytes
copyMemoryBc:
	ldi		a, (hl)			; $2c47: $2a
	ld		(de), a			; $2c48: $12
	inc		de			; $2c49: $13
	dec		bc			; $2c4a: $0b
	ld		a, b			; $2c4b: $78
	or		c			; $2c4c: $b1
	jr		nz, copyMemoryBc			; $2c4d: $20 $f8
	ret					; $2c4f: $c9

; Unused?
func_2c50:
	inc		de			; $2c50: $13
	ld		h, a			; $2c51: $67
	ld		a, (de)			; $2c52: $1a
	ld		l, a			; $2c53: $6f
	inc		de			; $2c54: $13
	ld		a, (de)			; $2c55: $1a
	inc		de			; $2c56: $13
	call		func_2c60			; $2c57: $cd $60 $2c
	ld		a, (de)			; $2c5a: $1a
	cp		$00			; $2c5b: $fe $00
	jr		nz, func_2c50			; $2c5d: $20 $f1
	ret					; $2c5f: $c9

func_2c60:
	push		af			; $2c60: $f5
	and		$3f			; $2c61: $e6 $3f
	ld		b, a			; $2c63: $47
	pop		af			; $2c64: $f1
	rlca					; $2c65: $07
	rlca					; $2c66: $07
	and		$03			; $2c67: $e6 $03
	jr		z, func_2c73			; $2c69: $28 $08
	dec		a			; $2c6b: $3d
	jr		z, func_2c7a			; $2c6c: $28 $0c
	dec		a			; $2c6e: $3d
	jr		z, func_2c81			; $2c6f: $28 $10
	jr		func_2c8e			; $2c71: $18 $1b
func_2c73:
	ld		a, (de)			; $2c73: $1a
	ldi		(hl), a			; $2c74: $22
	inc		de			; $2c75: $13
	dec		b			; $2c76: $05
	jr		nz, func_2c73			; $2c77: $20 $fa
	ret					; $2c79: $c9
func_2c7a:
	ld		a, (de)			; $2c7a: $1a
	inc		de			; $2c7b: $13
-
	ldi		(hl), a			; $2c7c: $22
	dec		b			; $2c7d: $05
	jr		nz, -			; $2c7e: $20 $fc
	ret					; $2c80: $c9
func_2c81:
	ld		a, (de)			; $2c81: $1a
	ld		(hl), a			; $2c82: $77
	inc		de			; $2c83: $13
	ld		a, b			; $2c84: $78
	ld		bc, $0020		; $2c85: $01 $20 $00
	add		hl, bc			; $2c88: $09
	ld		b, a			; $2c89: $47
	dec		b			; $2c8a: $05
	jr		nz, func_2c81			; $2c8b: $20 $f4
	ret					; $2c8d: $c9
func_2c8e:
	ld		a, (de)			; $2c8e: $1a
	ld		(hl), a			; $2c8f: $77
	ld		a, b			; $2c90: $78
	ld		bc, $0020		; $2c91: $01 $20 $00
	add		hl, bc			; $2c94: $09
	ld		b, a			; $2c95: $47
	dec		b			; $2c96: $05
	jr		nz, func_2c8e			; $2c97: $20 $f5
	inc		de			; $2c99: $13
	ret					; $2c9a: $c9

; TODO: something to do with oam data
; eg game select cursor has:
; a = $ab
; hl = $9944
; de = $40
; bc = $02
; @param	a		always seems to be $ab
; @param	hl		position of sprite
; @param	de		typically $40, 1 case $20, 1 case $720 - number of bytes to copy?
; @param	bc		either $0001-$0004 or $0104
loadCursorData:
	; $cf06 = $3c
	; $cf07 = l
	; $cf08 = h
	; $cf0f = a
	; $cf11 = b
	; $cf12 = c
	; $cf17 = e
	; $cf18 = d
	; $cf19 = 0
	ld		($cf0f), a		; $2c9b: $ea $0f $cf
	ld		a, b			; $2c9e: $78
	ld		(wExtraMenuColumns), a		; $2c9f: $ea $11 $cf
	ld		a, c			; $2ca2: $79
	ld		(wExtraMenuRows), a		; $2ca3: $ea $12 $cf
	ld		a, e			; $2ca6: $7b
	ld		(wCursorXMovement), a		; $2ca7: $ea $17 $cf
	ld		a, d			; $2caa: $7a
	ld		(wCursorYMovement), a		; $2cab: $ea $18 $cf
	ld		a, $3c			; $2cae: $3e $3c
	ld		($cf06), a		; $2cb0: $ea $06 $cf
	xor		a			; $2cb3: $af
	ld		(wMenuOptionSelected), a		; $2cb4: $ea $19 $cf
	ld		bc, $0000		; $2cb7: $01 $00 $00
	call		storeHlIntoCf08_7			; $2cba: $cd $2f $22
	call		func_2e0f			; $2cbd: $cd $0f $2e
func_2cc0:
	ld		a, (wcf3a)		; $2cc0: $fa $3a $cf
	cp		$01			; $2cc3: $fe $01
	jr		nz, func_2cee			; $2cc5: $20 $27
	ld		a, (wcf39)		; $2cc7: $fa $39 $cf
	and		a			; $2cca: $a7
	jr		z, func_2cd3			; $2ccb: $28 $06
	ld		a, $f0			; $2ccd: $3e $f0
	ld		(wMenuOptionSelected), a		; $2ccf: $ea $19 $cf
	ret					; $2cd2: $c9
func_2cd3:
	ld		a, ($cf06)		; $2cd3: $fa $06 $cf
	dec		a			; $2cd6: $3d
	ld		($cf06), a		; $2cd7: $ea $06 $cf
	jr		nz, +			; $2cda: $20 $08
	ld		a, $3c			; $2cdc: $3e $3c
	ld		($cf06), a		; $2cde: $ea $06 $cf
	call		serialTransferByte9f_copy			; $2ce1: $cd $b1 $03
+
	push		bc			; $2ce4: $c5
	call		pollInput			; $2ce5: $cd $45 $2b
	pop		bc			; $2ce8: $c1
	call		waitUntilVBlankHandled_andXorCf39			; $2ce9: $cd $d2 $0f
	jr		func_2d07			; $2cec: $18 $19
func_2cee:
	push		hl			; $2cee: $e5
	push		de			; $2cef: $d5
	push		bc			; $2cf0: $c5
	ld		a, $02			; $2cf1: $3e $02
	ld		(wcf3a), a		; $2cf3: $ea $3a $cf
	ld		a, (wcf3c)		; $2cf6: $fa $3c $cf
	and		a			; $2cf9: $a7
	jr		z, func_2d01			; $2cfa: $28 $05
	call		func_3512			; $2cfc: $cd $12 $35
	jr		func_2d04			; $2cff: $18 $03
func_2d01:
	call		func_3505			; $2d01: $cd $05 $35
func_2d04:
	pop		bc			; $2d04: $c1
	pop		de			; $2d05: $d1
	pop		hl			; $2d06: $e1
func_2d07:
	ldh		a, (<hNewKeysPressed)		; $2d07: $f0 $8c
	and		a			; $2d09: $a7
	jr		z, func_2cc0			; $2d0a: $28 $b4
	bit		BTN_BIT_A, a			; $2d0c: $cb $47
	jr		z, @notA			; $2d0e: $28 $09

@optionSelected:
	call		func_2e1d			; $2d10: $cd $1d $2e
	ld		b, SND_MENU_OPTION_SELECTED			; $2d13: $06 $10
	rst_playSound
	jp		@retAfterOptionSelectedOrGoingBack			; $2d16: $c3 $f0 $2d
	
@notA:
	bit		BTN_BIT_B, a			; $2d19: $cb $4f
	jr		z, @notAorB			; $2d1b: $28 $0e
	call		func_2e1d			; $2d1d: $cd $1d $2e
	ld		a, $ff			; $2d20: $3e $ff
	ld		(wMenuOptionSelected), a		; $2d22: $ea $19 $cf
	ld		b, SND_PRESSED_B_ON_MENU			; $2d25: $06 $11
	rst_playSound
	jp		@retAfterOptionSelectedOrGoingBack			; $2d28: $c3 $f0 $2d

@notAorB:
	bit		BTN_BIT_START, a
	jr		z, @directionals
	jp		@optionSelected

@directionals:
	bit		BTN_BIT_RIGHT, a			; $2d32: $cb $67
	jr		z, @notRight			; $2d34: $28 $2e
	ld		a, (wExtraMenuColumns)		; $2d36: $fa $11 $cf
	and		a			; $2d39: $a7
	jp		z, @notRight		; $2d3a: $ca $64 $2d

	; pressed right and can go right
	call		func_2e1d			; $2d3d: $cd $1d $2e
	ld		a, (wExtraMenuColumns)		; $2d40: $fa $11 $cf
	sub		b			; $2d43: $90
	jr		nz, @func_2d4a			; $2d44: $20 $04
	ld		b, $00			; $2d46: $06 $00
	jr		@rightDone			; $2d48: $18 $11
	
@func_2d4a:
	inc		b			; $2d4a: $04
	ld		a, (wExtraMenuColumns)		; $2d4b: $fa $11 $cf
	sub		b			; $2d4e: $90
	jr		nz, @rightDone			; $2d4f: $20 $0a
	ld		a, ($cf13)		; $2d51: $fa $13 $cf
	sub		c			; $2d54: $91
	jr		nc, @rightDone			; $2d55: $30 $04
	ld		a, ($cf13)		; $2d57: $fa $13 $cf
	ld		c, a			; $2d5a: $4f

@rightDone:
	call		@directionalsDone			; $2d5b: $cd $f1 $2d
	call		directionalButtonsPressedInMenu			; $2d5e: $cd $06 $2e
	jp		func_2cc0			; $2d61: $c3 $c0 $2c

@notRight:
	ldh		a, (<hNewKeysPressed)		; $2d64: $f0 $8c
	bit		BTN_BIT_LEFT, a			; $2d66: $cb $6f
	jr		z, @notRightLeft			; $2d68: $28 $26
	ld		a, (wExtraMenuColumns)		; $2d6a: $fa $11 $cf
	and		a			; $2d6d: $a7
	jr		z, @notRightLeft			; $2d6e: $28 $20

	; left can be processed
	call		func_2e1d			; $2d70: $cd $1d $2e
	ld		a, b			; $2d73: $78
	and		a			; $2d74: $a7
	jr		nz, @func_2d83			; $2d75: $20 $0c
	ld		a, (wExtraMenuColumns)		; $2d77: $fa $11 $cf
	ld		b, a			; $2d7a: $47
	ld		a, ($cf13)		; $2d7b: $fa $13 $cf
	sub		c			; $2d7e: $91
	jr		c, @func_2d86			; $2d7f: $38 $05
	jr		@leftDone			; $2d81: $18 $04

@func_2d83:
	dec		b			; $2d83: $05
	jr		@leftDone			; $2d84: $18 $01

@func_2d86:
	dec		b			; $2d86: $05

@leftDone:
	call		@directionalsDone			; $2d87: $cd $f1 $2d
	call		directionalButtonsPressedInMenu			; $2d8a: $cd $06 $2e
	jp		func_2cc0			; $2d8d: $c3 $c0 $2c

@notRightLeft:
	ldh		a, (<hNewKeysPressed)		; $2d90: $f0 $8c
	bit		BTN_BIT_UP, a			; $2d92: $cb $77
	jr		z, @notRightLeftUp			; $2d94: $28 $29
	ld		a, (wExtraMenuRows)		; $2d96: $fa $12 $cf
	and		a			; $2d99: $a7
	jr		z, @notRightLeftUp			; $2d9a: $28 $23
	
	; up can be processed
	call		func_2e1d			; $2d9c: $cd $1d $2e
	ld		a, c			; $2d9f: $79
	and		a			; $2da0: $a7
	jr		nz, @func_2db5			; $2da1: $20 $12
	ld		a, (wExtraMenuColumns)		; $2da3: $fa $11 $cf
	sub		b			; $2da6: $90
	jr		z, @func_2daf			; $2da7: $28 $06
	ld		a, (wExtraMenuRows)		; $2da9: $fa $12 $cf
	ld		c, a			; $2dac: $4f
	jr		@upDone			; $2dad: $18 $07

@func_2daf:
	ld		a, ($cf13)		; $2daf: $fa $13 $cf
	ld		c, a			; $2db2: $4f
	jr		@upDone			; $2db3: $18 $01

@func_2db5:
	dec		c			; $2db5: $0d

@upDone:
	call		@directionalsDone			; $2db6: $cd $f1 $2d
	call		directionalButtonsPressedInMenu			; $2db9: $cd $06 $2e
	jp		func_2cc0			; $2dbc: $c3 $c0 $2c

@notRightLeftUp:
	ldh		a, (<hNewKeysPressed)		; $2dbf: $f0 $8c
	bit		BTN_BIT_DOWN, a			; $2dc1: $cb $7f
	jp		z, func_2cc0		; $2dc3: $ca $c0 $2c
	ld		a, (wExtraMenuRows)		; $2dc6: $fa $12 $cf
	and		a			; $2dc9: $a7
	jp		z, func_2cc0		; $2dca: $ca $c0 $2c

	; down can be processed
	call		func_2e1d			; $2dcd: $cd $1d $2e
	ld		a, (wExtraMenuRows)		; $2dd0: $fa $12 $cf
	sub		c			; $2dd3: $91
	jr		z, @func_2de5			; $2dd4: $28 $0f
	ld		a, (wExtraMenuColumns)		; $2dd6: $fa $11 $cf
	sub		b			; $2dd9: $90
	jr		nz, +			; $2dda: $20 $06
	ld		a, ($cf13)		; $2ddc: $fa $13 $cf
	sub		c			; $2ddf: $91
	jr		z, @func_2de5			; $2de0: $28 $03
+
	inc		c			; $2de2: $0c
	jr		@downDone			; $2de3: $18 $02
	
@func_2de5:
	ld		c, $00			; $2de5: $0e $00
	
@downDone:
	call		@directionalsDone			; $2de7: $cd $f1 $2d
	call		directionalButtonsPressedInMenu			; $2dea: $cd $06 $2e
	jp		func_2cc0			; $2ded: $c3 $c0 $2c
	
@retAfterOptionSelectedOrGoingBack:
	ret					; $2df0: $c9

@directionalsDone:
	ld		a, b			; $2df1: $78
	push		hl			; $2df2: $e5
	push		af			; $2df3: $f5
	ld		a, (wExtraMenuRows)		; $2df4: $fa $12 $cf
	ld		l, a			; $2df7: $6f
	pop		af			; $2df8: $f1
	inc		l			; $2df9: $2c
	ld		h, $00			; $2dfa: $26 $00
	call		hlTimesEqualsA			; $2dfc: $cd $4d $1f
	ld		a, c			; $2dff: $79
	add		l			; $2e00: $85
	; a = b*(wExtraMenuRows+1)+c
	ld		(wMenuOptionSelected), a		; $2e01: $ea $19 $cf
	pop		hl			; $2e04: $e1
	ret					; $2e05: $c9

directionalButtonsPressedInMenu:
	push		bc
	push		hl
	push		de
	ld		b, SND_MOVING_AROUND_MENU
	rst_playSound
	pop		de
	pop		hl
	pop		bc
func_2e0f:
	call		hlEqualsCursorRealPosition			; $2e0f: $cd $2a $2e
	call		waitUntilHBlankJustStarted			; $2e12: $cd $74 $1f
	ld		a, ($cf0f)		; $2e15: $fa $0f $cf
	ld		(hl), a			; $2e18: $77
	call		waitUntilVBlankHandled_andXorCf39			; $2e19: $cd $d2 $0f
	ret					; $2e1c: $c9

func_2e1d:
	call		hlEqualsCursorRealPosition			; $2e1d: $cd $2a $2e
	call		waitUntilHBlankJustStarted			; $2e20: $cd $74 $1f
	ld		a, $ff			; $2e23: $3e $ff
	ld		(hl), a			; $2e25: $77
	call		waitUntilVBlankHandled_andXorCf39			; $2e26: $cd $d2 $0f
	ret					; $2e29: $c9

;;
; @param		bc		current cursor column/row
; @param[out]	hl
hlEqualsCursorRealPosition:
	push		bc
	ld		a, (wCursorXMovement)
	ld		h, $00
	ld		l, c
	call		hlTimesEqualsA
	call		storeHlIntoCf0a_9

	ld		a, (wCursorYMovement)
	ld		h, $00
	ld		l, b
	call		hlTimesEqualsA
	; bc = cursor x position - origin
	ld		b, h
	ld		c, l
	call		readHlFromCf0a_9

	; hl = cursor y position - origin
	add		hl, bc
	ld		b, h
	ld		c, l
	call		hlEqualsCursorOriginalPosition

	add		hl, bc
	pop		bc
	ret

.include "data/data_2e74.s"

func_3162:
	ld		d, $00			; $3162: $16 $00
	ld		a, ($c2ef)		; $3164: $fa $ef $c2
	cp		$50			; $3167: $fe $50
	jr		nc, func_3184			; $3169: $30 $19
	ld		b, a			; $316b: $47
	ld		hl, data_31c9		; $316c: $21 $c9 $31
-
	ldi		a, (hl)			; $316f: $2a
	ld		c, a			; $3170: $4f
	sub		b			; $3171: $90
	jr		nc, func_3177			; $3172: $30 $03
	inc		d			; $3174: $14
	jr		-			; $3175: $18 $f8
func_3177:
	ld		a, d			; $3177: $7a
	ld		hl, data_31d8		; $3178: $21 $d8 $31
	call		addAToHl			; $317b: $cd $6b $24
	ld		a, (hl)			; $317e: $7e
	ld		c, a			; $317f: $4f
	ld		b, $00			; $3180: $06 $00
	jr		func_3188			; $3182: $18 $04
func_3184:
	ld		c, $ff			; $3184: $0e $ff
	ld		b, $f0			; $3186: $06 $f0
func_3188:
	push		bc			; $3188: $c5
	ld		a, c			; $3189: $79
	ld		l, a			; $318a: $6f
	ld		h, $02			; $318b: $26 $02
--
	ld		b, $00			; $318d: $06 $00
	ld		d, $04			; $318f: $16 $04
-
	sla		a			; $3191: $cb $27
	rl		b			; $3193: $cb $10
	dec		d			; $3195: $15
	jr		nz, -			; $3196: $20 $f9
	ld		e, a			; $3198: $5f
	ld		a, b			; $3199: $78
	cp		$0f			; $319a: $fe $0f
	call		z, func_31b7		; $319c: $cc $b7 $31
	dec		h			; $319f: $25
	jr		z, func_31a5			; $31a0: $28 $03
	ld		a, e			; $31a2: $7b
	jr		--			; $31a3: $18 $e8
func_31a5:
	ld		c, l			; $31a5: $4d
	ld		a, c			; $31a6: $79
	ld		($c2f0), a		; $31a7: $ea $f0 $c2
	pop		bc			; $31aa: $c1
	ld		a, c			; $31ab: $79
	ld		hl, $984d		; $31ac: $21 $4d $98
	call		draw2DigitsAtHl			; $31af: $cd $5d $20
	ld		a, b			; $31b2: $78
	call		draw2DigitsAtHl			; $31b3: $cd $5d $20
	ret					; $31b6: $c9

func_31b7:
	push		af			; $31b7: $f5
	ld		a, h			; $31b8: $7c
	cp		$02			; $31b9: $fe $02
	jr		nz, func_31c3			; $31bb: $20 $06
	ld		a, l			; $31bd: $7d
	and		$0f			; $31be: $e6 $0f
	ld		l, a			; $31c0: $6f
	jr		func_31c7			; $31c1: $18 $04
func_31c3:
	ld		a, l			; $31c3: $7d
	and		$f0			; $31c4: $e6 $f0
	ld		l, a			; $31c6: $6f
func_31c7:
	pop		af			; $31c7: $f1
	ret					; $31c8: $c9

data_31c9:
	dec		b			; $31c9: $05
	rlca					; $31ca: $07
	add		hl, bc			; $31cb: $09
	inc		c			; $31cc: $0c
	rrca					; $31cd: $0f
	inc		de			; $31ce: $13
	rla					; $31cf: $17
	inc		e			; $31d0: $1c
	ld		hl, $2d27		; $31d1: $21 $27 $2d
	inc		(hl)			; $31d4: $34
	inc		a			; $31d5: $3c
	ld		b, l			; $31d6: $45
	ld		c, a			; $31d7: $4f

data_31d8:
	jr		nz, $18			; $31d8: $20 $18
	ld		d, $14			; $31da: $16 $14
	ld		(de), a			; $31dc: $12
	stop					; $31dd: $10
	ld		sp, hl			; $31de: $f9
	ld		hl, sp-$09		; $31df: $f8 $f7
	or		$f5			; $31e1: $f6 $f5
.db $f4
	di					; $31e4: $f3
.db $f2
	pop		af			; $31e6: $f1

func_31e7:
	ld		de, wListOfRandomLevels		; $31e7: $11 $11 $c3
	ld		a, (wc377)		; $31ea: $fa $77 $c3
	ld		(wRng1), a		; $31ed: $ea $28 $cf
	ld		(wRng2), a		; $31f0: $ea $29 $cf
	ld		(wRng3), a		; $31f3: $ea $2a $cf
	ld		(wRng4), a		; $31f6: $ea $2b $cf
	ld		c, $63			; $31f9: $0e $63
-
	call		getNextRandomNumber			; $31fb: $cd $54 $32
	ld		l, a			; $31fe: $6f
	ld		h, $00			; $31ff: $26 $00
	call		getScrollingLevel1stRoomIdxAndRangeOfRoomsBasedOnDifficulty			; $3201: $cd $c9 $3e
	ld		a, b			; $3204: $78
	call		hlDivModA			; $3205: $cd $2b $1f
	add		$1e			; $3208: $c6 $1e
	call		func_323c			; $320a: $cd $3c $32
	cp		$ab			; $320d: $fe $ab
	jr		z, -			; $320f: $28 $ea
	ld		(de), a			; $3211: $12
	inc		de			; $3212: $13
	dec		c			; $3213: $0d
	jr		nz, -			; $3214: $20 $e5

	ld		a, (wNumberOfRandomRoomsForDifficulty)		; $3216: $fa $b9 $c2
	ld		b, a			; $3219: $47
	ld		a, (wGameMode)		; $321a: $fa $b8 $c2
	cp		GAMEMODE_HEADING_OUT			; $321d: $fe $01
	jr		z, +			; $321f: $28 $08
	ld		a, (wc2ba)		; $3221: $fa $ba $c2
	ld		c, a			; $3224: $4f
	sub		b			; $3225: $90
	jr		c, +			; $3226: $38 $01
	ld		b, c			; $3228: $41
+
	ld		a, b			; $3229: $78
	ld		hl, $c2fd		; $322a: $21 $fd $c2
	call		addAToHl			; $322d: $cd $6b $24
	ld		b, $14			; $3230: $06 $14
	ld		de, $c2fd		; $3232: $11 $fd $c2
-
	ldi		a, (hl)			; $3235: $2a
	ld		(de), a			; $3236: $12
	inc		de			; $3237: $13
	dec		b			; $3238: $05
	jr		nz, -			; $3239: $20 $fa
	ret					; $323b: $c9

func_323c:
	push		de			; $323c: $d5
	push		bc			; $323d: $c5
	ld		b, $14			; $323e: $06 $14
	ld		c, a			; $3240: $4f
	dec		de			; $3241: $1b
-
	ld		a, (de)			; $3242: $1a
	cp		c			; $3243: $b9
	jr		z, func_324c			; $3244: $28 $06
	dec		de			; $3246: $1b
	dec		b			; $3247: $05
	jr		nz, -			; $3248: $20 $f8
	jr		func_3250			; $324a: $18 $04
func_324c:
	ld		a, $ab			; $324c: $3e $ab
	jr		func_3251			; $324e: $18 $01
func_3250:
	ld		a, c			; $3250: $79
func_3251:
	pop		bc			; $3251: $c1
	pop		de			; $3252: $d1
	ret					; $3253: $c9

;;
; @param[out]	a		Random number
getNextRandomNumber:
	; divide cf2b by 2 and add carry+$25 to cf28
	ld		a, (wRng4)
	rr		a
	ld		(wRng4), a
	ld		a, (wRng1)
	adc		$25
	ld		(wRng1), a

	; add carry from cf28 + $33 to cf29
	; b = cf28
	ld		b, a
	ld		a, (wRng2)
	adc		$33
	ld		(wRng2), a

	; add carry from cf29 + cf28 + that carry + 55 into cf2a
	; b = cf29+cf28
	adc		b
	ld		b, a
	ld		a, (wRng3)
	adc		$53
	ld		(wRng3), a

	; add carry from the previous (+55)
	; b/a = cf2a+cf29+cf28
	adc		b
	ld		b, a
	ld		a, (wRng4)
	; xor original a without rightmost bit, with b/a above and store back into cf2b
	rl		a
	xor		b
	ld		(wRng4), a
	ret


func_3283:
	ld		a, ($cf3d)		; $3283: $fa $3d $cf
	and		a			; $3286: $a7
	jr		z, +			; $3287: $28 $16
	ld		a, (wc375)		; $3289: $fa $75 $c3
	ldh		(R_SB), a		; $328c: $e0 $01
	ld		hl, SC		; $328e: $21 $02 $ff
	set		0, (hl)			; $3291: $cb $c6
	set		7, (hl)			; $3293: $cb $fe
	ld		a, (wcf3a)		; $3295: $fa $3a $cf
	cp		$01			; $3298: $fe $01
	jr		nz, +			; $329a: $20 $03
	call		doALoop6000Times			; $329c: $cd $d9 $06
+
	ret					; $329f: $c9

func_32a0:
	push		bc			; $32a0: $c5
	ld		bc, $0064		; $32a1: $01 $64 $00
-
	dec		bc			; $32a4: $0b
	ld		a, b			; $32a5: $78
	or		c			; $32a6: $b1
	jr		nz, -			; $32a7: $20 $fb
	pop		bc			; $32a9: $c1
	ret					; $32aa: $c9


serialInterrupt:
	push		af			; $32ab: $f5
	push		bc			; $32ac: $c5
	push		de			; $32ad: $d5
	push		hl			; $32ae: $e5
	ld		a, $01			; $32af: $3e $01
	ldh		(R_IE), a		; $32b1: $e0 $ff
	ldh		a, (R_SB)		; $32b3: $f0 $01
	ld		(wc376), a		; $32b5: $ea $76 $c3
	ld		a, (wcf46)		; $32b8: $fa $46 $cf
	and		a			; $32bb: $a7
	jp		nz, serialFunc_3460		; $32bc: $c2 $60 $34
	ld		a, (wcf48)		; $32bf: $fa $48 $cf
	and		a			; $32c2: $a7
	jp		nz, serialFunc_3328		; $32c3: $c2 $28 $33
	ld		a, (wc376)		; $32c6: $fa $76 $c3
	cp		$71			; $32c9: $fe $71
	jr		nz, serialFunc_32ec			; $32cb: $20 $1f
	ld		a, (wcf3a)		; $32cd: $fa $3a $cf
	cp		$08			; $32d0: $fe $08
	jr		nz, serialFunc_32ec			; $32d2: $20 $18
	ld		a, $01			; $32d4: $3e $01
	ld		(wcf46), a		; $32d6: $ea $46 $cf
	xor		a			; $32d9: $af
	ld		(wcf3a), a		; $32da: $ea $3a $cf
	ld		(wcf01), a		; $32dd: $ea $01 $cf
	ld		a, $72			; $32e0: $3e $72
	ld		(wcf02), a		; $32e2: $ea $02 $cf
	ld		a, $09			; $32e5: $3e $09
	ldh		(R_IE), a		; $32e7: $e0 $ff
	jp		serialFunc_36bc			; $32e9: $c3 $bc $36

serialFunc_32ec:
	ld		a, (wIsDemoScenes)		; $32ec: $fa $43 $cf
	and		a			; $32ef: $a7
	jr		z, +			; $32f0: $28 $03
	ld		(wcf3a), a		; $32f2: $ea $3a $cf
+
	ld		a, (wcf3a)		; $32f5: $fa $3a $cf
	bit		0, a			; $32f8: $cb $47
	jr		nz, serialFunc_3356			; $32fa: $20 $5a
	bit		1, a			; $32fc: $cb $4f
	jp		nz, serialFunc_33b7		; $32fe: $c2 $b7 $33
	bit		2, a			; $3301: $cb $57
	jp		nz, serialFunc_33d0		; $3303: $c2 $d0 $33
	bit		3, a			; $3306: $cb $5f
	jp		nz, serialFunc_33e5		; $3308: $c2 $e5 $33
	bit		4, a			; $330b: $cb $67
	jp		nz, serialFunc_347f		; $330d: $c2 $7f $34
	bit		5, a			; $3310: $cb $6f
	jp		nz, serialFunc_3498		; $3312: $c2 $98 $34
	bit		6, a			; $3315: $cb $77
	jp		nz, serialFunc_34ae		; $3317: $c2 $ae $34
	bit		7, a			; $331a: $cb $7f
	jp		nz, serialFunc_34ce		; $331c: $c2 $ce $34
serialFunc_311f:
	ld		a, $09			; $311f: $3e $09
	ldh		(R_IE), a		; $3321: $e0 $ff
	pop		hl			; $3323: $e1
	pop		de			; $3324: $d1
	pop		bc			; $3325: $c1
	pop		af			; $3326: $f1
	reti					; $3327: $d9

serialFunc_3328:
	xor		a			; $3328: $af
	ld		(wcf05), a		; $3329: $ea $05 $cf
	ld		(wcf48), a		; $332c: $ea $48 $cf
	ld		a, (wcf3c)		; $332f: $fa $3c $cf
	and		a			; $3332: $a7
	jr		z, serialFunc_3349			; $3333: $28 $14
	ld		a, (wc376)		; $3335: $fa $76 $c3
	cp		$fc			; $3338: $fe $fc
	jr		z, serialFunc_3341			; $333a: $28 $05
	ld		a, $01			; $333c: $3e $01
	ld		(wcf05), a		; $333e: $ea $05 $cf
serialFunc_3341:
	ld		a, $01			; $3341: $3e $01
	ld		(wcf39), a		; $3343: $ea $39 $cf
	jp		serialFunc_311f			; $3346: $c3 $1f $33

serialFunc_3349:
	ld		a, (wc376)		; $3349: $fa $76 $c3
	cp		$08			; $334c: $fe $08
	jr		z, serialFunc_3341			; $334e: $28 $f1
	xor		a			; $3350: $af
	ld		(wcf42), a		; $3351: $ea $42 $cf
	jr		serialFunc_3341			; $3354: $18 $eb

serialFunc_3356:
	ld		a, (wc376)		; $3356: $fa $76 $c3
	cp		$9f			; $3359: $fe $9f
	jr		z, serialFunc_336c			; $335b: $28 $0f
	cp		$66			; $335d: $fe $66
	jr		z, serialFunc_3384			; $335f: $28 $23
	cp		$ff			; $3361: $fe $ff
	jr		nz, serialFunc_3374			; $3363: $20 $0f
	xor		a			; $3365: $af
	ld		($cf3d), a		; $3366: $ea $3d $cf
	jp		serialFunc_3374			; $3369: $c3 $74 $33

serialFunc_336c:
	ld		a, $01			; $336c: $3e $01
	ld		(wcf39), a		; $336e: $ea $39 $cf
	jp		serialFunc_311f			; $3371: $c3 $1f $33

serialFunc_3374:
	ld		hl, SC		; $3374: $21 $02 $ff
	res		7, (hl)			; $3377: $cb $be
	ld		a, $9f			; $3379: $3e $9f
	ldh		(R_SB), a		; $337b: $e0 $01
	res		0, (hl)			; $337d: $cb $86
	set		7, (hl)			; $337f: $cb $fe
	jp		serialFunc_311f			; $3381: $c3 $1f $33

serialFunc_3384:
	ld		a, (wc375)		; $3384: $fa $75 $c3
	cp		$66			; $3387: $fe $66
	jr		z, serialFunc_3374			; $3389: $28 $e9
	ld		a, (wIsDemoScenes)		; $338b: $fa $43 $cf
	and		a			; $338e: $a7
	jr		nz, +			; $338f: $20 $0c
	ld		a, (wNumberOfRandomRoomsForDifficulty)		; $3391: $fa $b9 $c2
	ld		(wc37d), a		; $3394: $ea $7d $c3
	ld		a, (wc2ba)		; $3397: $fa $ba $c2
	ld		(wc37e), a		; $339a: $ea $7e $c3
+
	xor		a			; $339d: $af
	ld		(wcf3a), a		; $339e: $ea $3a $cf
	ld		(wcf3c), a		; $33a1: $ea $3c $cf
	ld		(wIsDemoScenes), a		; $33a4: $ea $43 $cf
	ld		a, $01			; $33a7: $3e $01
	ld		(wcf42), a		; $33a9: $ea $42 $cf
	xor		a			; $33ac: $af
	ldh		(R_SCX), a		; $33ad: $e0 $43
	ld		a, $09			; $33af: $3e $09
	ldh		(R_IE), a		; $33b1: $e0 $ff
	ei					; $33b3: $fb
	jp		serialFunc_7049			; $33b4: $c3 $49 $70

serialFunc_33b7:
	ld		a, (wcf3c)		; $33b7: $fa $3c $cf
	and		a			; $33ba: $a7
	jr		nz, +			; $33bb: $20 $07
	ld		a, (wc376)		; $33bd: $fa $76 $c3
	ldh		(<hKeysPressed), a		; $33c0: $e0 $8b
	ldh		(<hNewKeysPressed), a		; $33c2: $e0 $8c
+
	ld		a, $01			; $33c4: $3e $01
	ld		(wcf39), a		; $33c6: $ea $39 $cf
	xor		a			; $33c9: $af
	ld		(wcf3a), a		; $33ca: $ea $3a $cf
	jp		serialFunc_311f			; $33cd: $c3 $1f $33

serialFunc_33d0:
	ld		a, (wcf3c)		; $33d0: $fa $3c $cf
	and		a			; $33d3: $a7
	jp		nz, serialFunc_33dd		; $33d4: $c2 $dd $33
	ld		a, (wc376)		; $33d7: $fa $76 $c3
	ld		(wc377), a		; $33da: $ea $77 $c3
serialFunc_33dd:
	ld		a, $01			; $33dd: $3e $01
	ld		(wcf39), a		; $33df: $ea $39 $cf
	jp		serialFunc_311f			; $33e2: $c3 $1f $33

serialFunc_33e5:
	ld		a, (wc376)		; $33e5: $fa $76 $c3
	cp		$ff			; $33e8: $fe $ff
	jr		z, ++			; $33ea: $28 $3e
	bit		7, a			; $33ec: $cb $7f
	jr		z, +			; $33ee: $28 $08
	res		7, a			; $33f0: $cb $bf
	ld		(wc376), a		; $33f2: $ea $76 $c3
	ld		b, SND_RESET_STAGE_IN_SCROLLING_LEVEL			; $33f5: $06 $13
	rst_playSound
+
	ld		a, (wc2bc)		; $33f8: $fa $bc $c2
	ld		b, a			; $33fb: $47
	ld		a, (wc376)		; $33fc: $fa $76 $c3
	and		a			; $33ff: $a7
	jp		z, ++		; $3400: $ca $2a $34
	cp		$ff			; $3403: $fe $ff
	jp		z, ++		; $3405: $ca $2a $34
	cp		b			; $3408: $b8
	jr		z, ++			; $3409: $28 $1f
	inc		b			; $340b: $04
	cp		b			; $340c: $b8
	jr		nz, ++			; $340d: $20 $1b
	ld		(wc2bc), a		; $340f: $ea $bc $c2
	ld		b, SND_12			; $3412: $06 $12
	rst_playSound
	ld		a, (wc2bc)		; $3415: $fa $bc $c2
	ld		b, a			; $3418: $47
	ld		a, (wc2ba)		; $3419: $fa $ba $c2
	sub		b			; $341c: $90
	inc		a			; $341d: $3c
	call		get2DigitsToDrawFromNonBCD_A			; $341e: $cd $12 $21
	ld		hl, $9823		; $3421: $21 $23 $98
	call		draw2DigitsAtHl			; $3424: $cd $5d $20
	call		serialFunc_344e			; $3427: $cd $4e $34
++
	ld		a, (wcf3c)		; $342a: $fa $3c $cf
	and		a			; $342d: $a7
	jp		nz, serialFunc_311f		; $342e: $c2 $1f $33
	ld		a, (wcf41)		; $3431: $fa $41 $cf
	ld		b, a			; $3434: $47
	ld		a, (wc2bb)		; $3435: $fa $bb $c2
	or		b			; $3438: $b0
	ldh		(R_SB), a		; $3439: $e0 $01
	ld		hl, SC		; $343b: $21 $02 $ff
	res		0, (hl)			; $343e: $cb $86
	set		7, (hl)			; $3440: $cb $fe
	xor		a			; $3442: $af
	ld		(wcf41), a		; $3443: $ea $41 $cf
	ld		a, $01			; $3446: $3e $01
	ld		(wcf00), a		; $3448: $ea $00 $cf
	jp		serialFunc_311f			; $344b: $c3 $1f $33


serialFunc_344e:
	ld		a, (wc2bc)		; $344e: $fa $bc $c2
	ld		($c380), a		; $3451: $ea $80 $c3
	ld		a, (wc2ba)		; $3454: $fa $ba $c2
	ld		($c37f), a		; $3457: $ea $7f $c3
	ld		a, $00			; $345a: $3e $00
	call		func_1e1f			; $345c: $cd $1f $1e
	ret					; $345f: $c9

serialFunc_3460:
	ld		a, (wc376)		; $3460: $fa $76 $c3
	ld		(wcf03), a		; $3463: $ea $03 $cf
	ld		a, $01			; $3466: $3e $01
	ld		(wcf04), a		; $3468: $ea $04 $cf
	jp		serialFunc_311f			; $346b: $c3 $1f $33

func_346e:
	ld		a, (wcf01)		; $346e: $fa $01 $cf
	and		a			; $3471: $a7
	jp		z, serialFunc_383f		; $3472: $ca $3f $38
	ld		a, (wcf3c)		; $3475: $fa $3c $cf
	and		a			; $3478: $a7
	jp		z, func_36ed		; $3479: $ca $ed $36
	jp		serialFunc_383f			; $347c: $c3 $3f $38

serialFunc_347f:
	ld		a, (wcf3c)		; $347f: $fa $3c $cf
	and		a			; $3482: $a7
	jr		nz, +			; $3483: $20 $0b
	ld		a, (wc376)		; $3485: $fa $76 $c3
	cp		$76			; $3488: $fe $76
	jp		nc, serialFunc_311f		; $348a: $d2 $1f $33
	ld		(wc377), a		; $348d: $ea $77 $c3
+
	ld		a, $01			; $3490: $3e $01
	ld		(wcf39), a		; $3492: $ea $39 $cf
	jp		serialFunc_311f			; $3495: $c3 $1f $33

serialFunc_3498:
	ld		a, (wc376)		; $3498: $fa $76 $c3
	cp		$66			; $349b: $fe $66
	jr		z, serialFunc_34a6			; $349d: $28 $07
	cp		$ee			; $349f: $fe $ee
	jr		z, serialFunc_34a6			; $34a1: $28 $03
	jp		serialFunc_311f			; $34a3: $c3 $1f $33

serialFunc_34a6:
	ld		a, $01			; $34a6: $3e $01
	ld		(wcf39), a		; $34a8: $ea $39 $cf
	jp		serialFunc_311f			; $34ab: $c3 $1f $33

serialFunc_34ae:
	ld		a, (wcf3c)		; $34ae: $fa $3c $cf
	and		a			; $34b1: $a7
	jr		nz, serialFunc_34c6			; $34b2: $20 $12
	ld		a, (wc376)		; $34b4: $fa $76 $c3
	bit		0, a			; $34b7: $cb $47
	jr		z, serialFunc_34c2			; $34b9: $28 $07
-
	ld		a, $01			; $34bb: $3e $01
	ld		(wcf40), a		; $34bd: $ea $40 $cf
	jr		serialFunc_34c6			; $34c0: $18 $04

serialFunc_34c2:
	bit		3, a			; $34c2: $cb $5f
	jr		nz, -			; $34c4: $20 $f5
serialFunc_34c6:
	ld		a, $01			; $34c6: $3e $01
	ld		(wcf39), a		; $34c8: $ea $39 $cf
	jp		serialFunc_311f			; $34cb: $c3 $1f $33

serialFunc_34ce:
	ld		a, (wc376)		; $34ce: $fa $76 $c3
	cp		$aa			; $34d1: $fe $aa
	jr		z, serialFunc_34f9			; $34d3: $28 $24
	cp		$bb			; $34d5: $fe $bb
	jr		z, serialFunc_34ff			; $34d7: $28 $26
	ld		(wc2ba), a		; $34d9: $ea $ba $c2
serialFunc_34dc:
	ld		a, $01			; $34dc: $3e $01
	ld		(wcf39), a		; $34de: $ea $39 $cf
	ld		a, (wcf3c)		; $34e1: $fa $3c $cf
	and		a			; $34e4: $a7
	jr		z, serialFunc_34ea			; $34e5: $28 $03
	jp		serialFunc_311f			; $34e7: $c3 $1f $33

serialFunc_34ea:
	ld		a, (wNumberOfRandomRoomsForDifficulty)		; $34ea: $fa $b9 $c2
	ldh		(R_SB), a		; $34ed: $e0 $01
	ld		hl, SC		; $34ef: $21 $02 $ff
	res		0, (hl)			; $34f2: $cb $86
	set		7, (hl)			; $34f4: $cb $fe
	jp		serialFunc_311f			; $34f6: $c3 $1f $33

serialFunc_34f9:
	ld		a, $01			; $34f9: $3e $01
	ldh		(<hNewKeysPressed), a		; $34fb: $e0 $8c
	jr		serialFunc_34dc			; $34fd: $18 $dd

serialFunc_34ff:
	ld		a, $02			; $34ff: $3e $02
	ldh		(<hNewKeysPressed), a		; $3501: $e0 $8c
	jr		serialFunc_34dc			; $3503: $18 $d7


func_3505:
	ld		a, $ee			; $3505: $3e $ee
func_3507:
	ld		hl, SC		; $3507: $21 $02 $ff
	res		7, (hl)			; $350a: $cb $be
	ldh		(R_SB), a		; $350c: $e0 $01
	res		0, (hl)			; $350e: $cb $86
	set		7, (hl)			; $3510: $cb $fe
func_3512:
	xor		a			; $3512: $af
	ld		(wcf39), a		; $3513: $ea $39 $cf
-
	ld		a, (wcf39)		; $3516: $fa $39 $cf
	and		a			; $3519: $a7
	jr		z, -			; $351a: $28 $fa
	xor		a			; $351c: $af
	ld		(wcf3a), a		; $351d: $ea $3a $cf
	ret					; $3520: $c9

func_3521:
	ld		a, (wcf3c)		; $3521: $fa $3c $cf
	and		a			; $3524: $a7
	jp		z, func_1083		; $3525: $ca $83 $10
	xor		a			; $3528: $af
	ld		(wcf3a), a		; $3529: $ea $3a $cf
	ld		a, $08			; $352c: $3e $08
	ld		(wc375), a		; $352e: $ea $75 $c3
	call		func_3283			; $3531: $cd $83 $32
	jp		func_1083			; $3534: $c3 $83 $10

func_03_3537:
	ld		a, (wcf3c)		; $3537: $fa $3c $cf
	and		a			; $353a: $a7
	jp		z, func_107e		; $353b: $ca $7e $10
	ld		a, (wcf02)		; $353e: $fa $02 $cf
	ld		a, (wcf01)		; $3541: $fa $01 $cf
	and		a			; $3544: $a7
	jr		z, func_354b			; $3545: $28 $04
	ld		a, $71			; $3547: $3e $71
	jr		func_354d			; $3549: $18 $02
func_354b:
	ld		a, $72			; $354b: $3e $72
func_354d:
	ld		(wc375), a		; $354d: $ea $75 $c3
	call		func_3283			; $3550: $cd $83 $32
	jp		func_107e			; $3553: $c3 $7e $10

func_3556:
	ld		a, (wIsDemoScenes)		; $3556: $fa $43 $cf
	and		a			; $3559: $a7
	jp		z, func_1083		; $355a: $ca $83 $10
	ldh		a, (<hKeysPressed)		; $355d: $f0 $8b
	push		af			; $355f: $f5
	call		pollInput			; $3560: $cd $45 $2b
	ldh		a, (<hNewKeysPressed)		; $3563: $f0 $8c
	and		BTN_A|BTN_START			; $3565: $e6 $09
	jr		nz, func_356f			; $3567: $20 $06
	pop		af			; $3569: $f1
	ldh		(<hKeysPressed), a		; $356a: $e0 $8b
	jp		func_1083			; $356c: $c3 $83 $10
func_356f:
	pop		af			; $356f: $f1
	xor		a			; $3570: $af
	ldh		(R_SCX), a		; $3571: $e0 $43
	ld		(wIsDemoScenes), a		; $3573: $ea $43 $cf
	ld		(wcf3a), a		; $3576: $ea $3a $cf
	ei					; $3579: $fb
	jp		func_018d			; $357a: $c3 $8d $01

func_357d:
	ld		a, (wcf3c)		; $357d: $fa $3c $cf
	and		a			; $3580: $a7
	jp		z, func_1083		; $3581: $ca $83 $10
	call		pollInput			; $3584: $cd $45 $2b
	ldh		a, (<hNewKeysPressed)		; $3587: $f0 $8c
	cp		BTN_A			; $3589: $fe $01
	jp		nz, func_1083		; $358b: $c2 $83 $10
	ld		a, ($c2ec)		; $358e: $fa $ec $c2
	sla		a			; $3591: $cb $27
	ld		(wc375), a		; $3593: $ea $75 $c3
	ld		(wc377), a		; $3596: $ea $77 $c3
	call		func_3283			; $3599: $cd $83 $32
	ld		a, $01			; $359c: $3e $01
	ld		(wcf3c), a		; $359e: $ea $3c $cf
	xor		a			; $35a1: $af
	jp		func_107e			; $35a2: $c3 $7e $10

func_35a5:
	ld		a, (wcf3c)		; $35a5: $fa $3c $cf
	and		a			; $35a8: $a7
	jp		z, func_1083		; $35a9: $ca $83 $10
	call		pollInput			; $35ac: $cd $45 $2b
	ldh		a, (<hNewKeysPressed)		; $35af: $f0 $8c
	bit		BTN_BIT_START, a			; $35b1: $cb $5f
	jp		z, func_1083		; $35b3: $ca $83 $10
	ld		a, $66			; $35b6: $3e $66
	ld		(wc375), a		; $35b8: $ea $75 $c3
	call		func_3283			; $35bb: $cd $83 $32
	ld		a, $01			; $35be: $3e $01
	ld		(wcf3c), a		; $35c0: $ea $3c $cf
	xor		a			; $35c3: $af
	jp		func_107e			; $35c4: $c3 $7e $10

func_35c7:
	ld		a, (wcf3c)		; $35c7: $fa $3c $cf
	and		a			; $35ca: $a7
	jp		z, func_1083		; $35cb: $ca $83 $10
	call		pollInput			; $35ce: $cd $45 $2b
	ldh		a, (<hNewKeysPressed)		; $35d1: $f0 $8c
	and		a			; $35d3: $a7
	jp		z, func_1083		; $35d4: $ca $83 $10
	ld		(wc375), a		; $35d7: $ea $75 $c3
	call		func_3283			; $35da: $cd $83 $32
	call		func_32a0			; $35dd: $cd $a0 $32
	xor		a			; $35e0: $af
	jp		func_107e			; $35e1: $c3 $7e $10

func_35e4:
	ld		a, (wcf3c)		; $35e4: $fa $3c $cf
	and		a			; $35e7: $a7
	jp		z, func_107e		; $35e8: $ca $7e $10
	ld		a, (wcf41)		; $35eb: $fa $41 $cf
	ld		b, a			; $35ee: $47
	ld		a, (wc2bb)		; $35ef: $fa $bb $c2
	or		b			; $35f2: $b0
	ld		(wc375), a		; $35f3: $ea $75 $c3
	call		func_3283			; $35f6: $cd $83 $32
	xor		a			; $35f9: $af
	ld		(wcf41), a		; $35fa: $ea $41 $cf
	jp		func_107e			; $35fd: $c3 $7e $10

func_3600:
	ld		a, (wcf3c)		; $3600: $fa $3c $cf
	and		a			; $3603: $a7
	jp		z, func_1083		; $3604: $ca $83 $10
	ld		a, (wc377)		; $3607: $fa $77 $c3
	ld		(wc375), a		; $360a: $ea $75 $c3
	call		func_32a0			; $360d: $cd $a0 $32
	call		func_3283			; $3610: $cd $83 $32
	xor		a			; $3613: $af
	jp		func_107e			; $3614: $c3 $7e $10

func_3617:
	ld		a, (wcf3c)		; $3617: $fa $3c $cf
	and		a			; $361a: $a7
	jp		z, func_1083		; $361b: $ca $83 $10
	call		pollInput			; $361e: $cd $45 $2b
	ldh		a, (<hNewKeysPressed)		; $3621: $f0 $8c
	and		BTN_A|BTN_START			; $3623: $e6 $09
	jp		z, func_1083		; $3625: $ca $83 $10
	ld		(wcf40), a		; $3628: $ea $40 $cf
	ldh		a, (<hNewKeysPressed)		; $362b: $f0 $8c
	ld		(wc375), a		; $362d: $ea $75 $c3
	call		func_3283			; $3630: $cd $83 $32
	xor		a			; $3633: $af
	jp		func_107e			; $3634: $c3 $7e $10

func_3637:
	ld		a, (wcf3c)		; $3637: $fa $3c $cf
	and		a			; $363a: $a7
	jp		z, func_1083		; $363b: $ca $83 $10
	ldh		a, (<hNewKeysPressed)		; $363e: $f0 $8c
	and		BTN_A|BTN_START			; $3640: $e6 $09
	jr		nz, func_3657			; $3642: $20 $13
	ldh		a, (<hNewKeysPressed)		; $3644: $f0 $8c
	bit		BTN_BIT_B, a			; $3646: $cb $4f
	jr		nz, func_365b			; $3648: $20 $11
	ld		a, (wNumberOfRandomRoomsForDifficulty)		; $364a: $fa $b9 $c2
func_364d:
	ld		(wc375), a		; $364d: $ea $75 $c3
	call		func_3283			; $3650: $cd $83 $32
	xor		a			; $3653: $af
	jp		func_1083			; $3654: $c3 $83 $10
func_3657:
	ld		a, $aa			; $3657: $3e $aa
	jr		func_364d			; $3659: $18 $f2
func_365b:
	ld		a, $bb			; $365b: $3e $bb
	jr		func_364d			; $365d: $18 $ee

func_365f:
	xor		a			; $365f: $af
	ld		(wcf3a), a		; $3660: $ea $3a $cf
	ld		b, $12			; $3663: $06 $12
-
	call		func_381c			; $3665: $cd $1c $38
	dec		b			; $3668: $05
	jr		nz, -			; $3669: $20 $fa
	ret					; $366b: $c9

func_366c:
	xor		a			; $366c: $af
	ld		(wcf3a), a		; $366d: $ea $3a $cf
	ldh		(R_SCX), a		; $3670: $e0 $43
	ld		b, $b4			; $3672: $06 $b4
--
	ldh		a, (R_LY)		; $3674: $f0 $44
	cp		$28			; $3676: $fe $28
	jr		z, func_367c			; $3678: $28 $02
	jr		--			; $367a: $18 $f8
func_367c:
	ld		a, ($ceff)		; $367c: $fa $ff $ce
	ldh		(R_SCX), a		; $367f: $e0 $43
-
	ldh		a, (R_LY)		; $3681: $f0 $44
	cp		$68			; $3683: $fe $68
	jr		z, func_3689			; $3685: $28 $02
	jr		-			; $3687: $18 $f8
func_3689:
	xor		a			; $3689: $af
	ldh		(R_SCX), a		; $368a: $e0 $43
	call		waitUntilVBlankHandled_andXorCf39			; $368c: $cd $d2 $0f
	dec		b			; $368f: $05
	jr		nz, --			; $3690: $20 $e2
	ret					; $3692: $c9

func_3693:
	ld		a, (wc2bb)		; $3693: $fa $bb $c2
	ld		($c380), a		; $3696: $ea $80 $c3
	ld		a, (wNumberOfRandomRoomsForDifficulty)		; $3699: $fa $b9 $c2
	ld		($c37f), a		; $369c: $ea $7f $c3
	ld		a, $01			; $369f: $3e $01
	call		func_1e1f			; $36a1: $cd $1f $1e
	ret					; $36a4: $c9

func_36a5:
	call		clear1st100bytesOfWram			; $36a5: $cd $81 $1f
	ld		a, (wGameMode)		; $36a8: $fa $b8 $c2
	cp		GAMEMODE_HEADING_OUT			; $36ab: $fe $01
	jr		z, func_36ed			; $36ad: $28 $3e
	ld		a, $71			; $36af: $3e $71
	ld		(wcf02), a		; $36b1: $ea $02 $cf
	ld		a, $01			; $36b4: $3e $01
	ld		(wcf01), a		; $36b6: $ea $01 $cf
	ld		(wcf46), a		; $36b9: $ea $46 $cf
serialFunc_36bc:
	ei					; $36bc: $fb
	xor		a			; $36bd: $af
	ld		(wcf03), a		; $36be: $ea $03 $cf
	ld		(wcf04), a		; $36c1: $ea $04 $cf
	ld		a, (wcf3c)		; $36c4: $fa $3c $cf
	and		a			; $36c7: $a7
	jr		nz, func_36d8			; $36c8: $20 $0e
	ld		hl, SC		; $36ca: $21 $02 $ff
	res		7, (hl)			; $36cd: $cb $be
	ld		a, (wcf02)		; $36cf: $fa $02 $cf
	ldh		(R_SB), a		; $36d2: $e0 $01
	res		0, (hl)			; $36d4: $cb $86
	set		7, (hl)			; $36d6: $cb $fe
func_36d8:
	ld		a, (wcf04)		; $36d8: $fa $04 $cf
	and		a			; $36db: $a7
	jr		z, func_36d8			; $36dc: $28 $fa
	ld		a, (wcf03)		; $36de: $fa $03 $cf
	cp		$71			; $36e1: $fe $71
	jp		z, func_346e		; $36e3: $ca $6e $34

; Unused?
func_36e6:
	cp		$72			; $36e6: $fe $72
	jr		z, func_36ed			; $36e8: $28 $03
	jp		serialFunc_36bc			; $36ea: $c3 $bc $36

func_36ed:
	ei					; $36ed: $fb
	ld		a, $09			; $36ee: $3e $09
	ldh		(R_IE), a		; $36f0: $e0 $ff
	xor		a			; $36f2: $af
	ld		(wcf01), a		; $36f3: $ea $01 $cf
	ld		(wcf02), a		; $36f6: $ea $02 $cf
	ld		(wcf46), a		; $36f9: $ea $46 $cf
	ld		(wcf3a), a		; $36fc: $ea $3a $cf
	ld		($c37a), a		; $36ff: $ea $7a $c3
	ld		($cf3f), a		; $3702: $ea $3f $cf
	call		func_3693			; $3705: $cd $93 $36
	ld		a, (wGameMode)		; $3708: $fa $b8 $c2
	cp		GAMEMODE_HEADING_OUT			; $370b: $fe $01
	jr		nz, +			; $370d: $20 $03
	call		func_20b2			; $370f: $cd $b2 $20
+
	ld		hl, $9a01		; $3712: $21 $01 $9a
	ld		de, clearedLayoutData		; $3715: $11 $cb $3a
	call		loadBGTileMapData			; $3718: $cd $d4 $3a
	ld		b, MUS_LEVEL_JUST_CLEARED			; $371b: $06 $04
	rst_playSound
	ld		a, $ff			; $371e: $3e $ff
	ldh		(<hNewKeysPressed), a		; $3720: $e0 $8c
	call		func_365f			; $3722: $cd $5f $36
	ld		a, ($c378)		; $3725: $fa $78 $c3
	inc		a			; $3728: $3c
	ld		($c378), a		; $3729: $ea $78 $c3
	call		doALoop6000Times			; $372c: $cd $d9 $06
	jp		func_392a			; $372f: $c3 $2a $39

func_3732:
	ld		a, $09			; $3732: $3e $09
	ldh		(R_IE), a		; $3734: $e0 $ff
	ld		a, (wIsDemoScenes)		; $3736: $fa $43 $cf
	and		a			; $3739: $a7
	call		nz, resetSerialTransfer		; $373a: $c4 $11 $70
	call		drawLevelClearScreen			; $373d: $cd $f7 $39
	call		func_17dc			; $3740: $cd $dc $17
	call		func_7000			; $3743: $cd $00 $70
	ld		a, (wGameMode)		; $3746: $fa $b8 $c2
	cp		GAMEMODE_HEADING_OUT			; $3749: $fe $01
	jp		z, func_3804		; $374b: $ca $04 $38
	call		func_3754			; $374e: $cd $54 $37
	jp		func_39bd			; $3751: $c3 $bd $39

func_3754:
	ld		hl, wOam		; $3754: $21 $00 $c0
	ld		a, $84			; $3757: $3e $84
	ldi		(hl), a			; $3759: $22
	ld		a, $88			; $375a: $3e $88
	ldi		(hl), a			; $375c: $22
	ld		a, (wcf3c)		; $375d: $fa $3c $cf
	and		a			; $3760: $a7
	jr		z, func_3767			; $3761: $28 $04
	ld		a, $92			; $3763: $3e $92
	jr		func_3769			; $3765: $18 $02
func_3767:
	ld		a, $92			; $3767: $3e $92
func_3769:
	ldi		(hl), a			; $3769: $22
	ld		a, $00			; $376a: $3e $00
	ldi		(hl), a			; $376c: $22
	ld		a, $8c			; $376d: $3e $8c
	ldi		(hl), a			; $376f: $22
	ld		a, $88			; $3770: $3e $88
	ldi		(hl), a			; $3772: $22
	ld		a, $9e			; $3773: $3e $9e
	ldi		(hl), a			; $3775: $22
	ld		a, $00			; $3776: $3e $00
	ldi		(hl), a			; $3778: $22
	ld		a, ($c001)		; $3779: $fa $01 $c0
	ld		b, a			; $377c: $47
	ld		c, $04			; $377d: $0e $04
	ld		a, $00			; $377f: $3e $00
	ld		(wcf3a), a		; $3781: $ea $3a $cf
func_3784:
	call		waitUntilVBlankHandled_andXorCf39			; $3784: $cd $d2 $0f
	call		waitUntilVBlankHandled_andXorCf39			; $3787: $cd $d2 $0f
	ld		a, b			; $378a: $78
	ld		($c001), a		; $378b: $ea $01 $c0
	ld		($c005), a		; $378e: $ea $05 $c0
	dec		c			; $3791: $0d
	jr		nz, func_37a6			; $3792: $20 $12
	ld		c, $04			; $3794: $0e $04
	ld		a, ($c006)		; $3796: $fa $06 $c0
	cp		$9e			; $3799: $fe $9e
	jr		z, func_37a1			; $379b: $28 $04
	ld		a, $9e			; $379d: $3e $9e
	jr		func_37a3			; $379f: $18 $02
func_37a1:
	ld		a, $9f			; $37a1: $3e $9f
func_37a3:
	ld		($c006), a		; $37a3: $ea $06 $c0
func_37a6:
	dec		b			; $37a6: $05
	ld		a, $20			; $37a7: $3e $20
	cp		b			; $37a9: $b8
	jr		nz, func_3784			; $37aa: $20 $d8
	call		clear1st100bytesOfWram			; $37ac: $cd $81 $1f
	call		doALoop6000Times			; $37af: $cd $d9 $06
	call		doALoop6000Times			; $37b2: $cd $d9 $06
	ld		a, $40			; $37b5: $3e $40
	ld		(wcf3a), a		; $37b7: $ea $3a $cf
	call		func_382c			; $37ba: $cd $2c $38
	xor		a			; $37bd: $af
	ld		($c381), a		; $37be: $ea $81 $c3
func_37c1:
	ld		hl, data_3a33		; $37c1: $21 $33 $3a
	ld		bc, $0018		; $37c4: $01 $18 $00
	ld		a, ($c381)		; $37c7: $fa $81 $c3
	call		func_3b88			; $37ca: $cd $88 $3b
	ld		a, (wcf3c)		; $37cd: $fa $3c $cf
	and		a			; $37d0: $a7
	jr		z, func_37ff			; $37d1: $28 $2c
	ld		hl, data_3a63		; $37d3: $21 $63 $3a
func_37d6:
	ld		bc, $0118		; $37d6: $01 $18 $01
	ld		a, ($c381)		; $37d9: $fa $81 $c3
	call		func_3b88			; $37dc: $cd $88 $3b
	ld		hl, data_3abb		; $37df: $21 $bb $3a
	ld		bc, $0308		; $37e2: $01 $08 $03
	ld		a, ($c381)		; $37e5: $fa $81 $c3
	call		func_3b88			; $37e8: $cd $88 $3b
	call		func_381c			; $37eb: $cd $1c $38
	ld		a, ($c381)		; $37ee: $fa $81 $c3
	cpl					; $37f1: $2f
	ld		($c381), a		; $37f2: $ea $81 $c3
	ld		a, (wcf40)		; $37f5: $fa $40 $cf
	and		a			; $37f8: $a7
	jp		z, func_37c1		; $37f9: $ca $c1 $37
	jp		func_39bd			; $37fc: $c3 $bd $39
func_37ff:
	ld		hl, data_3a63		; $37ff: $21 $63 $3a
	jr		func_37d6			; $3802: $18 $d2

func_3804:
	ld		a, (wIsDemoScenes)		; $3804: $fa $43 $cf
	and		a			; $3807: $a7
	jr		nz, func_3816			; $3808: $20 $0c
	call		pollInput			; $380a: $cd $45 $2b
	ldh		a, (<hNewKeysPressed)		; $380d: $f0 $8c
	and		BTN_A|BTN_START			; $380f: $e6 $09
	jp		nz, func_39bd		; $3811: $c2 $bd $39
	jr		func_3804			; $3814: $18 $ee
func_3816:
	call		func_365f			; $3816: $cd $5f $36
	jp		func_018d			; $3819: $c3 $8d $01

func_381c:
	push		bc			; $381c: $c5
	ld		b, $0a			; $381d: $06 $0a
func_381f:
	call		waitUntilVBlankHandled_andXorCf39			; $381f: $cd $d2 $0f
	dec		b			; $3822: $05
	jr		nz, func_381f			; $3823: $20 $fa
	pop		bc			; $3825: $c1
	ret					; $3826: $c9
func_3827:
	push		bc			; $3827: $c5
	ld		b, $05			; $3828: $06 $05
	jr		func_381f			; $382a: $18 $f3

func_382c:
	ld		a, (wcf3c)		; $382c: $fa $3c $cf
	and		a			; $382f: $a7
	ret		nz			; $3830: $c0
	ld		hl, SC		; $3831: $21 $02 $ff
	res		7, (hl)			; $3834: $cb $be
	ld		a, $ee			; $3836: $3e $ee
	ldh		(R_SB), a		; $3838: $e0 $01
	res		0, (hl)			; $383a: $cb $86
	set		7, (hl)			; $383c: $cb $fe
	ret					; $383e: $c9

serialFunc_383f:
	ei					; $383f: $fb
	ld		a, $09			; $3840: $3e $09
	ldh		(R_IE), a		; $3842: $e0 $ff
	xor		a			; $3844: $af
	ld		(wcf3a), a		; $3845: $ea $3a $cf
	ld		(wcf01), a		; $3848: $ea $01 $cf
	ld		(wcf02), a		; $384b: $ea $02 $cf
	ld		(wcf46), a		; $384e: $ea $46 $cf
	call		waitUntilVBlankHandled_andXorCf39			; $3851: $cd $d2 $0f
	ld		b, MUS_LEVEL_JUST_CLEARED			; $3854: $06 $04
	rst_playSound
	ld		a, $ff			; $3857: $3e $ff
	ldh		(<hNewKeysPressed), a		; $3859: $e0 $8c
	ld		a, $01			; $385b: $3e $01
	ld		($cf3f), a		; $385d: $ea $3f $cf
	ld		($c37a), a		; $3860: $ea $7a $c3
	xor		a			; $3863: $af
	ld		($cf3e), a		; $3864: $ea $3e $cf
	ld		a, ($c379)		; $3867: $fa $79 $c3
	inc		a			; $386a: $3c
	ld		($c379), a		; $386b: $ea $79 $c3
	ld		a, (wc2ba)		; $386e: $fa $ba $c2
	inc		a			; $3871: $3c
	ld		(wc2bc), a		; $3872: $ea $bc $c2
	call		serialFunc_344e			; $3875: $cd $4e $34
	ld		hl, $9821		; $3878: $21 $21 $98
	ld		de, clearedLayoutData		; $387b: $11 $cb $3a
	call		loadBGTileMapData			; $387e: $cd $d4 $3a
	xor		a			; $3881: $af
	ld		(wc2bc), a		; $3882: $ea $bc $c2
	call		func_366c			; $3885: $cd $6c $36
	call		clear1st100bytesOfWram			; $3888: $cd $81 $1f
	jp		func_392a			; $388b: $c3 $2a $39
func_388e:
	ld		a, $09			; $388e: $3e $09
	ldh		(R_IE), a		; $3890: $e0 $ff
	call		drawLevelClearScreen			; $3892: $cd $f7 $39
	call		func_17dc			; $3895: $cd $dc $17

	ld		hl, wOam		; $3898: $21 $00 $c0
	ld		a, $84			; $389b: $3e $84
	ldi		(hl), a			; $389d: $22
	ld		a, $68			; $389e: $3e $68
	ldi		(hl), a			; $38a0: $22
	ld		a, (wcf3c)		; $38a1: $fa $3c $cf
	and		a			; $38a4: $a7
	jr		z, func_38ab			; $38a5: $28 $04
	ld		a, $92			; $38a7: $3e $92
	jr		func_38ad			; $38a9: $18 $02
func_38ab:
	ld		a, $92			; $38ab: $3e $92
func_38ad:
	ldi		(hl), a			; $38ad: $22
	ld		a, $00			; $38ae: $3e $00
	ldi		(hl), a			; $38b0: $22
	ld		a, $8c			; $38b1: $3e $8c
	ldi		(hl), a			; $38b3: $22
	ld		a, $68			; $38b4: $3e $68
	ldi		(hl), a			; $38b6: $22
	ld		a, $9e			; $38b7: $3e $9e
	ldi		(hl), a			; $38b9: $22
	ld		a, $00			; $38ba: $3e $00
	ldi		(hl), a			; $38bc: $22
	ld		a, (wcf3c)		; $38bd: $fa $3c $cf
	ld		b, $16			; $38c0: $06 $16
	sla		a			; $38c2: $cb $27
	sla		a			; $38c4: $cb $27
	add		b			; $38c6: $80
	ld		b, a			; $38c7: $47
-
	ld		hl, wOam		; $38c8: $21 $00 $c0
	dec		(hl)			; $38cb: $35
	ld		de, $0004		; $38cc: $11 $04 $00
	add		hl, de			; $38cf: $19
	dec		(hl)			; $38d0: $35
	call		func_3827			; $38d1: $cd $27 $38
	inc		(hl)			; $38d4: $34
	ld		de, -$04		; $38d5: $11 $fc $ff
	add		hl, de			; $38d8: $19
	inc		(hl)			; $38d9: $34
	call		func_3827			; $38da: $cd $27 $38
	dec		b			; $38dd: $05
	jr		nz, -			; $38de: $20 $e8
func_38e0:
	call		func_382c			; $38e0: $cd $2c $38
	ld		hl, data_3a93		; $38e3: $21 $93 $3a
	ld		a, (wcf3c)		; $38e6: $fa $3c $cf
	and		a			; $38e9: $a7
	jr		nz, +			; $38ea: $20 $03
	ld		hl, data_3a93		; $38ec: $21 $93 $3a
+
	ld		bc, $0018		; $38ef: $01 $18 $00
	xor		a			; $38f2: $af
	call		func_3b88			; $38f3: $cd $88 $3b
	ld		a, $40			; $38f6: $3e $40
	ld		(wcf3a), a		; $38f8: $ea $3a $cf
	xor		a			; $38fb: $af
	ld		($c381), a		; $38fc: $ea $81 $c3
-
	ld		hl, data_3aab		; $38ff: $21 $ab $3a
	ld		bc, $0108		; $3902: $01 $08 $01
	ld		a, ($c381)		; $3905: $fa $81 $c3
	call		func_3b88			; $3908: $cd $88 $3b
	ld		a, ($c381)		; $390b: $fa $81 $c3
	cpl					; $390e: $2f
	ld		($c381), a		; $390f: $ea $81 $c3
	call		func_381c			; $3912: $cd $1c $38
	ld		a, (wcf40)		; $3915: $fa $40 $cf
	and		a			; $3918: $a7
	jr		z, -			; $3919: $28 $e4
	ld		a, ($c37a)		; $391b: $fa $7a $c3
	cp		$ff			; $391e: $fe $ff
	jp		nz, func_39bd		; $3920: $c2 $bd $39
	xor		a			; $3923: $af
	ld		($c37a), a		; $3924: $ea $7a $c3
	jp		func_39a5			; $3927: $c3 $a5 $39
func_392a:
	xor		a			; $392a: $af
	ld		(wcf40), a		; $392b: $ea $40 $cf
	ld		($cf3e), a		; $392e: $ea $3e $cf
	cpl					; $3931: $2f
	ld		($cf1f), a		; $3932: $ea $1f $cf
	ld		a, ($c2bd)		; $3935: $fa $bd $c2
	sra		a			; $3938: $cb $2f
	inc		a			; $393a: $3c
	ld		b, a			; $393b: $47
	ld		a, ($c378)		; $393c: $fa $78 $c3
	cp		b			; $393f: $b8
	jp		z, func_3732		; $3940: $ca $32 $37
	ld		a, ($c379)		; $3943: $fa $79 $c3
	cp		b			; $3946: $b8
	jp		z, func_388e		; $3947: $ca $8e $38
	xor		a			; $394a: $af
	ld		($cf1f), a		; $394b: $ea $1f $cf
	xor		a			; $394e: $af
	ld		(wcf3a), a		; $394f: $ea $3a $cf
	call		func_17dc			; $3952: $cd $dc $17
	ld		a, (wGameMode)		; $3955: $fa $b8 $c2
	cp		GAMEMODE_HEADING_OUT			; $3958: $fe $01
	jp		z, func_3804		; $395a: $ca $04 $38
	ld		a, (wcf3c)		; $395d: $fa $3c $cf
	and		a			; $3960: $a7
	jr		z, +			; $3961: $28 $03
	call		func_381c			; $3963: $cd $1c $38
+
	call		func_382c			; $3966: $cd $2c $38
	ld		a, ($c37a)		; $3969: $fa $7a $c3
	and		a			; $396c: $a7
	jr		z, func_3977			; $396d: $28 $08
	ld		a, $ff			; $396f: $3e $ff
	ld		($c37a), a		; $3971: $ea $7a $c3
	jp		func_38e0			; $3974: $c3 $e0 $38
func_3977:
	ld		a, $40			; $3977: $3e $40
	ld		(wcf3a), a		; $3979: $ea $3a $cf
	xor		a			; $397c: $af
	ld		($c381), a		; $397d: $ea $81 $c3
-
	ld		hl, data_3a63		; $3980: $21 $63 $3a
	ld		a, (wcf3c)		; $3983: $fa $3c $cf
	and		a			; $3986: $a7
	jr		nz, +			; $3987: $20 $03
	ld		hl, data_3a63		; $3989: $21 $63 $3a
+
	ld		bc, $0018		; $398c: $01 $18 $00
	ld		a, ($c381)		; $398f: $fa $81 $c3
	call		func_3b88			; $3992: $cd $88 $3b
	ld		a, ($c381)		; $3995: $fa $81 $c3
	cpl					; $3998: $2f
	ld		($c381), a		; $3999: $ea $81 $c3
	call		func_381c			; $399c: $cd $1c $38
	ld		a, (wcf40)		; $399f: $fa $40 $cf
	and		a			; $39a2: $a7
	jr		z, -			; $39a3: $28 $db

func_39a5:
	xor		a			; $39a5: $af
	ld		(wcf3a), a		; $39a6: $ea $3a $cf
	xor		a			; $39a9: $af
	ld		($cf3e), a		; $39aa: $ea $3e $cf
	xor		a			; $39ad: $af
	ld		(wc2bb), a		; $39ae: $ea $bb $c2
	ld		(wc2bc), a		; $39b1: $ea $bc $c2
	ld		b, MUS_LEVEL_SELECT_MENU			; $39b4: $06 $03
	rst_playSound
	call		clear1st100bytesOfWram			; $39b7: $cd $81 $1f
	jp		func_05ef			; $39ba: $c3 $ef $05

func_39bd:
	ld		a, (wc37d)		; $39bd: $fa $7d $c3
	ld		(wNumberOfRandomRoomsForDifficulty), a		; $39c0: $ea $b9 $c2
	ld		a, (wc37e)		; $39c3: $fa $7e $c3
	ld		(wc2ba), a		; $39c6: $ea $ba $c2
	call		clear1st100bytesOfWram			; $39c9: $cd $81 $1f
	xor		a			; $39cc: $af
	ld		($c378), a		; $39cd: $ea $78 $c3
	ld		($c379), a		; $39d0: $ea $79 $c3
	ld		($cf3e), a		; $39d3: $ea $3e $cf
	ld		(wc2bb), a		; $39d6: $ea $bb $c2
	ld		(wc2bc), a		; $39d9: $ea $bc $c2
	ld		b, MUS_LEVEL_SELECT_MENU			; $39dc: $06 $03
	rst_playSound
	jp		func_05ef			; $39df: $c3 $ef $05

; Unused?
func_39e2:
	ld		a, (wcf3a)		; $39e2: $fa $3a $cf
	push		af			; $39e5: $f5
	xor		a			; $39e6: $af
	ld		(wcf3a), a		; $39e7: $ea $3a $cf
	ld		b, $3c			; $39ea: $06 $3c
-
	call		waitUntilVBlankHandled_andXorCf39			; $39ec: $cd $d2 $0f
	dec		b			; $39ef: $05
	jr		nz, -			; $39f0: $20 $fa
	pop		af			; $39f2: $f1
	ld		(wcf3a), a		; $39f3: $ea $3a $cf
	ret					; $39f6: $c9

drawLevelClearScreen:
	call		vramLoad_mostGraphicsForLevelClearScreen
	call		blankScreenDuringVBlankPeriod
	ld		a, $ef
	call		fill1stBgMap
	call		enableLCD

	ld		hl, BG_MAP1+$22
	ld		de, $100b
	call		loadPipesAndBlankTilesInside

	ld		hl, BG_MAP1+$161
	ld		de, $1206
	call		loadPipesAndBlankTilesInside

	ld		a, (wGameMode)
	cp		GAMEMODE_HEADING_OUT
	ret		z

	ld		hl, BG_MAP1+$1a3
	ld		de, houseLayoutData
	call		loadBGTileMapData
	ret

houseLayoutData:
	.db $ff $90 $80 $aa
	.db $81 $82 $83 $aa
	.db $84 $85 $86
	.db $bb

.include "data/data_3a33.s"

.include "layouts/group3.s"

;;
; @param	hl		bg tile map
; @param	de		pointer to data
loadBGTileMapData:
	push		bc			; $3ad4: $c5
	ld		b, h			; $3ad5: $44
	ld		c, l			; $3ad6: $4d
@loop:
	; every aa value we find in de table, add $20 to bc (start of rows)
	ld		a, (de)			; $3ad7: $1a
	cp		$aa			; $3ad8: $fe $aa
	jr		nz, @nonAAvalue			; $3ada: $20 $09
	ld		hl, $0020		; $3adc: $21 $20 $00
	add		hl, bc			; $3adf: $09
	ld		c, l			; $3ae0: $4d
	ld		b, h			; $3ae1: $44
	inc		de			; $3ae2: $13
	jr		@loop			; $3ae3: $18 $f2
@nonAAvalue:
	; if value is $46, we put that in ($cf07)
	cp		$bb			; $3ae5: $fe $bb
	jr		z, @BBvalue			; $3ae7: $28 $2a
	cp		$46			; $3ae9: $fe $46
	jr		nz, @non46value			; $3aeb: $20 $05
	ld		(wCursorOriginX), a		; $3aed: $ea $07 $cf
	jr		@46or47value			; $3af0: $18 $07
@non46value:
	; if value is $47, we put that in ($cf07)
	cp		$47			; $3af2: $fe $47
	jr		nz, @otherValues			; $3af4: $20 $15
	ld		(wCursorOriginX), a		; $3af6: $ea $07 $cf
@46or47value:
	; 46 or 47, we subtract $21 from hl, then put that value into (hl)
	; on hblank start, we go back to the last tile location
	push		hl			; $3af9: $e5
	push		bc			; $3afa: $c5
	ld		bc, -$21		; $3afb: $01 $df $ff
	add		hl, bc			; $3afe: $09
	pop		bc			; $3aff: $c1
	call		waitUntilHBlankJustStarted			; $3b00: $cd $74 $1f
	ld		a, (wCursorOriginX)		; $3b03: $fa $07 $cf
	ld		(hl), a			; $3b06: $77
	pop		hl			; $3b07: $e1
	inc		de			; $3b08: $13
	jr		@loop			; $3b09: $18 $cc
@otherValues:
	; other values, we just put them into (hl), and increment
	call		waitUntilHBlankJustStarted			; $3b0b: $cd $74 $1f
	ld		a, (de)			; $3b0e: $1a
	ldi		(hl), a			; $3b0f: $22
	inc		de			; $3b10: $13
	jr		@loop			; $3b11: $18 $c4
@BBvalue:
	; $bb denotes the end of the data read
	pop		bc			; $3b13: $c1
	ret					; $3b14: $c9

loadPipesAndBlankTilesInside:
	ld		c, e			; $3b15: $4b
	ld		a, $74			; $3b16: $3e $74
	ld		(wCursorOriginX), a		; $3b18: $ea $07 $cf
	inc		a			; $3b1b: $3c
	ld		($cf09), a		; $3b1c: $ea $09 $cf
	inc		a			; $3b1f: $3c
	ld		($cf0b), a		; $3b20: $ea $0b $cf
	ld		b, d			; $3b23: $42
	push		hl			; $3b24: $e5
	call		func_3b5f			; $3b25: $cd $5f $3b
	pop		hl			; $3b28: $e1
	ld		a, $20			; $3b29: $3e $20
	call		addAToHl			; $3b2b: $cd $6b $24
	dec		c			; $3b2e: $0d
	dec		c			; $3b2f: $0d
-
	ld		b, d			; $3b30: $42
	ld		a, $77			; $3b31: $3e $77
	ld		(wCursorOriginX), a		; $3b33: $ea $07 $cf
	ld		a, $ff			; $3b36: $3e $ff
	ld		($cf09), a		; $3b38: $ea $09 $cf
	ld		a, $78			; $3b3b: $3e $78
	ld		($cf0b), a		; $3b3d: $ea $0b $cf
	push		hl			; $3b40: $e5
	call		func_3b5f			; $3b41: $cd $5f $3b
	pop		hl			; $3b44: $e1
	ld		a, $20			; $3b45: $3e $20
	call		addAToHl			; $3b47: $cd $6b $24
	dec		c			; $3b4a: $0d
	jr		nz, -			; $3b4b: $20 $e3
	ld		b, d			; $3b4d: $42
	ld		a, $79			; $3b4e: $3e $79
	ld		(wCursorOriginX), a		; $3b50: $ea $07 $cf
	inc		a			; $3b53: $3c
	ld		($cf09), a		; $3b54: $ea $09 $cf
	inc		a			; $3b57: $3c
	ld		($cf0b), a		; $3b58: $ea $0b $cf
	call		func_3b5f			; $3b5b: $cd $5f $3b
	ret					; $3b5e: $c9

func_3b5f:
	ld		a, (wCursorOriginX)		; $3b5f: $fa $07 $cf
	call		func_3b77			; $3b62: $cd $77 $3b
	dec		b			; $3b65: $05
	dec		b			; $3b66: $05
	ld		a, ($cf09)		; $3b67: $fa $09 $cf
-
	call		func_3b77			; $3b6a: $cd $77 $3b
	dec		b			; $3b6d: $05
	jr		nz, -			; $3b6e: $20 $fa
	ld		a, ($cf0b)		; $3b70: $fa $0b $cf
	call		func_3b77			; $3b73: $cd $77 $3b
	ret					; $3b76: $c9

func_3b77:
	push		af			; $3b77: $f5
	ld		a, $01			; $3b78: $3e $01
	ldh		(R_IE), a		; $3b7a: $e0 $ff
	call		waitUntilHBlankJustStarted			; $3b7c: $cd $74 $1f
	pop		af			; $3b7f: $f1
	ldi		(hl), a			; $3b80: $22
	push		af			; $3b81: $f5
	ld		a, $09			; $3b82: $3e $09
	ldh		(R_IE), a		; $3b84: $e0 $ff
	pop		af			; $3b86: $f1
	ret					; $3b87: $c9

; @param	a		normally value in $c381, but 1 time $00
; @param	b		normally $00, $01, $03
; @param	c		normally $08 or $18
; @param	hl		address of table
; eg bc = $0108, a from $c381, hl table is 3aab
; store c bytes into wOam + b*$18
; if a ($c381 or 0) is 0, use the first c bytes in hl, else use the next c bytes
func_3b88:
	push		de			; $3b88: $d5
	and		a			; $3b89: $a7
	jr		z, +			; $3b8a: $28 $04
	ld		d, $00			; $3b8c: $16 $00
	ld		e, c			; $3b8e: $59
	add		hl, de			; $3b8f: $19
+
	push		hl			; $3b90: $e5
	ld		hl, $0018		; $3b91: $21 $18 $00
	ld		a, b			; $3b94: $78
	call		hlTimesEqualsA			; $3b95: $cd $4d $1f
	ld		b, l			; $3b98: $45
	pop		hl			; $3b99: $e1
	ld		d, >wOam			; $3b9a: $16 $c0
	ld		e, b			; $3b9c: $58
-
	ldi		a, (hl)			; $3b9d: $2a
	ld		(de), a			; $3b9e: $12
	inc		de			; $3b9f: $13
	dec		c			; $3ba0: $0d
	jr		nz, -			; $3ba1: $20 $fa
	pop		de			; $3ba3: $d1
	ret					; $3ba4: $c9

func_3ba5:
	xor		a			; $3ba5: $af
	ldh		(<hNewKeysPressed), a		; $3ba6: $e0 $8c
	call		loadLevelSelectTiles			; $3ba8: $cd $a7 $06
	ld		a, (wGameMode)		; $3bab: $fa $b8 $c2
	cp		GAMEMODE_HEADING_OUT			; $3bae: $fe $01
	jr		z, +			; $3bb0: $28 $09
	ld		hl, $9943		; $3bb2: $21 $43 $99
	ld		de, contestProgressLayoutData		; $3bb5: $11 $fd $08
	call		loadBGTileMapData			; $3bb8: $cd $d4 $3a
+
	ld		hl, $9987		; $3bbb: $21 $87 $99
	ld		de, $0803		; $3bbe: $11 $03 $08
	call		loadPipesAndBlankTilesInside			; $3bc1: $cd $15 $3b
	ld		hl, $99ab		; $3bc4: $21 $ab $99
	ld		de, roomLayoutData_3d19		; $3bc7: $11 $19 $3d
	call		loadBGTileMapData			; $3bca: $cd $d4 $3a
	ld		hl, $9903		; $3bcd: $21 $03 $99
	ld		de, selectCourseLayoutData		; $3bd0: $11 $ef $08
	call		loadBGTileMapData			; $3bd3: $cd $d4 $3a
	ld		b, $00			; $3bd6: $06 $00
	ld		c, $1e			; $3bd8: $0e $1e
	ld		a, (wNumberOfRandomRoomsForDifficulty)		; $3bda: $fa $b9 $c2
	ld		l, a			; $3bdd: $6f
	ld		h, $00			; $3bde: $26 $00
	ld		a, $0a			; $3be0: $3e $0a
	call		hlDivModA			; $3be2: $cd $2b $1f
	ld		($c37b), a		; $3be5: $ea $7b $c3
	ld		a, l			; $3be8: $7d
	ld		($c37c), a		; $3be9: $ea $7c $c3
func_3bec:
	push		bc			; $3bec: $c5
	call		pollInput			; $3bed: $cd $45 $2b
	ld		a, (wcf3c)		; $3bf0: $fa $3c $cf
	and		a			; $3bf3: $a7
	jr		nz, +			; $3bf4: $20 $06
	ldh		a, (<hNewKeysPressed)		; $3bf6: $f0 $8c
	and		BTN_RIGHT|BTN_LEFT|BTN_UP|BTN_DOWN			; $3bf8: $e6 $f0
	ldh		(<hNewKeysPressed), a		; $3bfa: $e0 $8c
+
	pop		bc			; $3bfc: $c1
	ldh		a, (<hNewKeysPressed)		; $3bfd: $f0 $8c
	and		$0b			; $3bff: $e6 $0b
	jr		nz, func_3c1f			; $3c01: $20 $1c
	ldh		a, (<hNewKeysPressed)		; $3c03: $f0 $8c
	and		BTN_RIGHT|BTN_LEFT|BTN_UP|BTN_DOWN			; $3c05: $e6 $f0
	jr		z, func_3c1f			; $3c07: $28 $16
	push		af			; $3c09: $f5
	push		bc			; $3c0a: $c5
	ld		b, SND_MOVING_AROUND_MENU			; $3c0b: $06 $0d
	rst_playSound
	pop		bc			; $3c0e: $c1
	pop		af			; $3c0f: $f1
	bit		7, a			; $3c10: $cb $7f
	jp		nz, func_3c91		; $3c12: $c2 $91 $3c
	bit		6, a			; $3c15: $cb $77
	jp		nz, func_3ca0		; $3c17: $c2 $a0 $3c
	and		$30			; $3c1a: $e6 $30
	jp		nz, func_3cec		; $3c1c: $c2 $ec $3c
func_3c1f:
	ld		a, (wcf3c)		; $3c1f: $fa $3c $cf
	and		a			; $3c22: $a7
	jr		nz, +			; $3c23: $20 $0c
	ld		a, (wNumberOfRandomRoomsForDifficulty)		; $3c25: $fa $b9 $c2
	ldh		(R_SB), a		; $3c28: $e0 $01
	ld		hl, SC		; $3c2a: $21 $02 $ff
	res		0, (hl)			; $3c2d: $cb $86
	set		7, (hl)			; $3c2f: $cb $fe
+
	ld		a, (wGameMode)		; $3c31: $fa $b8 $c2
	cp		GAMEMODE_VS_MODE			; $3c34: $fe $02
	jr		z, func_3c3d			; $3c36: $28 $05
	call		waitUntilVBlankHandled_andXorCf39			; $3c38: $cd $d2 $0f
	jr		func_3c59			; $3c3b: $18 $1c
func_3c3d:
	ld		a, $80			; $3c3d: $3e $80
	ld		(wcf3a), a		; $3c3f: $ea $3a $cf
	call		func_3512			; $3c42: $cd $12 $35
	ld		a, (wc2ba)		; $3c45: $fa $ba $c2
	ld		l, a			; $3c48: $6f
	ld		h, $00			; $3c49: $26 $00
	ld		a, $0a			; $3c4b: $3e $0a
	call		hlDivModA			; $3c4d: $cd $2b $1f
	swap		l			; $3c50: $cb $35
	or		l			; $3c52: $b5
	ld		hl, $9948		; $3c53: $21 $48 $99
	call		draw2DigitsAtHl			; $3c56: $cd $5d $20
func_3c59:
	ld		a, ($c37b)		; $3c59: $fa $7b $c3
	ld		d, a			; $3c5c: $57
	ld		a, ($c37c)		; $3c5d: $fa $7c $c3
	swap		a			; $3c60: $cb $37
	or		d			; $3c62: $b2
	ld		hl, $99a8		; $3c63: $21 $a8 $99
	call		draw2DigitsAtHl			; $3c66: $cd $5d $20
	ld		a, c			; $3c69: $79
	cp		$0a			; $3c6a: $fe $0a
	jr		nc, +			; $3c6c: $30 $0d
	ld		hl, $99a8		; $3c6e: $21 $a8 $99
	ld		a, b			; $3c71: $78
	call		addAToHl			; $3c72: $cd $6b $24
	call		waitUntilHBlankJustStarted			; $3c75: $cd $74 $1f
	ld		a, $ff			; $3c78: $3e $ff
	ld		(hl), a			; $3c7a: $77
+
	dec		c			; $3c7b: $0d
	jr		nz, +			; $3c7c: $20 $02
	ld		c, func_3c9e			; $3c7e: $0e $1e
+
	ldh		a, (<hNewKeysPressed)		; $3c80: $f0 $8c
	and		BTN_A|BTN_START			; $3c82: $e6 $09
	jp		nz, func_3cf4		; $3c84: $c2 $f4 $3c
	ldh		a, (<hNewKeysPressed)		; $3c87: $f0 $8c
	bit		BTN_BIT_B, a			; $3c89: $cb $4f
	jp		nz, func_3d0e		; $3c8b: $c2 $0e $3d
	jp		func_3bec			; $3c8e: $c3 $ec $3b
func_3c91:
	ld		hl, $c37b		; $3c91: $21 $7b $c3
	ld		a, b			; $3c94: $78
	cpl					; $3c95: $2f
	and		$01			; $3c96: $e6 $01
	jr		z, +			; $3c98: $28 $03
	ld		hl, $c37c		; $3c9a: $21 $7c $c3
+
	dec		(hl)			; $3c9d: $35
func_3c9e:
	jr		func_3cad			; $3c9e: $18 $0d
func_3ca0:
	ld		hl, $c37b		; $3ca0: $21 $7b $c3
	ld		a, b			; $3ca3: $78
	cpl					; $3ca4: $2f
	and		$01			; $3ca5: $e6 $01
	jr		z, +			; $3ca7: $28 $03
	ld		hl, $c37c		; $3ca9: $21 $7c $c3
+
	inc		(hl)			; $3cac: $34
func_3cad:
	ld		a, ($c37b)		; $3cad: $fa $7b $c3
	cp		$ff			; $3cb0: $fe $ff
	call		z, ld_a_09		; $3cb2: $cc $e9 $3c
	ld		($c37b), a		; $3cb5: $ea $7b $c3
	cp		$0a			; $3cb8: $fe $0a
	jr		c, +			; $3cba: $38 $04
	xor		a			; $3cbc: $af
	ld		($c37b), a		; $3cbd: $ea $7b $c3
+
	ld		a, ($c37c)		; $3cc0: $fa $7c $c3
	cp		$ff			; $3cc3: $fe $ff
	call		z, ld_a_09		; $3cc5: $cc $e9 $3c
	ld		($c37c), a		; $3cc8: $ea $7c $c3
	cp		$0a			; $3ccb: $fe $0a
	jr		c, +			; $3ccd: $38 $04
	xor		a			; $3ccf: $af
	ld		($c37c), a		; $3cd0: $ea $7c $c3
+
	push		bc			; $3cd3: $c5
	ld		hl, $000a		; $3cd4: $21 $0a $00
	ld		a, ($c37c)		; $3cd7: $fa $7c $c3
	call		hlTimesEqualsA			; $3cda: $cd $4d $1f
	ld		b, l			; $3cdd: $45
	ld		a, ($c37b)		; $3cde: $fa $7b $c3
	add		b			; $3ce1: $80
	ld		(wNumberOfRandomRoomsForDifficulty), a		; $3ce2: $ea $b9 $c2
	pop		bc			; $3ce5: $c1
	jp		func_3c1f			; $3ce6: $c3 $1f $3c

ld_a_09:
	ld		a, $09			; $3ce9: $3e $09
	ret					; $3ceb: $c9

func_3cec:
	ld		a, b			; $3cec: $78
	cpl					; $3ced: $2f
	and		$01			; $3cee: $e6 $01
	ld		b, a			; $3cf0: $47
	jp		func_3c1f			; $3cf1: $c3 $1f $3c
func_3cf4:
	ld		b, SND_MENU_OPTION_SELECTED			; $3cf4: $06 $10
	rst_playSound
	ld		a, (wNumberOfRandomRoomsForDifficulty)		; $3cf7: $fa $b9 $c2
	call		incAIf0			; $3cfa: $cd $15 $3d
	ld		(wNumberOfRandomRoomsForDifficulty), a		; $3cfd: $ea $b9 $c2
	ld		a, (wc2ba)		; $3d00: $fa $ba $c2
	call		incAIf0			; $3d03: $cd $15 $3d
	ld		(wc2ba), a		; $3d06: $ea $ba $c2
	xor		a			; $3d09: $af
func_3d0a:
	ld		(wMenuOptionSelected), a		; $3d0a: $ea $19 $cf
	ret					; $3d0d: $c9
func_3d0e:
	ld		b, SND_PRESSED_B_ON_MENU			; $3d0e: $06 $11
	rst_playSound
	ld		a, $ff			; $3d11: $3e $ff
	jr		func_3d0a			; $3d13: $18 $f5

incAIf0:
	and		a			; $3d15: $a7
	ret		nz			; $3d16: $c0
	inc		a			; $3d17: $3c
	ret					; $3d18: $c9
	
.include "layouts/group4.s"


func_3d1d:
	xor		a			; $3d1d: $af
	ld		(wcf3a), a		; $3d1e: $ea $3a $cf
	call		vramLoad_mainGameTiles			; $3d21: $cd $51 $02
	ld		a, (wGameMode)		; $3d24: $fa $b8 $c2
	cp		GAMEMODE_VS_MODE			; $3d27: $fe $02
	jr		nz, +			; $3d29: $20 $05
	call		contestPreGameScreen			; $3d2b: $cd $34 $3d
	jr		@done			; $3d2e: $18 $03
+
	call		confirmGoingUpOrHeadingOutScreen			; $3d30: $cd $b2 $3d
@done:
	ret

contestPreGameScreen:
	call		blankScreenDuringVBlankPeriod			; $3d34: $cd $07 $2c
	ld		a, $cf			; $3d37: $3e $cf
	call		fill1stBgMap			; $3d39: $cd $38 $2c
	call		enableLCD			; $3d3c: $cd $20 $2c
	ld		hl, $9800		; $3d3f: $21 $00 $98
	ld		de, $1411		; $3d42: $11 $11 $14
	call		loadPipesAndBlankTilesInside			; $3d45: $cd $15 $3b
	ld		hl, $9841		; $3d48: $21 $41 $98
	ld		de, contestPreGameLayoutData		; $3d4b: $11 $1c $3e
	call		loadBGTileMapData			; $3d4e: $cd $d4 $3a
	ld		a, ($c2bd)		; $3d51: $fa $bd $c2
	add		$f0			; $3d54: $c6 $f0
	ld		hl, $9891		; $3d56: $21 $91 $98
	call		draw2DigitsAtHl			; $3d59: $cd $5d $20
	ld		hl, $98d1		; $3d5c: $21 $d1 $98
	ld		a, $aa			; $3d5f: $3e $aa
	ld		($cf0b), a		; $3d61: $ea $0b $cf
	call		func_19bc			; $3d64: $cd $bc $19
	ld		hl, $9906		; $3d67: $21 $06 $99
	ld		de, $98c6		; $3d6a: $11 $c6 $98
	call		func_3df0			; $3d6d: $cd $f0 $3d
	ld		a, ($c378)		; $3d70: $fa $78 $c3
	ld		b, a			; $3d73: $47
	ld		a, ($c379)		; $3d74: $fa $79 $c3
	add		b			; $3d77: $80
	inc		a			; $3d78: $3c
	call		get2DigitsToDrawFromNonBCD_A			; $3d79: $cd $12 $21
	ld		hl, $994b		; $3d7c: $21 $4b $99
	call		draw2DigitsAtHl			; $3d7f: $cd $5d $20
	ld		hl, $9888		; $3d82: $21 $88 $98
	call		func_3d8c			; $3d85: $cd $8c $3d
	call		func_3d95			; $3d88: $cd $95 $3d
	ret					; $3d8b: $c9

func_3d8c:
	ld		a, (wDifficulty)		; $3d8c: $fa $c0 $c2
	add		$f1			; $3d8f: $c6 $f1
	call		drawDigitAtHl			; $3d91: $cd $6a $20
	ret					; $3d94: $c9

func_3d95:
	ld		hl, $9987		; $3d95: $21 $87 $99
	ld		de, startEndLayoutData		; $3d98: $11 $65 $3e
	call		loadBGTileMapData			; $3d9b: $cd $d4 $3a
	ld		hl, $9986		; $3d9e: $21 $86 $99
	ld		bc, $0001		; $3da1: $01 $01 $00
	ld		de, $0040		; $3da4: $11 $40 $00
	ld		a, $01			; $3da7: $3e $01
	ld		($cf13), a		; $3da9: $ea $13 $cf
	ld		a, $ab			; $3dac: $3e $ab
	call		loadCursorData			; $3dae: $cd $9b $2c
	ret					; $3db1: $c9

;;
; @param	a		$00 if going up, $01 if heading out
confirmGoingUpOrHeadingOutScreen:
	and		a			; $3db2: $a7
	jr		nz, @headingOut			; $3db3: $20 $05
	ld		de, confirmGoingUpLayoutData		; $3db5: $11 $70 $3e
	jr		+			; $3db8: $18 $03
@headingOut:
	ld		de, confirmHeadingOutLayoutData		; $3dba: $11 $8b $3e
+
	ld		hl, $9903		; $3dbd: $21 $03 $99
	call		loadLevelSelectTiles_andLayoutData			; $3dc0: $cd $ce $06
	ld		a, (wGameMode)		; $3dc3: $fa $b8 $c2
	and		a			; $3dc6: $a7
	jr		nz, func_3de0			; $3dc7: $20 $17
	ld		a, (wRoomIndex)		; $3dc9: $fa $bf $c2
	call		aEqualsADiv10Plus1			; $3dcc: $cd $5a $15
	ld		hl, $994f		; $3dcf: $21 $4f $99
	push		hl			; $3dd2: $e5
	call		draw2DigitsAtHl			; $3dd3: $cd $5d $20
	pop		hl			; $3dd6: $e1
	dec		hl			; $3dd7: $2b
	call		waitUntilHBlankJustStarted			; $3dd8: $cd $74 $1f
	ld		a, $1d			; $3ddb: $3e $1d
	ld		(hl), a			; $3ddd: $77
	jr		func_3de6			; $3dde: $18 $06
func_3de0:
	ld		hl, $994c		; $3de0: $21 $4c $99
	call		func_3df0			; $3de3: $cd $f0 $3d
func_3de6:
	ld		hl, $994a		; $3de6: $21 $4a $99
	call		func_3d8c			; $3de9: $cd $8c $3d
	call		func_3d95			; $3dec: $cd $95 $3d
	ret					; $3def: $c9

func_3df0:
	ld		a, (wNumberOfRandomRoomsForDifficulty)		; $3df0: $fa $b9 $c2
func_3df3:
	push		af			; $3df3: $f5
	push		hl			; $3df4: $e5
	dec		hl			; $3df5: $2b
	call		waitUntilHBlankJustStarted			; $3df6: $cd $74 $1f
	pop		hl			; $3df9: $e1
	pop		af			; $3dfa: $f1
	call		get2DigitsToDrawFromNonBCD_A			; $3dfb: $cd $12 $21
	call		draw2DigitsAtHl			; $3dfe: $cd $5d $20
	ret		c			; $3e01: $d8
	ld		a, (wGameMode)		; $3e02: $fa $b8 $c2
	cp		GAMEMODE_VS_MODE			; $3e05: $fe $02
	ret		nz			; $3e07: $c0
	ld		a, (wc2ba)		; $3e08: $fa $ba $c2
	call		get2DigitsToDrawFromNonBCD_A			; $3e0b: $cd $12 $21
	ld		h, d			; $3e0e: $62
	ld		l, e			; $3e0f: $6b
	push		af			; $3e10: $f5
	push		hl			; $3e11: $e5
	dec		hl			; $3e12: $2b
	call		waitUntilHBlankJustStarted			; $3e13: $cd $74 $1f
	pop		hl			; $3e16: $e1
	pop		af			; $3e17: $f1
	call		draw2DigitsAtHl			; $3e18: $cd $5d $20
	ret					; $3e1b: $c9

.include "layouts/group5.s"

populateListOfRandomLevelsBasedOnDifficulty:
	xor		a			; $3ea9: $af
	ld		(wCurrentLevelIdxInListOfRandomLevels), a		; $3eaa: $ea $74 $c3
	ld		a, $28			; $3ead: $3e $28
	ld		($cf45), a		; $3eaf: $ea $45 $cf

	call		getScrollingLevel1stRoomIdxAndRangeOfRoomsBasedOnDifficulty			; $3eb2: $cd $c9 $3e
	add		30			; $3eb5: $c6 $1e
	; scrolling levels start at idx 30-149
	ld		(wRoomIndex), a		; $3eb7: $ea $bf $c2

	ld		a, b			; $3eba: $78
	ld		(wNumberOfRandomRoomsForDifficulty), a		; $3ebb: $ea $b9 $c2

	ld		hl, wListOfRandomLevels		; $3ebe: $21 $11 $c3
	ld		a, 30			; $3ec1: $3e $1e
-
	ldi		(hl), a			; $3ec3: $22
	inc		a			; $3ec4: $3c
	dec		b			; $3ec5: $05
	jr		nz, -			; $3ec6: $20 $fb
	ret					; $3ec8: $c9

;;
; @param[out]	a/b		2 values from table below based on difficulty
getScrollingLevel1stRoomIdxAndRangeOfRoomsBasedOnDifficulty:
	push		hl
	ld		a, (wDifficulty)
	ld		hl, @difficultyTable
	sla		a
	call		addAToHl
	ldi		a, (hl)
	ld		b, (hl)
	pop		hl
	ret

@difficultyTable:
	.db  0 30
	.db 30 80-30
	.db 80 120-80


data_3edf:
.db $ff
	ld		a, $01			; $3ee0: $3e $01
	ccf					; $3ee2: $3f
	rst		$38			; $3ee3: $ff
	rst		$38			; $3ee4: $ff
	rst		$38			; $3ee5: $ff
	rst		$38			; $3ee6: $ff
	dec		b			; $3ee7: $05
	ccf					; $3ee8: $3f
	dec		b			; $3ee9: $05
	ccf					; $3eea: $3f
	rst		$38			; $3eeb: $ff
	rst		$38			; $3eec: $ff
	rst		$38			; $3eed: $ff
	rst		$38			; $3eee: $ff
	dec		d			; $3eef: $15
	ccf					; $3ef0: $3f
	dec		d			; $3ef1: $15
	ccf					; $3ef2: $3f
	add		hl, de			; $3ef3: $19
	ccf					; $3ef4: $3f
	rst		$38			; $3ef5: $ff
	rst		$38			; $3ef6: $ff
	jr		z, $3f			; $3ef7: $28 $3f
	rst		$38			; $3ef9: $ff
	rst		$38			; $3efa: $ff
	ld		d, h			; $3efb: $54
	ccf					; $3efc: $3f
	ld		b, h			; $3efd: $44
	ccf					; $3efe: $3f
	rst		$38			; $3eff: $ff
.db $ec

data_3f01:
	jp		c, $d9ff		; $3f01: $da $ff $d9
.db $db
	ret		nz			; $3f05: $c0
	pop		bc			; $3f06: $c1
	jp		$c2c5			; $3f07: $c3 $c5 $c2
	jp		z, $cdc6		; $3f0a: $ca $c6 $cd
	call		nz, $c9c7		; $3f0d: $c4 $c7 $c9
	set		1, b			; $3f10: $cb $c8
	adc		$cc			; $3f12: $ce $cc
	cp		a			; $3f14: $bf
	or		b			; $3f15: $b0
	or		h			; $3f16: $b4
	or		c			; $3f17: $b1
	or		l			; $3f18: $b5
	or		d			; $3f19: $b2
	cp		c			; $3f1a: $b9
	or		e			; $3f1b: $b3
	cp		b			; $3f1c: $b8
	xor		(hl)			; $3f1d: $ae
	xor		h			; $3f1e: $ac
	xor		l			; $3f1f: $ad
	xor		a			; $3f20: $af
	or		(hl)			; $3f21: $b6
	cp		e			; $3f22: $bb
	or		a			; $3f23: $b7
	cp		h			; $3f24: $bc
	cp		d			; $3f25: $ba
	cp		l			; $3f26: $bd
	cp		(hl)			; $3f27: $be

data_3f28:
	ld		(hl), e			; $3f28: $73
	ld		(hl), d			; $3f29: $72
	ld		(hl), c			; $3f2a: $71
	ld		(hl), d			; $3f2b: $72
	halt					; $3f2c: $76
	ld		(hl), l			; $3f2d: $75
	ld		(hl), h			; $3f2e: $74
	ld		(hl), l			; $3f2f: $75
	ld		a, c			; $3f30: $79
	ld		a, b			; $3f31: $78
	ld		(hl), a			; $3f32: $77
	ld		a, b			; $3f33: $78
	ld		a, h			; $3f34: $7c
	ld		a, e			; $3f35: $7b
	ld		a, d			; $3f36: $7a
	ld		a, e			; $3f37: $7b

data_3f38:
	add		b			; $3f38: $80
	add		b			; $3f39: $80
	add		c			; $3f3a: $81
	add		c			; $3f3b: $81
	add		d			; $3f3c: $82
	add		d			; $3f3d: $82
	add		e			; $3f3e: $83
	add		e			; $3f3f: $83
	ld		a, l			; $3f40: $7d
	ld		a, l			; $3f41: $7d
	ld		a, (hl)			; $3f42: $7e
	ld		a, a			; $3f43: $7f
	ret		nc			; $3f44: $d0
	pop		de			; $3f45: $d1
.db $d3
	jp		nc, $d8d7		; $3f47: $d2 $d7 $d8
	push		de			; $3f4a: $d5
	rst		$8			; $3f4b: $cf
	ret		nc			; $3f4c: $d0
	sub		$d3			; $3f4d: $d6 $d3
	call		nc, $d8d7		; $3f4f: $d4 $d7 $d8
	push		de			; $3f52: $d5
	rst		$8			; $3f53: $cf

data_3f54:
.db $fd
.db $fd
.db $fd
.db $fd
.db $fc
	ld		hl, sp-$09		; $3f59: $f8 $f7
	cp		$f5			; $3f5b: $fe $f5
	ld		a, ($f6f9)		; $3f5d: $fa $f9 $f6

data_3f60:
.db $fd

data_3f61:
	and		c			; $3f61: $a1
	and		d			; $3f62: $a2
	and		e			; $3f63: $a3
	and		b			; $3f64: $a0
	and		l			; $3f65: $a5
	and		(hl)			; $3f66: $a6
	and		a			; $3f67: $a7
	and		h			; $3f68: $a4
	xor		c			; $3f69: $a9
	xor		d			; $3f6a: $aa
	xor		e			; $3f6b: $ab
	xor		b			; $3f6c: $a8
	xor		h			; $3f6d: $ac
	xor		(hl)			; $3f6e: $ae
	xor		l			; $3f6f: $ad

data_3f70:
	and		e			; $3f70: $a3
	and		b			; $3f71: $a0
	and		c			; $3f72: $a1
	and		d			; $3f73: $a2
	and		a			; $3f74: $a7
	and		h			; $3f75: $a4
	and		l			; $3f76: $a5
	and		(hl)			; $3f77: $a6
	xor		e			; $3f78: $ab
	xor		b			; $3f79: $a8
	xor		c			; $3f7a: $a9
	xor		d			; $3f7b: $aa
	xor		h			; $3f7c: $ac
	xor		(hl)			; $3f7d: $ae
	xor		l			; $3f7e: $ad

data_3f7f:
	add		b			; $3f7f: $80
	ld		b, b			; $3f80: $40
	jr		nz, $10			; $3f81: $20 $10
	ret		nz			; $3f83: $c0
	ld		h, b			; $3f84: $60
	jr		nc, -$70			; $3f85: $30 $90
	ldh		($70), a		; $3f87: $e0 $70
	or		b			; $3f89: $b0
	ret		nc			; $3f8a: $d0
	ldh		a, ($a0)		; $3f8b: $f0 $a0
	ld		d, b			; $3f8d: $50

.include "layouts/group6.s"

data_4136:
.db $f4
	ret		nz			; $4137: $c0
	ret		nc			; $4138: $d0
	di					; $4139: $f3
	adc		(hl)			; $413a: $8e
	ret		nz			; $413b: $c0
	ret		nc			; $413c: $d0

.include "layouts/group7.s"

; Unused room layout data?
	ld		e, e			; $4160: $5b
	rst		$38			; $4161: $ff
	rst		$38			; $4162: $ff
	ld		a, b			; $4163: $78
	xor		d			; $4164: $aa
	ld		(hl), a			; $4165: $77
	rst		$38			; $4166: $ff
	rst		$38			; $4167: $ff
	rst		$38			; $4168: $ff
	rst		$38			; $4169: $ff
	rst		$38			; $416a: $ff
	rst		$38			; $416b: $ff
	inc		a			; $416c: $3c
	rst		$38			; $416d: $ff
	ld		a, b			; $416e: $78
	ld		(hl), a			; $416f: $77
	rst		$38			; $4170: $ff
	ld		a, $3c			; $4171: $3e $3c
	inc		a			; $4173: $3c
	inc		a			; $4174: $3c
	rst		$38			; $4175: $ff
	ld		a, b			; $4176: $78
	xor		d			; $4177: $aa
	ld		a, c			; $4178: $79
	ld		a, d			; $4179: $7a
	ld		a, d			; $417a: $7a
	ld		a, d			; $417b: $7a
	ld		a, d			; $417c: $7a
	ld		a, d			; $417d: $7a
	ld		a, d			; $417e: $7a
	ld		a, d			; $417f: $7a
	ld		a, d			; $4180: $7a
	ld		a, e			; $4181: $7b
	ld		a, c			; $4182: $79
	ld		a, d			; $4183: $7a
	ld		a, d			; $4184: $7a
	ld		a, d			; $4185: $7a
	ld		a, d			; $4186: $7a
	ld		a, d			; $4187: $7a
	ld		a, d			; $4188: $7a
	ld		a, e			; $4189: $7b
	.db $bb

; Unused room layout data?
	ld		(hl), h			; $418b: $74
	ld		(hl), l			; $418c: $75
	ld		(hl), l			; $418d: $75
	ld		(hl), l			; $418e: $75
	ld		(hl), l			; $418f: $75
	ld		(hl), l			; $4190: $75
	ld		(hl), l			; $4191: $75
	ld		(hl), l			; $4192: $75
	ld		(hl), l			; $4193: $75
	halt					; $4194: $76
	xor		d			; $4195: $aa
	ld		(hl), a			; $4196: $77
	jr		$09			; $4197: $18 $09
	daa					; $4199: $27
	rst		$38			; $419a: $ff
	rst		$38			; $419b: $ff
	ld		e, a			; $419c: $5f
	ld		e, c			; $419d: $59
	ld		d, b			; $419e: $50
	ld		a, b			; $419f: $78
	xor		d			; $41a0: $aa
	ld		(hl), a			; $41a1: $77
	nop					; $41a2: $00
	ld		bc, $7d12		; $41a3: $01 $12 $7d
	ld		a, d			; $41a6: $7a
	ld		a, d			; $41a7: $7a
	ld		a, d			; $41a8: $7a
	ld		a, d			; $41a9: $7a
	ld		a, e			; $41aa: $7b
	xor		d			; $41ab: $aa
	ld		a, c			; $41ac: $79
	ld		a, d			; $41ad: $7a
	ld		a, d			; $41ae: $7a
	ld		a, d			; $41af: $7a
	ld		a, e			; $41b0: $7b
	cp		e			; $41b1: $bb

; Unused room layout data?
	ld		(hl), h			; $41b2: $74
	ld		(hl), l			; $41b3: $75
	ld		(hl), l			; $41b4: $75
	ld		(hl), l			; $41b5: $75
	ld		(hl), l			; $41b6: $75
	ld		(hl), l			; $41b7: $75
	ld		(hl), l			; $41b8: $75
	ld		(hl), l			; $41b9: $75
	ld		(hl), l			; $41ba: $75
	halt					; $41bb: $76
	xor		d			; $41bc: $aa
	ld		(hl), a			; $41bd: $77
	add		a			; $41be: $87
	adc		b			; $41bf: $88
	adc		b			; $41c0: $88
	adc		b			; $41c1: $88
	adc		b			; $41c2: $88
	adc		b			; $41c3: $88
	adc		b			; $41c4: $88
	adc		c			; $41c5: $89
	ld		a, b			; $41c6: $78
	xor		d			; $41c7: $aa
	ld		(hl), a			; $41c8: $77
	add		a			; $41c9: $87
	adc		b			; $41ca: $88
	adc		b			; $41cb: $88
	adc		b			; $41cc: $88
	adc		b			; $41cd: $88
	adc		b			; $41ce: $88
	adc		b			; $41cf: $88
	adc		c			; $41d0: $89
	ld		a, b			; $41d1: $78
	xor		d			; $41d2: $aa
	ld		a, c			; $41d3: $79
	ld		a, d			; $41d4: $7a
	ld		a, d			; $41d5: $7a
	ld		a, d			; $41d6: $7a
	ld		a, d			; $41d7: $7a
	ld		a, d			; $41d8: $7a
	ld		a, d			; $41d9: $7a
	ld		a, d			; $41da: $7a
	ld		a, d			; $41db: $7a
	ld		a, e			; $41dc: $7b
	cp		e			; $41dd: $bb

; Unused room layout data?
data_41de:
	ld		(hl), h			; $41de: $74
	ld		(hl), l			; $41df: $75
	ld		(hl), l			; $41e0: $75
	ld		(hl), l			; $41e1: $75
	ld		(hl), l			; $41e2: $75
	ld		(hl), l			; $41e3: $75
	ld		(hl), l			; $41e4: $75
	ld		(hl), l			; $41e5: $75
	ld		(hl), l			; $41e6: $75
	halt					; $41e7: $76
	xor		d			; $41e8: $aa
	ld		(hl), a			; $41e9: $77
	add		a			; $41ea: $87
	adc		b			; $41eb: $88
	adc		b			; $41ec: $88
	adc		b			; $41ed: $88
	adc		b			; $41ee: $88
	adc		b			; $41ef: $88
	adc		b			; $41f0: $88
	adc		c			; $41f1: $89
	ld		a, b			; $41f2: $78
	xor		d			; $41f3: $aa
	ld		(hl), a			; $41f4: $77
	jr		$09			; $41f5: $18 $09
	daa					; $41f7: $27
	rst		$38			; $41f8: $ff
	rst		$38			; $41f9: $ff
	ld		e, a			; $41fa: $5f
	ld		e, c			; $41fb: $59
	ld		d, b			; $41fc: $50
	ld		a, b			; $41fd: $78
	xor		d			; $41fe: $aa
	ld		a, c			; $41ff: $79
	ld		a, d			; $4200: $7a
	ld		a, d			; $4201: $7a
	ld		a, d			; $4202: $7a
	ld		a, d			; $4203: $7a
	ld		a, d			; $4204: $7a
	ld		a, d			; $4205: $7a
	ld		a, d			; $4206: $7a
	ld		a, d			; $4207: $7a
	ld		a, e			; $4208: $7b
	cp		e			; $4209: $bb

; Unused room layout data?
data_420a:
.db $f4
	ret		nz			; $420b: $c0
	ret		nc			; $420c: $d0
	di					; $420d: $f3
	adc		(hl)			; $420e: $8e
	ret		nz			; $420f: $c0
	ret		nc			; $4210: $d0
	ld		e, (hl)			; $4211: $5e
.db $e4
	ld		d, a			; $4213: $57
	xor		d			; $4214: $aa
	xor		d			; $4215: $aa
	ld		e, a			; $4216: $5f
	ld		e, c			; $4217: $59
	ld		d, b			; $4218: $50
	xor		d			; $4219: $aa
	xor		d			; $421a: $aa
	xor		d			; $421b: $aa
	xor		d			; $421c: $aa
	xor		d			; $421d: $aa
	inc		hl			; $421e: $23
	daa					; $421f: $27
	inc		d			; $4220: $14
	inc		b			; $4221: $04
	dec		bc			; $4222: $0b
	xor		d			; $4223: $aa
	xor		d			; $4224: $aa
	inc		de			; $4225: $13
	daa					; $4226: $27
	inc		hl			; $4227: $23
	ld		hl, $22bb		; $4228: $21 $bb $22
	inc		de			; $422b: $13
	ld		b, (hl)			; $422c: $46
	dec		bc			; $422d: $0b
	cp		e			; $422e: $bb

; Unused room layout data, or just artifacts?
	.db $ff $ff $ff $aa
	.db $ff $ff $ff
	.db $bb

.org $0250

.include "data/roomData.s"

.org $1c00

gfxData_5c00:
	m_GfxData gfx_kwirk_logo ; $5c00
	m_GfxData gfx_big_kwirk_pipe ; $6000
	m_GfxData gfx_medium_kwirks ; $6200
	m_GfxData gfx_sprites ; $6400
	m_GfxDataSpaceAfterByte gfx_ascii ; $6c00
	m_GfxDataSpaceAfterByte gfx_logo_borders ; $6f00


; All sound funcs from here on down?
func_7000:
	ld		a, (wIsDemoScenes)		; $7000: $fa $43 $cf
	and		a			; $7003: $a7
	ret		z			; $7004: $c8
startSerialTransfer:
	xor		a			; $7005: $af
	ld		(wcf49), a		; $7006: $ea $49 $cf
	ld		hl, SC		; $7009: $21 $02 $ff
	res		0, (hl)			; $700c: $cb $86
	set		7, (hl)			; $700e: $cb $fe
	ret					; $7010: $c9

resetSerialTransfer:
	ld		a, $01			; $7011: $3e $01
	ld		(wcf49), a		; $7013: $ea $49 $cf
	ld		hl, SC		; $7016: $21 $02 $ff
	res		7, (hl)			; $7019: $cb $be
	set		0, (hl)			; $701b: $cb $c6
	ret					; $701d: $c9

loadDemoScenes:
	ld		a, $01			; $701e: $3e $01
	ld		(wIsDemoScenes), a		; $7020: $ea $43 $cf
	ld		(wcf3c), a		; $7023: $ea $3c $cf
	ld		(wIsDiagonalView), a		; $7026: $ea $be $c2
	ld		(wGameMode), a		; $7029: $ea $b8 $c2

	xor		a			; $702c: $af
	ld		(wCurrentDemoSceneRoomIdx), a		; $702d: $ea $de $ce
	ld		(wIdxOfDemoSceneMovementSteps), a		; $7030: $ea $dc $ce
	ld		(wIdxOfDemoSceneMovementSteps+1), a		; $7033: $ea $dd $ce

	ld		a, $05			; $7036: $3e $05
	ld		(wNumberOfRandomRoomsForDifficulty), a		; $7038: $ea $b9 $c2
	call		getNextRoomIndexForScrollingLevel			; $703b: $cd $74 $06
	call		resetSerialTransfer			; $703e: $cd $11 $70
	jp		loadLevelForDemoScenes			; $7041: $c3 $e1 $01

; Unused?
serialFunc_7044:
	ld		a, $0a			; $7044: $3e $0a
	ld		(wNumberOfRandomRoomsForDifficulty), a		; $7046: $ea $b9 $c2

serialFunc_7049:
	call		startSerialTransfer			; $7049: $cd $05 $70
	ld		a, $01			; $704c: $3e $01
	ld		(wcf48), a		; $704e: $ea $48 $cf
	ld		a, $fc			; $7051: $3e $fc
	call		func_3507			; $7053: $cd $07 $35
	xor		a			; $7056: $af
	ld		(wcf05), a		; $7057: $ea $05 $cf
	ld		(wcf48), a		; $705a: $ea $48 $cf
	ld		($cf3e), a		; $705d: $ea $3e $cf
	call		clear1st100bytesOfWram			; $7060: $cd $81 $1f
	call		waitUntilVBlankHandled_andXorCf39			; $7063: $cd $d2 $0f
	jp		func_0351			; $7066: $c3 $51 $03


getKeyPressedForDemoScenes:
	ld		a, (wIdxOfDemoSceneMovementSteps)
	ld		l, a
	ld		a, (wIdxOfDemoSceneMovementSteps+1)
	ld		h, a
	
	ld		a, $04
	call		hlDivModA
	; a is div, l is mod
	push		af
	ld		a, l
	ld		hl, demoScenesMovementData
	call		addAToHl
	ld		b, (hl)
	pop		af
-
	and		a
	jr		z, @processByteOfMovementData
	sla		b
	sla		b
	dec		a
	jr		-
	
; @param	b		2 bits of movement data in the upper 2 bits of b
@processByteOfMovementData:
	ld		a, b
	and		$c0
	jr		z, @moveDown
	cp		$40
	jr		z, @moveUp
	cp		$80
	jr		z, @moveLeft
	ld		a, BTN_RIGHT
	jr		@storeButtonInKeysPressed

@moveLeft:
	ld		a, BTN_LEFT
	jr		@storeButtonInKeysPressed

@moveDown:
	ld		a, BTN_DOWN
	jr		@storeButtonInKeysPressed

@moveUp:
	ld		a, BTN_UP

@storeButtonInKeysPressed:
	ldh		(<hKeysPressed), a
	ld		a, (wIdxOfDemoSceneMovementSteps)
	add		$01
	ld		(wIdxOfDemoSceneMovementSteps), a
	ld		a, (wIdxOfDemoSceneMovementSteps+1)
	adc		$00
	ld		(wIdxOfDemoSceneMovementSteps+1), a
	
	call		waitUntilVBlankHandled_andXorCf39
	call		waitUntilVBlankHandled_andXorCf39
	call		waitUntilVBlankHandled_andXorCf39
	jp		_handleMovementFromKeysPressed


demoSceneRooms:
	.db $20 $2e $26 $34 $36

.include "layouts/group8.s"


demoScenesMovementData:
	; %11 - down
	; %01 - up
	; %10 - left
	; %00 - right
	; %10101010 - left * 4
	; TODO: break it all down, and per level
	.db $aa $a2 $96 $8f $5a $8a $aa $aa
	.db $aa $83 $58 $08 $02 $0d $62 $aa
	.db $aa $96 $a0 $a0 $2a $09 $d7 $53
	.db $5f $d5 $aa $82 $96 $a0 $aa $96
	.db $a2 $bd $63 $5a $8f $d6 $35 $aa
	.db $a3 $7f $a8 $ff $d6 $35 $a8 $3f
	.db $58 $d6 $aa $a2 $a2 $aa $5a $a2
	.db $02 $a5 $7f $02 $a5 $68 $00 $2a
	.db $56 $a0

data_7139:
	.db $68 $48 $60 $00
	.db $68 $50 $61 $00
	.db $70 $48 $70 $00
	.db $70 $50 $71 $00
	.db $78 $48 $64 $00
	.db $78 $50 $65 $00

	.db $68 $48 $62 $00
	.db $68 $50 $63 $00
	.db $70 $48 $72 $00
	.db $70 $50 $73 $00
	.db $78 $48 $74 $00
	.db $78 $50 $75 $00

	.db $68 $58 $66 $00
	.db $68 $60 $67 $00
	.db $70 $58 $76 $00
	.db $70 $60 $77 $00
	.db $78 $58 $6a $00
	.db $78 $60 $6b $00

	.db $68 $58 $68 $00
	.db $68 $60 $69 $00
	.db $70 $58 $78 $00
	.db $70 $60 $79 $00
	.db $78 $58 $74 $00
	.db $78 $60 $75 $00

.org $31af

.include "audio/audio.s"