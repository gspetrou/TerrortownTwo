TTT.Languages = TTT.Languages or {}
local langs = langs or {} -- Used for networking
local numlangs = numlangs or -1

if SERVER then
	util.AddNetworkString("TTT_ServerDefaultLanguage")

	if not file.Exists("ttt/language.txt", "DATA") then
		file.Write("ttt/language.txt", "english")
	end

	TTT.ServerDefaultLanguage = file.Read("ttt/language.txt", "DATA")

	concommand.Add("ttt_language_default", function(_, _, arg)
		local lang = arg[1]

		if #arg == 0 or lang == "" then
			print("Current default language is set to '"..TTT.ServerDefaultLanguage.."'.")
			return
		end

		if lang == TTT.ServerDefaultLanguage then
			return
		end

		if not TTT.IsValidLanguage(lang) then
			print("'"..lang.."' is not a valid language. Type 'ttt_language_list' to see available languages.")

			if TTT.IsValidLanguage(TTT.ServerDefaultLanguage) then
				print("Reverting to previous language, "..TTT.ServerDefaultLanguage..".")
				return
			elseif TTT.IsValidLanguage("english") then
				print("Defaulting language to English.")
				lang = "english"
			else
				return
			end
		end

		TTT.ServerDefaultLanguage = lang
		file.Write("ttt/language.txt", lang)

		net.Start("TTT_ServerDefaultLanguage")
			net.WriteUInt(langs[lang], 6)
		net.Broadcast()
	end)

	hook.Add("PlayerInitialSpawn", "TTT_SendServerDefaultLanguage", function(ply)
		net.Start("TTT_ServerDefaultLanguage")
			net.WriteUInt(langs[TTT.ServerDefaultLanguage] or 0, 6)
		net.Send(ply)
	end)
else
	net.Receive("TTT_ServerDefaultLanguage", function()
		local langnum = net.ReadUInt(6)

		for k, v in pairs(langs) do
			if langnum == v then
				TTT.ServerDefaultLanguage = k
			end
		end
	end)
end

function TTT.IsValidLanguage(lang)
	if type(lang) ~= "string" then
		return false
	elseif SERVER then
		return TTT.Languages[lang] == true
	else
		return type(TTT.Languages[lang]) == "table"
	end
end

function TTT.LoadLanguages()
	local files = {}

	-- Load external langauges first
	local root = "modules/languages/languages/"
	local f = file.Find(root.."*.lua", "LUA")
	for i, v in ipairs(f) do
		files.v = root
	end

	-- Now internal languages
	root = GAMEMODE_NAME.."/gamemode/modules/languages/languages/"
	f = file.Find(root.."*.lua", "LUA")
	for i, v in ipairs(f) do
		if not files.v then
			files[v] = root
		end
	end

	for k, v in pairs(files) do
		if SERVER then
			AddCSLuaFile(v..k)
		end
		include(v..k)

		numlangs = numlangs + 1
		langs[string.sub(k, 1, #k-4)] = numlangs
	end
end

function TTT.AddLanguage(tbl)
	local id = tbl.ID
	if type(id) ~= "string" then
		DebugPrint("Unable to add language since it is missing the ID field, aborting.")
		return
	end
	
	id = string.lower(id)
	if id == "default" then
		DebugPrint("You can't set the ID field of the language to 'default', aborting.")
		return
	end

	if SERVER then
		TTT.Languages[id] = true
	else
		TTT.Languages[id] = tbl
	end
end

hook.Add("Initialize", "TTT_LoadLanguages", function()
	TTT.LoadLanguages()
end)

concommand.Add("ttt_language_list", function()
	for k, v in pairs(TTT.Languages) do
		print(k)
	end
end)