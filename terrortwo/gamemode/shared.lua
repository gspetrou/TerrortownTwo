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
TTT.Version = 20180523					-- YearMonthDay
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
		for i, v in ipairs(player.GetAll()) do
			if not v:IsSpectator() then
				v:SetRole(ROLE_WAITING)
			end
			if CLIENT then
				TTT.Scoreboard.ClearTag(v)
			end
		end
	elseif state == ROUND_PREP then
		if CLIENT then
			TTT.Notifications:Clear()
			for i, v in ipairs(player.GetAll()) do
				TTT.Scoreboard.ClearTag(v)
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
-- TODO: Finish this
hook.Add("TTT.Notifications.InitStandardMessages", "TTT", function()
	-- AFK warning.
	TTT.Notifications:AddStandardMsg("AFK_WARNING", "ntfc_idle_warning")

	-- Body messages.
	--TTT.Notifications:AddStandardMsg("BODY_FOUND", "ntfc_body_found", function()end)
	--TTT.Notifications:AddStandardMsg("BODY_CONFIRM", "ntfc_body_confirm", function()end)
	TTT.Notifications:AddStandardMsg("BODY_CALL_ERROR", "ntfc_body_call_error")
	TTT.Notifications:AddStandardMsg("BODY_CREDITS", "ntfc_body_credits")

	-- Round messages.
	TTT.Notifications:AddStandardMsg("START_TRAITOR_SOLO", "ntfcn_start_traitor_solo", nil, nil, Color(255, 0, 0, 200))
	TTT.Notifications:AddStandardMsg("START_TRAITOR_MULTI", "ntfcn_start_traitor_multi", function()
		local output = ""
		for i, ply in ipairs(player.GetAll()) do
			if ply ~= LocalPlayer() and ply:IsTraitor() then
				output = output..ply:Nick()..", "
			end
		end

		return string.sub(output, 1, #output-2)
	end, nil, Color(255, 0, 0, 200))
	TTT.Notifications:AddStandardMsg("ROUND_NOTENOUGH_PLAYERS", "ntfc_round_minplayers")
	--TTT.Notifications:AddStandardMsg("ROUND_MAPVOTE", "ntfc_round_voting")
	--TTT.Notifications:AddStandardMsg("ROUND_BEGINS_IN", "ntfc_round_begintime")
	TTT.Notifications:AddStandardMsg("ROUND_TRAITORS_SELECTED", "ntfc_round_selected")
	TTT.Notifications:AddStandardMsg("ROUND_BEGAN", "ntfcn_round_start")

	TTT.Notifications:AddStandardMsg("ROUND_WIN_TIME", "ntfcn_win_time")
	TTT.Notifications:AddStandardMsg("ROUND_WIN_TRAITORS", "ntfcn_win_traitor")
	TTT.Notifications:AddStandardMsg("ROUND_WIN_INNOCENTS", "ntfcn_win_innocent")
	--TTT.Notifications:AddStandardMsg("ROUND_SHOW_REPORT", "ntfcn_win_showreport")

	--TTT.Notifications:AddStandardMsg("ROUND_ROUND_LIMIT", "ntfcn_limit_round")
	--TTT.Notifications:AddStandardMsg("ROUND_TIME_LIMIT", "ntfcn_limit_time")
	--TTT.Notifications:AddStandardMsg("ROUND_TIME_LEFT", "ntfcn_limit_left")

	-- Karma messages
	TTT.Notifications:AddStandardMsg("KARMA_DEAL_FULL_DMG", "ntfc_karma_dmg_full")
	TTT.Notifications:AddStandardMsg("KARMA_DEAL_LESS_DMG", "ntfc_karma_dmg_other")

	-- Weapon messges
	TTT.Notifications:AddStandardMsg("WEAPON_STORE_NO_STOCK", "ntfc_store_buy_no_stock")
	TTT.Notifications:AddStandardMsg("WEAPON_STORE_RECEIVED", "ntfc_store_buy_received")

	-- Store messages
	-- TODO: Should be role colors
	TTT.Notifications:AddStandardMsg("CRED_TRANSFER_NO_RECIP", "ntfc_transfer_no_recip")
	TTT.Notifications:AddStandardMsg("CRED_TRANSFER_NO_CREDITS", "ntfc_transfer_no_credits")
	--TTT.Notifications:AddStandardMsg("CRED_TRANSFER_SUCCESS", "ntfc_transfer_success")
	--TTT.Notifications:AddStandardMsg("CRED_TRANSFER_RECEIVED", "ntfc_transfer_received")
	--TTT.Notifications:AddStandardMsg("DET_CREDIT_REWARD", "ntfcn_credit_det_all")
	--TTT.Notifications:AddStandardMsg("TR_CREDIT_REWARD", "ntfcn_credit_tr_all")
	--TTT.Notifications:AddStandardMsg("CRED_REWARD_FOR_KILLING", "ntfcn_credit_kill")
end)
