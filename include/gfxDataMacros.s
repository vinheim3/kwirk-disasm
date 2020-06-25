.macro m_GfxData
\1:
	.fopen "gfx//\1.bin" fp
    .fsize fp t
    .repeat t
    .fread fp d
    .db d
    .endr
    .undefine t, d
.endm

.macro m_GfxDataSpaceAfterByte
\1:
	.fopen "gfx//\1.bin" fp
    .fsize fp t
    .repeat t/2
    .fread fp d
    .db d
    .fread fp d
    .endr
    .undefine t, d
.endm

.macro m_GfxDataSpaceBeforeByte
\1:
	.fopen "gfx//\1.bin" fp
    .fsize fp t
    .repeat t/2
    .fread fp d
    .fread fp d
    .db d
    .endr
    .undefine t, d
.endm

.define gfx_heart $6700
.define gfx_brick $6af0
.define gfx_lines $6f50