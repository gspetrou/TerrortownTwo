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

hook.Add("TTT.Scoreboard.InitializeItems", "TTT", function(panel)
	--------------
	-- COLUMNS
	--------------
	TTT.Scoreboard.AddColumn("karma", "sb_karma", 50, 10, function(ply)
		return 1337
	end)

	TTT.Scoreboard.AddColumn("score", "sb_score", 50, 20, function(ply)
		return ply:Frags()
	end, function(plyA, plyB)
		return plyA:Frags() < plyB:Frags()
	end)

	TTT.Scoreboard.AddColumn("deaths", "sb_deaths", 50, 30, function(ply)
		return ply:Deaths()
	end, function(plyA, plyB)
		return plyA:Deaths() < plyB:Deaths()
	end)

	TTT.Scoreboard.AddColumn("ping", "sb_ping", 50, 40, function(ply)
		return ply:Ping()
	end, function(plyA, plyB)
		return plyA:Ping() < plyB:Ping()
	end)

	------------
	-- GROUPS
	------------
	TTT.Scoreboard.AddGroup("terrorists", "sb_terrorists", 10, Color(40, 200, 40, 100), function(ply)
		return ply:Alive()
	end, function(pnl, ply)
		--
	end)
/*
	--TTT.Scoreboard.AddGroup("missing", "sb_missing", 20, Color(130, 190, 130, 100), function(ply) return false end)

	TTT.Scoreboard.AddGroup("dead", "sb_dead", 30, Color(130, 170, 10, 100), function(ply)
		return ply:IsConfirmedDead()
	end)
*/
	TTT.Scoreboard.AddGroup("spectators", "sb_spectators", 40, Color(200, 200, 0, 100), function(ply)
		return ply:IsSpectator()
	end)

	-------------------
	-- EXTRA SORTING
	-------------------
	TTT.Scoreboard.AddExtraSortingOption("name", "sb_name", 10, function(plyA, plyB)
		return string.lower(plyA:Nick()) > string.lower(plyB:Nick())
	end)
	TTT.Scoreboard.AddExtraSortingOption("role", "sb_role", 20, function(plyA, plyB)
		return plyA:GetRole() > plyB:GetRole()
	end)
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