-- Handles the drawing of all non-derma VGUI.
TTT.VGUI = TTT.VGUI or {}

if CLIENT then
	TTT.VGUI.Elements = TTT.VGUI.Elements or {}

	surface.CreateFont("TTT_HudText", {
		font = "Verdana",
		size = 28,
		weight = 900
	})

	surface.CreateFont("TTT_WeaponSwitchText", {
		font = "Verdana",
		size = 20,
		weight = 900
	})

	-----------------------
	-- TTT.VGUI.AddElement
	-----------------------
	-- Desc:		Adds a hud element.
	-- Arg One:		String. A unique and simple name for the panel.
	-- Arg Two:		Function, what should we draw. Called with the localplayer, screen width, and screen height as arguements.
	-- Arg Three:	Function, called to see if this panel should be drawn. First arguement of this function is the localplayer.
	function TTT.VGUI.AddElement(name, func, condition)
		TTT.VGUI.Elements[name] = {func, condition}
	end

	-- Since HUDPaint is called so much might as well micro-optimize.
	local LocalPlayer, pairs, ScrW, ScrH = LocalPlayer, pairs, ScrW, ScrH
	
	---------------------
	-- TTT.VGUI.HUDPaint
	---------------------
	-- Desc:		Called to paint all the huds.
	function TTT.VGUI.HUDPaint()
		local ply, w, h = LocalPlayer(), ScrW(), ScrH()
		local isspecmode = ply:GetObserverMode() ~= OBS_MODE_NONE

		for k, v in pairs(TTT.VGUI.Elements) do
			if v[2](ply, isspecmode) then
				v[1](ply, w, h, isspecmode)
			end
		end
	end

	local disabled = {
		CHudHealth = true,
		CHudBattery = true,
		CHudAmmo = true,
		CHudSecondaryAmmo = true
	}
	--------------------------
	-- TTT.VGUI.HUDShouldDraw
	--------------------------
	-- Desc:		Should the HUD with the given name be drawn.
	-- Arg One:		String, name of a VGUI panel.
	function TTT.VGUI.HUDShouldDraw(name)
		return not disabled[name]
	end
end

-----------------------
-- TTT.VGUI.Initialize
-----------------------
-- Protip:		If you're working on your own HUD, rather than constantly changing maps simply call this function to refresh your HUD.
function TTT.VGUI.Initialize()
	TTT.Library.LoadOverridableFolder("library/vgui/vgui/", "ttt/vgui/", "client")
end
