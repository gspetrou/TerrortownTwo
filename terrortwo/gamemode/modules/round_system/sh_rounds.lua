ROUND_WAITING = 0
ROUND_PREP = 1
ROUND_ACTIVE = 2
ROUND_POST = 3

TTT.RoundState = ROUND_WAITING

function TTT.GetRoundEndTime()
	return GetGlobalFloat("ttt_roundend_time")
end

function TTT.GetRemainingRoundTime()
	return TTT.GetRoundEndTime() - CurTime()
end

function TTT.GetRoundState()
	return TTT.RoundState
end

local roundtypes = {
	[ROUND_WAITING] = "WAITING",
	[ROUND_PREP] = "PREP",
	[ROUND_ACTIVE] = "ACTIVE",
	[ROUND_POST] = "POST"
}

-- For console prints/logging
function TTT.RoundTypeToPrint(state)
	return roundtypes[state] or "UNKNOWN (".. state ..")"
end

if CLIENT then
	net.Receive("TTT_ChangeRoundState", function()
		TTT.RoundState = net.ReadUInt(4)
	end)
end