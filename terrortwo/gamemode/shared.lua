--[[
	About this gamemode:

		While the name as of now is unofficial, Trouble in Terrorist Town Two aims to be a
	solid replacement of the original Trouble in Terrorist Town created by Bad King Urgrain
	written primarily by Stalker. The original TTT was made for one of the Fretta coding
	competitions way back when and has since been built upon it's hastily written core codebase
	which suffers poor optimizations and networking. This version of TTT aims to improve on
	the original's weaknesses by being modular, well documented, optimized, and networked.
	Other than UI changes this gamemode should more or less be the same as the original.

	BIG thanks to Bad King Urgrain for the years upon years of joy his gamemode gave me.

-----------------------------------------------------------------------------------------------
	
	About the code:

		The code for this gamemode is split in two. While the library folder houses the
	decleration of nearly every function/variable they are rarely executed in their containning
	folders. They are instead called in cl_init.lua, init.lua, and shared.lua. These three files
	control how the gamemode uses the available library. By doing so we split implimentation from
	application, making the gamemode very neat and organized. Furthermore, none of the libraries
	reference code from other libraries. For example, nothing in the rounds library is ever called
	in the roles library. Whenever this connection needs to be made a hook is instead used in one
	of the three previously mentionned application files. By doing so we make the gamemode much
	easier to expand upon, much easier to see what is going on in the grand scheme of things, and
	much easier to later change with another addon.

-----------------------------------------------------------------------------------------------

	About third party code:

		While this is a recode of Bad King Urgrain's original gamemode a decent bit of his code
	has been adapted into here. I try to credit him where possible but if some uncreditted snippet
	of code seems to be taken from the original TTT please know I by no means intend to take credit
	for his work. If that is ever the case with the original TTT's code or any other third party
	code used in this gamemode please let me know in a pull request and I'll credit it. I'll
	usually credit other people's work in the documentation right above the declaration of their
	code.

	- Stalker
]]

GM.Name = "Trouble in Terrorist Town Two"
GM.Author = "George 'Stalker' Petrou"
GM.Email = "N/A"
GM.Website = "N/A"
TTT.Version = 20170309					-- YearMonthDay

DEFINE_BASECLASS("gamemode_base")

-- Thanks TTT.
TTT.Colors = {
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

	if SERVER then
		TTT.PlayerSettings.Initialize()	-- Select the player models for the map.
	end
	
	TTT.Rounds.Initialize()				-- Begin the round managing system.
end

-- This is for auto-refresh to work.
if TTT.LibrariesInitiallyLoaded then
	TTT.Library.Initialize()
end

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