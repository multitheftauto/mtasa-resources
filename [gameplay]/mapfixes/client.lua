-- MTA:SA Map Fixes

local function loadObjects()

    local PLACE_BUILDINGS = {
        -- Big Smoke Crack Den inside area
        {17933, 2532.992188, -1289.789062, 39.281250, 0, 0, 0},
        {17946, 2533.820312, -1290.554688, 36.945312, 0, 0, 0},
    }

    for _, v in pairs(PLACE_BUILDINGS) do
        createBuilding(unpack(v))
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    loadObjects()
end, false)
