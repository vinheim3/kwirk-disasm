## Building
* Just wla-gb I think

## Level loading
Code for loading levels is in code/levelLoading.s.
Data for levels is in data/roomData.s, and split into 3 lookup tables
* Room size table - 2 bytes, 1st for width, 2nd for height (TODO: 31+)
* Object positions - every bit set in these bytes determine if an object exists there
* Object types - determine which object is in the level, each byte corresponds
to each bit in Object positions

Eg for level 1:
* Room size: `$10 $03` or 16x3
* Object positions: (if you play level 1, those top and bottom 1s are walls
left is stairs, right is you, middle 2 is walls, and the other ones in the middle
are the 3-legged spinners)
```
	dwbe %0001000000001000
	dwbe %0100010110100010
	dwbe %0001000000001000
```
* Object types
`.db $00 $00 $a1 $9a $00 $00 $9c $01 $00 $00` - ($00)wall, wall, ($a1)stairs,
($9a)3-leg spinner without left leg, wall, wall, ($9c)3-leg spinner without right
leg, ($01)you, wall, wall

For levels 31+, the room size table is 1 byte each and is used to determine how
the exit path looks like (WIP)

## Object types
```
00 - brick
01 - me
02 - teardrop guy
03 - fire/shield guy
04 - carrot guy

10 - pushable block (1x1)
11 - pushable block (1x2)
12 - pushable block (1x3)
13 - pushable block (1x4)
14 - pushable block (1x5)
1a - pushable block (1x11)

1f - pushable block (2x1)
20 - pushable block (2x2)
21 - pushable block (2x3)

2d - pushable block (3x1)
2e - pushable block (3x2)
2f - pushable block (3x3)

36 - pushable block (4x1)
38 - pushable block (4x3) ?
39 - pushable block (4x4) ?

40 - pushable block (5x5)

90 - 2-tile facing up
91 - 2-tile facing right
92 - 2-tile facing down
93 - 2-tile facing left

94 - ??? (long spinner (l+r)?)
95 - long spinner (u+d)

96 - l shape (u+r)
97 - l shape (d+r)
98 - l shape (d+l)
99 - l shape (u+l)

9a - 3 leg turner without left leg
9b - 3 leg turner without top leg
9c - 3 leg turner without right leg
9d - 3 leg turner without bottom leg

9e - 4 leg

a0 - pit (1x1)
a1 - stair
```

## Scripts in tools/
* `convertToAscii.py` - used for converting bytes of data in layouts/ to their
ascii equivalent as shown in-game
* `dumpGfxData.py` - gets 2bpp data from a given address range (or 1bpp which 
I forgot exists hence the 'spaced' stuff in the tool and in-code). Sends it out
as gfx_new.bin
* `dumpRoomData.py` - converts room data in a much more readable format. Will
be adapted in the future for level-scrolling rooms, and maybe adapted if
aggregating the 3 tables, and using macros to split them out
* `extractBytes.py` - gets a range of bytes in rom and dumps x amount per row,
or dumps a series of 'words' eg for address lookups or jump tables
* `gfx.py` - generic script to convert between 2bpp/1bpp data to a png format,
eg `python tools/gfx.py png gfx_new.bin`