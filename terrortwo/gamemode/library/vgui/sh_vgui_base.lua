-- Handles the drawing of all non-derma VGUI.
TTT.VGUI = TTT.VGUI or {}

if CLIENT then
	TTT.VGUI.Elements = TTT.VGUI.Elements or {}

	surface.CreateFont("TTT_HudText", {
		font = "Trebuchet24",
		size = 30,
		weight = 800
	})

	surface.CreateFont("TTT_WeaponSwitchText", {
		font = "Trebuchet22",
		size = 22,
		weight = 800
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
	-- Load files in addons/library/vgui/vgui.
	local path = "library/vgui/vgui/"
	local loadedfiles = {}
	local files, _ = file.Find(path.."*.lua", "LUA")
	for i, v in ipairs(files) do
		if SERVER then
			AddCSLuaFile(path..v)
		else
			include(path..v)
		end
		loadedfiles[v] = true
	end

	-- Now load files in terrortwo/gamemode/ibrary/vgui/vgui and if there
	-- are files with same names as the ones in the addons folder then skip over it.
	path = GAMEMODE.FolderName.."/gamemode/library/vgui/vgui/"
	files, _ = file.Find(path.."*.lua", "LUA")
	for i, v in ipairs(files) do
		if not loadedfiles[v] then
			if SERVER then
				AddCSLuaFile(path..v)
			else
				include(path..v)
			end
			loadedfiles[v] = true
		end
	end
end
