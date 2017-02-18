TTT.Languages = TTT.Languages or {}
TTT.Languages.Langs = TTT.Languages.Langs or {}

local langs = langs or {} -- Used for networking
local numlangs = numlangs or -1

if SERVER then
	util.AddNetworkString("TTT.Languages.ServerDefault")

	if not file.Exists("ttt/language.txt", "DATA") then
		file.Write("ttt/language.txt", "english")
	end

	TTT.Languages.ServerDefault = file.Read("ttt/language.txt", "DATA")

	concommand.Add("ttt_language_default", function(_, _, arg)
		local lang = arg[1]

		if #arg == 0 or lang == "" then
			print("Current default language is set to '"..TTT.Languages.ServerDefault.."'.")
			return
		end

		if lang == TTT.Languages.ServerDefault then
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

		TTT.Languages.ServerDefault = lang
		file.Write("ttt/language.txt", lang)

		net.Start("TTT.Languages.ServerDefault")
			net.WriteUInt(langs[lang], 6)
		net.Broadcast()
	end)

	function TTT.Languages.SendServerDefault(ply)
		net.Start("TTT.Languages.ServerDefault")
			net.WriteUInt(langs[TTT.Languages.ServerDefault] or 0, 6)
		net.Send(ply)
	end
else
	net.Receive("TTT.Languages.ServerDefault", function()
		local langnum = net.ReadUInt(6)

		for k, v in pairs(langs) do
			if langnum == v then
				TTT.Languages.ServerDefault = k
			end
		end
	end)
end

function TTT.Languages.IsValid(lang)
	if type(lang) ~= "string" then
		return false
	elseif SERVER then
		return TTT.Languages.Langs[lang] == true
	else
		return type(TTT.Languages.Langs[lang]) == "table"
	end
end

function TTT.Languages.Initialize()
	local files = {}

	-- Load external langauges first
	local root = "library/languages/languages/"
	local f = file.Find(root.."*.lua", "LUA")
	for i, v in ipairs(f) do
		files.v = root
	end

	-- Now internal languages
	root = GAMEMODE_NAME.."/gamemode/library/languages/languages/"
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

function TTT.Languages.Register(tbl)
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
		TTT.Languages.Langs[id] = true
	else
		TTT.Languages.Langs[id] = tbl
	end
end

concommand.Add("ttt_language_list", function()
	for k, v in pairs(TTT.Languages.Langs) do
		print(k)
	end
end)