TTT = TTT or {}
TTT.Library = TTT.Library or {}
TTT.Debug = TTT.Debug or {}

-------------------------
-- TTT.Debug.IsDebugMode
-------------------------
-- Desc:		Returns if debug mode is enabled or not.
-- ReturnsL		Boolean, is debug mode enabled.
local debugmode = CreateConVar("ttt_debug_prints", "0", nil, "Enables debug prints.")
function TTT.Debug.IsDebugMode()
	return debugmode:GetBool()
end

-------------------
-- TTT.Debug.Print
-------------------
-- Desc:		Prints and logs debug info.
-- Arg One:		String, text to print.
function TTT.Debug.Print(text)
	MsgC(Color(210, 20, 20), "TTT DEBUG: ", color_white, text.."\n")

	text = os.date("%d/%m/%Y - %H:%M:%S", os.time()).."\t"..text.."\n"
	if not file.Exists("ttt/debug_prints.txt", "DATA") then
		file.Write("ttt/debug_prints.txt", text)
	else
		file.Append("ttt/debug_prints.txt", text)
	end
end

-------------------
-- net.WritePlayer
-------------------
-- Desc:		A more optimized version of net.WriteEntity specifically for players.
-- Arg One:		Player entity to be networked.
if not net.WritePlayer then
	function net.WritePlayer(ply)
		if IsValid(ply) then
			net.WriteUInt(ply:EntIndex(), 7)
		else
			net.WriteUInt(0, 7)
		end
	end
end

------------------
-- net.ReadPlayer
------------------
-- Desc:		Optimized version of net.ReadEntity specifically for players.
-- Returns:		Player entity thats been written.
if not net.ReadPlayer then
	function net.ReadPlayer()
		local i = net.ReadUInt(7)
		if not i then
			return
		end
		return Entity(i)
	end
end

-------------------------
-- TTT.Library.SetupFile
-------------------------
-- Desc:		Given a file's path and the file's prefix will include/AddCSLua the file.
-- Arg One:		String, path to the file.
-- Arg Two:		String, three character prefix to the file.
function TTT.Library.SetupFile(path, prefix)
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

--------------------------
-- TTT.Library.Initialize
--------------------------
-- Desc:		Loads the library folder containning the library used by the gamemode.
function TTT.Library.Initialize()
	local rootPath = GAMEMODE.FolderName .."/gamemode/library/"
	local miscFiles, folders = file.Find(rootPath .."*", "LUA")
	for i, v in ipairs(miscFiles) do
		if v:sub(1, 1) ~= "_" then
			TTT.Library.SetupFile(rootPath .. v, v:sub(1, 3))

			if TTT.Debug.IsDebugMode() then
				TTT.Debug.Print("Loaded libary file '".. rootPath .. v .."'.")
			end
		end
	end

	for i, v in ipairs(folders) do
		local rootPathAndFolder = rootPath .. v
		local files = file.Find(rootPathAndFolder .."/*.lua", "LUA")
		for j, d in ipairs(files) do
			TTT.Library.SetupFile(rootPathAndFolder .."/".. d, d:sub(1, 3))

			if TTT.Debug.IsDebugMode() then
				TTT.Debug.Print("Loaded libary file '".. rootPathAndFolder .."/".. d .."'.")
			end
		end
	end

	hook.Call("TTT.PostLibariesLoaded")
end