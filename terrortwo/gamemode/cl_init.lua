include("library/_prelib.lua")	-- Will load the library for us.
include("shared.lua")

--------------------------
-- General Gamemode Hooks
--------------------------
function GM:InitPostEntity()
	TTT.Roles.InitializeSpectator()
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

end)end)

----------------
-- Weapon Hooks
----------------
function GM:OnSpawnMenuOpen()
	TTT.Weapons.RequestDropCurrentWeapon()
	return false
end