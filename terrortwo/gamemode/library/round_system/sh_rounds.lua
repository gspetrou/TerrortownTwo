TTT.Rounds = TTT.Rounds or {}

ROUND_WAITING = 0
ROUND_PREP = 1
ROUND_ACTIVE = 2
ROUND_POST = 3

WIN_TIME = 0
WIN_INNOCENT = 1
WIN_TRAITOR = 2

TTT.Rounds.State = ROUND_WAITING

function TTT.Rounds.GetEndTime()
	return GetGlobalFloat("ttt_roundend_time")
end

function TTT.Rounds.GetRemainingTime()
	return math.max(TTT.Rounds.GetEndTime() - CurTime(), 0)
end

function TTT.Rounds.GetFormattedRemainingTime()
	local time = TTT.Rounds.GetRemainingTime()

	return string.FormattedTime(time, "%02i:%02i")
end

local phrases = {
	[ROUND_WAITING] = "waiting",
	[ROUND_PREP] = "preperation",
	[ROUND_ACTIVE] = "active",
	[ROUND_POST] = "roundend"
}
function TTT.Rounds.GetFormattedState()
	return TTT.Languages.GetPhrase(phrases[TTT.Rounds.GetState()])
end

function TTT.Rounds.GetState()
	return TTT.Rounds.State
end

local roundtypes = {
	[ROUND_WAITING] = "WAITING",
	[ROUND_PREP] = "PREP",
	[ROUND_ACTIVE] = "ACTIVE",
	[ROUND_POST] = "POST"
}

-- For console prints/logging
function TTT.Rounds.TypeToPrint(state)
	return roundtypes[state] or "UNKNOWN (".. state ..")"
end

if CLIENT then
	net.Receive("TTT.Rounds.ChangeState", function()
		TTT.Rounds.State = net.ReadUInt(3)
	--[[
		if TTT.RoundState == ROUND_POST then
			local wintype = net.ReadUInt(3)
		end
	]]
	end)
end