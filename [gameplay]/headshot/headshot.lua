local removeHeadOnHeadshot = get("removeHeadOnHeadshot")

addEvent("onPlayerHeadshot", false)

local function checkForHeadshot(attacker, weapon, bodypart, loss)
	if bodypart == 9 then
		local forceDeath = triggerEvent("onPlayerHeadshot", source, attacker, weapon, loss)

		if forceDeath then
			killPed(source, attacker, weapon, bodypart)

			if removeHeadOnHeadshot then
				setPedHeadless(source, true)
			end
		end
	end
end
addEventHandler("onPlayerDamage", root, checkForHeadshot)

local function restorePlayerHead()
	if removeHeadOnHeadshot and isPedHeadless(source) then
		setPedHeadless(source, false) -- Restore head if it got blown off
	end
end
addEventHandler("onPlayerSpawn", root, restorePlayerHead)