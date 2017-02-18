GM.Name = "Trouble in Terrorist Town Two"
GM.Author = "Stalker"
GM.Email = "N/A"
GM.Website = "N/A"

DEFINE_BASECLASS("gamemode_base")

function GM:Initialize()
	if not file.IsDir("ttt", "DATA") then
		file.CreateDir("ttt")			-- Create a data folder to store anything we may want to later.
	end

	TTT.Library.Initialize()			-- Load the library.
	TTT.Languages.Initialize()			-- Load the languages.
	TTT.VGUI.Initialize()				-- Get their HUDs working.

	if SERVER then
		TTT.Rounds.Initialize()	-- Begin the round managing system.
	end
end