util.AddNetworkString("TTT_ChangeRoundState")
local preventwin = CreateConVar("ttt_dev_preventwin", "0", nil, "Set to 1 to prevent the rounds from ending.")
local preventstart = CreateConVar("ttt_dev_preventstart", "0", nil, "Set to 1 to prevent the round from starting.")
local posttime = CreateConVar("ttt_post_time", "30", nil, "Time in seconds after a round has ended till the game goes into prep. Set to 0 to skip post round time.")
local preptime = CreateConVar("ttt_prep_time", "30", nil, "Time in seconds after the round has entered preperation time till the round actually starts. Set to 0 to skip prep round time.")
local roundtime = CreateConVar("ttt_roundtime_seconds", "600", nil, "How long is the round in seconds. This is before any extensions are added to it like haste or overtime.")
local minimum_players = CreateConVar("ttt_minimum_players", "2", nil, "This many players is required for a round to start.")

function TTT.SetRoundState(state, wintype)
	local newstate = hook.Call("TTT_RoundStateChanged", GM, state) or state
	TTT.RoundState = newstate

	net.Start("TTT_ChangeRoundState")
		net.WriteUInt(newstate, 3)
		if wintype then
			net.WriteUInt(wintype, 3)
		end
	net.Broadcast()

	print("Round state changed to: ".. TTT.RoundTypeToPrint(state))
end

function TTT.SetRoundEndTime(seconds)
	SetGlobalFloat("ttt_roundend_time", seconds)
end

function TTT.AddRoundTime(seconds)
	TTT.SetRoundEndTime(TTT.GetRoundEndTime() + seconds)
end

function TTT.RemoveRoundTime(seconds)
	TTT.AddRoundTime(-seconds)
end

function TTT.EnterPrep()
	local delay = preptime:GetInt()

	if delay <= 0 then
		TTT.StartRound()
	else
		TTT.SetRoundState(ROUND_PREP)

		-- This is only really used for client's HUDs at this point.
		TTT.SetRoundEndTime(CurTime() + delay)

		timer.Create("TTT_PrepTime", delay, 1, function()
			TTT.StartRound()
		end)
	end
end

function TTT.StartRound()
	if preventstart:GetBool() or hook.Call("TTT_ShouldStartRound", GM) == false or #TTT.GetActivePlayers() < minimum_players:GetInt() then
		return
	end

	TTT.PickRoles()
	TTT.SyncRoles()

	TTT.SetRoundState(ROUND_ACTIVE)
	TTT.SetRoundEndTime(CurTime() + roundtime:GetFloat())
end

function TTT.EndRound(wintype)
	TTT.ClearRoles()
	
	local delay = posttime:GetInt()
	if delay <= 0 then
		TTT.EnterPrep()
	else
		-- For HUDs
		TTT.SetRoundEndTime(CurTime() + delay)
		TTT.SetRoundState(ROUND_POST)

		timer.Create("TTT_PostTime", delay, 1, function()
			TTT.EnterPrep()
		end)
	end
end

function TTT.ShouldEndRound()
	if preventwin:GetBool() or hook.Call("TTT_ShouldEndRound", GM) == false then
		return false
	end

	local numplys = #TTT.GetActivePlayers()
	local wintype = false

	if numplys == #TTT.GetDetectives() + #TTT.GetInnocents() then
		wintype = WIN_INNOCENT		
	elseif numplys == #TTT.GetTraitors() then
		wintype = WIN_TRAITOR
	end

	return wintype
end

hook.Add("PostPlayerDeath", "TTT_CheckRound", function(ply)
	local wintype = TTT.ShouldEndRound()

	if wintype then
		TTT.EndRound(wintype)
	end
end)

hook.Add("Initialize", "TTT_CheckRoundStatus", function()
	timer.Create("TTT_CheckRoundStatus", 1, 0, function()
		local roundstate = TTT.GetRoundState()

		if #TTT.GetActivePlayers() >= minimum_players:GetInt() then
			if roundstate == ROUND_WAITING then
				TTT.EnterPrep()
			elseif roundstate == ROUND_ACTIVE then
				local wintype = TTT.ShouldEndRound()
				if wintype then
					TTT.EndRound(wintype)
				end
			end

		elseif roundstate ~= ROUND_WAITING then
			TTT.SetRoundEndTime(0)
			TTT.SetRoundState(ROUND_WAITING)
			
			if timer.Exists("TTT_PrepTime") then
				timer.Remove("TTT_PrepTime")
			elseif timer.Exists("TTT_PostTime") then
				timer.Remove("TTT_PostTime")
			end
		end
	end)
end)