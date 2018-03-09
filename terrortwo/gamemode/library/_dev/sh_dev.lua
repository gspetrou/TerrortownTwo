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

	concommand.Add("addbots", function(_, _, args)
		for i = 1, args[1] do
			RunConsoleCommand("bot")
		end
	end)
	concommand.Add("kickbots", function()
		for i, v in ipairs(player.GetBots()) do
			v:Kick("You're a bot")
		end
	end)
else
	concommand.Add("lrc", function(_, _, _, argstr)
		RunString(argstr)
	end)
end

function Stalker()
	return player.GetBySteamID("STEAM_0:1:18093014")
end

function GetBot(num)
	for i, v in ipairs(player.GetBots()) do
		local endNum = tonumber(string.sub(v:Nick(), 4))
		if endNum == num then
			return v
		end
	end
end