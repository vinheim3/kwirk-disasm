loadAllLevelData:
	ld		a, (wGameMode)
	and		a
	jr		z, loadRoomSizeForStairsRooms

	; for non-stairs rooms
	ld		hl, wLevelLocationX
	ld		a, $06
	ldi		(hl), a
	ldi		(hl), a
	ld		a, $08
	ldi		(hl), a
	ld		a, $06
	ld		(hl), a
	jr		loadRoomObjectsAndTypes

loadRoomSizeForStairsRooms:
	ld		bc, roomSizeTable
	call		getAddressOfRoomData
	call		storeAddressOfRoomDataInHl

	; set left room's X based on width so it's centered
	ldi		a, (hl)
	ld		(wLevelWidth), a
	ld		c, a
	ld		a, $14
	sub		c
	srl		a
	ld		(wLevelLocationX), a

	; same with Y
	ld		a, (hl)
	ld		(wLevelHeight), a
	ld		c, a
	ld		a, $12
	sub		c
	srl		a
	ld		(wLevelLocationY), a

loadRoomObjectsAndTypes:
	ld		h, $00
	ld		b, $00
	ld		a, (wLevelLocationY)
	ld		l, a
	sla		l
	sla		l
	ld		c, l
	; c = 4l, l = 4levelY
	sla		c
	rl		b
	sla		c
	rl		b
	; bc = 16l, l = 4levelY
	add		hl, bc

	ld		a, (wLevelLocationX)
	call		addAToHl
	ld		b, h
	ld		c, l

	; bc = 16(levelY)+(levelX)
	ld		hl, wRoomObjects
	add		hl, bc

	ld		a, l
	ld		(wRoomDataAddress), a
	ld		(wRoomDataAddressCopy), a

	ld		a, h
	ld		(wRoomDataAddress+1), a
	ld		(wRoomDataAddressCopy+1), a

	; load object positions
	ld		bc, roomObjectPositionsTable
	call		getAddressOfRoomData
	call		storeAddressOfRoomDataInHl
	ld		a, l
	ld		(wRoomObjectPositionsAddress), a
	ld		a, h
	ld		(wRoomObjectPositionsAddress+1), a

	; load object types
	ld		bc, roomObjectTypesTable
	call		getAddressOfRoomData
	call		storeAddressOfRoomDataInHl
	ld		a, l
	ld		(wRoomObjectTypesAddress), a
	ld		a, h
	ld		(wRoomObjectTypesAddress+1), a

    ; fill screen with object wall types
	ld		hl, wRoomObjects
	ld		bc, ROOM_WIDTH*ROOM_HEIGHT
-
	ld		a, OBJ_BRICK_WALL
	ldi		(hl), a
	dec		bc
	ld		a, c
	and		a
	jr		nz, -
	ld		a, b
	and		a
	jr		nz, -


	ld		a, (wRoomObjectPositionsAddress)
	ld		l, a
	ld		a, (wRoomObjectPositionsAddress+1)
	ld		h, a

	ld		a, (wLevelHeight)
	ld		c, a

@startProcessingIntoNextRowOfData:
	ld		a, (wLevelWidth)
	ld		b, a

@processNextByteOfData:
	ld		d, $08
	ldi		a, (hl)

@processNextBitOfData:
	sla		a
	call		processBitReadFromObjectPositionsData
	dec		b
	jr		nz, @notEndOfLevelWidth

	; end of level width
	call		startDrawingOnNextRow
	dec		c
	jr		nz, @startProcessingIntoNextRowOfData
	jr		allRoomDataLoaded

@notEndOfLevelWidth:
	dec		d
	jr		nz, @processNextBitOfData
	jr		@processNextByteOfData


allRoomDataLoaded:
	ld		a, (wGameMode)
	and		a
	jp		z, @getCorrectWallValues

	; load non-stairs room size data (related to the shape of the path leading out)
	ld		bc, roomSizeTable
	call		getAddressOfRoomData
	call		storeAddressOfRoomDataInHl

	ld		a, (hl)
	ld		c, a
	ld		a, (wRandomRoomIsFlippedVertically)
	cp		$01
	jr		nz, +

	; if flipped vertically c = ${5-high nybble}{5-low nybble}
	ld		a, c
	and		$0f
	ld		b, a
	ld		a, $05
	sub		b
	ld		d, a
	ld		a, c
	swap		a
	and		$0f
	ld		b, a
	ld		a, $05
	sub		b
	swap		a
	add		d
	ld		c, a
