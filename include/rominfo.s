.memorymap
	slotsize $4000
	defaultslot 1
	slot 0 $0000
	slot 1 $4000

	slotsize $1000
	slot 2 $c000
	slot 3 $d000
.endme

.banksize $4000
.rombanks 2

.gbheader
	name "KWIRK"
	version $00
	licenseecodeold $51
	cartridgetype $00
	ramsize $00
	countrycode $01
	nintendologo
	romdmg
.endgb

.emptyfill $ff

.asciitable
	map "A" TO "Z" = $00
	map "#" = $1d
	map "'" = $1e
	map "-" = $1f
	map "!" = $20
	map "?" = $21
	map "0" TO "9" = $3c
	map ":" = $e0
	map " " = $ff
.enda