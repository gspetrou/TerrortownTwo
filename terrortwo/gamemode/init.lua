AddCSLuaFile("util.lua")		-- Mini utility library to load beforehand and be used throughought the gamemode.
AddCSLuaFile("lib_loader.lua")	-- Loads the library loader
AddCSLuaFile("shared.lua")

include("util.lua")
include("lib_loader.lua")
include("shared.lua")

-----------------
-- General Hooks
-----------------
function GM:IsSpawnpointSuitable(ply, spawn, force)
	return TTT.Map.CanSpawnHere(ply, spawn, force)
end

function GM:PlayerSelectSpawn(ply)
	return TTT.Map.SelectSpawnPoint(ply)
end

----------------
-- Player Hooks
----------------
function GM:PlayerInitialSpawn(ply)
	TTT.Library.InitPlayerSQLData(ply)
	TTT.Roles.SetupAlwaysSpectate(ply)
	TTT.Languages.SendDefaultLanguage(ply)
	TTT.Player.SetSpeeds(ply)
end

function GM:PlayerSpawn(ply)
	ply:ResetViewRoll()

	-- If something needs to spawn a player mid-game and doesn't want to deal with this function it can enable ply.ttt_OverrideSpawn.
	if ply.ttt_OverrideSpawn ~= true then
		if ply:IsSpectator() or TTT.Rounds.IsActive() or TTT.Rounds.IsPost() then
			self:PlayerSpawnAsSpectator(ply)
			hook.Call("TTT.Player.PostPlayerSpawn", nil, ply, true)
		else
			ply:UnSpectate()
			ply.ttt_InFlyMode = false
			ply:SetupHands()
			hook.Call("TTT.Player.PostPlayerSpawn", nil, ply, false)
		end
	end

	self:PlayerSetModel(ply)
	self:PlayerLoadout(ply)		-- Doesn't do anything, backwards compatability.
end

hook.Add("TTT.Player.PostPlayerSpawn", "TTT", function(ply, isSpec)
	TTT.Weapons.StripCompletely(ply)

	if not isSpec then
		TTT.Weapons.GiveStarterWeapons(ply)
	end
end)

function GM:PlayerSetModel(ply)			-- For backwards compatability.
	TTT.Player.SetModel(ply)
	TTT.Player.SetModelColor(ply)
end

function GM:PlayerSpawnAsSpectator(ply)	-- For backwards compatability.
	TTT.Player.SpawnInFlyMode(ply)
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)
	--ply.ttt_deathrag = TTT.Corpse.Create(ply, dmginfo)
	--TTT.Corpse.SetRagdollData(ply.ttt_deathrag, ply, attacker, dmginfo)
end

-- Get rid of the death beeps.
function GM:PlayerDeathSound()
	return true
end

function GM:PlayerDeath(ply)
	TTT.Player.RecordDeathPos(ply)
	ply:Flashlight(false)
	ply:Extinguish()
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
	if ply:Alive() then
		return true
	end
	return false
end

-- Disallow player taunting.
function GM:PlayerShouldTaunt()
	return false
end

local PLAYER = FindMetaTable("Player")
TTT.OldAlive = TTT.OldAlive or PLAYER.Alive
function PLAYER:Alive()
	if self:IsSpectator() or self:IsInFlyMode() then
		return false
	end
	return TTT.OldAlive(self)
end

hook.Add("TTT.Player.ForceSpawnedPlayer", "TTT", function(ply, resetSpawn, shouldarm)
	if resetSpawn then
		TTT.Map.PutPlayerAtRandomSpawnPoint(ply)
	end
	if shouldarm then
		TTT.Weapons.StripCompletely(ply)
		TTT.Weapons.GiveStarterWeapons(ply)
		TTT.Weapons.GiveRoleWeapons(ply)
	end
end)

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
	for i, v in ipairs(TTT.Player.GetAlivePlayers()) do
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

	local numplys = #TTT.Player.GetAlivePlayers()
	if numplys == numaliveTraitors then
		return WIN_TRAITOR
	elseif numplys == (numaliveInnocents + numaliveDetectives) then
		return WIN_INNOCENT
	end

	return false
end)

hook.Add("TTT.Rounds.RoundStarted", "TTT", function()
	for i, v in ipairs(TTT.Player.GetDeadPlayers()) do
		TTT.Player.ForceSpawnPlayer(v, true) -- Technically the round already started.
	end
	TTT.Roles.PickRoles()
	TTT.Roles.Sync()

	for i, ply in ipairs(player.GetAll()) do
		TTT.Weapons.GiveRoleWeapons(ply)	-- Give all player's the weapons for their newly given roles.
	end

	timer.Simple(1, function()
		TTT.Rounds.CheckForRoundEnd()	-- Could happen if ttt_dev_preventwin is 0 and ttt_minimum_players is <= 1.
	end)
end)

hook.Add("TTT.Rounds.EnteredPrep", "TTT", function()
	TTT.Player.SetDefaultModelColor(TTT.Player.GetRandomPlayerColor())
	TTT.Map.ResetMap()
	TTT.Roles.Clear()

	local defaultWeapon = GetConVar("ttt_weapons_default"):GetString()
	for i, ply in ipairs(TTT.Player.GetAlivePlayers()) do
		TTT.Weapons.StripCompletely(ply)
		TTT.Weapons.GiveStarterWeapons(ply)

		ply:SelectWeapon(defaultWeapon)
	end
end)

--------------
-- Role Hooks
--------------
hook.Add("TTT.Roles.PlayerBecameSpectator", "TTT", function(ply)
	TTT.Rounds.CheckForRoundEnd()
end)

hook.Add("TTT.Roles.PlayerExittedSpectator", "TTT", function(ply)
	if not TTT.Rounds.IsActive() and not TTT.Rounds.IsPost() then
		TTT.Player.ForceSpawnPlayer(ply, true)
		hook.Call("PlayerSetModel", nil, ply)
	end
end)

----------------
-- Weapon Hooks
----------------
function GM:PlayerCanPickupWeapon(ply, wep)
	return TTT.Weapons.CanPickupWeapon(ply, wep)
end

hook.Add("TTT.Weapons.DroppedWeapon", "TTT", function(ply, wep)
	-- TODO: PLAY WEAPON DROP ANIMATION!
end)