+

	; below draws the paths on each side of the room
	ld		a, c
	push		af
	and		$0f

	; store lower nybble of room size in cf0d
	; it will be read back to process the right side of the room
	ld		($cf0d), a
	pop		af
	and		$f0
	swap		a

; Outer loop processes twice, once for each side of the room
	ld		c, $02
---
	; with higher nybble, get a byte and a word from the 2 tables
	; store byte in e, and 2 bytes in b, then cf0e
	push		af
	ld		hl, outerCustomPathStartingCoordinates
	call		addAToHl
	ld		e, (hl)
	ld		d, >wRoomObjects
	ld		hl, outerCustomPathSpacesData
	pop		af
	add		a
	call		addAToHl
	ld		b, (hl)
	inc		hl
	ld		a, (hl)
	ld		($cf0e), a

; Inner loop processes a byte each from the bottom table
; Each byte's nybble represents 4 tiles in a row for 4 rows of data
; Each bit set in these nybbles is a floor space
	push		bc
	ld		c, $02
--
	ld		hl, $0408
-
	sla		b
	jr		nc, +
	xor		a
	ld		(de), a
+
	inc		de
	dec		h
	jr		nz, +
	ld		a, $10
	add		e
	ld		e, a
	ld		h, $04
+
	dec		l
	jr		nz, -
	ld		a, ($cf0e)
	ld		b, a
	dec		c
	jr		nz, --
	pop		bc

	dec		c
	jr		z, @doneWithScrollingPaths
	ld		a, ($cf0d)
	add		$06
	jr		---

@doneWithScrollingPaths:
	; extend the outer paths
	; kwirk, then empty space on the right
	ld		a, OBJ_KWIRK			; $0a7a: $3e $c0
	ld		de, $c1b2		; $0a7c: $11 $b2 $c1
	ld		(de), a			; $0a7f: $12
	xor		a			; $0a80: $af
	inc		de			; $0a81: $13
	ld		(de), a			; $0a82: $12

	; empty spaces to the left
	ld		de, $c1a1		; $0a83: $11 $a1 $c1
	ld		(de), a			; $0a86: $12
	dec		de			; $0a87: $1b
	ld		(de), a			; $0a88: $12
	ld		a, (wRandomRoomIsFlippedVertically)		; $0a89: $fa $fa $c2
	and		a			; $0a8c: $a7
	jr		z, @getCorrectWallValues			; $0a8d: $28 $03
	call		func_0dec			; $0a8f: $cd $ec $0d


@getCorrectWallValues:
	ld		hl, wRoomObjects
	ld		bc, ROOM_WIDTH*ROOM_HEIGHT
-
	ld		a, (hl)
	call		scfIfObjectIsWall
	call		c, getCorrectWallSpriteValBasedOnSurroundingWalls
	inc		hl
	dec		bc
	ld		a, c
	and		a
	jr		nz, -
	ld		a, b
	and		a
	jr		nz, -
	ret

; regular path is 8 tiles down
outerCustomPathStartingCoordinates:
	; top-left corner of path to draw (left side)
	.db 6*20+2  7*20+2  8*20+2  8*20+2  8*20+2  8*20+2
	; top-left corner of path to draw (right side)
	.db 6*20+$e 7*20+$e 8*20+$e 8*20+$e 8*20+$e 8*20+$e

outerCustomPathSpacesData:
	; left paths
	.db $74 $c0 $7c $00
	.db $f0 $00 $c7 $00
	.db $c4 $70 $c4 $47

	; right paths
	.db $e2 $30 $e3 $00
	.db $f0 $00 $3e $00
	.db $32 $e0 $32 $2e

;;
; The following 2 called after each other
getAddressOfRoomData:
	ld		a, (wRoomIndex)
	ld		h, b
	ld		l, c
	push		af
	call		addAToHl
	pop		af
	call		addAToHl
	ret

