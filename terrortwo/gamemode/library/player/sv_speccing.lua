TTT.Player = TTT.Player or {}
local PLAYER = FindMetaTable("Player")

------------------------------
-- TTT.Player.GetAlivePlayers
------------------------------
-- Desc:		Gets all the alive players.
-- Returns:		Table, containning alive players.
function TTT.Player.GetAlivePlayers()
	return table.Filter(player.GetAll(), function(ply)
		return ply:Alive()
	end)
end

-----------------------------
-- TTT.Player.GetDeadPlayers
-----------------------------
-- Desc:		Gets a table containning all dead players, does not include spectators.
-- Returns:		Table, all dead players that are not spectators.
function TTT.Player.GetDeadPlayers()
	return table.Filter(player.GetAll(), function(ply)
		return not TTT.OldAlive(ply) and not ply:IsSpectator()
	end)
end

-----------------------------
-- TTT.Player.RecordDeathPos
-----------------------------
-- Desc:		Records where the player died.
-- Arg One:		Player, who died.
function TTT.Player.RecordDeathPos(ply)
	ply.ttt_deathpos = ply:GetPos()
	ply.ttt_deathang = ply:GetAngles()
	ply.ttt_deathpos_set = true
end

------------------------------------
-- TTT.Player.SpawnSkipGamemodeHook
------------------------------------
-- Desc:		Simple function to spwan a player and skip the gamemode's default PlayerSpawn hook code.
-- Arg One:		Player, to spawn.
function TTT.Player.SpawnSkipGamemodeHook(ply)
	ply.ttt_OverrideSpawn = true
	ply:Spawn()
	ply.ttt_OverrideSpawn = false
end

-------------------------------
-- TTT.Player.ForceSpawnPlayer
-------------------------------
-- Desc:		Forces a player to spawn.
-- Arg One:		Player, to be spawned.
-- Arg Two:		(Optional=false) Boolean, should we reset their spawn position to a map spawn spot.
-- Arg Three:	(Optional=true) Boolean, should we arm the player with the default weapons when they spawn.
function TTT.Player.ForceSpawnPlayer(ply, resetspawn, shouldarm)
	resetspawn = isbool(resetspawn) and resetspawn or false
	
	TTT.Player.SpawnSkipGamemodeHook(ply)

	if not resetspawn then
		ply:SetPos(ply:GetPos())
		ply:SetEyeAngles(ply:GetAngles())
	end

	ply:UnSpectate()
	ply.ttt_InFlyMode = false
	ply:SetNoDraw(false)

	GAMEMODE:PlayerSetModel(ply)
	GAMEMODE:PlayerLoadout(ply)
	hook.Call("TTT.Player.ForceSpawnedPlayer", nil, ply, resetspawn, isbool(shouldarm) and shouldarm or true)
end

-----------------------------
-- TTT.Player.SpawnInFlyMode
-----------------------------
-- Desc:		Spawns the player in a flying mode.
-- Arg One:		Player, to be set as a spectator.
function TTT.Player.SpawnInFlyMode(ply)
	-- If the player is actually dead, spawn them first.
	if not TTT.OldAlive(ply) then
		TTT.Player.SpawnSkipGamemodeHook(ply)
	end

	if not ply:IsInFlyMode() then
		ply.ttt_InFlyMode = true
	end

	-- Spectate their death ragdoll, if thats invalid for some reason then just free fly starting at their death position.
	-- If all else fails, they just spawn at a spawn point so no big deal.
	if IsValid(ply.ttt_deathragdoll) then
		ply:Spectate(OBS_MODE_IN_EYE)
		ply:SpectateEntity(ply.ttt_deathragdoll)
	else
		ply:Spectate(OBS_MODE_ROAMING)

		if ply.ttt_deathpos_set then
			ply:SetPos(ply.ttt_deathpos)
			ply:SetAngles(ply.ttt_deathang)
			ply.ttt_deathpos_set = false
		end
	end
	ply:SetMoveType(MOVETYPE_NOCLIP)
end

----------------------
-- PLAYER:IsInFlyMode
----------------------
-- Desc:		Is the player in fly mode.
-- Returns:		Boolean, are they in fly mode.
function PLAYER:IsInFlyMode()
	return self.ttt_InFlyMode or false
end

------------------------
-- PLAYER:ResetViewRoll
------------------------
-- Desc:		Resets the view roll of the player.
function PLAYER:ResetViewRoll()
	local ang = self:EyeAngles()
	if ang.r ~= 0 then
		ang.r = 0
		self:SetEyeAngles(ang)
	end
end