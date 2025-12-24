-- https://wiki.multitheftauto.com/wiki/OnSettingChange
-- gets triggered when a resource setting has been changed
function resourceSettingChanged(strSetting, strOldValue, strNewValue)
	logAction("Setting \""..strSetting.."\" has been changed from \""..fromJSON(strOldValue).."\" to \""..fromJSON(strNewValue).."\"");
end
addEventHandler("onSettingChange", root, resourceSettingChanged);



-- https://wiki.multitheftauto.com/wiki/OnAccountDataChange
-- gets triggered when account has been changed
function accountDataChanged(uAccount, strKey, strValue)
	logAction("Data \""..strKey.."\" of account \""..getAccountName(uAccount).."\" has been changed to \""..strValue.."\"");
end
addEventHandler("onAccountDataChange", root, accountDataChanged);