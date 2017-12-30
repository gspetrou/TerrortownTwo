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

-------------------------------
-- TTT.Player.ForceSpawnPlayer
-------------------------------
-- Desc:		Forces a player to spawn.
-- Arg One:		Player, to be spawned.
-- Arg Two:		Boolean, should we reset their spawn position to a map spawn spot.
-- Arg Three:	Boolean, should we arm the player with the default weapons when they spawn. Optional, true by default.
function TTT.Player.ForceSpawnPlayer(ply, resetspawn, shouldarm)
	if not TTT.OldAlive(ply) then
		local pos = ply:GetPos()
		local ang = ply:GetAngles()
		ply:Spawn()
		if not resetspawn then
			ply:SetPos(pos)
			ply:SetEyeAngles(ang)
		end
	end
	ply:UnSpectate()
	ply.ttt_InFlyMode = false
	ply:SetNoDraw(false)
	hook.Call("TTT.Player.ForceSpawnedPlayer", nil, ply, resetspawn, shouldarm or true)
end

-----------------------------
-- TTT.Player.SpawnInFlyMode
-----------------------------
-- Desc:		Spawns the player in a flying mode.
-- Arg One:		Player, to be set as a spectator.
function TTT.Player.SpawnInFlyMode(ply)
	-- If the player is actually dead, spawn them first.
	if not TTT.OldAlive(ply) then
		ply.ttt_OverrideSpawn = true
		ply:Spawn()
		ply.ttt_OverrideSpawn = false
	end

	if not ply:IsInFlyMode() then
		ply.ttt_InFlyMode = true
	end

	-- Spectate their death ragdoll, if thats invalid for some reason then just free fly starting at their death position.
	-- If all else fails, they just spawn at a spawn point so no big deal.
	if IsValid(ply.ttt_deathrag) then
		ply:Spectate(OBS_MODE_IN_EYE)
		ply:SpectateEntity(ply.ttt_deathrag)
	elseif ply.ttt_deathpos_set then
		ply:Spectate(OBS_MODE_ROAMING)
		ply:SetPos(ply.ttt_deathpos)
		ply:SetAngles(ply.ttt_deathang)
		ply.ttt_deathpos_set = false
	end
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