--[[
	About this gamemode:

		While the name as of now is unofficial, Trouble in Terrorist Town Two aims to be a
	solid replacement of the original Trouble in Terrorist Town created by Bad King Urgrain
	written primarily by Stalker. The original TTT was made for one of the Fretta coding
	competitions way back when and has since been built upon it's hastily written core codebase
	which suffers poor optimizations and networking. This version of TTT aims to improve on
	the original's weaknesses by being modular, well documented, optimized, and networked.
	Other than UI changes this gamemode should more or less be the same as the original.

	BIG thanks to Bad King Urgrain for the years upon years of joy his gamemode gave me.

-----------------------------------------------------------------------------------------------
	
	About the code:

		The code for this gamemode is split in two. While the library folder houses the
	decleration of nearly every function/variable they are rarely executed in their containning
	folders. They are instead called in cl_init.lua, init.lua, and shared.lua. These three files
	control how the gamemode uses the available library. By doing so we split implimentation from
	application, making the gamemode very neat and organized. Furthermore, none of the libraries
	reference code from other libraries. For example, nothing in the rounds library is ever called
	in the roles library. Whenever this connection needs to be made a hook is instead used in one
	of the three previously mentionned application files. By doing so we make the gamemode much
	easier to expand upon, much easier to see what is going on in the grand scheme of things, and
	much easier to later change with another addon.

-----------------------------------------------------------------------------------------------

	About third party code:

		While this is a recode of Bad King Urgrain's original gamemode a decent bit of his code
	has been adapted into here. I try to credit him where possible but if some uncreditted snippet
	of code seems to be taken from the original TTT please know I by no means intend to take credit
	for his work. If that is ever the case with the original TTT's code or any other third party
	code used in this gamemode please let me know in a pull request and I'll credit it. I'll
	usually credit other people's work in the documentation right above the declaration of their
	code.

	- Stalker
]]

GM.Name = "Trouble in Terrorist Town Two"
GM.Author = "George 'Stalker' Petrou"
GM.Email = "N/A"
GM.Website = "N/A"
TTT.Version = 20190225					-- YearMonthDay
DEFINE_BASECLASS("gamemode_base")

hook.Add("TTT.PreLibraryLoaded", "TTT", function()
	hook.Remove("PlayerTick", "TickWidgets")	-- Why does this even run on the base gamemode.

	if SERVER then
		TTT.Library.InitSQL()	-- Load information from the SQLite database.
	end
end)

GM:LoadLibraries()	-- Load the gamemode's library. Also gets called on auto-refresh to reload library.

-- PLAYER.Alive now returns true if the player is not spectating, is alive, and not in fly mode.
-- Clientside the only person they'll know if they're in fly mode or not is themselves so this will be false for everyone else.
local PLAYER = FindMetaTable("Player")
TTT.OldAlive = TTT.OldAlive or PLAYER.Alive
function PLAYER:Alive()
	if self:IsSpectator() or self:IsInFlyMode() then
		return false
	end
	return TTT.OldAlive(self)
end

--------------------------
-- General Gamemode Hooks
--------------------------
function GM:Initialize()
	math.randomseed(os.time())
	
	TTT.Languages.Initialize()			-- Load the languages.
	TTT.Weapons.RedirectMapEntities()	-- Swap non-TTT entities with TTT entities.
	TTT.VGUI.Initialize()				-- Get their HUDs working.
	TTT.Scoreboard.Initialize()			-- Load up the scoreboard.
	TTT.Equipment.Initialize()			-- Load up equipment.
	TTT.Notifications.Initialize()		-- Initialize standard notifications.

	if SERVER then
		RunConsoleCommand("mp_friendlyfire", "1")	-- Enables lag compensation.
		TTT.Player.Initialize()			-- Select the player models for the map.
	end
	
	TTT.Rounds.Initialize()				-- Begin the round managing system.	
end

function GM:InitPostEntity()
	TTT.Weapons.CreateCaches()		-- Cache some weapons for quick retrieval later.

	if SERVER then
		TTT.Player.CreateDrownDamageInfo()	-- Create the drown damage info once now so we don't have to later.
		TTT.Weapons.LoadImportWeaponsScript()	-- If one exists, load up the weapon import script for the map.
	end

	if CLIENT and ((TTT.Rounds.IsWaiting() or TTT.Rounds.IsPrep()) and not LocalPlayer():IsSpectator()) then
		LocalPlayer():SetInFlyMode(true)
	end
end

----------------
-- Entity Hooks
----------------
hook.Add("TTT.Weapons.ShouldRedirectWeapons", "TTT", function()
	return true
end)

---------------
-- Round Hooks
---------------
hook.Add("TTT.Rounds.StateChanged", "TTT", function(state)
	if state == ROUND_WAITING then
		for k = 1, player.GetCount() do
			local v = player.GetAll()[k]
			if not v:IsSpectator() then
				v:SetRole(ROLE_WAITING)
			end
			if CLIENT then
				TTT.Scoreboard.ClearTag(v)
			end
		end
	elseif state == ROUND_PREP then
		if CLIENT then
		for k = 1, player.GetCount() do
				TTT.Scoreboard.ClearTag(player.GetAll()[k])
			end
		end
		
		TTT.Corpse.ResetBodyStatuses()
	end
end)

------------------
-- Movement Hooks
------------------
function GM:SetupMove(ply, mv)
	TTT.Player.SetupMovement(ply, mv)
end

----------------------
-- Notification Hooks
----------------------
hook.Add("TTT.Notifications.InitStandardMessages", "TTT", function()
	TTT.Notifications:AddStandardMsg("START_INNOCENT", "notification_start_innocent")
	TTT.Notifications:AddStandardMsg("START_DETECTIVE", "notification_start_detective", function()
		return "BUTTON"
	end)
	TTT.Notifications:AddStandardMsg("START_TRAITOR_MULTI", "notification_start_traitor_multi", function()
		return "BUDDIES", "TBUTTON"
	end)
	TTT.Notifications:AddStandardMsg("START_TRAITOR_SOLO", "notification_start_traitor_solo", function()
		return "TBUTTON"
	end)
	--TTT.Notifications:AddStandardMsg("START_DURATION", "notification_start_duration")
end)











