include("util.lua")			-- Mini utility library to load beforehand and be used throughought the gamemode.
include("lib_loader.lua")	-- Loads the library loader
include("shared.lua")

--------------------------
-- General Gamemode Hooks
--------------------------
-- I hooked onto PlayerBindPress this way rather than through the GM table so that other addons can easily disable this.
hook.Add("PlayerBindPress", "TTT", function(ply, bind, pressed)
	return TTT.VGUI.WeaponSwitcherHandler(ply, bind, pressed)
end)

-- If a player joins mid round, make them a spectator. This will last till the next role sync, usually when the round is over.
hook.Add("OnEntityCreated", "TTT", function(ent)
	if ent:IsPlayer() and TTT.Rounds.IsActive() then
		ent:SetRole(ROLE_SPECTATOR)
	end
end)

function GM:CalcView(ply, o, a, f)
	local view = {
		origin = o,
		angles = a,
		fov = f
	}

	-- If we are "in eye" spectating a ragdoll (i.e. corpse) then actually look from their eye.
	-- Tables are passed by reference in Lua so the view table is being modified in this function.
	TTT.Player.ModifyRagdollInEyeView(ply, view)	

	return view
end

function GM:CreateMove(cmd)
	TTT.Player.DisableCrouchInFreeRoam(cmd)	-- Fixes weird twitch when hitting IN_DUCK while in free cam sometimes.
end

------------
-- UI Hooks
------------
local IsValid, LocalPlayer = IsValid, LocalPlayer
function GM:HUDPaint()
	if not IsValid(LocalPlayer()) then
		return
	end

	TTT.VGUI.HUDPaint()
end

function GM:HUDShouldDraw(name)
	if not IsValid(LocalPlayer()) then
		return false
	end

	return TTT.VGUI.HUDShouldDraw(name)
end

--------------------
-- Scoreboard Hooks
--------------------
function GM:HUDDrawScoreBoard()
end

function GM:ScoreboardShow()
	TTT.Scoreboard.Open()
end

function GM:ScoreboardHide()
	TTT.Scoreboard.Close()
end

hook.Add("TTT.Scoreboard.Initialize", "TTT", function()
	--------------
	-- COLUMNS
	--------------
	if TTT.Karma:IsEnabled() then
		TTT.Scoreboard.AddColumn("karma", "sb_karma", 50, 10, function(ply)
			return ply:GetBaseKarma()
		end)
	end

	TTT.Scoreboard.AddColumn("score", "sb_score", 50, 20, function(ply)
		return ply:Frags()
	end, function(plyA, plyB)
		return plyA:Frags() - plyB:Frags()
	end)

	TTT.Scoreboard.AddColumn("deaths", "sb_deaths", 50, 30, function(ply)
		return ply:Deaths()
	end, function(plyA, plyB)
		return plyA:Deaths() - plyB:Deaths()
	end)

	TTT.Scoreboard.AddColumn("ping", "sb_ping", 50, 40, function(ply)
		return ply:Ping()
	end, function(plyA, plyB)
		return plyA:Ping() - plyB:Ping()
	end)

	------------
	-- GROUPS
	------------
	TTT.Scoreboard.AddGroup("terrorists", "sb_terrorists", Color(40, 200, 40, 100), 10, function(ply)
		return ply:Alive()
	end, TTT.Scoreboard.DrawTags, 40)

	TTT.Scoreboard.AddGroup("missing", "sb_missing", Color(130, 190, 130, 100), 20, function(ply)
		return ply:IsMissing()
	end)

	TTT.Scoreboard.AddGroup("dead", "sb_dead", Color(130, 170, 10, 100), 30, function(ply)
		return ply:IsConfirmedDead()
	end)

	TTT.Scoreboard.AddGroup("spectators", "sb_spectators", Color(200, 200, 0, 100), 40, function(ply)
		return ply:IsSpectator() or ply:IsWaiting()
	end)

	-------------------
	-- EXTRA SORTING
	-------------------
	TTT.Scoreboard.AddExtraSortingOption("name", "sb_name", 10, function(plyA, plyB)
		return 0	-- Returning 0 in this function defaults to sorting by name.
	end)
	TTT.Scoreboard.AddExtraSortingOption("role", "sb_role", 20, function(plyA, plyB)
		return plyA:GetRole() - plyB:GetRole()
	end)

	---------------
	-- INFO TAGS
	---------------
	TTT.Scoreboard.AddTag("sb_tag_friend", TTT.Colors.Green)
	TTT.Scoreboard.AddTag("sb_tag_suspect", TTT.Colors.Yellow)
	TTT.Scoreboard.AddTag("sb_tag_avoid", Color(255, 150, 0, 255))
	TTT.Scoreboard.AddTag("sb_tag_kill", TTT.Colors.Red)
	TTT.Scoreboard.AddTag("sb_tag_missing", Color(130, 190, 130, 255))
end)

hook.Add("TTT.Roles.Changed", "TTT", function(ply)
	ply:SetScoreboardRowOpen(false)		-- Close that player's scoreboard row if its open.
	TTT.Scoreboard.ClearTag(ply)		-- Clear player's tags.
end)

---------------
-- Round Hooks
---------------
hook.Add("TTT.Rounds.MapEnded", "TTT", function(wintype)
	-- Map stuff here
end)

----------------
-- Weapon Hooks
----------------
function GM:OnSpawnMenuOpen()
	TTT.Weapons.RequestDropCurrentWeapon()
	return false
end

-------------------
-- Key Input Hooks
-------------------
function GM:PlayerBindPress(ply, bind, pressed)
	if bind == "+use" and pressed then
		if not ply:Alive() then
			TTT.Player.AttemptInspectObject()	-- Will see if theres anything in front of the player to spectate or search (if its a body).
			return true
		elseif ply:IsTraitor() and TTT.Map.TraitorButtons:IsHovered() then
			TTT.Map.TraitorButtons:UseHoveredButton()
			return true
		end
	elseif (bind == "gmod_undo" or bind == "undo") and pressed then
		TTT.Weapons.RequestDropCurrentAmmo()
		return true
	end
end

---------------------
-- Player Animations
---------------------
function GM:UpdateAnimation(ply, vel, maxseqgroundspeed)
	ply:AnimUpdateGesture()

	return self.BaseClass.UpdateAnimation(self, ply, vel, maxseqgroundspeed)
end

function GM:GrabEarAnimation(ply) end