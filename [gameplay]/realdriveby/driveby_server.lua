local settings = {
	driver = get"driveby_driver" or { 22,23,24,25,28,29,32 },
	passenger = get"driveby_passenger" or { 22,23,24,25,26,28,29,32,30,31,33 },
	shotdelay = get"driveby_shot_delay" or { ['22']=300,['23']=300,['24']=800,['26']=700 },
	blockedVehicles = get"driveby_blocked_vehicles" or { 432,601,437,431,592,553,577,488,497,548,563,512,476,447,425,519,520,460,417,469,487,513,441,464,501,465,564,538,449,537,539,570,472,473,493,595,484,430,453,452,446,454,606,591,607,611,610,590,569,611,435,608,584,450 },
	steerCars = get"driveby_steer_cars" == true,
	steerBikes = get"driveby_steer_bikes" == true,
	autoEquip = get"driveby_auto_equip" or false
}
--Remove any BS IDs by checking them
local validDrivebyWeapons = { [22]=true,[23]=true,[24]=true,[25]=true,
[26]=true,[27]=true,[28]=true,[29]=true,[32]=true,[30]=true,[31]=true,
[32]=true,[33]=true,[38]=true }
--Loop through both driveby tables and ensure they have proper IDs
for key,weaponID in ipairs(settings.driver) do
	if not validDrivebyWeapons[weaponID] then
		table.remove ( settings.driver, key )
	end
end
for key,weaponID in ipairs(settings.passenger) do
	if not validDrivebyWeapons[weaponID] then
		table.remove ( settings.driver, key )
	end
end


--Verifies the clientscript is downloaded before initiating
addEvent ( "driveby_clientScriptLoaded", true )
addEventHandler ( "driveby_clientScriptLoaded", getRootElement(),
	function()
		triggerClientEvent ( client, "doSendDriveBySettings", client, settings )
	end
)

