-- Handles the drawing of all non-derma VGUI.
TTT.VGUI = TTT.VGUI or {}

if CLIENT then
	TTT.VGUI.Elements = TTT.VGUI.Elements or {}
	function TTT.VGUI.AddElement(name, func, condition)
		TTT.VGUI.Elements[name] = {func, condition}
	end

	-- Since HUDPaint is called so much might as well micro-optimize.
	local LocalPlayer, pairs, hookCall, ScrW, ScrH = LocalPlayer, pairs, hook.Call, ScrW, ScrH
	function TTT.VGUI.HUDPaint()
		local ply, w, h = LocalPlayer(), ScrW(), ScrH()

		for k, v in pairs(TTT.VGUI.Elements) do
			if TTT.VGUI.HUDShouldDraw(k) and v[2](ply) then
				v[1](ply, w, h)
			end
		end
	end

	local disabled = {
		CHudHealth = true,
		CHudBattery = true,
		CHudAmmo = true,
		CHudSecondaryAmmo = true
	}
	function TTT.VGUI.HUDShouldDraw(name)
		return not disabled[name]
	end
end

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
		print(path..v)
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
