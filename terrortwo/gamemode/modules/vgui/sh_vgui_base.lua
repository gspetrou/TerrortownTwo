-- Handles the drawing of all non-derma VGUI.
TTT.VGUI = TTT.VGUI or {}

if CLIENT then
	TTT.VGUI.Elements = TTT.VGUI.Elements or {}
	function TTT.VGUI.AddElement(name, func, condition)
		TTT.VGUI.Elements[name] = {func, condition}
	end

	-- Since HUDPaint is called so much might as well micro-optimize.
	local LocalPlayer, pairs, hookCall, ScrW, ScrH, IsValid = LocalPlayer, pairs, hook.Call, ScrW, ScrH, IsValid
	function GM:HUDPaint()
		local ply, w, h = LocalPlayer(), ScrW(), ScrH()

		-- To prevent some retardation caused by Gmod when players are initializing.
		if not IsValid(ply) then
			return
		end

		for k, v in pairs(TTT.VGUI.Elements) do
			if hookCall("HUDShouldDraw", self, k) and v[2](ply) then
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

	function GM:HUDShouldDraw(name)
		return not disabled[name]
	end
end

hook.Add("TTT_PostModulesLoaded", "TTT_VGUI_Initialize", function()
	-- Same exact way module loading works.
	local path = "modules/vgui/vgui/"
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


	path = GM.FolderName.."/gamemode/modules/vgui/vgui/"
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
end)