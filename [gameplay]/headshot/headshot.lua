local removeHeadOnHeadshot = get("removeHeadOnHeadshot")

function onPlayerDamage(attacker, weapon, bodypart, loss)
	if bodypart == 9 then
		killPed(source, attacker, weapon, bodypart)

		if removeHeadOnHeadshot then
			setPedHeadless(source, true)
		end
	end
end
addEventHandler("onPlayerDamage", root, onPlayerDamage)

function onPlayerSpawn()
	if removeHeadOnHeadshot and isPedHeadless(source) then
		setPedHeadless(source, false) -- Restore head if it got blown off
	end
end
addEventHandler("onPlayerSpawn", root, onPlayerSpawn)