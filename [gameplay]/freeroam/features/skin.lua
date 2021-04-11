local screenX, screenY = guiGetScreenSize()

addWindow("skin",
    {
        topTitle = "Set skin",

        defaultWidth = 230,
        defaultHeight = 340,

        x = screenX - 240,
        y = screenY / 2 - 290 / 2,

        rowHeight = 25,

        render = {
            {"GuiGridList", x = 5, y = 25, width = 220, height = 270},
            {"br", height = 280},
            {"GuiEdit", text = "", width = 50, height = 25},
            {"GuiButton", text = "Set", height = 25},
            {"GuiButton", text = "Close", height = 25}
        }
    }
)