TTT.Scoreboard = TTT.Scoreboard or {}
TTT.Scoreboard.PlayerGroups = TTT.Scoreboard.PlayerGroups or {}

-- I've been dreading writing this module since I started this project. Here we go...

---------------------------------
-- TTT.Scoreboard.AddPlayerGroup
---------------------------------
-- Desc:		Adds a new player section to the scoreboard.
-- Arg One:		String, displayed as the header for the group.
-- Arg Two:		Color, used for the background of the header text.
-- Arg Three:	Table, sequential table of all players to list in this group.
-- Returns:		ScoreGroup object. TO-DO DOCUMENT BETTER!
function TTT.Scoreboard.AddPlayerGroup(nm, col, plys)
	local ScoreGroup = {
		name = nm,
		color = col,
		players = plys
	}
	function ScoreGroup:SetPlayers(plys)
		self.players = plys
	end
	
	table.insert(TTT.Scoreboard.PlayerGroups, group)
end

function TTT.Scoreboard.Open()
	TTT.Scoreboard.Scoreboard = vgui.Create("TTT.Scoreboard")
end

function TTT.Scoreboard.Close()
	if IsValid(TTT.Scoreboard.Scoreboard) then
		TTT.Scoreboard.Scoreboard:Remove()
	end
end