storeAddressOfRoomDataInHl:
	ldi		a, (hl)
	ld		b, a
	ld		a, (hl)
	ld		h, a
	ld		l, b
	ret

;;
; @param	cflag		if a bit was found when processing room object positions data
processBitReadFromObjectPositionsData:
	push		af			; $0ae2: $f5
	push		hl			; $0ae3: $e5
	push		bc			; $0ae4: $c5
	push		de			; $0ae5: $d5
	jr		nc, @bitNotSet			; $0ae6: $30 $05

	call		processNextByteOfObjectTypesData			; $0ae8: $cd $4c $0b
	jr		@done			; $0aeb: $18 $0d

@bitNotSet:
	call		loadRoomDataAddressIntoHl			; $0aed: $cd $a4 $0b
	ld		a, (hl)			; $0af0: $7e
	cp		OBJ_BRICK_WALL			; $0af1: $fe $f0
	jr		nz, @notWall			; $0af3: $20 $03
	xor		a			; $0af5: $af
	jr		@done			; $0af6: $18 $02

@notWall:
	ld		a, $ff			; $0af8: $3e $ff

@done:
	call		func_0b02			; $0afa: $cd $02 $0b
	pop		de			; $0afd: $d1
	pop		bc			; $0afe: $c1
	pop		hl			; $0aff: $e1
	pop		af			; $0b00: $f1
	ret					; $0b01: $c9

;;
; stores $00 in wRoomObjects if wall in place
; @param 	a		$00 if no bit set and unchanged by another tile
;					$ff if no bit set and changed by another tile
;					byte for current object read if bit set
func_0b02:
	push		af			; $0b02: $f5
	ld		a, (wRoomDataAddress)		; $0b03: $fa $0f $cf
	ld		l, a			; $0b06: $6f
	ld		a, (wRoomDataAddress+1)		; $0b07: $fa $10 $cf
	ld		h, a			; $0b0a: $67

	pop		af			; $0b0b: $f1
	; no bit set and not the original $f0 (eg extra tile from a spinner)
	; dont do anything
	cp		$ff			; $0b0c: $fe $ff
	jr		z, func_0b20			; $0b0e: $28 $10

	; bit set or untouched, store $00 if untouched (floor), or another byte
	cp		$e0			; $0b10: $fe $e0
	jr		nz, func_0b1f			; $0b12: $20 $0b

	; pit
	ld		a, (hl)			; $0b14: $7e
	cp		$f0			; $0b15: $fe $f0
	; pit and address not changed from a spinner on top of it
	; keep it as $e0
	jr		z, func_0b1d			; $0b17: $28 $04

	; TODO:
	add		$10			; $0b19: $c6 $10
	jr		func_0b1f			; $0b1b: $18 $02
func_0b1d:
	ld		a, $e0			; $0b1d: $3e $e0
func_0b1f:
	ld		(hl), a			; $0b1f: $77
func_0b20:
	inc		hl			; $0b20: $23
	ld		a, l			; $0b21: $7d
	ld		(wRoomDataAddress), a		; $0b22: $ea $0f $cf
	ld		a, h			; $0b25: $7c
	ld		(wRoomDataAddress+1), a		; $0b26: $ea $10 $cf

	xor		a			; $0b29: $af
	ld		($cf15), a		; $0b2a: $ea $15 $cf
	ret					; $0b2d: $c9

startDrawingOnNextRow:
	push		af
	push		hl
	ld		a, (wRoomDataAddressCopy)
	ld		l, a
	ld		a, (wRoomDataAddressCopy+1)
	ld		h, a
	call		getTileBelowCurrent
	ld		a, l
	ld		(wRoomDataAddress), a
	ld		(wRoomDataAddressCopy), a
	ld		a, h
	ld		(wRoomDataAddress+1), a
	ld		(wRoomDataAddressCopy+1), a
	pop		hl
	pop		af
	ret

