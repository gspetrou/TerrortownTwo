GM.Name = "Trouble in Terrorist Town Two"
GM.Author = "Stalker"
GM.Email = "N/A"
GM.Website = "N/A"

DEFINE_BASECLASS("gamemode_base")
local debugmode = CreateConVar("ttt_debug_prints", "1", nil, "Enables debug prints.")

local function SetupFile(path, prefix)
	if prefix == "sv_" then
		if SERVER then
			include(path)
		end
	elseif prefix == "cl_" then
		if SERVER then
			AddCSLuaFile(path)
		else
			include(path)
		end
	else
		if SERVER then
			AddCSLuaFile(path)
		end
		include(path)
	end
end

GM.Modules = {}

-- Loads stock gamemode modules and addon modules.
-- Addon modules with the same name as stock modules replace the stock module.
function GM:LoadModules()
	local _, addon_module_folders = file.Find("modules/*", "LUA")
	for _, v in ipairs(addon_module_folders) do
		if not GM.Modules[v] then
			GM.Modules[v] = true

			local addon_module_files = file.Find("modules/"..v.."/*.lua", "LUA")
			for _, j in ipairs(addon_module_files) do
				SetupFile("modules/"..v.."/"..j, j:sub(1, 3))
			end
		elseif debugmode:GetBool() then
			DebugPrint("Module with the name '"..v.."' already has been mounted.")
		end
	end

	local root = self.FolderName.."/gamemode/modules/"
	local _, gm_module_folders = file.Find(root.."*", "LUA")
	for _, v in ipairs(gm_module_folders) do
		if not GM.Modules[v] then
			GM.Modules[v] = true

			local gm_module_files = file.Find(root..v.."/*.lua", "LUA")
			for _, j in ipairs(gm_module_files) do
				SetupFile(root..v.."/"..j, j:sub(1, 3))
			end
		elseif debugmode:GetBool() then
			DebugPrint("Module with the name '"..v.."' already has been mounted.")
		end
	end

	hook.Call("TTT_PostModulesLoaded", GM)
end

GM:LoadModules()

if not file.IsDir("ttt", "DATA") then
	file.CreateDir("ttt")
end