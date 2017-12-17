include("library/_prelib.lua")	-- Will load the library for us.
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

function GM:HUDDrawScoreBoard()
end

function GM:ScoreboardShow()
	TTT.Scoreboard.Open()
end

function GM:ScoreboardHide()
	TTT.Scoreboard.Close()
end

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