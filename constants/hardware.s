.define INT_VBLANK	$01
.define INT_LCD		$02
.define INT_TIMER	$04
.define INT_SERIAL	$08
.define INT_JOYPAD	$10

.define BIT_VBLANK	0
.define BIT_LCD		1
.define BIT_TIMER	2
.define BIT_SERIAL	3
.define BIT_JOYPAD	4

.define BTN_A		$01
.define BTN_B		$02
.define BTN_SELECT	$04
.define BTN_START	$08
.define BTN_RIGHT	$10
.define BTN_LEFT	$20
.define BTN_UP		$40
.define BTN_DOWN	$80

.define BTN_BIT_A	0
.define BTN_BIT_B	1
.define BTN_BIT_SELECT	2
.define BTN_BIT_START	3
.define BTN_BIT_RIGHT	4
.define BTN_BIT_LEFT	5
.define BTN_BIT_UP	6
.define BTN_BIT_DOWN	7

; Bits in flag register. Need this because contents of flag register get dumped into $cddb
; for certain script-related functions.
.define CPU_CFLAG	$10
.define CPU_ZFLAG	$80

.define P1    $ff00
.define SB    $ff01
.define SC    $ff02
.define DIV   $ff04
.define TIMA  $ff05
.define TMA   $ff06
.define TAC   $ff07
.define IF    $ff0f
.define NR10  $ff10
.define NR11  $ff11
.define NR12  $ff12
.define NR13  $ff13
.define NR14  $ff14
.define NR21  $ff16
.define NR22  $ff17
.define NR23  $ff18
.define NR24  $ff19
.define NR30  $ff1a
.define NR31  $ff1b
.define NR32  $ff1c
.define NR33  $ff1d
.define NR34  $ff1e
.define NR41  $ff20
.define NR42  $ff21
.define NR43  $ff22
.define NR44  $ff23
.define NR50  $ff24
.define NR51  $ff25
.define NR52  $ff26
.define LCDC  $ff40
.define STAT  $ff41
.define SCY   $ff42
.define SCX   $ff43
.define LY    $ff44
.define LYC   $ff45
.define DMA   $ff46
.define BGP   $ff47
.define OBP0  $ff48
.define OBP1  $ff49
.define WY    $ff4a
.define WX    $ff4b
.define KEY1  $ff4d
.define VBK   $ff4f
.define HDMA1 $ff51
.define HDMA2 $ff52
.define HDMA3 $ff53
.define HDMA4 $ff54
.define HDMA5 $ff55
.define RP    $ff56
.define BGPI  $ff68
.define BGPD  $ff69
.define OBPI  $ff6a
.define OBPD  $ff6b
.define SVBK  $ff70
.define IE    $ffff

.define R_P1    $00
.define R_SB    $01
.define R_SC    $02
.define R_DIV   $04
.define R_TIMA  $05
.define R_TMA   $06
.define R_TAC   $07
.define R_IF    $0f
.define R_NR10  $10
.define R_NR11  $11
.define R_NR12  $12
.define R_NR13  $13
.define R_NR14  $14
.define R_NR21  $16
.define R_NR22  $17
.define R_NR23  $18
.define R_NR24  $19
.define R_NR30  $1a
.define R_NR31  $1b
.define R_NR32  $1c
.define R_NR33  $1d
.define R_NR34  $1e
.define R_NR41  $20
.define R_NR42  $21
.define R_NR43  $22
.define R_NR44  $23
.define R_NR50  $24
.define R_NR51  $25
.define R_NR52  $26
.define R_LCDC  $40
.define R_STAT  $41
.define R_SCY   $42
.define R_SCX   $43
.define R_LY    $44
.define R_LYC   $45
.define R_DMA   $46
.define R_BGP   $47
.define R_OBP0  $48
.define R_OBP1  $49
.define R_WY    $4a
.define R_WX    $4b
.define R_KEY1  $4d
.define R_VBK   $4f
.define R_HDMA1 $51
.define R_HDMA2 $52
.define R_HDMA3 $53
.define R_HDMA4 $54
.define R_HDMA5 $55
.define R_RP    $56
.define R_BGPI  $68
.define R_BGPD  $69
.define R_OBPI  $6a
.define R_OBPD  $6b
.define R_SVBK  $70
.define R_IE    $ff

.define VRAM_BLOCK0	$8000
.define VRAM_BLOCK1	$8800
.define VRAM_BLOCK2	$9000
.define BG_MAP1		$9800
.define BG_MAP2		$9c00