local ADMIN_GROUP = "Admin"
local MAX_PASSWORD_CHARS = 30
local g_console = getElementsByType"console"[1]
local g_inWizard,g_wizardCR,g_pattern,g_inputIgnore

function aStartWizard ()
	--Check if they have any admins
	for i,object in ipairs(aclGroupListObjects ( aclGetGroup(ADMIN_GROUP) )) do
		if string.find(object,"user.") == 1 then
			return
		end
	end
	outputServerLog ( "-> It appears your server lacks any Administrators." )
	outputServerLog ( "-> An Administrator is required in order to manage a server.  Please use the command 'adminwizard' to setup an admin." )
end

local function input(message)
	if message == "adminwizard" then return end
	if not g_pattern then return end
	--outputServerLog ( coroutine.status ( g_wizardCR ).." "..tostring(message) )
	if g_pattern(message) then
		g_wizardCR(false)
		return
	end
	g_wizardCR(message)
	--outputSevrerLog ( "|"..tostring( coroutine.resume(g_wizardCR,message) ) )
end


local wizard = {}
wizard[1] = function()
		outputServerLog ( "-> Please enter the default USERNAME for the account.  This may be any alphanumerical name." )
		g_pattern = function(msg) return string.find(msg,"%W") end
		local message = coroutine.yield()
		g_pattern = nil
		outputServerLog ( "message: "..tostring(message) )
		if not message then
			outputServerLog ( "-> The username was invalid." )
			g_wizardCR = coroutine.wrap(wizard[1])
			g_wizardCR()
			return
		end
		outputServerLog ( "-> Here "..tostring(wizard[2]) )
		wizard.username = message
		g_wizardCR = coroutine.wrap(wizard[2])
		g_wizardCR()
	end
wizard[2] = function()
		outputServerLog ( "-> Please enter the default PASSWORD for the account.  This may be up to "..MAX_PASSWORD_CHARS.." characters in length." )
		g_pattern = function(msg) return #msg <= MAX_PASSWORD_CHARS end
		addEventHandler ( "onConsole", g_console, input )
		local message = coroutine.yield()
		g_pattern = nil
		removeEventHandler ( "onConsole", g_console, input )
		if not message then
			outputServerLog ( "-> The password was invalid." )
			g_wizardCR = coroutine.wrap(wizard[2])
			g_wizardCR()
			return
		end
		wizard.password = message
		g_wizardCR = coroutine.wrap(wizard[3])
		g_wizardCR()
	end
wizard[3] = function()
		outputServerLog ( "-> You have chosen to create an admin account with username '"..wizard.username.."' and password '"..wizard.password.."'.  Is this correct? (y/n)" )
		g_pattern = function(msg) return msg == "y" or msg == "yes" end
		local message = coroutine.yield()
		g_pattern = nil
		if message then
			if addAccount ( wizard.username, wizard.password ) then
				outputServerLog ( "-> The admin account has been added successfully.  Please use the 'login' command ingame to log in.  Syntax: login <username> <password>" )
				outputServerLog ( "-> You can use this wizard again anytime by typing 'adminwizard' in the server console." )
			else
				outputServerLog ( "-> The account could not be created.  It may exist already.  Please type 'adminwizard' to run the wizard again." )
			end
		else
			outputServerLog ( "-> Please type 'adminwizard' to run the wizard again." )
		end
		g_wizardCR,g_inWizard = nil,nil
	end


addCommandHandler ( "adminwizard",
	function(source)
		if source ~= g_console then return end
		if g_inWizard then
			outputServerLog ( "-> You are already in an admin wizard." )
			return
		end
		addEventHandler ( "onConsole", g_console, input )
		g_wizardCR = coroutine.wrap(wizard[1])
		g_wizardCR()
	end
)
