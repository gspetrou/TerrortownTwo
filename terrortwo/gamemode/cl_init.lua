TTT = TTT or {}

TTT.VGUIElements = TTT.VGUIElements or {}
function TTT.AddVGUIElement(name, func)
	TTT.VGUIElements[name] = func
end

-- Since HUDPaint is called so much might as well micro-optimize.
local LocalPlayer, pairs, hookCall = LocalPlayer, pairs, hook.Call
function GM:HUDPaint()
	local ply = LocalPlayer()

	for k, v in pairs(TTT.VGUIElements) do
		if hookCall("HUDShouldDraw", self, k) then
			v(ply)
		end
	end
end

local disabled = {
	CHudHealth = true,
	CHudBattery = true,
	CHudAmmo = true,
	CHudSecondaryAmmo = true
}
function GM:HudShouldDraw(name)
	return not disabled[name]
end

include("lib.lua")
include("shared.lua")