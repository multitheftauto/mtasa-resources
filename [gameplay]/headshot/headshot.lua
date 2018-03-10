local removeHeadOnHeadshot = get("removeHeadOnHeadshot");

addEvent "onPlayerHeadshot"

addEventHandler("onPlayerDamage", getRootElement(),
	function (attacker, weapon, bodypart, loss)
		if bodypart == 9 then
			local result = triggerEvent("onPlayerHeadshot", source, attacker, weapon, loss)
			if result == true then
				killPed(source, attacker, weapon, bodypart)
				if removeHeadOnHeadshot then
					setPedHeadless(source, true)
				end
			end
		end
	end
)

addEventHandler("onPlayerSpawn", getRootElement(),
	function()
		-- Restore head if it got blown off
		if removeHeadOnHeadshot and isPedHeadless(source) then
			setPedHeadless(source, false)
		end
	end
)