processNextByteOfObjectTypesData:
	ld		a, (wRoomObjectTypesAddress)
	ld		l, a
	ld		a, (wRoomObjectTypesAddress+1)
	ld		h, a
	ldi		a, (hl)
	push		af
	ld		a, l
	ld		(wRoomObjectTypesAddress), a
	ld		a, h
	ld		(wRoomObjectTypesAddress+1), a
	pop		af
	call		processAllTilesRelatedToCurrentObject
	ret

;;
; eg will load the other parts of a pushable block, and legs of a spinner
; @param		a		the object type being loaded when a bit was found in room positions data
; @param		hl		wRoomObjectTypesAddress
; @param[out]	a		the actual byte to store in wRoomDataAddress
processAllTilesRelatedToCurrentObject:
	ld		bc, $0004
	ld		e, a
-
	srl		a
	rr		b
	dec		c
	jr		nz, -

	and		$0f
	swap		b
	and		a
	jr		nz, @notBrickOrCharacter

	call		getBrickOrCharacterObjectVal
	jr		@done

@notBrickOrCharacter:
	cp		$0a
	jr		nz, @notPitOrStairs
	call		getPitOrStairsObjectVal
	jr		@done

@notPitOrStairs:
	cp		$05
	jr		nc, @notPushableBlock

	; pushable block
	ld		a, e
	call		getPushBlockValAndStoreAllOtherPiecesOfPushableBlock
	jr		@done

@notPushableBlock:
	cp		$09
	jr		nc, @spinner

	; upper nybble is >=5 and <9 (doesnt seem to exist)
	push		af
	ld		a, $01
	ld		($cf15), a
	pop		af
	ld		a, e
	sub		$40
	call		getPushBlockValAndStoreAllOtherPiecesOfPushableBlock
	jr		@done

@spinner:
	call		getSpinnerObjectVals

@done:
	ret

loadRoomDataAddressIntoHl:
	push		af
	ld		a, (wRoomDataAddress)
	ld		l, a
	ld		a, (wRoomDataAddress+1)
	ld		h, a
	pop		af
	ret

;;
; @param	b		lower nybble of object type if upper nybble is zero
getBrickOrCharacterObjectVal:
	ld		a, b
	ld		hl, objectTypesBrickOrCharacter
	call		addAToHl
	ld		a, (hl)
	ret

;;
; @param	b		0 for pit, 1 for stairs
getPitOrStairsObjectVal:
	ld		a, b
	ld		hl, objectTypesPitOrStairs
	call		addAToHl
	ld		a, (hl)
	ret

resetDrawLocation:
	push		af
	ld		a, (wRoomDataAddress)
	ld		(wCurrentPushableBlockDrawLocation), a
	ld		a, (wRoomDataAddress+1)
	ld		(wCurrentPushableBlockDrawLocation+1), a
	pop		af
	ret

;;
; @param	a		original object type byte
; @param	b		lower nybble of object type
; @param	hl		wRoomObjectTypesAddress
getPushBlockValAndStoreAllOtherPiecesOfPushableBlock:
	cp		$10
	jr		nz, @not1x1
	; 1x1
	ld		a, $40
	call		getCorrectTileBasedOnDisplayView
	jp		@done

@not1x1:
	cp		$1f
	jr		nc, @not1byx

	; 1x(>1)
	; top edge of vertical block
	call		resetDrawLocation

	sub		$11
	jr		z, +
	; probably stores vertical parts of block (not top/bottom edges)
	ld		b, $4a
	call		storeB_AtimesInRoomAddressBelowPushBlock
+
	; bottom part of vertical block
	ld		b, $48
	call		shiftDrawLocationDownAndStoreTile
	ld		a, $42
	call		getCorrectTileBasedOnDisplayView
	jp		@done

@not1byx:
	; top-left corner of pushable block
	ld		b, $45
	call		resetDrawLocation
	cp		$1f
	jr		z, @xby1done

	; not 2x1
	cp		$2d
	jr		nz, @not2or3by1

	; is 3x1
	; $01 is probably top edge of pushable block
	ld		a, $01
	call		storeBInRoomAddressToRightOfPushBlock
	jr		@xby1done

@not2or3by1:
	cp		$36
	jr		nz, @not4by1

	; is 4x1
	ld		a, $02
	call		storeBInRoomAddressToRightOfPushBlock
	jr		@xby1done

