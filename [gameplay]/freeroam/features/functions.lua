local addCommandHandler_ = addCommandHandler

local function addCommandHandler(cmd, cb)
    if type(cmd) == "table" then
        for index, cmd in ipairs(cmd) do
            addCommandHandler_(cmd, cb)
        end
    else
        addCommandHandler_(cmd, cb)
    end
    return true
end

function toggleJetPack()

end

function killYourself()
    localPlayer:setHealth(0)
end
addCommandHandler({"kill", "Kill", "killme", "Killme", "samp"}, killYourself)