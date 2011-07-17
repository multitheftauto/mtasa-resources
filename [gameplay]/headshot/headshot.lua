addEvent "onPlayerHeadshot"

addEventHandler("onPlayerDamage", getRootElement(),
	function (attacker, weapon, bodypart, loss)
		if bodypart == 9 then
			local result = triggerEvent("onPlayerHeadshot", source, attacker, weapon, loss)
			if result == true then
				killPed(source, attacker, weapon, bodypart)
			end
		end
	end
)