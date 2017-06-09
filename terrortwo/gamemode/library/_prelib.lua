TTT = TTT or {}
TTT.Library = TTT.Library or {}
TTT.Debug = TTT.Debug or {}

-- Thanks TTT.
TTT.Colors = {
	Dead		= Color(90, 90, 90, 230),
	Innocent	= Color(39, 174, 96, 230),
	Detective	= Color(41, 128, 185, 230),
	Traitor		= Color(192, 57, 43, 230),
	PunchYellow	= Color(205, 155, 0),

	White		= Color(255, 255, 255),
	Black		= Color(0, 0, 0),
	Green		= Color(0, 255, 0),
	DarkGreen	= Color(0, 100, 0),
	Red			= Color(255, 0, 0),
	Yellow		= Color(200, 200, 0),
	LightGray	= Color(200, 200, 200),
	Blue		= Color(0, 0, 255),
	Navy		= Color(0, 0, 100),
	Pink		= Color(255, 0, 255),
	Orange		= Color(250, 100, 0),
	Olive		= Color(100, 100, 0)
}

if not file.IsDir("ttt", "DATA") then
	file.CreateDir("ttt")			-- Create a data folder to store anything we may want to later.
end

function GM:LoadLibraries()
	TTT.Library.Initialize()			-- Load the libraries.
end

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
	local rootPath = GM.FolderName.."/gamemode/library/"
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