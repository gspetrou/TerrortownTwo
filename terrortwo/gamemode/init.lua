AddCSLuaFile("util.lua")		-- Mini utility library to load beforehand and be used throughought the gamemode.
AddCSLuaFile("lib_loader.lua")	-- Loads the library loader
AddCSLuaFile("shared.lua")

include("util.lua")
include("lib_loader.lua")
include("shared.lua")

-----------------
-- General Hooks
-----------------
local player_GetAll, IsValid = player.GetAll, IsValid
function GM:Tick()
	for k = 1, player.GetCount() do
		local ply = player_GetAll[k]
		if ply:Alive() then
			TTT.Player.HandleDrowning(ply)
		else
			TTT.Player.HandleDeathSpectating(ply)
		end
	end
end

-- Set a newly connected player's karma for the edge case where they are authed after initial spawn.
function GM:NetworkIDValidated(name, steamID)
	for k = 1, player.GetCount() do
		local ply = player_GetAll[k]
		if IsValid(ply) and ply:SteamID() == steamID and ply.ttt_DelayKarmaRecall then
			TTT.Karma:LateRecallAndSet(ply)
			return
		end
	end
end

function GM:KeyPress(ply, key)
	if not ply:Alive() and not ply:IsSpectatingCorpse() then
		--ply:ResetViewRoll() -- TODO: Why am I resetting view roll here... wtf?
		TTT.Player.HandleSpectatorKeypresses(ply, key)
	end
end

-- Handle +use overrides and body searching.
function GM:KeyRelease(ply, key)
	if key == IN_USE and IsValid(ply) and ply:Alive() then
		local tr = util.TraceLine({
			start  = ply:GetShootPos(),
			endpos = ply:GetShootPos() + ply:GetAimVector() * 84,
			filter = ply,
			mask   = MASK_SHOT
		})

		if tr.Hit and IsValid(tr.Entity) then
			if tr.Entity.CanUseKey and tr.Entity.UseOverride then
				local phys = tr.Entity:GetPhysicsObject()
				if IsValid(phys) and not phys:HasGameFlag(FVPHYSICS_PLAYER_HELD) then
					tr.Entity:UseOverride(ply)
				end
				return true
			elseif tr.Entity:IsCorpse() then
				TTT.Corpse.Search(ply, tr.Entity, ply:KeyDown(IN_WALK) or ply:KeyDownLast(IN_WALK))
				return true
			end
		end
	end
end

-- The GetFallDamage hook does not get called until around 600 speed, which is a
-- rather high drop already. Hence we do our own fall damage handling in OnPlayerHitGround.
function GM:GetFallDamage(ply, speed)
	return 0
end

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
	for k = 1, player.GetCount() do
		local ply = player_GetAll[k]
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
		for k = 1, #TTT.Map.GetSpawnEntities() do
			local ent = TTT.Map.GetSpawnEntities()[k]
			ent.BeingRemoved = true -- Remove entity next tick.
			ent:Remove()
		end
	end
end)

-- The player must be alive, a traitor, and within the usable range to use thr traitor button.
hook.Add("TTT.Map.TraitorButtons.CanUse", "TTT", function(ply, btn)
	return ply:Alive() and ply:IsTraitor() and ply:GetPos():Distance(btn:GetPos()) < btn:GetUsableRange()
end)


----------------
-- Player Hooks
----------------
function GM:PlayerInitialSpawn(ply)
	TTT.Library.InitPlayerSQLData(ply)
	TTT.Roles.SetupAlwaysSpectate(ply)
	TTT.Rounds.TellClientCurrentRoundState(ply)
	TTT.Languages.SendDefaultLanguage(ply)
	TTT.Player.SetSpeeds(ply)
	TTT.Karma:InitPlayer(ply)

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
		self:PlayerLoadout(ply, false)
		hook.Call("TTT.Player.PostPlayerSpawn", nil, ply, false)
	end
end

