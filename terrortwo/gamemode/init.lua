AddCSLuaFile("util.lua")		-- Mini utility library to load beforehand and be used throughought the gamemode.
AddCSLuaFile("lib_loader.lua")	-- Loads the library loader
AddCSLuaFile("shared.lua")

include("util.lua")
include("lib_loader.lua")
include("shared.lua")

---------------------
-- Map Related Hooks
---------------------
function GM:IsSpawnpointSuitable(ply, spawn, force)
	return TTT.Map.CanSpawnHere(ply, spawn, force)
end

function GM:PlayerSelectSpawn(ply)
	return TTT.Map.SelectSpawnPoint(ply)
end

-- When the map resets make spectators move back to a spawn point.
-- Make non-spectators spawn again (at a spawn point).
hook.Add("TTT.Map.OnReset", "TTT", function()
	TTT.Map.RunImportScriptMapSettings()	-- If the map passes any import script settings load them up here.
	TTT.Weapons.PlaceEntities()				-- Place weapons, entities, and spawns as necessary.

	-- Spawn players around the map.
	local randomSpectatorSpawnPoint = table.RandomSequential(TTT.Map.GetSpawnEntities()):GetPos() + Vector(0, 0, 64)
	for i, ply in ipairs(player.GetAll()) do
		if not ply:IsSpectator() then
			if ply:IsInFlyMode() then
				ply:UnSpectate()
			end

			ply:Spawn()
		else
			ply:SetPos(randomSpectatorSpawnPoint)
		end
	end
end)

-- Called immediately after TTT.Map.OnReset to handle any map settings that may have been set by the import script.
hook.Add("TTT.Map.HandleImportScriptSetting", "TTT", function(key, value)
	if key == "replacespawns" and value == "1" then
		for i, ent in ipairs(TTT.Map.GetSpawnEntities()) do
			ent.BeingRemoved = true -- Remove entity next tick.
			ent:Remove()
		end
	end
end)

-- The player must be alive, a traitor, and within the usable range to use thr traitor button.
hook.Add("TTT.Map.TraitorButtons.CanUse", "TTT", function(ply, btn)
	return ply:Alive() and ply:IsTraitor() and ply:GetPos():Distance(btn:GetPos()) < btn:GetUsableRange()
end)

-----------------
-- General Hooks
-----------------
local ipairs, player_GetAll = ipairs, player.GetAll
function GM:Tick()
	for i, ply in ipairs(player_GetAll()) do
		if ply:Alive() then
			TTT.Player.HandleDrowning(ply)
		else
			TTT.Player.HandleDeathSpectating(ply)
		end
	end
end

function GM:KeyPress(ply, key)
	if not ply:Alive() and not ply:IsSpectatingCorpse() then
		ply:ResetViewRoll()
		TTT.Player.HandleSpectatorKeypresses(ply, key)
	end
end

----------------
-- Player Hooks
----------------
function GM:PlayerInitialSpawn(ply)
	TTT.Library.InitPlayerSQLData(ply)
	TTT.Roles.SetupAlwaysSpectate(ply)
	TTT.Rounds.TellClientCurrentRoundState(ply)
	TTT.Languages.SendDefaultLanguage(ply)
	TTT.Player.SetSpeeds(ply)

	if ply:IsSpectator() then
		local randomSpawn = table.RandomSequential(TTT.Map.GetSpawnEntities())
		ply:SetPos(randomSpawn:GetPos() + Vector(0, 0, 64))	-- If theyre a spectator then put them at a random spawn point.
	end
end

