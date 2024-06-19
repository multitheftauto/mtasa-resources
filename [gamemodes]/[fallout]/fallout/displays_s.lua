textDisplays = {}
textItems = {}

textDisplays.countDownDisplay = textCreateDisplay()
textItems.countDownText = textCreateTextItem("", 0.5, 0.3, "high", 255, 127, 0, 255, 2, "center")
textDisplayAddText(textDisplays.countDownDisplay, textItems.countDownText)

textDisplays.suicideDisplay = textCreateDisplay()
local suicideText = textCreateTextItem("You lose! Press space for a quick death.", 0.5, 0.5, "low", 255, 127, 0, 255, 2, "center")
textDisplayAddText(textDisplays.suicideDisplay, suicideText)

textDisplays.winnersDisplay = textCreateDisplay()
textItems.winnersText = textCreateTextItem("Winners:", 0.5, 0.35, "low", 255, 127, 0, 255, 2, "center", "center")
textDisplayAddText(textDisplays.winnersDisplay, textItems.winnersText)

textDisplays.spectatorCamDisplay = textCreateDisplay()
textItems.specCamText = textCreateTextItem("Use your player movement keys to move the spectator camera.\nUse your sprint key to speed the camera up.", 0.5, 0.22, "low", 255, 127, 0, 255, 1.3, "center")
textDisplayAddText(textDisplays.spectatorCamDisplay, textItems.specCamText)

textDisplays.podiumDisplay = textCreateDisplay()

textItems.firstText = textCreateTextItem("1st:", 0.45, 0.08, "high", 255, 127, 0, 255, 1.5)
textItems.secondText = textCreateTextItem("2nd:", 0.45, 0.12, "high", 255, 127, 0, 255, 1.5)
textItems.thirdText = textCreateTextItem("3rd:", 0.45, 0.16, "high", 255, 127, 0, 255, 1.5)

-- Tournament text
textDisplayAddText(textDisplays.podiumDisplay, textCreateTextItem("Tournament Leaders", 0.45, 0.04, "high", 255, 127, 0, 255, 1.5))

textDisplayAddText(textDisplays.podiumDisplay, textItems.firstText)
textDisplayAddText(textDisplays.podiumDisplay, textItems.secondText)
textDisplayAddText(textDisplays.podiumDisplay, textItems.thirdText)