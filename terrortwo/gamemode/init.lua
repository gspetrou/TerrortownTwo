AddCSLuaFile("library/_prelib.lua")	-- Will load the library
include("library/_prelib.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

----------------
-- Player Hooks
----------------
function GM:PlayerInitialSpawn(ply)
	TTT.Roles.SetupSpectator(ply)
	TTT.Languages.SendDefaultLanguage(ply)
end

function GM:PlayerSpawn(ply)
	-- If something needs to spawn a player mid-game and doesn't want to deal with this function it can enable ply.ttt_silentspawn.
	if ply.ttt_silentspawn then
		if ply:IsSpectator() or TTT.Rounds.IsActive() or TTT.Rounds.IsPost() then
			TTT.Roles.SpawnInFlyMode(ply)
		else
			TTT.Roles.SpawnAsPlayer(ply)
		end
	end
	
	ply:SetupHands()					-- Get c_ hands working.
end

function GM:PlayerDeath(ply)

end

function GM:PostPlayerDeath(ply)
	TTT.Rounds.CheckForRoundEnd()
end

function GM:PlayerDisconnected(ply)
	timer.Simple(1, function()	-- Wait till they actually disconnect.
		TTT.Rounds.CheckForRoundEnd()
	end)
end

function GM:PlayerSetHandsModels(ply, ent)
	-- Get c_ hands working.
	local simplemodel = player_manager.TranslateToPlayerModelName(ply:GetModel())
	local info = player_manager.TranslatePlayerHands(simplemodel)
	if info then
		ent:SetModel(info.model)
		ent:SetSkin(info.skin)
		ent:SetBodyGroups(info.body)
	end
end

---------------
-- Round Hooks
---------------
hook.Add("TTT.Rounds.Initialize", "TTT", function()
	if TTT.Rounds.ShouldStart() then
		TTT.Rounds.EnterPrep()
	else
		TTT.Rounds.WaitForStart()
	end
end)

hook.Add("TTT.Rounds.ShouldStart", "TTT", function()
	if GetConVar("ttt_dev_preventstart"):GetBool() or #TTT.Roles.GetActivePlayers() < GetConVar("ttt_minimum_players"):GetInt() then
		return false
	end
	
	return true
end)

hook.Add("TTT.Rounds.ShouldEnd", "TTT", function()
	if not TTT.Rounds.IsActive() or GetConVar("ttt_dev_preventwin"):GetBool() then
		return false
	end

	local numAlive, numaliveTraitors, numaliveInnocents, numaliveDetectives = 0, 0, 0, 0
	for i, v in ipairs(TTT.Roles.GetAlivePlayers()) do
		numAlive = numAlive + 1

		if v:IsInnocent() then
			numaliveInnocents = numaliveInnocents + 1
		elseif v:IsTraitor() then
			numaliveTraitors = numaliveTraitors + 1
		elseif v:IsDetective() then
			numaliveDetectives = numaliveDetectives + 1
		end
	end

	if numAlive == 0 then
		return WIN_TRAITOR
	end

	local numplys = #TTT.Roles.GetAlivePlayers()
	if TTT.Rounds.GetRemainingTime() <= 0 then
		return WIN_TIME
	elseif numplys == numaliveTraitors then
		return WIN_TRAITOR
	elseif numplys == (numaliveInnocents + numaliveDetectives) then
		return WIN_INNOCENT
	end

	return false
end)

hook.Add("TTT.Rounds.RoundStarted", "TTT", function()
	for i, v in ipairs(TTT.Roles.GetDeadPlayers()) do
		TTT.Roles.SpawnMidRound(v) -- Technically the round already started.
	end
	TTT.Roles.PickRoles()
	TTT.Roles.Sync()
end)

hook.Add("TTT.Rounds.EnteredPrep", "TTT", function()
	TTT.MapHandler.ResetMap()
	TTT.Roles.Clear()
end)

--------------
-- Role Hooks
--------------
hook.Add("TTT.Roles.PlayerBecameSpectator", "TTT", function(ply)
	TTT.Rounds.CheckForRoundEnd()
end)
hook.Add("TTT.Roles.PlayerExittedSpectator", "TTT", function(ply)
	if not TTT.Rounds.IsActive() or not TTT.Rounds.IsPost() then
		TTT.Roles.SpawnAsPlayer(ply)
	end
end)