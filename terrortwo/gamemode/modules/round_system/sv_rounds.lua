util.AddNetworkString("TTT_ChangeRoundState")
local preventwin = CreateConVar("ttt_dev_preventwin", "0", nil, "Set to 1 to prevent the rounds from ending.")
local preventstart = CreateConVar("ttt_dev_preventstart", "0", nil, "Set to 1 to prevent the round from starting.")
local posttime = CreateConVar("ttt_post_time", "30", nil, "Time in seconds after a round has ended till the game goes into prep. Set to 0 to skip post round time.")
local preptime = CreateConVar("ttt_prep_time", "30", nil, "Time in seconds after the round has entered preperation time till the round actually starts.")
local roundtime = CreateConVar("ttt_roundtime_seconds", "600", nil, "How long is the round in seconds. This is before any extensions are added to it like haste or overtime.")
local minimum_players = CreateConVar("ttt_minimum_players", "2", nil, "This many players is required for a round to start.")

function TTT.SetRoundState(state)
	local newstate = hook.Call("TTT_RoundStateChanged", GM, state) or state
	TTT.RoundState = newstate

	net.Start("TTT_ChangeRoundState")
		net.WriteUInt(newstate, 4)
	net.Broadcast()

	print("Round state changed to: ".. TTT.RoundTypeToPrint(state))
end

local function StartPrepOrActive()
	if math.max(preptime:GetInt(), 0) == 0 then
		TTT.SetRoundState(ROUND_ACTIVE)
	else
		TTT.SetRoundState(ROUND_PREP)
	end
end

function TTT.StartRound()
	if preventstart:GetBool() or hook.Call("TTT_ShouldStartRound", GM) == false or #TTT.GetActivePlayers() < minimum_players:GetInt() then
		return
	end

	TTT.PickRoles()
	TTT.SyncRoles()

	TTT.SetRoundState(ROUND_ACTIVE)
	SetGlobalFloat("ttt_roundend_time", CurTime() + roundtime:GetFloat())
end

function TTT.EndRound()
	if preventwin:GetBool() or hook.Call("TTT_ShouldEndRound", GM) == false then
		return
	end

	local delay = math.max(posttime:GetInt(), 0)

	if delay == 0 then
		StartPrepOrActive()
	else
		TTT.SetRoundState(ROUND_POST)

		timer.Create("TTT_PostTillPrep", delay, 1, function()
			StartPrepOrActive()
		end)
	end
end

hook.Add("TTT_RoundStateChanged", "TTT_RoundController", function(state)
	if state == ROUND_PREP then
		local delay = math.max(preptime:GetInt(), 0)

		timer.Create("TTT_PrepTillActive", delay, 1, function()
			TTT.StartRound()
		end)
	elseif state == ROUND_ACTIVE then
		timer.Create("TTT_ActiveTillPost", 1, 0, function()
			if CurTime() > TTT.GetRoundEndTime() then
				TTT.EndRound()
				timer.Remove("TTT_ActiveTillPost")
			end
		end)
	end
end)

hook.Add("PostPlayerDeath", "TTT_CheckRound", function(ply)
	if #TTT.GetActivePlayers() < 2 then
		TTT.EndRound()
	end
end)

hook.Add("PlayerInitialSpawn", "TTT_StartOnPlayerConnect", function(ply)

end)

timer.Create("TTT_CheckRoundStatus", 1, 0, function()
	if TTT.GetRoundState() == ROUND_WAITING and #TTT.GetActivePlayers() >= minimum_players:GetInt() then
		TTT.StartRound()
	end
end)