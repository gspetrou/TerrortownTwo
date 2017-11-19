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
			hook.Call("TTT.Player.PostPlayerSpawn", nil, ply, true)
		else
			ply:UnSpectate()
			ply.ttt_InFlyMode = false
			ply:SetupHands()					-- Get c_ hands working.
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
end

function GM:PlayerSpawnAsSpectator(ply)	-- For backwards compatability.
	TTT.Roles.SpawnInFlyMode(ply)
end

function GM:PlayerDeath(ply)
	ply.ttt_deathpos = ply:GetPos()
	ply.ttt_deathang = ply:GetAngles()
	ply.ttt_deathpos_set = true
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
		TTT.Roles.ForceSpawnPlayer(v, true) -- Technically the round already started.
	end
	TTT.Roles.PickRoles()
	TTT.Roles.Sync()

	TTT.Weapons.GiveRoleWeapons()

	timer.Simple(1, function()
		TTT.Rounds.CheckForRoundEnd()	-- Could happen if ttt_dev_preventwin is 0 and ttt_minimum_players is <= 1.
	end)
end)

hook.Add("TTT.Rounds.EnteredPrep", "TTT", function()
	TTT.Player.SetDefaultModelColor(TTT.Player.GetRandomPlayerColor())
	TTT.MapHandler.ResetMap()
	TTT.Roles.Clear()

	local defaultWeapon = GetConVar("ttt_weapons_default"):GetString()
	for i, ply in ipairs(TTT.Roles.GetAlivePlayers()) do
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
	print(TTT.Rounds.IsPost())
	if not TTT.Rounds.IsActive() and not TTT.Rounds.IsPost() then
		TTT.Roles.ForceSpawnPlayer(ply, true)
		TTT.Player.SetModel(ply)
	end
end)

hook.Add("TTT.Roles.ForceSpawnedPlayer", "TTT", function(ply, resetSpawn, shouldarm)
	if resetSpawn then
		TTT.MapHandler.PutPlayerAtRandomSpawnPoint(ply)
	end
	if shouldarm then
		TTT.Weapons.StripCompletely(ply)
		TTT.Weapons.GiveStarterWeapons(ply)
	end
end)

----------------
-- Weapon Hooks
----------------
function GM:PlayerCanPickupWeapon(ply, wep)
	if not IsValid(ply) or not ply:Alive() then
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