function GM:PlayerLoadout(ply, forceSpawned, forceArm, forceGear)
	TTT.Weapons.StripCompletely(ply)

	if ply:IsSpectator() then
		return
	end

	if not forceSpawned then
		TTT.Weapons.GiveStarterWeapons(ply)	-- Dont give role gear on a normal spawn, that will happen at round start.
	else
		if forceArm then
			TTT.Weapons.GiveStarterWeapons(ply)
		else
			ply:Give("weapon_ttt_unarmed")	-- If the player isn't carrying anything the console will be spammed with annoying red text.
		end

		if forceGear then
			TTT.Weapons.GiveRoleWeapons(ply)
			TTT.Equipment.GiveRoleEquipment(ply)
		end
	end

	ply:SelectWeapon("weapon_ttt_unarmed")	-- The game assumes every alive player has at least the unarmed weapon. Having no weapon spams the console with errors (thanks gmod).
end

hook.Add("TTT.Player.PostPlayerSpawn", "TTT", function(ply, forced)
	
end)

function GM:PlayerSetModel(ply)			-- For backwards compatability.
	TTT.Player.SetModel(ply)
	TTT.Player.SetModelColor(ply)
end

function GM:PlayerSpawnAsSpectator(ply)	-- For backwards compatability.
	TTT.Player.SpawnInFlyMode(ply)
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)
	if ply:IsSpectator() or ply:IsInFlyMode() then
		hook.Call("TTT.Player.SpecDoPlayerDeath", nil, ply, attacker, dmginfo)
		return
	end

	-- Shoot a dying shot.
	if GetConVar("ttt_weapon_dyingshot"):GetBool() and ply:CanDyingShot() then
		local weapon = ply:GetActiveWeapon()
		if IsValid(weapon) and weapon.DyingShot and dmginfo:IsBulletDamage() and not ply:WasHeadshotted() then
			weapon:DyingShot()
		end
	end

	local ragdoll = TTT.Corpse.CreateBody(ply, attacker, dmginfo)	-- Create body.
	TTT.Player.RecordDeathPos(ply)	-- Record their death position so that their spectator camera spawns here.
	TTT.Player.StoreDeathInfo(ply, dmginfo)	-- Store the death CTakeDamageInfo so we can refer to it later.

	-- Remove the body at round start if they died during prep.
	if TTT.Rounds.IsPrep() then
		ply:GetCorpse():SetRemoveOnRoundStart(true)
	end

	-- Drop all weapons on death.
	for k, weapon in next, ply:GetWeapons() do
		TTT.Weapons.DropWeapon(ply, weapon, true)
		weapon:DampenDrop()
	end

	TTT.Player.CreateDeathEffects(ply)
	TTT.StartBleeding(ragdoll, dmginfo:GetDamage(), math.random(10, 20))
	TTT.Karma:Killed(attacker, ply, dmginfo)

	local killWeapon = TTT.WeaponFromDamageInfo(dmginfo)
	if not (ply:WasHeadshotted() or dmginfo:IsDamageType(DMG_SLASH) or (IsValid(killWeapon) and killWeapon.IsSilent)) then
		TTT.Player.PlayDeathYell(ply)
	end

	-- TODO: Voice stuff.

	-- Anyone who was spectating this player while that player died should exit specate mode.
	local pos = Vector(0, 0, 25) + ply:GetPos()
	for k = 1, player.GetCount() do
		local v = player_GetAll[k]
		if v:GetObserverTarget() == ply then
			v:Spectate(OBS_MODE_ROAMING)
			v:SpectateEntity(nil)
			v:SetPos(pos)
		end
	end
end

