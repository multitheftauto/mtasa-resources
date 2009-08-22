-- Start with console command: gamemode deathmatch dm-port69
-- Port 69 by Ransom 2006

local vehicles = getElementsByType ( "vehicle", getRootElement () )

for k,v in pairs(vehicles) do
	toggleVehicleRespawn ( v, true )
    setVehicleIdleRespawnDelay ( v, 5000 )
    setVehicleRespawnDelay ( v, 1000 )
end
