if SERVER then
	util.AddNetworkString("rmap")

	local function rmap()
		RunConsoleCommand("changelevel", game.GetMap())
	end
	concommand.Add("rmap", rmap)
	net.Receive("rmap", rmap)

	concommand.Add("cls", function()
		print(string.rep("\n", 30))	-- Ehh fuckit good enough.
	end)

	concommand.Add("lr", function(_, _, _, argstr)
		RunString(argstr)	-- Im lazy
	end)
else
	concommand.Add("rmap", function()
		net.Start("rmap")
		net.SendToServer()
	end)

	concommand.Add("lrc", function(_, _, _, argstr)
		RunString(argstr)
	end)
end

function Stalker()
	return player.GetBySteamID("STEAM_0:1:18093014")
end