function GM:PlayerDeath(ply, inflictor, attacker)
	ply:Flashlight(false)
	ply:Extinguish()
	TTT.Corpse.SetMissingForTraitors(ply)	-- Let traitors know that this player is now considered missing.
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
	if TTT.Karma:IsEnabled() then
		TTT.Karma:Remember(ply)
	end

	local steamID = ply:SteamID()
	timer.Create("TTT.WaitForFullPlayerDisconnect", .5, 0, function()
		if not IsValid(ply) then
			TTT.Rounds.CheckForRoundEnd()
			timer.Remove("TTT.WaitForFullPlayerDisconnect")
			hook.Call("TTT.PlayerFullyDisconnect", nil, steamID)	-- Who knows, someone might find this useful.
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

hook.Add("TTT.Player.ForcedSpawnedPlayer", "TTT", function(ply, resetSpawn, forced_Arm, forced_RoleGear)
	if resetSpawn then
		TTT.Map.PutPlayerAtRandomSpawnPoint(ply)
	else
		ply:SetPos(ply.ttt_noResetSpawnPos)
		ply:SetEyeAngles(ply.ttt_noResetSpawnAng)
	end
	
	GAMEMODE:PlayerLoadout(ply, true, forced_Arm, forced_RoleGear)
	hook.Call("TTT.Player.PostPlayerSpawn", nil, ply, true)
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

function GM:PlayerTraceAttack(ply, dmgInfo, dir, trace)
	TTT.Player.StoreDeathSceneData(ply, trace)
	return false
end

function GM:ScalePlayerDamage(ply, hitGroup, dmgInfo)
	local wasHeadShotted = false

	-- Actual damage scaling.
	if hitGroup == HITGROUP_HEAD then
		-- headshot if it was dealt by a bullet
		wasHeadShotted = dmgInfo:IsBulletDamage()

		local wep = TTT.WeaponFromDamageInfo(dmgInfo)

		if IsValid(wep) then
			local scale = wep:GetHeadshotMultiplier(ply, dmgInfo) or 2
			dmgInfo:ScaleDamage(scale)
		end
	elseif (hitGroup == HITGROUP_LEFTARM or
		hitGroup == HITGROUP_RIGHTARM or
		hitGroup == HITGROUP_LEFTLEG or
		hitGroup == HITGROUP_RIGHTLEG or
		hitGroup == HITGROUP_GEAR) then

		dmgInfo:ScaleDamage(0.55)
	end

	ply:SetWasHeadshotted(wasHeadShotted)

	if (dmgInfo:IsDamageType(DMG_DIRECT) or
		dmgInfo:IsExplosionDamage() or
		dmgInfo:IsDamageType(DMG_FALL) or
		dmgInfo:IsDamageType(DMG_PHYSGUN)) then

		dmgInfo:ScaleDamage(2)
	end
end

function GM:OnPlayerHitGround(ply, inWater, onFloater, speed)
	TTT.Player.HandleFallDamage(ply, inWater, onFloater, speed)
end

hook.Add("TTT.Player.AllowPVP", "TTT", function()
	local state = TTT.Rounds.GetState()
	return state == ROUND_ACTIVE or (state == ROUND_POST and GetConVar("ttt_rounds_postdeathmatch"):GetBool())
end)

hook.Add("TTT.Player.OnTakeDamage", "TTT", function(ply, dmgInfo)
	TTT.Player.OnTakeDamage(ply, dmgInfo)	
end)

-- Disable the built in team switching stuff the source engine uses.
function GM:PlayerRequestTeam()
end

-- Implementing stuff that should already be in gmod, chpt. 389.
function GM:PlayerEnteredVehicle(ply, vehicle)
	if IsValid(vehicle) then
		vehicle:SetNWEntity("ttt_driver", ply)
	end
end

function GM:PlayerLeaveVehicle(ply, vehicle)
	if IsValid(vehicle) then
		vehicle:SetNWEntity("ttt_driver", vehicle)	-- Setting nil will not do anything, so bogusify.
	end
end

-- Called when a spectating/dead player wants to inspect a corpse.
hook.Add("TTT.Player.WantsToSearchCorpse", "TTT", function(ply, corpse)
	TTT.Corpse.Search(ply, corpse, false)
end)

----------------
-- Entity Hooks
----------------
function GM:EntityRemoved(entity)
	if entity:IsCorpse() then
		TTT.Corpse.ClearCacheSpot(entity)
	end
end

function GM:EntityTakeDamage(ent, dmgInfo)
	if not IsValid(ent) then
		return
	end

	local attacker = dmgInfo:GetAttacker()

	-- If PVP is disabled then cancel out any prop to player or player to player damage.
	if not TTT.Player.AllowPVP() then
		if ent:IsAnExplosive() or (ent:IsPlayer() and IsValid(attacker) and attacker:IsPlayer()) then
			dmgInfo:ScaleDamage(0)
			dmgInfo:SetDamage(0)
		end

	-- Let PlayerTakeDamage handle damage dealt to players.
	elseif ent:IsPlayer() then
		TTT.Player.HandleDamage(ent, dmgInfo)

	-- Old comment here said that when a barrel hits a player the source engine counts it as the player damaging the barrel.
	-- This can lead to the dying player being blamed for their own death or even for killing their attacker. This code will prevent that.
	elseif ent:IsAnExplosive() then
		if IsValid(attacker) and attacker:IsPlayer() and dmgInfo:IsDamageType(DMG_CRUSH) and IsValid(ent:GetPhysicsAttacker()) then
			dmgInfo:SetAttacker(ent:GetPhysicsAttacker())
			dmgInfo:ScaleDamage(0)
			dmgInfo:SetDamage(0)
		end

--[[	TODO

	elseif ent.is_pinned and ent.OnPinnedDamage then
		ent:OnPinnedDamage(dmgInfo)

		dmgInfo:SetDamage(0)
]]
	end
end

-- Disable default implementation for killing NPCs, we really dont care about them in this gamemode.
function GM:OnNPCKilled()
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
	for k = 1, #TTT.Player.GetAlivePlayers() do
		local v = TTT.Player.GetAlivePlayers()[k]
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
	TTT.Karma:RoundEnd()
end)

local ents = ents
hook.Add("TTT.Rounds.RoundStarted", "TTT", function()
	TTT.Map.TriggerRoundStateOutsputs(ROUND_ACTIVE)

	-- Delete any entities marked for deletion at round start.
	for k = 1, ents.GetCount() do -- # https://wiki.garrysmod.com/page/ents/GetCount
		local v = ents.GetAll()[k]
		if v:GetRemoveOnRoundStart() then
			v:Remove()
		end
	end

	for k = 1, #TTT.Player.GetDeadPlayers() do
		TTT.Player.ForceSpawnPlayer(TTT.Player.GetDeadPlayers()[k], true, true, false) -- Technically the round already started. Force spawn all players that managed to die in prep.
	end

	TTT.Roles.PickRoles()
	TTT.Roles.Sync()

	for k = 1, player.GetCount() do
		local ply = player_GetAll[k]
		ply:SetCanDyingShot(true)				-- Enable dying shots on all the players (so long as ttt_weapon_dyingshot is enabled).
		ply:ClearPushData()						-- Clear data stored about the last time the player was pushed.
		ply:SetWasHeadshotted(false)			-- The round just began, clear headshots.
		ply:SetCleanRound(true)					-- Nobody has damaged teammates yet, the round just started.
		TTT.Weapons.GiveRoleWeapons(ply)		-- Give all players the weapons for their newly given roles.
		TTT.Equipment.GiveRoleEquipment(ply)	-- Give all players the equipment their role starts with.
	end

	TTT.Notifications.DispatchStartRoundMessages()

	timer.Simple(1, function()
		TTT.Rounds.CheckForRoundEnd()	-- Could happen if ttt_dev_preventwin is 0 and ttt_minimum_players is <= 1.
	end)
end)

hook.Add("TTT.Rounds.EnteredPrep", "TTT", function()
	TTT.Map.ResetMap()
	TTT.Map.TriggerRoundStateOutsputs(ROUND_PREP)
	TTT.Roles.Clear()
	TTT.Karma:RoundBegin()
	
	local col = hook.Call("TTT.Player.SetDefaultSpawnColor")
	if not IsColor(col) then
		col = TTT.Player.GetRandomPlayerColor()
	end
	TTT.Player.SetDefaultModelColor(col)	-- Set a new color for players each round.

	for k = 1, player.GetCount() do
		player_GetAll[k]:ClearEquipment()
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