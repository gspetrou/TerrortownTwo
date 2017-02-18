include("library/_prelib.lua")	-- All we need to include library-wise.
include("shared.lua")

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
	print("dick")
end

function GM:ScoreboardHide()
	print("titss")
end