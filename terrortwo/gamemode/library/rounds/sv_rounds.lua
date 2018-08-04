TTT.Rounds = TTT.Rounds or {}

util.AddNetworkString("TTT.Rounds.StateChanged")
util.AddNetworkString("TTT.Rounds.RoundWin")

-- Create round related convars.
local preventwin = CreateConVar("ttt_dev_preventwin", "0", nil, "Set to 1 to prevent the rounds from ending.")
local preventstart = CreateConVar("ttt_dev_preventstart", "0", nil, "Set to 1 to prevent the round from starting.")
local posttime = CreateConVar("ttt_post_time", "30", FCVAR_ARCHIVE, "Time in seconds after a round has ended till the game goes into prep. Set to 0 to skip post round time.")
local initialpreptime = CreateConVar("ttt_prep_time_initial", "60", FCVAR_ARCHIVE, "Time in seconds after the first round has entered preperation time till the round actually starts. Set to 0 to skip prep round time.")
local preptime = CreateConVar("ttt_prep_time", "30", FCVAR_ARCHIVE, "Time in seconds after the round has entered preperation time till the round actually starts. Set to 0 to skip prep round time.")
local minimum_players = CreateConVar("ttt_minimum_players", "2", FCVAR_ARCHIVE, "This many players are required for a round to start.")

-- When enabled, ttt_dev_preventwin prevents rounds from being won.
cvars.AddChangeCallback("ttt_dev_preventwin", function(_, _, newval)
	if newval == "0" and TTT.Rounds.IsActive() then
		TTT.Rounds.CheckForRoundEnd()
	end
end)

-- When enabled, ttt_dev_preventstart prevents rounds from starting.
cvars.AddChangeCallback("ttt_dev_preventstart", function(_, _, newval)
	if newval == "0" and not TTT.Rounds.IsActive() then
		if TTT.Rounds.ShouldStart() then
			TTT.Rounds.EnterPrep()
			if timer.Exists("TTT.Rounds.WaitForStart") then
				timer.Remove("TTT.Rounds.WaitForStart")
			end
		end
	end
end)

///////////////////////////
// Round State Functions.
///////////////////////////
-----------------------
-- TTT.Rounds.SetState
-----------------------
-- Desc:		Changes the current round state.
-- Arg One:		ROUND_ enum to set the round state to.
function TTT.Rounds.SetState(state)
	TTT.Rounds.State = state

	net.Start("TTT.Rounds.StateChanged")
		net.WriteUInt(state, 3)
	net.Broadcast()

	hook.Call("TTT.Rounds.StateChanged", nil, state)
	print("Round state changed to: ".. TTT.Rounds.TypeToString(state))
end

------------------------------------------
-- TTT.Rounds.TellClientCurrentRoundState
------------------------------------------
-- Desc:		Let the client know what the current round state is.
-- Arg One:		Player entity, to inform.
function TTT.Rounds.TellClientCurrentRoundState(ply)
	net.Start("TTT.Rounds.StateChanged")
		net.WriteUInt(TTT.Rounds.State, 3)
	net.Send(ply)
end

---------------------------
-- TTT.Rounds.WaitForStart
---------------------------
-- Desc:		When called makes a timer that checks every second to see if the round should start.
function TTT.Rounds.WaitForStart()
	if timer.Exists("TTT.Rounds.WaitForStart") then
		timer.Remove("TTT.Rounds.WaitForStart")
	end

	timer.Create("TTT.Rounds.WaitForStart", 1, 0, function()
		if TTT.Rounds.ShouldStart() then
			TTT.Rounds.EnterPrep()
			timer.Remove("TTT.Rounds.WaitForStart")
		end
	end)
end

--------------------------
-- TTT.Rounds.ShouldStart
--------------------------
-- Desc:		CHecks to see if its a good time to start the round.
-- Returns:		Boolean, should the round start.
function TTT.Rounds.ShouldStart()
	return hook.Call("TTT.Rounds.ShouldStart") or false
end

--------------------
-- TTT.Rounds.Start
--------------------
-- Desc:		Starts the round.
function TTT.Rounds.Start()
	if not TTT.Rounds.ShouldStart() then
		TTT.Rounds.Waiting()
		TTT.Rounds.WaitForStart()
		return
	end

	TTT.Rounds.ClearTimers()
	TTT.Rounds.SetState(ROUND_ACTIVE)
	TTT.Rounds.SetEndTime(CurTime() + GetConVar("ttt_roundtime_seconds"):GetFloat())
	timer.Create("TTT.Rounds.CheckForTimeRunOut", 1, 0, function()
		if (TTT.Rounds.GetRemainingTime() <= 0) and (TTT.Rounds.IsActive() and not GetConVar("ttt_dev_preventwin"):GetBool()) then
			TTT.Rounds.End(WIN_TIME)
		end
	end)

	hook.Call("TTT.Rounds.RoundStarted")
end

------------------------
-- TTT.Rounds.ShouldEnd
------------------------
-- Desc:		Decides if the round should end or not.
-- Returns:		WIN_ enum if there should be a win, false otherwise.
function TTT.Rounds.ShouldEnd()
	return hook.Call("TTT.Rounds.ShouldEnd") or false
end

