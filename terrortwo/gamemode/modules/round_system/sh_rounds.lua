ROUND_WAITING = 0
ROUND_PREP = 1
ROUND_ACTIVE = 2
ROUND_POST = 3

WIN_TIME = 0
WIN_INNOCENT = 1
WIN_TRAITOR = 2

TTT.RoundState = ROUND_WAITING

function TTT.GetRoundEndTime()
	return GetGlobalFloat("ttt_roundend_time")
end

function TTT.GetRemainingRoundTime()
	return math.max(TTT.GetRoundEndTime() - CurTime(), 0)
end

function TTT.GetFormattedRemainingTime()
	local time = TTT.GetRemainingRoundTime()

	return string.FormattedTime(time, "%02i:%02i")
end

local phrases = {
	[ROUND_WAITING] = "waiting",
	[ROUND_PREP] = "preperation",
	[ROUND_ACTIVE] = "active",
	[ROUND_POST] = "roundend"
}
function TTT.GetFormattedRoundState()
	return TTT.GetPhrase(phrases[TTT.GetRoundState()])
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
		TTT.RoundState = net.ReadUInt(3)

--[[	if TTT.RoundState == ROUND_POST then
			local wintype = net.ReadUInt(3)

		end
]]
	end)
end