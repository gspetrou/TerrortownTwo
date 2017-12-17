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

hook.Add("TTT.Scoreboard.InitializeColumns", "TTT", function(panel)
	TTT.Scoreboard.AddColumn("karma", "sb_karma", 50, 10, function(ply)
		--return ply:GetKarma()
		return 1337
	end)

/*	TTT.Scoreboard.AddColumn("score", "sb_score", 50, 20, function(ply)
		--return ply:GetScore()
		return 6969
	end)

	TTT.Scoreboard.AddColumn("deaths", "sb_deaths", 50, 30, function(ply)
		return ply:Deaths()
	end)

	TTT.Scoreboard.AddColumn("ping", "sb_ping", 50, 40, function(ply)
		return ply:Ping()
	end)*/
end)

hook.Add("TTT.Scoreboard.InitializeGroups", "TTT", function(panel)
	TTT.Scoreboard.AddGroup("terrorists", "sb_terrorists", 10, function(ply)
		return ply:Alive()
	end)
/*
	--TTT.Scoreboard.AddGroup("missing", "sb_missing", 20, function(ply) return false end)

	TTT.Scoreboard.AddGroup("dead", "sb_dead", 30, function(ply)
		return not ply:Alive()
	end)
*/
	TTT.Scoreboard.AddGroup("spectators", "sb_spectators", 40, function(ply)
		return ply:IsBot()
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