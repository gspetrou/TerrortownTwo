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
		return not ply:Alive()
	end)
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
util.AddNetworkString("TTT.Player.SwitchedFlyMode")
function TTT.Player.ForceSpawnPlayer(ply, resetspawn, shouldarm)
	resetspawn = isbool(resetspawn) and resetspawn or false
	
	TTT.Player.SpawnSkipGamemodeHook(ply)

	if not resetspawn then
		ply:SetPos(ply:GetPos())
		ply:SetEyeAngles(ply:GetAngles())
	end

	ply:SetIsSpectatingCorpse(false)
	ply:UnSpectate()
	ply.ttt_InFlyMode = false
	ply:SetNoDraw(false)

	net.Start("TTT.Player.SwitchedFlyMode")
		net.WriteBool(false)
	net.Send(ply)

	GAMEMODE:PlayerSetModel(ply)
	GAMEMODE:PlayerLoadout(ply)
	hook.Call("TTT.Player.ForceSpawnedPlayer", nil, ply, resetspawn, isbool(shouldarm) and shouldarm or true)
end

-----------------------------
-- TTT.Player.SpawnInFlyMode
-----------------------------
-- Desc:		Spawns the player in a flying mode.
-- Arg One:		Player, to be set as a spectator.
util.AddNetworkString("TTT.Player.EnteredFlyMode")
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
	if IsValid(ply:GetCorpse()) then
		ply:Spectate(OBS_MODE_IN_EYE)
		ply:SpectateEntity(ply:GetCorpse())
		ply:SetIsSpectatingCorpse(true)
	else
		ply:Spectate(OBS_MODE_ROAMING)

		if ply.ttt_deathpos_set then
			ply:SetPos(ply.ttt_deathpos)
			ply:SetAngles(ply.ttt_deathang)
			ply.ttt_deathpos_set = false
		end

		ply:SetIsSpectatingCorpse(false)
	end
	ply:SetMoveType(MOVETYPE_NOCLIP)

	net.Start("TTT.Player.SwitchedFlyMode")
		net.WriteBool(true)
	net.Send(ply)
end

-----------------------------
-- PLAYER:IsSpectatingCorpse
-----------------------------
-- Desc:		Is the player spectating a corpse.
-- Returns:		Boolean.
function PLAYER:IsSpectatingCorpse()
	return self.ttt_isSpectatingCorpse or false
end

---------------------------------------
-- PLAYER:GetTimeStartedSpectatingBody
---------------------------------------
-- Desc:		Gets the time the player started spectating a body.
-- Returns:		Number, time they started spectating the body. -1 if they aren't spectating a body.
function PLAYER:GetTimeStartedSpectatingBody()
	return self.ttt_specBodyTime
end

function PLAYER:SetIsSpectatingCorpse(bool)
	self.ttt_isSpectatingCorpse = bool

	if bool then
		self.ttt_specBodyTime = CurTime()
	else
		self.ttt_specBodyTime = -1
	end
end

------------------------------------
-- TTT.Player.HandleDeathSpectating
------------------------------------
-- Desc:		Handles the player's spectating status each tick. Lots taken from ttt.
-- Arg One:		Player, to handle the spectating for.
function TTT.Player.HandleDeathSpectating(ply)
	if ply:IsSpectatingCorpse() then
		local timeToSwitch, timeToChase, timeToRoam = 1, 4, 9
		local timeElapsed = CurTime() - ply:GetTimeStartedSpectatingBody()
		local clicked = ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_JUMP)

		-- After first click, go into chase cam, then after another click go into free roam.
		-- If no clicks are made, go into chase after timeToChase secondss, and roam after timeToRoam.
		-- Don't switch for timeToSwitch seconds in case the player was shooting when he died since this would make him accidentally switch out of ragdoll cam.

		local observerMode = ply:GetObserverMode()

		-- Enter free roam mode.
		if (observerMode == OBS_MODE_CHASE and clicked) or timeElapsed > timeToRoam then
			ply:SetIsSpectatingCorpse(false)
			ply:Spectate(OBS_MODE_ROAMING)

			-- Move to spectator spawn if mapper defined any.
			local spectatorSpawns = ents.FindByClass("ttt_spectator_spawn")
			if spectatorSpawns and #spectatorSpawns > 0 then
				local spawn = table.Random(spectatorSpawns)
				ply:SetPos(spawn:GetPos())
				ply:SetEyeAngles(spawn:GetAngles())
			end

		-- Start spectating ragdoll.
		elseif (observerMode == OBS_MODE_IN_EYE and clicked and timeElapsed > timeToSwitch) or timeElapsed > timeToChase then
			ply:Spectate(OBS_MODE_CHASE)
		end

		if not IsValid(ply:GetCorpse()) then
			ply:SetIsSpectatingCorpse(false)
		end
	else
		if ply:GetMoveType() == MOVETYPE_LADDER then
			ply:SetMoveType(MOVETYPE_NOCLIP)
		end

		if ply:GetObserverMode() ~= OBS_MODE_ROAMING then
			local target = ply:GetObserverTarget()
			if IsValid(target) and target:IsPlayer() then
				if not target:Alive() then
					-- Stop spectating as soon as the target dies.
					ply:Spectate(OBS_MODE_ROAMING)
					ply:SpectateEntity(nil)
				elseif TTT.Rounds.IsActive() then
					-- Parenting is so unstable that I'd rather just do it this messy way.
					ply:SetPos(target:GetPos())
				end
			end
		end
	end
