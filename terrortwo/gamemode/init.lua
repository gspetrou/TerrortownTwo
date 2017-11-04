AddCSLuaFile("library/_prelib.lua")	-- Will load the library
include("library/_prelib.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-----------------
-- General Hooks
-----------------
function GM:InitPostEntity()
	TTT.Weapons.Precache()
end

----------------
-- Player Hooks
----------------
function GM:PlayerInitialSpawn(ply)
	TTT.Roles.SetupSpectator(ply)
	TTT.Languages.SendDefaultLanguage(ply)
end

function GM:PlayerSpawn(ply)
	-- If something needs to spawn a player mid-game and doesn't want to deal with this function it can enable ply.ttt_OverrideSpawn.
	if ply.ttt_OverrideSpawn ~= true then
		if ply:IsSpectator() or TTT.Rounds.IsActive() or TTT.Rounds.IsPost() then
			self:PlayerSpawnAsSpectator(ply)
		else
			TTT.Roles.SpawnAsPlayer(ply, true)
		end
	end
	
	self:PlayerSetModel(ply)
	ply:SetupHands()					-- Get c_ hands working.
end

function GM:PlayerSetModel(ply)			-- For backwards compatability.
	TTT.Player.SetModel(ply)
end

function GM:PlayerSpawnAsSpectator(ply)	-- For backwards compatability.
	TTT.Roles.SpawnInFlyMode(ply)
end

function GM:PlayerDeath(ply)

end

function GM:PostPlayerDeath(ply)
	TTT.Rounds.CheckForRoundEnd()
end

function GM:PlayerDisconnected(ply)
	timer.Create("TTT.WaitForFullPlayerDisconnect", .5, 0, function()
		if not IsValid(ply) then
			TTT.Rounds.CheckForRoundEnd()
			timer.Remove("TTT.WaitForFullPlayerDisconnect")
		end
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

-- Only allow people who are actually alive to die.
function GM:CanPlayerSuicide(ply)
	if not ply:IsInFlyMode() then
		return true
	end
	return false
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

	if TTT.Rounds.GetRemainingTime() <= 0 then
		return WIN_TIME
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
	if numplys == numaliveTraitors then
		return WIN_TRAITOR
	elseif numplys == (numaliveInnocents + numaliveDetectives) then
		return WIN_INNOCENT
	end

	return false
end)

hook.Add("TTT.Rounds.RoundStarted", "TTT", function()
	for i, v in ipairs(TTT.Roles.GetDeadPlayers()) do
		TTT.Roles.ForceSpawn(v) -- Technically the round already started.
	end
	TTT.Roles.PickRoles()
	TTT.Roles.Sync()

	timer.Simple(1, function()
		TTT.Rounds.CheckForRoundEnd()	-- Could happen if ttt_dev_preventwin is 0 and ttt_minimum_players is <= 1.
	end)
end)

hook.Add("TTT.Rounds.EnteredPrep", "TTT", function()
	TTT.Player.SetDefaultModelColor(TTT.Player.GetRandomPlayerColor())
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
		TTT.Player.SetModel(ply)
	end
end)

hook.Add("TTT.Roles.PlayerSpawned", "TTT", function(ply, resetSpawn, wasForced)
	if resetSpawn then
		TTT.MapHandler.PutPlayerAtRandomSpawnPoint(ply)
	end
	
	TTT.Weapons.StripCompletely(ply)
	TTT.Weapons.GiveStarterWeapons(ply)
end)

hook.Add("TTT.Roles.PlayerSpawnedInFlyMode", "TTT", function(ply)
	TTT.Weapons.StripCompletely(ply)
end)

----------------
-- Weapon Hooks
----------------
function GM:PlayerCanPickupWeapon(ply, wep)
	if not IsValid(ply) or not ply:IsActive() then
		return false
	end

	if wep.Kind == nil then
		error("Player tried to pickup weapon with missing SWEP.Kind. Class name: '".. wep.ClassName .."'.")
	end

	if TTT.Weapons.HasWeaponInSlot(ply, wep.Kind) then
		return false
	end

	return true
end

hook.Add("TTT.Weapons.DroppedWeapon", "TTT", function(ply, wep)
	-- TODO: PLAY WEAPON DROP ANIMATION!
end)