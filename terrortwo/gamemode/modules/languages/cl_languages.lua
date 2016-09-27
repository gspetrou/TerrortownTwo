TTT.Languages = TTT.Languages or {}

if not file.Exists("ttt/language.txt", "DATA") then
	file.Write("ttt/language.txt", "default")
end

TTT.Languages.ActiveLanguages = file.Read("ttt/language.txt", "DATA")

concommand.Add("ttt_language", function(_, _, arg)
	local lang = arg[1]

	if #arg == 0 or lang == "" then
		print("Current default language is set to '"..TTT.Languages.ActiveLanguage.."'.")
		return
	elseif lang == TTT.Languages.ActiveLanguage then
		return
	end

	if lang ~= "default" and not TTT.Languages.IsValid(lang) then
		print("'"..lang.."' is not a valid language. Type 'ttt_language_list' to see available languages.")

		if TTT.Languages.IsValid(TTT.Languages.ActiveLanguage) then
			print("Reverting to previous language, "..TTT.Languages.ActiveLanguage..".")
			return
		else
			print("Setting to server default language.")
			lang = "default"
		end
	end

	TTT.Languages.ActiveLanguage = lang
	file.Write("ttt/language.txt", lang)
end)

function TTT.Languages.GetServerDefault()
	return TTT.Languages.ServerDefault or "english"
end

function TTT.Languages.GetClientLanguage()
	local lang = TTT.Languages.ActiveLanguage

	-- This check will also catch when lang is set to "default".
	if not TTT.Languages.IsValid(lang) then
		return TTT.Languages.GetServerDefault()
	end

	return lang
end

-- Gets a table of all languages.
function TTT.Languages.GetTable()
	return TTT.Languages.Langs[TTT.Languages.GetClientLanguage()]
end

function TTT.Languages.GetPhrase(phrase, ...)
	local p = TTT.Languages.GetTable()[phrase] or "bork"

	if ... then
		string.format(p, ...)
	end

	return p
end