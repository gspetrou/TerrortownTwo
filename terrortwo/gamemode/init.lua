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
	ply:SetupHands()					-- Get c_ hands working.
end

function GM:PlayerDeath(ply)

end

function GM:PostPlayerDeath(ply)
	TTT.Rounds.CheckForRoundEnd()
end

function GM:PlayerDisconnected(ply)
	TTT.Rounds.CheckForRoundEnd()
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
		timer.Create("TTT.Rounds.WaitForStart", 1, 0, function()
			if TTT.Rounds.ShouldStart() then
				timer.Remove("TTT.Rounds.WaitForStart")
				TTT.Rounds.EnterPrep()
			end
		end)
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

	local numaliveTraitors, numaliveInnocents, numaliveDetectives = 0, 0, 0
	for i, v in ipairs(player.GetAll()) do
		if v:Alive() then
			if v:IsInnocent() then
				numaliveInnocents = numaliveInnocents + 1
			elseif v:IsTraitor() then
				numaliveTraitors = numaliveTratiors + 1
			elseif v:IsDetective() then
				numaliveDetectives = numaliveDetectives + 1
			end
		end
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
	TTT.Roles.PickRoles()
	TTT.Roles.Sync()
end)

hook.Add("TTT.Rounds.RoundEnded", "TTT", function(wintype)
	TTT.Roles.Clear()
end)

hook.Add("TTT.Rounds.MapEnded", "TTT", function()
	TTT.MapHandler.HandleMapSwitch()
end)