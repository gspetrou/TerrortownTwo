TTT.Languages = TTT.Languages or {}

-- This is where the client will store their language.
if not file.Exists("ttt/clientlanguage.txt", "DATA") then
	file.Write("ttt/clientlanguage.txt", "default")
end

TTT.Languages.ActiveLanguage = file.Read("ttt/clientlanguage.txt", "DATA") or "default"

---------------------------------
-- ConCommand:		ttt_language
---------------------------------
-- Desc:		Sets or gets the current user's language.
-- Arg One:		Nothing - Prints the user's current language.
-- 				String  - Sets the user's language if the given string is a valid language.
concommand.Add("ttt_language", function(_, _, arg)
	local lang = arg[1]
	if #arg == 0 or lang == "" then
		print("Current default language is set to '"..TTT.Languages.ActiveLanguage.."'. The server default language is '".. TTT.Languages.GetServerDefaultLanguage() .."'.")
		return
	elseif lang == TTT.Languages.GetClientLanguage() then
		return
	end

	if lang ~= "default" and not TTT.Languages.IsValid(lang) then
		print("'"..lang.."' is not a valid language. Type 'ttt_language_list' to see available languages.")

		if TTT.Languages.IsValid(TTT.Languages.ActiveLanguage) then
			print("Reverting to previous language, "..TTT.Languages.ActiveLanguage..".")
			return
		else
			print("Setting language to server default language.")
			lang = "default"
		end
	end

	TTT.Languages.ActiveLanguage = lang
	file.Write("ttt/clientlanguage.txt", lang)
end)

------------------------------------------
-- TTT.Languages.GetServerDefaultLanguage
------------------------------------------
-- Desc:		Gets what the server default language is.
-- Returns:		String, language id name.
function TTT.Languages.GetServerDefaultLanguage()
	return TTT.Languages.ServerDefault or "english"
end

-----------------------------------
-- TTT.Languages.GetClientLanguage
-----------------------------------
-- Desc:		Gets what the client's set language is.
-- Returns:		String, language id for their language.
function TTT.Languages.GetClientLanguage()
	local lang = TTT.Languages.ActiveLanguage

	-- This check will also catch when lang is set to "default".
	if not TTT.Languages.IsValid(lang) then
		return TTT.Languages.GetServerDefaultLanguage()
	end

	return lang
end

--------------------------
-- TTT.Languages.GetTable
--------------------------
-- Desc:		Gets the phrase to text table for the player's current language.
-- Returns:		Table, the keywords being phrases and the values being the corresponding translated text.
function TTT.Languages.GetTable()
	return TTT.Languages.Languages[TTT.Languages.GetClientLanguage()]
end

---------------------------
-- TTT.Languages.GetPhrase
---------------------------
-- Desc:		Gets a phrase that is translated to the player's currently set language.
-- Arg One:		String, phrase ID.
-- Arg Two:		Varag, wherever there is a %s in the returned string it will be substituted here.
function TTT.Languages.GetPhrase(phrase, ...)
	local p = TTT.Languages.GetTable()[phrase] or "bork"

	if ... then
		p = string.format(p, ...)
	end

	return p
end

net.Receive("TTT.Languages.ServerDefault", function()
	local langIDNum = net.ReadUInt(6)
	local lang = "english"
	for k, v in pairs(TTT.Languages.NWLang) do
		if v == langIDNum then
			lang = k
			break
		end
	end

	TTT.Languages.ServerDefault = lang
end)