function GM:PlayerSpawn(ply)
	ply:ResetViewRoll()

	-- If something needs to spawn a player mid-game and doesn't want to deal with this function it can enable ply.ttt_OverrideSpawn.
	if ply.ttt_OverrideSpawn ~= true then
		local isspec
		if ply:IsSpectator() or TTT.Rounds.IsActive() or TTT.Rounds.IsPost() then
			self:PlayerSpawnAsSpectator(ply)
			isspec = true
		else
			ply:UnSpectate()
			ply:SetInFlyMode(false)
			ply:SetupHands()
			isspec = false

			net.Start("TTT.Player.SwitchedFlyMode")
				net.WriteBool(false)
			net.Send(ply)
		end

		self:PlayerSetModel(ply)
		self:PlayerLoadout(ply)		-- Doesn't do anything, backwards compatability.
		hook.Call("TTT.Player.PostPlayerSpawn", nil, ply, isspec)
	end
end

hook.Add("TTT.Player.PostPlayerSpawn", "TTT", function(ply, isSpec)
	TTT.Weapons.StripCompletely(ply)

	if not isSpec then
		TTT.Weapons.GiveStarterWeapons(ply)
		ply:SelectWeapon("weapon_ttt_unarmed")
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
	TTT.Corpse.CreateBody(ply, attacker, dmginfo)
	TTT.Player.RecordDeathPos(ply)	-- Record  their death position so that their spectator camera spawns here.
	if TTT.Rounds.IsPrep() then
		ply:GetCorpse():SetRemoveOnRoundStart(true)
	end
end

function GM:PlayerDeath(ply, inflictor, attacker)
	ply:Flashlight(false)
	ply:Extinguish()
end

hook.Add("TTT.Corpse.ShouldCreateBody", "TTT", function(ply)
	if ply:IsInFlyMode() or ply:IsSpectator() then
		return false
	end
	return true
end)

function GM:PostPlayerDeath(ply)
	TTT.Rounds.CheckForRoundEnd()

	-- If the player dies immediately respawn them so they can spectate.
	-- If they die during prep then make them wait till round start to prevent people from spamming respawn.
	if TTT.Rounds.IsPrep() then
		TTT.Player.SpawnInFlyMode(ply)
	else
		ply:Spawn()
	end
end

function GM:PlayerDisconnected(ply)
	timer.Create("TTT.WaitForFullPlayerDisconnect", .5, 0, function()
		if not IsValid(ply) then
			TTT.Rounds.CheckForRoundEnd()
			timer.Remove("TTT.WaitForFullPlayerDisconnect")
		end
	end)
end

-- Get c_ hands working.
function GM:PlayerSetHandsModels(ply, ent)
	local simplemodel = player_manager.TranslateToPlayerModelName(ply:GetModel())
	local info = player_manager.TranslatePlayerHands(simplemodel)
	if info then
		ent:SetModel(info.model)
		ent:SetSkin(info.skin)
		ent:SetBodyGroups(info.body)
	end
end

hook.Add("TTT.Player.ForcedSpawnedPlayer", "TTT", function(ply, resetSpawn, shouldarm, giveRoleGear)
	TTT.Weapons.StripCompletely(ply)

	if resetSpawn then
		TTT.Map.PutPlayerAtRandomSpawnPoint(ply)
	else
		ply:SetPos(ply.ttt_noResetSpawnPos)
		ply:SetEyeAngles(ply.ttt_noResetSpawnAng)
	end
			
	if shouldarm then
		TTT.Weapons.GiveStarterWeapons(ply)
	else
		ply:Give("weapon_ttt_unarmed")	-- If the player isn't carrying anything the console will be spammed with annoying red text.
	end

	if giveRoleGear then
		TTT.Weapons.GiveRoleWeapons(ply)
		TTT.Equipment.GiveRoleEquipment(ply)
	end
end)

-- Only spray when alive.
function GM:PlayerSpray(ply)
	if not IsValid(ply) or not ply:Alive() then
		return true
	end
end

-- Disallow player taunting.
function GM:PlayerShouldTaunt()
	return false
end

-- Only allow people who are actually alive to die.
function GM:CanPlayerSuicide(ply)
	if ply:Alive() then
		return true
	end
	return false
end

-- Get rid of the death beeps.
function GM:PlayerDeathSound()
	return true
end

-- Disable pressing USE to pick stuff up.
function GM:AllowPlayerPickup()
   return false
end

function GM:PlayerSwitchFlashlight(ply)
	return ply:Alive()
end

---------------
-- Round Hooks
---------------
-- Initialize the round system.
hook.Add("TTT.Rounds.Initialize", "TTT", function()
	if TTT.Rounds.ShouldStart() then
		TTT.Rounds.EnterPrep()
	else
		TTT.Rounds.WaitForStart()
	end
end)

-- Check if the round should start.
hook.Add("TTT.Rounds.ShouldStart", "TTT", function()
	if GetConVar("ttt_dev_preventstart"):GetBool() or #TTT.Roles.GetActivePlayers() < GetConVar("ttt_minimum_players"):GetInt() then
		return false
	end
	
	return true
end)

-- Check if the round should end.
hook.Add("TTT.Rounds.ShouldEnd", "TTT", function()
	if not TTT.Rounds.IsActive() or GetConVar("ttt_dev_preventwin"):GetBool() then
		return false
	end

	if TTT.Rounds.GetRemainingTime() <= 0 then
		return WIN_TIME
	end

	local numAlive, numaliveTraitors, numaliveInnocents, numaliveDetectives = 0, 0, 0, 0
	for i, v in ipairs(TTT.Player.GetAlivePlayers()) do
		if v:IsInnocent() then
			numaliveInnocents = numaliveInnocents + 1
		elseif v:IsTraitor() then
			numaliveTraitors = numaliveTraitors + 1
		elseif v:IsDetective() then
			numaliveDetectives = numaliveDetectives + 1
		end
		numAlive = numAlive + 1
	end

	if (numaliveTraitors + numaliveInnocents + numaliveDetectives) == 0 then
		return WIN_TRAITOR
	end

	if numAlive == numaliveTraitors then
		return WIN_TRAITOR
	elseif numAlive == (numaliveInnocents + numaliveDetectives) then
		return WIN_INNOCENT
	end

	return false
end)

hook.Add("TTT.Rounds.RoundEnded", "TTT", function(type)
	TTT.Map.TriggerRoundStateOutsputs(ROUND_POST, type)
end)

hook.Add("TTT.Rounds.RoundStarted", "TTT", function()
	TTT.Map.TriggerRoundStateOutsputs(ROUND_ACTIVE)

	-- Delete any entities marked for deletion at round start.
	for i, v in ipairs(ents.GetAll()) do
		if v:GetRemoveOnRoundStart() then
			v:Remove()
		end
	end

	for i, v in ipairs(TTT.Player.GetDeadPlayers()) do
		TTT.Player.ForceSpawnPlayer(v, true, true, false) -- Technically the round already started. Force spawn all players that managed to die in prep.
	end

	TTT.Roles.PickRoles()
	TTT.Roles.Sync()

	for i, ply in ipairs(player.GetAll()) do
		TTT.Weapons.GiveRoleWeapons(ply)		-- Give all players the weapons for their newly given roles.
		TTT.Equipment.GiveRoleEquipment(ply)	-- Give all players the equipment their role starts with.
	end

	timer.Simple(1, function()
		TTT.Rounds.CheckForRoundEnd()	-- Could happen if ttt_dev_preventwin is 0 and ttt_minimum_players is <= 1.
	end)
end)

hook.Add("TTT.Rounds.EnteredPrep", "TTT", function()
	TTT.Map.ResetMap()
	TTT.Map.TriggerRoundStateOutsputs(ROUND_PREP)
	TTT.Roles.Clear()
	
	local col = hook.Call("TTT.Player.SetDefaultSpawnColor")
	if not IsColor(col) then
		col = TTT.Player.GetRandomPlayerColor()
	end
	TTT.Player.SetDefaultModelColor(col)	-- Set a new color for players each round.

	for i, ply in ipairs(player.GetAll()) do
		ply:ClearEquipment()
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