@not4by1:
	cp		$3c
	jr		nz, @not5by1

	; there is no 3c? supposed to be 5x1?
	ld		a, $03
	call		storeBInRoomAddressToRightOfPushBlock
	jr		@xby1done

@not5by1:
	cp		$41
	jr		nz, @moreThan1row

	; there is no 41? supposed to be 6x1?
	ld		a, $04
	call		storeBInRoomAddressToRightOfPushBlock

@xby1done:
	; 2x1, 3x1, 4x1, maybe 5x1 and 6x1
	; probably stores top-right corner
	ld		b, $44
	call		shiftDrawLocationRightAndStoreTile
	ld		a, $41
	call		getCorrectTileBasedOnDisplayView
	jp		@done

@moreThan1row:
	; top-left corner of pushable block
	call		resetDrawLocation
	cp		$2d
	jr		nc, @not2by2plus

	; 2x2+
	sub		$20
	ld		c, a
	jr		z, +
	; 2x3+ - left edges
	ld		b, $4b
	call		storeB_AtimesInRoomAddressBelowPushBlock
+
	; bottom-left corner
	ld		b, $49
	call		shiftDrawLocationDownAndStoreTile

	; top right corner
	call		resetDrawLocation
	ld		b, $46
	call		shiftDrawLocationRightAndStoreTile

	ld		a, c
	and		a
	jr		z, +
	; right edges
	ld		b, $4e
	call		storeB_AtimesInRoomAddressBelowPushBlock
+
	; bottom-right corner
	ld		b, $4c
	call		shiftDrawLocationDownAndStoreTile
	ld		a, $43
	call		getCorrectTileBasedOnDisplayView
	jp		@done

@not2by2plus:
	; eg 3x2+, 4x2+, etc
	call		resetDrawLocation
	cp		$36
	jr		nc, @not3by2plus

	; 3x2+
	sub		$2e
	ld		c, $01
	jr		@3Plusby2PlusMiddleColumns

@not3by2plus:
	cp		$3c
	jr		nc, @not4by2plus
	sub		$37
	ld		c, $02
	jr		@3Plusby2PlusMiddleColumns

@not4by2plus:
	cp		$41
	jr		nc, @not5by2plus
	sub		$3d
	ld		c, $03
	jr		@3Plusby2PlusMiddleColumns

@not5by2plus:
	; eg 6x2+
	cp		$45
	jr		nc, @done
	sub		$42
	ld		c, $04

@3Plusby2PlusMiddleColumns:
	; a = rows - 2
	ld		(wPushBlockIs3PlusBy3Plus), a
	cp		$00
	jr		z, +
	; left edges
	ld		b, $4b
	call		storeB_AtimesInRoomAddressBelowPushBlock
+
	; bottom-left corner
	ld		b, $49
	call		shiftDrawLocationDownAndStoreTile


	call		resetDrawLocation
	ld		b, $47
-
	; next column
	call		shiftDrawLocationRightAndStoreTile
	ld		a, (wCurrentPushableBlockDrawLocation)
	ld		e, a
	ld		a, (wCurrentPushableBlockDrawLocation+1)
	ld		d, a
	ld		a, (wPushBlockIs3PlusBy3Plus)
	and		a
	jr		z, +
	; empty parts within block
	ld		b, $4f
	call		storeB_AtimesInRoomAddressBelowPushBlock
+
	; bottom edge
	ld		b, $4d
	call		shiftDrawLocationDownAndStoreTile

	ld		a, c
	dec		a
	jr		z, @3Plusby2PlusRightColumn
	ld		c, a
	ld		a, d
	ld		(wCurrentPushableBlockDrawLocation+1), a
	ld		a, e
	ld		(wCurrentPushableBlockDrawLocation), a
	ld		b, $47
	jr		-


@3Plusby2PlusRightColumn:
	ld		a, d
	ld		(wCurrentPushableBlockDrawLocation+1), a
	ld		a, e
	ld		(wCurrentPushableBlockDrawLocation), a
	; top-right corner
	ld		b, $46
	call		shiftDrawLocationRightAndStoreTile
	ld		a, (wPushBlockIs3PlusBy3Plus)
	and		a
	jr		z, +
