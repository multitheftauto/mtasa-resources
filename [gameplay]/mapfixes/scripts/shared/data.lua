mapFixComponents = {
    ["bs_crack_palace_interior"] = {
        -- Adds the original interior of Big Smoke's Crack Palace
        buildingsToSpawn = {
            -- Object positions taken from carter.ipl
            { 17933, 2532.992188, -1289.789062, 39.281250, 0, 0, 0 }, -- carter-light15b
            { 17946, 2533.820312, -1290.554688, 36.945312, 0, 0, 0 }, -- carter_ground
        },
    },
    ["bs_crack_palace_wall"] = {
        -- Adds the original wall covering the hole at Big Smoke's Crack Palace
        objectsToSpawn = {
            { modelID = 3059, unbreakable = true, frozen = true, x = 2522, y = -1272.9301, z = 35.61, rx = 0, ry = 0, rz = 0 }, -- imy_shash_wall
        },
    },
    ["atrium_lobby_interior"] = {
        -- Removes the doors of the atrium and places the original interior inside
        buildingsToSpawn = {
            -- Object positions taken from gen_int1.ipl
            { 14675, 1719.75,     -1655.765625, 30.1953125, 0, 0, 0 }, -- Hotelatrium_LAn
            { 14674, 1721.632813, -1655.1875,   24.3125,    0, 0, 0 }, -- hotelferns1_LAn
        },
        worldModelsToRemove = {
            -- Interior -1 needs to be used because these objects are spawned in Interior 13 (in lan_stream3.ipl)
            -- which causes them to appear in all interiors (GTA:SA behavior)
            { 1537, 5, 1725.4, -1637.4, 19.2, -1 }, -- Gen_doorEXT16
            { 1533, 5, 1728.4, -1637.4, 19.2, -1 }, -- Gen_doorEXT12
            { 1537, 5, 1700.1, -1669.4, 19.2, -1 }, -- Gen_doorEXT16
            { 1533, 5, 1700.1, -1669.4, 19.2, -1 }, -- Gen_doorEXT12
        },
        objectsToSpawn = {
            { modelID = 1533, physicalPropertiesGroup = 147, x = 1700.132812, y = -1666.40625,  z = 19.210938, rx = 0, ry = -0, rz = -90 },
            { modelID = 1537, physicalPropertiesGroup = 147, x = 1700.132812, y = -1669.421875, z = 19.210938, rx = 0, ry = 0,  rz = -90 },
            { modelID = 1537, physicalPropertiesGroup = 147, x = 1725.429688, y = -1637.4375,   z = 19.210938, rx = 0, ry = 0,  rz = -180 },
            { modelID = 1533, physicalPropertiesGroup = 147, x = 1728.445312, y = -1637.4375,   z = 19.210938, rx = 0, ry = 0,  rz = -180 },
        },
    },
    ["doherty_garage_interior"] = {
        -- Adds the original Doherty Safehouse Garage interior
        buildingsToSpawn = {
            -- Object positions taken from sfse_stream5.ipl
            { 11389, -2048.11719, 166.71875, 30.97656, 0.00000, 0.00000, 0.00000 }, -- hubinterior_SFS
            { 11388, -2048.17969, 166.71875, 34.51563, 0.00000, 0.00000, 0.00000 }, -- hubintroof_SFSe
            { 11390, -2048.17969, 166.71875, 32.22656, 0.00000, 0.00000, 0.00000 }, -- hubgirders_SFSE
            { 11394, -2048.16406, 168.31250, 31.73438, 0.00000, 0.00000, 0.00000 }, -- hubgrgbeams_SFSe
            { 11391, -2056.20313, 158.54688, 29.09375, 0.00000, 0.00000, 0.00000 }, -- hubprops6_SFSe
            { 11393, -2043.51563, 161.34375, 29.33594, 0.00000, 0.00000, 0.00000 }, -- hubprops1_SFS
            { 11392, -2047.75781, 168.14063, 27.88281, 0.00000, 0.00000, 0.00000 }, -- hubfloorstains_SFSe
        },
        garageIDsForInteriorsToOpen = {
            22, -- Mission Garage (Doherty)
        },
    },
    ["undamaged_crackfactory_with_interior"] = {
        -- Removes the destroyed SF factory building, and adds the original interior
        buildingsToSpawn = {
            -- Object positions taken from crack.ipl
            { 11007, -2164.45313, -248.00000, 40.78125, 0.00000, 0.00000, 0.00000 }, -- crack_wins_SFS
            { 11085, -2164.45313, -237.61719, 41.40625, 0.00000, 0.00000, 0.00000 }, -- crack_int1
            { 11086, -2164.45313, -237.39063, 43.42188, 0.00000, 0.00000, 0.00000 }, -- crack_int2
            { 11087, -2143.22656, -261.24219, 38.09375, 0.00000, 0.00000, 0.00000 }, -- crackfactwalk
            { 11089, -2185.52344, -263.92969, 38.76563, 0.00000, 0.00000, 90 },      -- crackfacttanks2_SFS
            { 11090, -2158.82031, -266.23438, 36.22656, 0.00000, 0.00000, 90 },      -- crackfactvats_SFS
            { 11233, -2164.45313, -255.39063, 38.12500, 0.00000, 0.00000, 0.00000 }, -- crackfactwalkb
            { 11234, -2180.45313, -251.46875, 37.99219, 0.00000, 0.00000, 0.00000 }, -- crackfactwalkc
            { 11235, -2180.45313, -261.28906, 37.99219, 0.00000, 0.00000, 0.00000 }, -- crackfactwalkd
            { 11236, -2164.45313, -255.39063, 38.12500, 0.00000, 0.00000, 0.00000 }, -- crackfactwalke
            { 939,   -2179.33594, -239.08594, 37.96094, 0.00000, 0.00000, 0.00000 }, -- CJ_DF_UNIT
            { 939,   -2140.22656, -237.50781, 37.96094, 0.00000, 0.00000, 90 },      -- CJ_DF_UNIT
            { 942,   -2159.06250, -239.06250, 37.96094, 0.00000, 0.00000, 0.00000 }, -- CJ_DF_UNIT_2
            { 942,   -2174.82813, -235.56250, 37.96094, 0.00000, 0.00000, 80 },      -- CJ_DF_UNIT_2
            { 942,   -2140.33594, -229.14844, 37.96094, 0.00000, 0.00000, 90 },      -- CJ_DF_UNIT_2
            { 942,   -2164.20313, -236.02344, 37.96094, 0.00000, 0.00000, 90 },      -- CJ_DF_UNIT_2
            { 944,   -2188.52344, -236.80469, 36.39844, 0.00000, 0.00000, 0.00000 }, -- Packing_carates04
            { 944,   -2153.79688, -229.03906, 36.39844, 0.00000, 0.00000, 0.00000 }, -- Packing_carates04
            { 944,   -2146.26563, -238.40625, 36.39844, 0.00000, 0.00000, -95 },     -- Packing_carates04
            { 944,   -2171.10156, -235.70313, 36.39844, 0.00000, 0.00000, -175 },    -- Packing_carates04
            { 944,   -2145.16406, -234.17188, 36.39844, 0.00000, 0.00000, -80 },     -- Packing_carates04
            { 944,   -2146.02344, -228.50000, 36.39844, 0.00000, 0.00000, -80 },     -- Packing_carates04
            { 944,   -2149.87500, -229.71875, 36.39844, 0.00000, 0.00000, 0.00000 }, -- Packing_carates04
            { 944,   -2177.53906, -259.82813, 36.39844, 0.00000, 0.00000, -95 },     -- Packing_carates04
            { 944,   -2175.75000, -266.33594, 36.39844, 0.00000, 0.00000, -55 },     -- Packing_carates04
            { 944,   -2146.06250, -251.00781, 36.39844, 0.00000, 0.00000, -90 },     -- Packing_carates04
            { 944,   -2180.39063, -247.46094, 36.39844, 0.00000, 0.00000, -90 },     -- Packing_carates04
        },
        worldModelsToRemove = {
            { 11088, 60, -2166.875,  -236.51562, 40.85938, 0 }, -- CF_ext_dem_SFS
            { 11282, 60, -2166.875,  -236.51562, 40.85938, 0 }, -- (LOD) CF_ext_dem_SFS
            { 11235, 15, -2180.4531, -261.28906, 37.99219, 0 }, -- crackfactwalkd
            { 11236, 25, -2164.4531, -255.39062, 38.125,   0 }, -- crackfactwalke
        },
    },
}