------------------
-- TTT.Rounds.End
------------------
-- Desc:		Ends the current round with the given WIN_ enum type.
-- Arg One:		WIN_ enum, the type of round win. If left nil will use WIN_NONE.
function TTT.Rounds.End(wintype)
	wintype = wintype or WIN_NONE
	TTT.Rounds.NumRoundsPassed = TTT.Rounds.NumRoundsPassed + 1

	timer.Remove("TTT.Rounds.CheckForTimeRunOut")

	hook.Call("TTT.Rounds.RoundEnded", nil, wintype)

	net.Start("TTT.Rounds.RoundWin")
		net.WriteUInt(wintype, 3)
	net.Broadcast()

	if TTT.Rounds.GetRoundsLeft() <= 0 then
		hook.Call("TTT.Rounds.MapEnded", nil, wintype)
	end

	if posttime:GetInt() <= 0 then
		TTT.Rounds.EnterPrep()
	else
		TTT.Rounds.EnterPost()
	end
end

-------------------------------
-- TTT.Rounds.CheckForRoundEnd
-------------------------------
-- Desc:		Checks to see if the round should end and ends it if it should.
function TTT.Rounds.CheckForRoundEnd()
	local win = TTT.Rounds.ShouldEnd()
	if win then
		TTT.Rounds.End(win)
	end
end

------------------------
-- TTT.Rounds.EnterPrep
------------------------
-- Desc:		Puts the round into preperation mode.
function TTT.Rounds.EnterPrep()
	TTT.Rounds.SetState(ROUND_PREP)
	hook.Call("TTT.Rounds.EnteredPrep")

	local delay = 0
	if not TTT.Rounds.NumRoundsPassed or TTT.Rounds.NumRoundsPassed == 0 then
		delay = initialpreptime:GetInt()
	else
		delay = preptime:GetInt()
	end

	if delay <= 0 then
		TTT.Rounds.Start()
	else
		TTT.Rounds.SetEndTime(CurTime() + delay)

		timer.Create("TTT.Rounds.PrepTime", delay, 1, function()
			TTT.Rounds.Start()
		end)
	end
end

------------------------
-- TTT.Rounds.EnterPost
------------------------
-- Desc:		Puts the round into round post mode.
function TTT.Rounds.EnterPost()
	TTT.Rounds.SetState(ROUND_POST)
	hook.Call("TTT.Rounds.EnteredPost")
	local delay = posttime:GetInt()

	if delay <= 0 then
		TTT.Rounds.EnterPrep()
	else
		TTT.Rounds.SetEndTime(CurTime() + delay)

		timer.Create("TTT.Rounds.PostTime", delay, 1, function()
			if TTT.Rounds.ShouldStart() then
				TTT.Rounds.EnterPrep()
			else
				TTT.Rounds.Waiting()
				TTT.Rounds.WaitForStart()
			end
		end)
	end
end

----------------------
-- TTT.Rounds.Waiting
----------------------
-- Desc:		Puts the game into the waiting round state.
function TTT.Rounds.Waiting()
	TTT.Rounds.ClearTimers()
	TTT.Rounds.SetEndTime(0)
	TTT.Rounds.SetState(ROUND_WAITING)
end

---------------------------
-- TTT.Rounds.RestartRound
---------------------------
-- Desc:		Restarts the current round.
function TTT.Rounds.RestartRound()
	TTT.Rounds.ClearTimers()
	TTT.Rounds.EnterPrep()
end

-------------------------------------
-- ConCommand:		ttt_roundrestart
-------------------------------------
-- Desc:		Restarts the current round.
concommand.Add("ttt_roundrestart", function(ply)
	if not IsValid(ply) or ply:IsSuperAdmin() then
		TTT.Rounds.RestartRound()
	else
		print("You do not have permission to run this command.")
	end
end)


//////////////////////////
// Round Time Functions.
//////////////////////////
-------------------------
-- TTT.Rounds.SetEndTime
-------------------------
-- Desc:		Sets a global float to the given time.
-- Arg One:		Number, the round end time. Make sure this is greater than CurTime.
function TTT.Rounds.SetEndTime(seconds)
	SetGlobalFloat("ttt_roundend_time", seconds)
end

----------------------
-- TTT.Rounds.AddTime
----------------------
-- Desc:		Adds time to the current round end time.
-- Arg One:		Number, added to end time.
function TTT.Rounds.AddTime(seconds)
	TTT.Rounds.SetEndTime(TTT.Rounds.GetEndTime() + seconds)
end

-------------------------
-- TTT.Rounds.RemoveTime
-------------------------
-- Desc:		Remove time from the current round end time.
-- Arg One:		Number, removed from the end time.
function TTT.Rounds.RemoveTime(seconds)
	TTT.Rounds.AddTime(-seconds)
end


/////////////////
// Misc. Stuff.
/////////////////
---------------------------
-- TTT.Rounds.TypeToString
---------------------------
-- Desc:		Given a ROUND_ enum will print a string of the round type.
-- Arg One:		ROUND_ enum, which round to get a string of.
-- Returns:		String, current round type.
local roundtypes = {
	[ROUND_WAITING] = "WAITING",
	[ROUND_PREP] = "PREP",
	[ROUND_ACTIVE] = "ACTIVE",
	[ROUND_POST] = "POST"
}
function TTT.Rounds.TypeToString(state)
	return roundtypes[state] or "UNKNOWN (".. state ..")"
end

--------------------------
-- TTT.Rounds.ClearTimers
--------------------------
-- Desc:		Removes the prep, post, and time run out timers.
function TTT.Rounds.ClearTimers()
	if timer.Exists("TTT.Rounds.PrepTime") then
		timer.Remove("TTT.Rounds.PrepTime")
	end
	if timer.Exists("TTT.Rounds.PostTime") then
		timer.Remove("TTT.Rounds.PostTime")
	end
	if timer.Exists("TTT.Rounds.CheckForTimeRunOut") then
		timer.Remove("TTT.Rounds.CheckForTimeRunOut")
	end
end