end

local timeTillDrown = CreateConVar("ttt_player_timetilldrowning", "8", FCVAR_ARCHIVE, "Time in seconds for a player to be underwater till they start drowning.")

function TTT.Player.CreateDrownDamageInfo()
	-- Damage info for drowning. Available to be editted. Not created till InitPostEntity.
	TTT.Player.DrownDamageInfo = DamageInfo()
	TTT.Player.DrownDamageInfo:SetDamage(15)
	TTT.Player.DrownDamageInfo:SetDamageType(DMG_DROWN)
	TTT.Player.DrownDamageInfo:SetAttacker(game.GetWorld())
	TTT.Player.DrownDamageInfo:SetInflictor(game.GetWorld())
	TTT.Player.DrownDamageInfo:SetDamageForce(Vector(0,0,1))
end

-----------------------------
-- TTT.Player.HandleDrowning
-----------------------------
-- Desc:		Handles the player drowning. Also extinquished people if they're in water and on fire.
-- Arg One:		Player, who can possibly drown.
function TTT.Player.HandleDrowning(ply)
	if ply:WaterLevel() == 3 then
		if ply:IsOnFire() then
			ply:Extinguish()
		end

		if ply.ttt_isDrowning then
			if ply.ttt_isDrowning < CurTime() then
				ply:TakeDamageInfo(TTT.Player.DrownDamageInfo)
				ply.ttt_isDrowning = CurTime() + 1	-- This 1 second is the time between drown damage.
			end
		else
			ply.ttt_isDrowning = CurTime() + timeTillDrown:GetInt()	-- Make them drown in ttt_player_timetilldrowning seconds.
		end
	else
		ply.ttt_isDrowning = nil
	end
end

util.AddNetworkString("TTT.Player.AttemptSpectateObject")
net.Receive("TTT.Player.AttemptSpectateObject", function(_, ply)
	if not ply:Alive() then
		local tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 128, ply)
		if tr.Hit and IsValid(tr.Entity) then
			if tr.Entity:IsCorpse() then
				--if not ply:KeyDown(IN_WALK) then
					--CORPSE.ShowSearch(ply, tr.Entity)
				--else
					ply:Spectate(OBS_MODE_IN_EYE)
					ply:SpectateEntity(tr.Entity)
				--end
			elseif tr.Entity:IsPlayer() and tr.Entity:Alive() then
				ply:Spectate(ply.ttt_specMode or OBS_MODE_CHASE)
				ply:SpectateEntity(tr.Entity)
			end
		end
	end
end)

function TTT.Player.HandleSpectatorKeypresses(ply, key)
	if key == IN_ATTACK then		-- Spectate random people.
		ply:Spectate(OBS_MODE_ROAMING)
		ply:SetEyeAngles(angle_zero)
		ply:SpectateEntity(nil)

		local alivePlayers = TTT.Player.GetAlivePlayers()
		
		if alivePlayers == 0 then
			return
		end
		
		local target = table.RandomSequential(alivePlayers)
		if IsValid(target) then
			ply:SetPos(target:EyePos())
			ply:SetEyeAngles(target:EyeAngles())
		end
	elseif key == IN_ATTACK2 then		-- Cycle to inspect next guy.
		local alivePlayers = TTT.Player.GetAlivePlayers()
		local curTarget = ply:GetObserverTarget()
		local nextPlayerIndex

		for i, v in ipairs(alivePlayers) do
			if v == curTarget then
				nextPlayerIndex = i + 1
			end
		end

		if not nextPlayerIndex then
			nextPlayerIndex = math.random(1, #alivePlayers)
		elseif nextPlayerIndex > #alivePlayers then
			nextPlayerIndex = 1
		end

		local target = alivePlayers[nextPlayerIndex]
		if IsValid(target) then
			ply:Spectate(ply.ttt_specMode or OBS_MODE_CHASE)
			ply:SpectateEntity(target)
		end
	elseif key == IN_DUCK then		-- Go back to roaming.
		local pos = ply:GetPos()
		local ang = ply:EyeAngles()

		local target = ply:GetObserverTarget()
		if IsValid(target) and target:IsPlayer() then
			pos = target:EyePos()
			ang = target:EyeAngles()
		end

		ply:Spectate(OBS_MODE_ROAMING)
		ply:SpectateEntity(nil)

		ply:SetPos(pos)
		ply:SetEyeAngles(ang)
		return true
	elseif key == IN_RELOAD then
		local target = ply:GetObserverTarget()
		if not IsValid(target) or not target:IsPlayer() then
			return
		end

		if not ply.ttt_specMode or ply.ttt_specMode == OBS_MODE_CHASE then
			ply.ttt_specMode = OBS_MODE_IN_EYE
		elseif ply.ttt_specMode == OBS_MODE_IN_EYE then
			ply.ttt_specMode = OBS_MODE_CHASE
		end
		-- roam stays roam

		ply:Spectate(ply.ttt_specMode)
	end
end