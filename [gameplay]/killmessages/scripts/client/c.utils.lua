local defaultIconsByVehType = {
    ['Automobile'] = 'icons/cars.png',
    ['Boat'] = 'icons/boat.png',
    ['Plane'] = 'icons/plane.png',
    ['Train'] = 'icons/train.png',
}

local customIcons = {
    [0] = "icons/fist.png",
    [1] = "icons/brassknuckle.png",
    [2] = "icons/golfclub.png",
    [3] = "icons/nitestick.png",
    [4] = "icons/knifecur.png",
    [5] = "icons/bat.png",
    [6] = "icons/shovel.png",
    [7] = "icons/poolcue.png",
    [8] = "icons/katana.png",
    [9] = "icons/chnsaw.png",
    [10] = "icons/gun_dildo1.png",
    [11] = "icons/gun_dildo2.png",
    [12] = "icons/gun_vibe1.png",
    [14] = "icons/flowera.png",
    [15] = "icons/gun_cane.png",
    [16] = "icons/grenade.png",
    [17] = "icons/teargas.png",
    [18] = "icons/molotov.png",
    [19] = "icons/explosion.png",
    [63] = "icons/explosion.png",
    [22] = "icons/colt45.png",
    [23] = "icons/Silenced.png",
    [24] = "icons/desert_eagle.png",
    [25] = "icons/chromegun.png",
    [26] = "icons/sawnoff.png",
    [27] = "icons/shotgspa.png",
    [28] = "icons/micro_uzi.png",
    [29] = "icons/mp5lng.png",
    [30] = "icons/ak47.png",
    [31] = "icons/m4.png",
    [32] = "icons/tec9.png",
    [33] = "icons/cuntgun.png",
    [34] = "icons/sniper.png",
    [35] = "icons/rocketla.png",
    [36] = "icons/heatseek.png",
    [37] = "icons/flame.png",
    [38] = "icons/minigun.png",
    [39] = "icons/satchel.png",
    [42] = "icons/fireextinguisher.png",
    [49] = "icons/rammed.png",
    [50] = "icons/maverick.png",
    [51] = "icons/explosion.png",
    [53] = "icons/drowned.png",
    [54] = "icons/fall.png",
    [255] = "icons/suicide.png",
    [256] = "icons/headshot.png",

    -----------vehicle specific icons, according to their vehicle id---------
    [431] = "icons/bus.png",
    [437] = "icons/bus.png",
    [414] = "icons/boxtruck.png",
    [456] = "icons/boxtruck.png",
    [498] = "icons/boxtruck.png",
    [499] = "icons/boxtruck.png",
    [609] = "icons/boxtruck.png",
    [440] = "icons/roundvan.png",
    [459] = "icons/roundvan.png",
    [482] = "icons/roundvan.png",
    [483] = "icons/roundvan.png",
    [582] = "icons/roundvan.png",
    [447] = "icons/sparrow.png",
    [469] = "icons/sparrow.png",
    [487] = "icons/maverick.png",
    [488] = "icons/maverick.png",
    [497] = "icons/maverick.png",
    [548] = "icons/maverick.png",
    [563] = "icons/maverick.png",
    [465] = "icons/rccopter.png",
    [501] = "icons/rccopter.png",
    [481] = "icons/bike.png",
    [509] = "icons/bike.png",
    [510] = "icons/bike.png",
    [514] = "icons/bigtruck.png",
    [515] = "icons/bigtruck.png",
    [461] = "icons/crotchrocket.png",
    [521] = "icons/crotchrocket.png",
    [522] = "icons/crotchrocket.png",
    [523] = "icons/crotchrocket.png",
    [581] = "icons/crotchrocket.png",
    [586] = "icons/crotchrocket.png",
    [407] = "icons/firetruck.png",
    [544] = "icons/firetruck.png",
    [444] = "icons/monstertruck.png",
    [556] = "icons/monstertruck.png",
    [557] = "icons/monstertruck.png",
    [596] = "icons/copcar.png",
    [597] = "icons/copcar.png",
    [598] = "icons/copcar.png",
    [425] = "icons/hunter.png",
    [406] = "icons/406.png",
    [408] = "icons/408.png",
    [416] = "icons/416.png",
    [417] = "icons/417.png",
    [423] = "icons/423.png",
    [424] = "icons/424.png",
    [427] = "icons/427.png",
    [428] = "icons/428.png",
    [429] = "icons/429.png",
    [432] = "icons/432.png",
    [433] = "icons/433.png",
    [434] = "icons/434.png",
    [441] = "icons/441.png",
    [443] = "icons/443.png",
    [448] = "icons/448.png",
    [457] = "icons/457.png",
    [460] = "icons/460.png",
    [462] = "icons/462.png",
    [463] = "icons/463.png",
    [464] = "icons/464.png",
    [468] = "icons/468.png",
    [470] = "icons/470.png",
    [471] = "icons/471.png",
    [480] = "icons/480.png",
    [485] = "icons/485.png",
    [486] = "icons/486.png",
    [508] = "icons/508.png",
    [511] = "icons/511.png",
    [512] = "icons/512.png",
    [513] = "icons/513.png",
    [520] = "icons/520.png",
    [524] = "icons/524.png",
    [528] = "icons/528.png",
    [530] = "icons/530.png",
    [531] = "icons/531.png",
    [532] = "icons/532.png",
    [539] = "icons/539.png",
    [564] = "icons/564.png",
    [568] = "icons/568.png",
    [571] = "icons/571.png",
    [572] = "icons/572.png",
    [573] = "icons/573.png",
    [574] = "icons/574.png",
    [578] = "icons/578.png",
    [588] = "icons/588.png",
    [593] = "icons/593.png",
    [599] = "icons/599.png",
    [999] = "icons/generic.png",
}

function getMessageIcon(weapon, attacker)
    local path

    if weapon then
        path = customIcons[weapon] or 'icons/generic.png'
    end

    local elemType = isElement(attacker) and getElementType(attacker)

    if (elemType == 'vehicle') then
        local model = getElementModel(attacker)
        path = customIcons[model] or defaultIconsByVehType[getVehicleType(attacker)] or 'icons/generic.png'

    elseif (elemType == 'player') then
        local vehicle = getPedOccupiedVehicle(attacker)
        if vehicle then
            return getMessageIcon(_, vehicle)
        end
    end

    local texture = getTexture(path)

    if texture then
        return {
            texture = texture,
            width = dxGetMaterialSize(texture)
        }
    end

    return false
end

local textures = {}

function getTexture(path)
    if (type(path) ~= 'string') then
        return false
    end

    if (textures[path] ~= nil) then
        return textures[path]
    end

    textures[path] = dxCreateTexture(path)

    return textures[path]
end

function removeHex(s)
    if (type(s) == "string") then
        while (s ~= s:gsub("#%x%x%x%x%x%x", "")) do
            s = s:gsub("#%x%x%x%x%x%x", "")
        end
    end
    return s or false
end
