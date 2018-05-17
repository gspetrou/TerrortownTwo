-- Map entity which allows the map to let a certain team win.

ENT.Type = "point"
ENT.Base = "base_point"

function ENT:AcceptInput(name)
	if name == "TraitorWin" then
		TTT.Rounds.End(WIN_TRAITOR)
		return true
	elseif name == "InnocentWin" then
		TTT.Rounds.End(WIN_INNOCENT)
		return true
	elseif name == "TimeWin" then
		TTT.Rounds.End(WIN_TIME)
		return true
	end
end