-
	; right edges
	ld		b, $4e
	call		shiftDrawLocationDownAndStoreTile
	dec		a
	jr		nz, -
+
	; bottom-right edge
	ld		b, $4c
	call		shiftDrawLocationDownAndStoreTile
	ld		a, $43
	call		getCorrectTileBasedOnDisplayView

@done:
	ret

shiftDrawLocationDownAndStoreTile:
	push		af
	push		hl
	ld		a, (wCurrentPushableBlockDrawLocation)
	add		$14
	ld		l, a
	ld		(wCurrentPushableBlockDrawLocation), a
	ld		a, (wCurrentPushableBlockDrawLocation+1)
	adc		$00
	ld		(wCurrentPushableBlockDrawLocation+1), a
	ld		h, a
	ld		(hl), b
	pop		hl
	pop		af
	ret

shiftDrawLocationRightAndStoreTile:
	push		af
	push		hl
	ld		a, (wCurrentPushableBlockDrawLocation)
	add		$01
	ld		l, a
	ld		(wCurrentPushableBlockDrawLocation), a
	ld		a, (wCurrentPushableBlockDrawLocation+1)
	adc		$00
	ld		h, a
	ld		(wCurrentPushableBlockDrawLocation+1), a
	ld		(hl), b
	pop		hl
	pop		af
	ret

;;
; @param	a		how many tiles to below
storeB_AtimesInRoomAddressBelowPushBlock:
	call		shiftDrawLocationDownAndStoreTile
	dec		a
	jr		nz, storeB_AtimesInRoomAddressBelowPushBlock
	ret

;;
; @param	a		how many tiles to the right
storeBInRoomAddressToRightOfPushBlock:
	call		shiftDrawLocationRightAndStoreTile
	dec		a
	jr		nz, storeBInRoomAddressToRightOfPushBlock
	ret

; if $cf15 = 1, a += $10, else not affected
getCorrectTileBasedOnDisplayView:
	push		bc			; $0d3c: $c5
	push		af			; $0d3d: $f5
	ld		a, ($cf15)		; $0d3e: $fa $15 $cf
	ld		b, a			; $0d41: $47
	pop		af			; $0d42: $f1
	dec		b			; $0d43: $05
	jr		nz, +			; $0d44: $20 $02
	add		$10			; $0d46: $c6 $10
+
	pop		bc			; $0d48: $c1
	ret					; $0d49: $c9

;;
; @param	b		lower nybble of spinner object type value
getSpinnerObjectVals:
	ld		a, b
	ld		hl, spinnerLegData
	call		addAToHl
	ld		a, (hl)

	srl		a
	call		c, _spinnerHasRightLeg

	srl		a
	call		c, _spinnerHasLeftLeg

	srl		a
	call		c, _spinnerHasBottomLeg

	srl		a
	call		c, _spinnerHasTopLeg

	ld		a, b
	ld		hl, objectTypeSpinnerVals
	call		addAToHl
	ld		a, (hl)
	ret

_spinnerHasTopLeg:
	push		af
	call		loadRoomDataAddressIntoHl
	call		subtract14FromHl_storeIntoA
	cp		OBJ_PIT
	jr		z, @pitUnderSpinner
	ld		a, $80
	jr		+
@pitUnderSpinner:
	ld		a, $90
+
	ld		(hl), a
	pop		af
	ret

_spinnerHasBottomLeg:
	push		af
	call		loadRoomDataAddressIntoHl
	call		getTileBelowCurrent
	ld		a, $82
	ld		(hl), a
	pop		af
	ret

_spinnerHasRightLeg:
	push		af
	call		loadRoomDataAddressIntoHl
	call		getTileToRightOfCurrent
	ld		a, $81
	ld		(hl), a
	pop		af
	ret

_spinnerHasLeftLeg:
	push		af
	call		loadRoomDataAddressIntoHl
	call		getTileToLeftOfCurrent
	cp		OBJ_PIT
	jr		z, @pitUnderSpinner
	ld		a, $83
	jr		+

@pitUnderSpinner:
	ld		a, $93
