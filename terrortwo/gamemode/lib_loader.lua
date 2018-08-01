-- This file loads the library loader and makes some useful debug functions.
TTT.Library = TTT.Library or {}
TTT.Debug = TTT.Debug or {}

-------------------------
-- TTT.Debug.IsDebugMode
-------------------------
-- Desc:		Returns if debug mode is enabled or not.
-- Returns:		Boolean, is debug mode enabled.
local debugmode = CreateConVar("ttt_debug_prints", "0", FCVAR_ARCHIVE, "Enables debug prints.")
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

-----------------------
-- TTT.Library.InitSQL
-----------------------
-- Desc:		Checks and creates the SQL table for the gamemode if need be.
function TTT.Library.InitSQL()
	sql.Query([[CREATE TABLE IF NOT EXISTS `ttt` (
		`id` INT UNSIGNED,
		`karma` INT,
		`is_spec` BOOL,
		PRIMARY KEY (id)
	);]])
end

---------------------------------
-- TTT.Library.InitPlayerSQLData
---------------------------------
-- Desc:		Initializes the given player's row in the SQL table.
-- Player:		Player to initialize in the SQL table.
function TTT.Library.InitPlayerSQLData(ply)
	local result = sql.Query("SELECT * from `ttt` WHERE id=".. sql.SQLStr(ply:SteamID64()) ..";")
	if not result then
		sql.Query("INSERT INTO ttt (id, karma, is_spec) VALUES (".. sql.SQLStr(ply:SteamID64()) ..", ".. 1000 ..", ".. 0 ..");")
	end
end

-------------------------------------
-- TTT.Library.LoadOverridableFolder
-------------------------------------
-- Desc:		Loads files from a given folder in the addons directory and records the file name.
-- 				Then loads files from the given directory in the gamemode and records the file name.
-- 				If the file name of a file found in the gamemodes folder is the same as an addon's file name, it will not be loaded.
-- Arg One:		String, path to gamemode folder to load. Starts at garrysmod/GAMEMODENAME/gamemode/.
-- Arg Two:		String, path to addon folder to load. Starts at garrysmod/addons/*/lua/.
-- Arg Three:	String, realm to load the file. "client" for client files, "server" for server files, "shared" for shared files.
local loadFunctions = {
	client = function(path)
		if SERVER then
			AddCSLuaFile(path)
		else
			include(path)
		end
	end,
	server = function(path) include(path) end,
	shared = function(path)
		if SERVER then
			AddCSLuaFile(path)
		end
		include(path)
	end
}
function TTT.Library.LoadOverridableFolder(localpath, addonpath, realm)
	local loadedfiles = {}
	local loadFn = loadFunctions[realm]
	if not isfunction(loadFn) then
		error("Tried to call TTT.Library.LoadOverridableFolder with invalid realm '"..realm.."'.")
	end

	-- Load files in garrysmod/addons/*/lua/addonpath/
	local files, _ = file.Find(addonpath.."*.lua", "LUA")
	for i, v in ipairs(files) do
		loadFn(addonpath..v)
		loadedfiles[v] = true
	end

	-- Now load files in gamemodename/gamemode/localpath/ and if there
	-- are files with same names as the ones in the addons folder then skip over it.
	local path = GAMEMODE.FolderName.."/gamemode/"..localpath
	files, _ = file.Find(path.."*.lua", "LUA")
	for i, v in ipairs(files) do
		if not loadedfiles[v] then
			loadFn(path..v)
			loadedfiles[v] = true
		end
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
	local rootPath = (istable(GM) and GM.FolderName or GAMEMODE.FolderName).."/gamemode/library/"
	local miscFiles, folders = file.Find(rootPath .."*", "LUA")

	-- Load misc files in library/
	for i, v in ipairs(miscFiles) do
		if v:sub(1, 1) ~= "_" then
			TTT.Library.SetupFile(rootPath .. v, v:sub(1, 3))

			TTT.Debug.Print("Loaded libary file '".. rootPath .. v .."'.")
		end
	end

	-- Load files inside folder of library/
	for i, v in ipairs(folders) do
		local rootPathAndFolder = rootPath .. v
		local files = file.Find(rootPathAndFolder .."/*.lua", "LUA")
		for j, d in ipairs(files) do
			TTT.Library.SetupFile(rootPathAndFolder .."/".. d, d:sub(1, 3))

			TTT.Debug.Print("Loaded libary file '".. rootPathAndFolder .."/".. d .."'.")
		end
	end

	TTT.LibraryFirstInitialized = true	-- Might be useful to someone.
end

function GM:LoadLibraries()
	if not file.IsDir("ttt", "DATA") then
		file.CreateDir("ttt")			-- Create a data folder to store anything we may want to later.
	end
	
	hook.Call("TTT.PreLibraryLoaded")
	TTT.Library.Initialize()			-- Load the libraries.
	hook.Call("TTT.PostLibraryLoaded")
end

--------------------
-- TTT.Reinitialize
--------------------
-- Desc:		Reinitializes the gamemode, useful for use while developing.
function TTT.Reinitialize()
	TTT.Library.Initialize()

	TTT.Languages.Initialize()			-- Load the languages.
	TTT.Weapons.RedirectMapEntities()	-- Swap non-TTT entities with TTT entities.
	TTT.VGUI.Initialize()				-- Get their HUDs working.
	TTT.Scoreboard.Initialize()			-- Load up the scoreboard.
	TTT.Equipment.Initialize()			-- Load up equipment.

	if SERVER then
		TTT.Player.Initialize()			-- Select the player models for the map.
	end
	
	TTT.Rounds.Initialize()				-- Begin the round managing system.	
end