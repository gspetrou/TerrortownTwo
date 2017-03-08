GM.Name = "Trouble in Terrorist Town Two"
GM.Author = "George Petrou (Stalker)"
GM.Email = "N/A"
GM.Website = "N/A"

DEFINE_BASECLASS("gamemode_base")

--------------------------
-- General Gamemode Hooks
--------------------------
function GM:Initialize()
	if not file.IsDir("ttt", "DATA") then
		file.CreateDir("ttt")			-- Create a data folder to store anything we may want to later.
	end

	TTT.Library.Initialize()			-- Load the library.
	TTT.Languages.Initialize()			-- Load the languages.
	TTT.VGUI.Initialize()				-- Get their HUDs working.

	TTT.Rounds.Initialize()				-- Begin the round managing system.
end

-- This is for auto-refresh to work.
if TTT.LibrariesInitiallyLoaded then
	TTT.Library.Initialize()
endend

---------------
-- Round Hooks
---------------
hook.Add("TTT.Rounds.StateChanged", "TTT", function(state)
	if state == ROUND_WAITING then
		for i, v in ipairs(player.GetAll()) do
			if not v:IsSpectator() then
				v:SetRole(ROLE_WAITING)
			end
		end
	end
end)