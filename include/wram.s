; ========================================================================================
; Bank 0
; ========================================================================================

.define stairsOam	$c09a
.define meOam		$c09e

.ramsection "RAM 0" bank 0 slot 2

wOam:
	dsb $a0
wOamEnd: ; $c0a0
	dsb $100-$a0

wRoomObjects: ; $c100
	dsb ROOM_WIDTH*ROOM_HEIGHT

wc268:
	dsb $b8-$68

; $0 for stairs rooms
; $1 for scrolling level
; $2 for contest mode?
wGameMode: ; $c2b8
	db

wNumberOfRandomRoomsForDifficulty: ; $c2b9
	db

wc2ba:
	db

wc2bb:
	db

wc2bc:
	dsb $e-$c

wIsDiagonalView: ; $c2be
	db

wRoomIndex: ; $c2bf
	db

wDifficulty: ; $c2c0
	dsb $d0-$c0

wNumCharacters: ; $c2d0
	dsb $fa-$d0

; $c2d1
; 3 when loading a character object
; $c2d4
; address of special objects? (characters and stairs)

; Set to 0 except when:
; Set to 1 possibly by getNextRandomNumber based on rng
; I'm guessing this flips rooms vertically?
wRandomRoomIsFlippedVertically: ; $c2fa
	dsb $311-$2fa

; start of data that stores index of random rooms?
; TODO: size 30
wListOfRandomLevels: ; $c311
	dsb $74-$11

wCurrentLevelIdxInListOfRandomLevels: ; $c374
	db

wc375:
	db

wc376:
	db

wc377:
	dsb $d-$7

wc37d:
	db

wc37e:
	dsb $edc-$37e

wIdxOfDemoSceneMovementSteps: ; $cedc
	dw

wCurrentDemoSceneRoomIdx: ; $cede
	dsb $f00-$ede

wcf00:
	db

wcf01:
	db

wcf02:
	db

wcf03:
	db

wcf04:
	db

wcf05:
	dsb 2

.union
	; these 2 may be used for all sprites? and various others
    wCursorOriginX: ; $cf07
    	db
    wCursorOriginY: ; $cf08
    	db

    ; address in wRoomObjects when processing room objects
    wcf09:
    	db
    wcf0a:
    	db

    wcf0b:
    	db

    wcf0c:
    	db

    wcf0d:
    	db

    wcf0e:
    	db

    wcf0f:
    	db

    wcf10:
    	db

	; if 0, we can't go left or right on the menu
	wExtraMenuColumns: ; $cf11
		db

	; if 0, we can't go up or down on the menu
	wExtraMenuRows: ; $cf12
		db

	wcf13:
		dsb 2

	wLevelIdxWithinDifficulty: ; $cf15
		dsb 2

	; $cf15 - bcd form of current level cleared?

	wCursorXMovement: ; $cf17
		db
.nextu
	; how indented the level is from the left
	wLevelLocationX: ; $cf07
		db

	wLevelLocationY: ; $cf08
		db

	wLevelWidth: ; $cf09
		db

	wLevelHeight: ; $cf0a
		db

	wRoomObjectPositionsAddress: ; $cf0b
		dw

	wRoomObjectTypesAddress: ; $cf0d
		dw

	; $cf0f/10 is set to $c100 + 16(levelY)+(levelX) - starting address of room data
	wRoomDataAddress: ; $cf0f
		dw

	; this and below are copies of wRoomDataAddress?
	wRoomDataAddressCopy:
		dw

	wCurrentPushableBlockDrawLocation: ; $cf13
		dw

	; room level within difficulty
	wcf15:
		dsb 2

	wPushBlockIs3PlusBy3Plus: ; $cf17
		db
.endu

wCursorYMovement: ; $cf18
	db

; $cf19 - 0 normally, ff when pressing B, f0 when loading cursor data(?)
wMenuOptionSelected: ; $cf19
	dsb $24-$19

; stores OAM details for temp hiding of sprites when loading in-game menu
wMeOamTempStorage: ; $cf24
	db
wStairsOamTempStorage: ; $cf25
	dsb 3

wRng1: ; $cf28
	db
wRng2: ; $cf29
	db
wRng3: ; $cf2a
	db
wRng4: ; $cf2b
	dsb $39-$2b

; $c377 - seed?

wcf39:
	db

wcf3a:
	dsb 2

wcf3c:
	dsb $40-$3c

wcf40:
	db

wcf41:
	db

; Set to 0 by func_03dc, difficultyOptionsScreen, func_0606, serialFunc_3349
; Set to 1 by serialFunc_3384
; If 1, func_040d jumps to difficultyOptionsScreen
; If 1, func_0351 jumps to func_0382
wcf42:
	db

wIsDemoScenes:
	dsb 3

wcf46:
	db

wcf47:
	db

wcf48:
	db

; if 0, vblankinterrupt calls serialTransferByte9f_copy, which writes byte $9f to SB (serial transfer data)
wcf49:
	db

.ends

; ========================================================================================
; Bank 1
; ========================================================================================

.ramsection "RAM 1" bank 1 slot 3

wd000:
	dsb $cff

wStackTop: ; $dcff
	dsb $f00-$cff


; 8 sound channels, 1 per $10 bytes
; low nybble 0 - bit 7 set for channels 0-3 if the matching channel in 4-7 has loaded
;              - bit 0 set when sound loaded
;              - bit 1 set when $54 read in sound data
; low nybble 1 - set to 1 when sound loaded
; low nybble 5 - set to 0 when sound loaded
; low nybble 6 - set to 0 when sound loaded
; low nybble 7 - set to 0 when sound loaded
; low nybble 8/9 - address of sound channel data
; low nybble e/f - data in data_76fa, indexed by byte read after $f0 sound byte
wSoundChannelData: ; $df00
	dsb $80
wSoundChannelDataEnd:
	.db

; set as part of rst_playSound
wNumSoundsToLoad: ; $df80
	db
wSound1ToLoad: ; $df81
	db
wSound2ToLoad: ; $df82
	db

; TODO: Initially set to sound channel index
wdf83:
	dsb $a7-$83

; For each sound channel, stores
wdf97:
	dsb 8*2

wdfa7:
	dsb 8*3

; wdbf

.ends