+
	ld		(hl), a
	pop		af
	ret

getCorrectWallSpriteValBasedOnSurroundingWalls:
	push		hl
	ld		d, $00
	push		hl
	call		subtract14FromHl_storeIntoA
	pop		hl
	call		scfIfObjectIsWall
	rl		d
	; bit 0 of d now set if tile above current wall is wall

	push		hl
	call		getTileBelowCurrent
	pop		hl
	call		scfIfObjectIsWall
	rl		d
	; bit 0 of d now set if tile below current wall is wall

	push		hl
	call		getTileToLeftOfCurrent
	pop		hl
	call		scfIfObjectIsWall
	rl		d
	; bit 0 of d now set if tile left of current wall is wall

	call		getTileToRightOfCurrent
	call		scfIfObjectIsWall
	rl		d
	; bit 0 of d now set if tile right of current wall is wall

	ld		a, d
	ld		hl, objectTypeBrickVals
	call		addAToHl
	ld		a, (hl)
	pop		hl
	ld		(hl), a
	ret

;;
; @param		a			converted object type value
; @param[out]	cflag		if type was stairs
scfIfObjectIsWall:
	cp		$f0
	jr		c, +
	scf
	jr		++
+
	ccf
++
	ret

; Called when random room is flipped vertically, before loading correct wall values
; maybe adjusts every object vertically
func_0dec:
	ld		hl, $c17e		; $0dec: $21 $7e $c1
	ld		de, $c1e2		; $0def: $11 $e2 $c1
	ld		c, $18			; $0df2: $0e $18
	ld		b, $08			; $0df4: $06 $08
-
	ld		a, (hl)			; $0df6: $7e
	call		func_0e10			; $0df7: $cd $10 $0e
	ld		(wCursorOriginX), a		; $0dfa: $ea $07 $cf
	ld		a, (de)			; $0dfd: $1a
	call		func_0e10			; $0dfe: $cd $10 $0e
	ld		(hl), a			; $0e01: $77
	ld		a, (wCursorOriginX)		; $0e02: $fa $07 $cf
	ld		(de), a			; $0e05: $12
	inc		hl			; $0e06: $23
	inc		de			; $0e07: $13
	dec		b			; $0e08: $05
	call		z, func_0e3d		; $0e09: $cc $3d $0e
	dec		c			; $0e0c: $0d
	jr		nz, -			; $0e0d: $20 $e7
	ret					; $0e0f: $c9

func_0e10:
	push		hl			; $0e10: $e5
	push		bc			; $0e11: $c5
	push		de			; $0e12: $d5
	ld		e, a			; $0e13: $5f
	ld		c, $1c			; $0e14: $0e $1c
	ld		d, $00			; $0e16: $16 $00
	ld		hl, data_0e49		; $0e18: $21 $49 $0e
-
	ldi		a, (hl)			; $0e1b: $2a
	ld		b, a			; $0e1c: $47
	ld		a, e			; $0e1d: $7b
	sub		b			; $0e1e: $90
	jr		nz, +			; $0e1f: $20 $05
	call		func_0e31			; $0e21: $cd $31 $0e
	jr		++			; $0e24: $18 $06
+
	dec		c			; $0e26: $0d
	jr		z, ++			; $0e27: $28 $03
	inc		d			; $0e29: $14
	jr		-			; $0e2a: $18 $ef
++
	ld		a, e			; $0e2c: $7b
	pop		de			; $0e2d: $d1
	pop		bc			; $0e2e: $c1
	pop		hl			; $0e2f: $e1
	ret					; $0e30: $c9

func_0e31:
	push		hl			; $0e31: $e5
	ld		hl, data_0e65		; $0e32: $21 $65 $0e
	ld		a, d			; $0e35: $7a
	call		addAToHl			; $0e36: $cd $6b $24
	ld		a, (hl)			; $0e39: $7e
	ld		e, a			; $0e3a: $5f
	pop		hl			; $0e3b: $e1
	ret					; $0e3c: $c9

