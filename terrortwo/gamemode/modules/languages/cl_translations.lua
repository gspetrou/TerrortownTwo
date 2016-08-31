if not file.Exists("ttt/language.txt", "DATA") then
	file.Write("ttt/language.txt", "default")
end

TTT.ActiveLanguage = file.Read("ttt/language.txt", "DATA")

concommand.Add("ttt_language", function(_, _, arg)
	local lang = arg[1]

	if #arg == 0 or lang == "" then
		print("Current default language is set to '"..TTT.ActiveLanguage.."'.")
		return
	elseif lang == TTT.ActiveLanguage then
		return
	end

	if lang ~= "default" and not TTT.IsValidLanguage(lang) then
		print("'"..lang.."' is not a valid language. Type 'ttt_language_list' to see available languages.")

		if TTT.IsValidLanguage(TTT.ActiveLanguage) then
			print("Reverting to previous language, "..TTT.ActiveLanguage..".")
			return
		else
			print("Setting to server default language.")
			lang = "default"
		end
	end

	TTT.ActiveLanguage = lang
	file.Write("ttt/language.txt", lang)
end)

function TTT.GetServerDefaultLanguage()
	return TTT.ServerDefaultLanguage or "english"
end

function TTT.GetClientLanguage()
	local lang = TTT.ActiveLanguage

	-- This check will also catch when lang is set to "default".
	if not TTT.IsValidLanguage(lang) then
		return TTT.GetServerDefaultLanguage()
	end

	return lang
end

function TTT.GetLanguageTable()
	return TTT.Languages[TTT.GetClientLanguage()]
end

function TTT.GetPhrase(phrase, ...)
	local p = TTT.GetLanguageTable()[phrase] or "bork"

	if ... then
		string.format(p, ...)
	end

	return p
end