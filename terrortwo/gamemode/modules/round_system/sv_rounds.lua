util.AddNetworkString("TTT_Rounds_ChangeState")
TTT.Rounds = TTT.Rounds or {}

local preventwin = CreateConVar("ttt_dev_preventwin", "0", nil, "Set to 1 to prevent the rounds from ending.")
local preventstart = CreateConVar("ttt_dev_preventstart", "0", nil, "Set to 1 to prevent the round from starting.")
local posttime = CreateConVar("ttt_post_time", "30", nil, "Time in seconds after a round has ended till the game goes into prep. Set to 0 to skip post round time.")
local preptime = CreateConVar("ttt_prep_time", "30", nil, "Time in seconds after the round has entered preperation time till the round actually starts. Set to 0 to skip prep round time.")
local roundtime = CreateConVar("ttt_roundtime_seconds", "600", nil, "How long is the round in seconds. This is before any extensions are added to it like haste or overtime.")
local minimum_players = CreateConVar("ttt_minimum_players", "2", nil, "This many players is required for a round to start.")

function TTT.Rounds.SetState(state, wintype)
	local newstate = hook.Call("TTT_Rounds_StateChanged", GM, state) or state
	TTT.Rounds.State = newstate

	net.Start("TTT_Rounds_ChangeState")
		net.WriteUInt(newstate, 3)
		if wintype then
			net.WriteUInt(wintype, 3)
		end
	net.Broadcast()

	print("Round state changed to: ".. TTT.Rounds.TypeToPrint(state))
end

function TTT.Rounds.SetEndTime(seconds)
	SetGlobalFloat("ttt_roundend_time", seconds)
end

function TTT.Rounds.AddTime(seconds)
	TTT.Rounds.SetEndTime(TTT.Rounds.GetEndTime() + seconds)
end

function TTT.Rounds.RemoveTime(seconds)
	TTT.Rounds.AddTime(-seconds)
end

function TTT.Rounds.EnterPrep()
	local delay = preptime:GetInt()

	if delay <= 0 then
		TTT.Rounds.Start()
	else
		TTT.Rounds.SetState(ROUND_PREP)

		-- This is only really used for client's HUDs at this point.
		TTT.Rounds.SetEndTime(CurTime() + delay)

		timer.Create("TTT_Rounds_PrepTime", delay, 1, function()
			TTT.Rounds.Start()
		end)
	end
end

function TTT.Rounds.EnterPost()
	local delay = posttime:GetInt()

	TTT.Rounds.SetEndTime(CurTime() + delay) -- For HUDs
	TTT.Rounds.SetState(ROUND_POST)

	timer.Create("TTT_Rounds_PostTime", delay, 1, function()
		TTT.Rounds.EnterPrep()
	end)
end

function TTT.Rounds.Start()
	if preventstart:GetBool() or hook.Call("TTT_Rounds_ShouldStart", GM) == false or #TTT.Roles.GetActivePlayers() < minimum_players:GetInt() then
		return
	end

	TTT.Roles.PickRoles()
	TTT.Roles.Sync()

	TTT.Rounds.SetState(ROUND_ACTIVE)
	TTT.Rounds.SetEndTime(CurTime() + roundtime:GetFloat())
end

function TTT.Rounds.End(wintype)
	TTT.Roles.Clear()
	
	if posttime:GetInt() <= 0 then
		TTT.Rounds.EnterPrep()
	else
		TTT.Rounds.EnterPost()
	end
end

function TTT.Rounds.Waiting()
	TTT.Rounds.SetEndTime(0)
	TTT.Rounds.SetState(ROUND_WAITING)
	
	if timer.Exists("TTT_Rounds_PrepTime") then
		timer.Remove("TTT_Rounds_PrepTime")
	elseif timer.Exists("TTT_Rounds_PostTime") then
		timer.Remove("TTT_Rounds_PostTime")
	end
end

function TTT.Rounds.ShouldEnd()
	if preventwin:GetBool() or hook.Call("TTT_Rounds_ShouldEnd", GM) == false then
		return false
	end

	local numplys = #TTT.Roles.GetActivePlayers()
	local wintype = false

	if numplys == #TTT.Roles.GetDetectives() + #TTT.Roles.GetInnocents() then
		wintype = WIN_INNOCENT		
	elseif numplys == #TTT.Roles.GetTraitors() then
		wintype = WIN_TRAITOR
	end

	return wintype
end

hook.Add("PostPlayerDeath", "TTT_CheckRound", function(ply)
	local wintype = TTT.Rounds.ShouldEnd()

	if wintype then
		TTT.Rounds.End(wintype)
	end
end)

hook.Add("Initialize", "TTT_Rounds_CheckStatus", function()
	timer.Create("TTT_Rounds_CheckStatus", 1, 0, function()
		local roundstate = TTT.Rounds.GetState()

		if #TTT.Roles.GetActivePlayers() >= minimum_players:GetInt() then
			if roundstate == ROUND_WAITING then
				TTT.Rounds.EnterPrep()
			elseif roundstate == ROUND_ACTIVE then
				local wintype = TTT.Rounds.ShouldEnd()
				if wintype then
					TTT.Rounds.End(wintype)
				end
			end

		elseif roundstate ~= ROUND_WAITING then
			TTT.Rounds.Waiting()
		end
	end)
end)