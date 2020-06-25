gameOptionsLayoutData:
	.asc "SELECT GAME"
	.db $aa $aa

	.asc " GOING UP?"
	.db $aa $aa

	.asc " HEADING OUT?"
	.db $aa $aa

	.asc " VS MODE"
	.db $bb

displayViewOptionsLayoutData:
	.asc " SELECT DISPLAY"
	.db $aa $aa
	.asc " DIAGONAL VIEW"
	.db $aa $aa
	.asc " BIRD'S-EYE VIEW"
	.db $bb

difficultyOptionsLayoutData:
	.asc "  SELECT SKILL"
	.db $aa $aa
	.asc " LEVEL#1 EASY"
	.db $aa $aa
	.asc " LEVEL#2 AVERAGE"
	.db $aa $aa
	.asc " LEVEL#3 HARD"
	.db $bb

floorOptionsLayoutData:
	.asc " SELECT FLOOR"
	.db $aa $aa
	.asc " FL# 1  FL# 6"
	.db $aa
	.asc " FL# 2  FL# 7"
	.db $aa
	.asc " FL# 3  FL# 8"
	.db $aa
	.asc " FL# 4  FL# 9"
	.db $aa
	.asc " FL# 5  FL#10"
	.db $bb

contestOptionsLayoutData:
	.asc "SELECT CONTEST"
	.db $aa $aa
	.asc " 1 GAME PLAYOFF"
	.db $aa
	.asc " BEST OF 3"
	.db $aa
	.asc " BEST OF 5"
	.db $aa
	.asc " BEST OF 7"
	.db $aa
	.asc " BEST OF 9"
	.db $bb

levelClearScreenLayoutData:
	.asc "  YOU DID IT!"
	.db $aa $aa
	.asc "LEVEL #  FL#"
	.db $aa $aa
	.asc "  TIME   :"
	.db $aa $aa
	.asc "  STEPS"
	.db $bb

returnToGameOptionsLayoutData:
	.asc "RETURN TO GAME"
	.db $aa $aa $aa $aa
	.asc "SELECT SKILL"
	.db $aa $aa
	.asc "SELECT GAME"
	.db $bb

selectFloorLayoutData:
	.asc "SELECT FLOOR"
	.db $bb

selectCourseLayoutData:
	.asc "SELECT COURSE"
	.db $bb

contestProgressLayoutData:
	.asc "OPP     RMS"
	.db $aa $aa $aa
	.asc "YOU"
	.db $bb

awesomeLevelClearedLayoutData:
	.asc "AWESOME!"
	.db $aa $aa
	.asc "LEVEL #"
	.db $aa $aa
	.asc "CLEARED"
	.db $bb

excellentLayoutData:
	.db $aa $aa
	.asc "EXCELLENT!"
	.db $bb