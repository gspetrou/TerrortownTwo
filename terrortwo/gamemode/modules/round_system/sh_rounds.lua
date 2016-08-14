ROUND_WAITING = 0
ROUND_PREP = 1
ROUND_ACTIVE = 2
ROUND_POST = 3

GM.RoundState = ROUND_WAITING

function TTT.GetRoundState()
	return GM.RoundState
end

if CLIENT then
	net.Receive("TTT_ChangeRoundState", function()
		GM.RoundState = net.ReadUInt(2)
	end)
end