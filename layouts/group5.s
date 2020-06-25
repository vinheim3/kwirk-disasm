contestPreGameLayoutData:
	.asc "     VS MODE  "
	.db $aa $aa
	.asc "LEVEL #  BEST OF"
	.db $aa $aa
	.asc " OPP    RMS"
	.db $aa $aa
	.asc " YOU    RMS"
	.db $aa $aa
	.asc "      GAME  "
	.db $bb

startEndLayoutData:
	.asc "START"
	.db $aa $aa
	.asc "END"
	.db $bb

confirmGoingUpLayoutData:
	.asc "   GOING UP?"
	.db $aa $aa
	.asc "LEVEL #  FL#"
	.db $bb

confirmHeadingOutLayoutData:
	.asc " HEADING OUT?"
	.db $aa $aa
	.asc "LEVEL #    RMS"
	.db $bb