; @param		hl		$c17f
; @param[out]	e		is itself minus $1c
; @param[out]	b		$08
func_0e3d:
	ld		a, $0c			; $0e3d: $3e $0c
	call		addAToHl			; $0e3f: $cd $6b $24
	ld		a, e			; $0e42: $7b
	sub		$1c			; $0e43: $d6 $1c
	ld		e, a			; $0e45: $5f
	ld		b, $08			; $0e46: $06 $08
	ret					; $0e48: $c9

data_0e49:
	ld		b, d			; $0e49: $42
	ld		b, e			; $0e4a: $43
	ld		b, (hl)			; $0e4b: $46
	ld		b, a			; $0e4c: $47
	ld		c, b			; $0e4d: $48
	ld		c, c			; $0e4e: $49
	ld		c, h			; $0e4f: $4c
	ld		c, l			; $0e50: $4d
	ld		d, d			; $0e51: $52
	ld		d, e			; $0e52: $53
	ld		d, (hl)			; $0e53: $56
	ld		d, a			; $0e54: $57
	ld		e, b			; $0e55: $58
	ld		e, c			; $0e56: $59
	ld		e, h			; $0e57: $5c
	ld		e, l			; $0e58: $5d
	and		b			; $0e59: $a0
	and		d			; $0e5a: $a2
	and		h			; $0e5b: $a4
	and		l			; $0e5c: $a5
	and		(hl)			; $0e5d: $a6
	and		a			; $0e5e: $a7
	xor		c			; $0e5f: $a9
	xor		e			; $0e60: $ab
	add		b			; $0e61: $80
	add		d			; $0e62: $82
	sub		b			; $0e63: $90
	sub		d			; $0e64: $92

data_0e65:
	ld		c, b			; $0e65: $48
	ld		c, c			; $0e66: $49
	ld		c, h			; $0e67: $4c
	ld		c, l			; $0e68: $4d
	ld		b, d			; $0e69: $42
	ld		b, e			; $0e6a: $43
	ld		b, (hl)			; $0e6b: $46
	ld		b, a			; $0e6c: $47
	ld		e, b			; $0e6d: $58
	ld		e, c			; $0e6e: $59
	ld		e, h			; $0e6f: $5c
	ld		e, l			; $0e70: $5d
	ld		d, d			; $0e71: $52
	ld		d, e			; $0e72: $53
	ld		d, (hl)			; $0e73: $56
	ld		d, a			; $0e74: $57
	and		d			; $0e75: $a2
	and		b			; $0e76: $a0
	and		l			; $0e77: $a5
	and		h			; $0e78: $a4
	and		a			; $0e79: $a7
	and		(hl)			; $0e7a: $a6
	xor		e			; $0e7b: $ab
	xor		c			; $0e7c: $a9
	add		d			; $0e7d: $82
	add		b			; $0e7e: $80
	sub		d			; $0e7f: $92
	sub		b			; $0e80: $90

objectTypesBrickOrCharacter:
	.db OBJ_BRICK_WALL
	.db OBJ_KWIRK
	.db OBJ_EDDIE_EGGPLANT
	.db OBJ_PEPPER_PETE
	.db OBJ_CURLY_CARROT

objectTypesPitOrStairs:
	.db OBJ_PIT
	.db OBJ_STAIRS

spinnerLegData:
	; bit 3 set if has top leg
	; bit 0 set if has right leg
	; bit 2 set if has bottom leg
	; bit 1 set if has left leg
	.db $08 $01 $04 $02	; 2-tile -> facing up,right,down,left
	.db $03 $0c			; 3-tile-long -> 3x1 and 1x3
	.db $09 $05 $06 $0a	; l-shape -> u+r,d+r,d+l,u+l
	.db $0d $07 $0e $0b	; 3-leg -> w/o left,w/o top,w/o right,w/o bottom
	.db $0f				; 4-leg

objectTypeSpinnerVals:
	.db $a0 $a1 $a2 $a3
	.db $ae $ad
	.db $a4 $a5 $a6 $a7
	.db $a8 $a9 $aa $ab
	.db $ac

objectTypeBrickVals:
; %ablr - above below left right
	.db $f0 $f1 $f4 $f5
	.db $f2 $f3 $f6 $f7
	.db $f8 $f9 $fc $fd
	.db $fa $fb $fe $ff