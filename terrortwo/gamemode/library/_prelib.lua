TTT = TTT or {}
TTT.Library = TTT.Library or {}
TTT.Debug = TTT.Debug or {}

-------------------------
-- TTT.Debug.IsDebugMode
-------------------------
-- Desc:		Returns if debug mode is enabled or not.
-- Returns:		Boolean, is debug mode enabled.
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
	if not TTT.Debug.IsDebugMode() then
		return
	end

	MsgC(Color(210, 20, 20), "TTT DEBUG: ", color_white, text.."\n")

	text = os.date("%d/%m/%Y - %H:%M:%S", os.time()).."\t"..text.."\n"
	if not file.Exists("ttt/debug_prints.txt", "DATA") then
		file.Write("ttt/debug_prints.txt", text)
	else
		file.Append("ttt/debug_prints.txt", text)
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
-- Desc:		Loads the library folder containning the library used by the gamemode. Loads util.lua first.
function TTT.Library.Initialize()
	local rootPath = GAMEMODE.FolderName .."/gamemode/library/"
	TTT.Library.SetupFile(rootPath .."util.lua")

	local miscFiles, folders = file.Find(rootPath .."*", "LUA")
	for i, v in ipairs(miscFiles) do
		if v:sub(1, 1) ~= "_" then
			TTT.Library.SetupFile(rootPath .. v, v:sub(1, 3))

			TTT.Debug.Print("Loaded libary file '".. rootPath .. v .."'.")
		end
	end

	for i, v in ipairs(folders) do
		local rootPathAndFolder = rootPath .. v
		local files = file.Find(rootPathAndFolder .."/*.lua", "LUA")
		for j, d in ipairs(files) do
			TTT.Library.SetupFile(rootPathAndFolder .."/".. d, d:sub(1, 3))

			TTT.Debug.Print("Loaded libary file '".. rootPathAndFolder .."/".. d .."'.")
		end
	end

	hook.Call("TTT.PostLibariesLoaded")
	TTT.LibrariesInitiallyLoaded = true
end