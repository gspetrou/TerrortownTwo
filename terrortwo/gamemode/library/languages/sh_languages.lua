TTT.Languages = TTT.Languages or {}
TTT.Languages.Languages = TTT.Languages.Languages or {}
TTT.Languages.NWLang = TTT.Languages.NWLang or {}
local fallbacklanguage = "english"

if SERVER then
	util.AddNetworkString("TTT.Languages.ServerDefault")

	-------------------------------------
	-- ConCommand:	ttt_language_default
	-------------------------------------
	-- Desc:		Sets or informs what the server default language is.
	-- Arg One:		String or nothing.
	-- 				String, a valid language file name.
	-- 				Nothing, will print the server default language.
	concommand.Add("ttt_language_default", function(_, _, arg)
		local lang = arg[1]
		if #arg == 0 or lang == nil or lang == "" or lang == TTT.Languages.ServerDefault then
			print("Current default language is set to '"..TTT.Languages.ServerDefault.."'.")
			return
		end
		
		if not TTT.Languages.IsValid(lang) then
			print("'"..lang.."' is not a valid language. Type 'ttt_language_list' to see available languages.")

			if TTT.Languages.IsValid(TTT.Languages.ServerDefault) then
				print("Reverting to previous language, "..TTT.Languages.ServerDefault..".")
				return
			elseif TTT.Languages.IsValid("english") then
				print("Defaulting language to English.")
				lang = "english"
			else
				return
			end
		end

		TTT.Languages.SetServerDefaultLanguage(lang)
	end)

	------------------------------------------
	-- TTT.Languages.SetServerDefaultLanguage
	------------------------------------------
	-- Desc:		Sets the server default language and informs players about it.
	-- Arg One:		String, language file name. You'll want to see if its a valid language beforehand with TTT.Languages.IsValid.
	function TTT.Languages.SetServerDefaultLanguage(lang)
		TTT.Languages.ServerDefault = lang
		file.Write("ttt/language.txt", lang)
		net.Start("TTT.Languages.ServerDefault")
			net.WriteUInt(TTT.Languages.GetLanguageNWID(lang), 6)
		net.Broadcast()
	end

	-------------------------------------------
	-- TTT.Languages.GetServerDefaultLanguage
	-------------------------------------------
	-- Desc:		Gets a string of what the server default language is.
	-- Returns:		String, the server default language.
	function TTT.Languages.GetServerDefaultLanguage()
		if not file.Exists("ttt/language.txt", "DATA") then
			file.Write("ttt/language.txt", fallbacklanguage)

			TTT.Languages.ServerDefault = fallbacklanguage
			return fallbacklanguage
		else
			local defaultlanguage = file.Read("ttt/language.txt")
			if not TTT.Languages.IsValid(defaultlanguage) then
				defaultlanguage = fallbacklanguage
				file.Write("ttt/language.txt", defaultlanguage)
			end

			TTT.Languages.ServerDefault = defaultlanguage
			return defaultlanguage
		end
	end

	-------------------------------------
	-- TTT.Languages.SendDefaultLanguage
	-------------------------------------
	-- Desc:		Tells the given client what the server default language is.
	-- Arg One:		Player entity, informed what the server default language is.
	function TTT.Languages.SendDefaultLanguage(ply)
		net.Start("TTT.Languages.ServerDefault")
			net.WriteUInt(TTT.Languages.GetLanguageNWID(TTT.Languages.ServerDefault), 6)
		net.Send(ply)
	end
end

-------------------------
-- TTT.Languages.IsValid
-------------------------
-- Desc:		Says whether the given language string file name is valid.
-- Arg One:		String, ID for the language.
-- Returns:		Boolean, is the language valid.
function TTT.Languages.IsValid(langID)
	return SERVER and TTT.Languages.Languages[langID] == true or type(TTT.Languages.Languages[langID]) == "table"
end


---------------------------------
-- TTT.Languages.GetLanguageNWID
---------------------------------
-- Desc:		Gets a number representing this language for both the client and server.
-- Arg One:		String, file name of the language.
-- Returns:		Number, represting the language.
function TTT.Languages.GetLanguageNWID(name)
	return TTT.Languages.NWLang[name]
end

-------------------------------
-- TTT.Languages.LoadLanguages
-------------------------------
-- Desc:		Loads the languages. Addons should place languages in "addonname/lua/tttlanguages/".
function TTT.Languages.LoadLanguages()
	local langFiles = {}
	local idnum = -1

	-- Addon languages take priority.
	local files = file.Find("tttlanguages/*.lua", "LUA")
	for i, v in ipairs(files) do
		local filename = v:sub(1, #v - 4)
		langFiles[filename] = true
		idnum = idnum + 1

		if SERVER then
			AddCSLuaFile("tttlanguages/".. v)
			TTT.Languages.Languages[filename] = true
		else
			TTT.Languages.Languages[filename] = include("tttlanguages/".. v)
		end
		TTT.Languages.NWLang[filename] = idnum
	end

	-- Now load gamemode languages.
	local root = GAMEMODE_NAME .."/gamemode/library/languages/languages/"
	files = file.Find(root .."*.lua", "LUA")
	for i, v in ipairs(files) do
		local filename = v:sub(1, #v - 4)
		if not langFiles[v] then
			langFiles[v] = true
			idnum = idnum + 1

			if SERVER then
				AddCSLuaFile(root .. v)
				TTT.Languages.Languages[filename] = true
			else
				TTT.Languages.Languages[filename] = include(root .. v)
			end
			TTT.Languages.NWLang[filename] = idnum
		end
	end
end

----------------------------
-- TTT.Languages.Initialize
----------------------------
-- Desc:		When called, usually upon gamemode initialization, will load languages inform players about them.
function TTT.Languages.Initialize()	
	TTT.Languages.LoadLanguages()

	if SERVER then
		TTT.Languages.GetServerDefaultLanguage()
	end
end

--------------------------------------
-- ConCommand:		ttt_language_list
--------------------------------------
-- Desc:		Prints all of the available language names to choose from.
concommand.Add("ttt_language_list", function()
	print("Available languages are:")
	for k, v in pairs(TTT.Languages.Languages) do
		print(k)
	end
end)