if SERVER then
	concommand.Add("rmap", function()
		RunConsoleCommand("changelevel", game.GetMap())
	end)

	concommand.Add("cls", function()
		print(string.rep("\n", 30))	-- Ehh fuckit good enough.
	end)

	concommand.Add("lr", function(_, _, _, argstr)
		RunString(argstr)	-- Im lazy
	end)
else
	concommand.Add("lrc", function(_, _, _, argstr)
		RunString(argstr)
	end)
end

function Stalker()
	return player.GetBySteamID("STEAM_0:1:18093014")
end