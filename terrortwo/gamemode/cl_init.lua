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
	print("a")
end

function GM:ScoreboardHide()
	print("b")
end

---------------
-- Round Hooks
---------------
hook.Add("TTT.Rounds.MapEnded", "TTT", function(wintype)

end)