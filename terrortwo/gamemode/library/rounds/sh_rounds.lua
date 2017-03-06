TTT.Rounds = TTT.Rounds or {}

ROUND_WAITING = 0
ROUND_PREP = 1
ROUND_ACTIVE = 2
ROUND_POST = 3

WIN_NONE = 0
WIN_TIME = 1
WIN_INNOCENT = 2
WIN_TRAITOR = 3

TTT.Rounds.State = ROUND_WAITING

-- Replicated ConVars need to be defined shared. Why do I always forget this.
local roundtime = CreateConVar("ttt_roundtime_seconds", "600", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "How long is the round in seconds. This is before any extensions are added to it like haste or overtime.")
local numrounds = CreateConVar("ttt_rounds_per_map", "7", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "How many rounds to play before a map change is initiated.")

-- Getter function for round states.
function TTT.Rounds.GetState() return TTT.Rounds.State end
function TTT.Rounds.IsWaiting() return TTT.Rounds.GetState() == ROUND_WAITING end
function TTT.Rounds.IsPrep() return TTT.Rounds.GetState() == ROUND_PREP end
function TTT.Rounds.IsActive() return TTT.Rounds.GetState() == ROUND_ACTIVE end
function TTT.Rounds.IsPost() return TTT.Rounds.GetState() == ROUND_POST end

-------------------------
-- TTT.Rounds.Initialize
-------------------------
-- Desc:		Calls the TTT.Rounds.Initialize hook to initialize the round system.
function TTT.Rounds.Initialize()
	hook.Call("TTT.Rounds.Initialize")
end

----------------------------
-- TTT.Rounds.GetRoundsLeft
----------------------------
-- Desc:		Gets the number of rounds left on the current map.
-- Returns:		Number, rounds left on the map.
TTT.Rounds.NumRoundsPassed = 0
function TTT.Rounds.GetRoundsLeft()
	return numrounds:GetInt() - TTT.Rounds.NumRoundsPassed
end

-------------------------
-- TTT.Rounds.GetEndTime
-------------------------
-- Desc:		Gets the round time.
-- Returns:		Number, CurTime + round time.
function TTT.Rounds.GetEndTime()
	return GetGlobalFloat("ttt_roundend_time")
end

-------------------------------
-- TTT.Rounds.GetRemainingTime
-------------------------------
-- Desc:		Gets the remaining round time.
-- Returns:		Number, time remaining.
function TTT.Rounds.GetRemainingTime()
	return math.max(TTT.Rounds.GetEndTime() - CurTime(), 0)
end

----------------------------------------
-- TTT.Rounds.GetFormattedRemainingTime
----------------------------------------
-- Desc:		Just read the name of the fucking function, jeez.
-- Returns:		String, time formatted as "Minutes:Seconds".
function TTT.Rounds.GetFormattedRemainingTime()
	local time = TTT.Rounds.GetRemainingTime()

	return string.FormattedTime(time, "%02i:%02i")
end

--------------------------------
-- TTT.Rounds.GetFormattedState
--------------------------------
-- Desc:		Gets the current round as a string in the correct language.
-- Returns:		String, current round state.
local phrases = {
	[ROUND_WAITING] = "waiting",
	[ROUND_PREP] = "preperation",
	[ROUND_ACTIVE] = "active",
	[ROUND_POST] = "roundend"
}
function TTT.Rounds.GetFormattedState()
	return TTT.Languages.GetPhrase(phrases[TTT.Rounds.GetState()])
end

if CLIENT then
	net.Receive("TTT.Rounds.StateChanged", function()
		TTT.Rounds.State = net.ReadUInt(3)
	end)

	net.Receive("TTT.Rounds.RoundWin", function()
		local wintype = net.ReadUInt(3)
		TTT.Rounds.NumRoundsPassed = TTT.Rounds.NumRoundsPassed + 1

		if TTT.Rounds.GetRoundsLeft() <= 0 then
			hook.Call("TTT.Rounds.MapEnded", nil, wintype)
		end

		hook.Call("TTT.Rounds.RoundEnded", nil, wintype)
	end)
end