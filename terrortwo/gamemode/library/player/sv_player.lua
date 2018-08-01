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
-- Arg Two:		(Optional=true) Boolean, should we reset their spawn position to a map spawn spot.
-- Arg Three:	(Optional=true) Boolean, should we arm the player with the default weapons when they spawn. Still gives unholstered either way.
-- Arg Four:	(Optional=true) Boolean, should we give the player the gear (weapons/equipment) their role should start the round with. E.g. DNA Scanner and Armor for detectives.
util.AddNetworkString("TTT.Player.SwitchedFlyMode")
function TTT.Player.ForceSpawnPlayer(ply, resetspawn, shouldarm, roleGear)
	if not isbool(resetspawn) then resetspawn = true end
	if not isbool(shouldarm) then shouldarm = true end
	if not isbool(roleGear) then roleGear = true end

	if not resetspawn then
		ply.ttt_noResetSpawnPos = ply:GetPos()
		ply.ttt_noResetSpawnAng = ply:GetAngles()
	end

	TTT.Player.SpawnSkipGamemodeHook(ply)

	ply:SetIsSpectatingCorpse(false)
	ply:UnSpectate()
	ply:SetInFlyMode(false)
	ply:SetNoDraw(false)

	net.Start("TTT.Player.SwitchedFlyMode")
		net.WriteBool(ply:IsInFlyMode())
	net.Send(ply)

	GAMEMODE:PlayerSetModel(ply)
	GAMEMODE:PlayerLoadout(ply)
	hook.Call("TTT.Player.ForcedSpawnedPlayer", nil, ply, resetspawn, shouldarm, roleGear)
	ply.ttt_noResetSpawnPos, ply.ttt_noResetSpawnAng = nil, nil
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
				local spawn = table.RandomSequential(spectatorSpawns)
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
		local curMoveType = ply:GetMoveType()
		if curMoveType == MOVETYPE_LADDER or curMoveType == MOVETYPE_OBSERVER then	-- MOVETYPE_OBSERVER is what causes that laggy feeling free fly cam.
			ply:SetMoveType(MOVETYPE_NOCLIP)
		end

		if ply:GetObserverMode() ~= OBS_MODE_ROAMING then
			local target = ply:GetObserverTarget()
			if IsValid(target) and target:IsPlayer() and target:Alive() and TTT.Rounds.IsActive() then
				-- Parenting is so unstable that I'd rather just do it this messy way.
				ply:SetPos(target:GetPos())
			end
		end
	end
end

------------------------
-- TTT.Player.SetSpeeds
------------------------
-- Desc:		Sets the player's movement settings.
-- Arg One:		Player, to set movement settings up.
function TTT.Player.SetSpeeds(ply)
	ply:SetCanZoom(false)	
	ply:SetJumpPower(160)
	ply:SetCrouchedWalkSpeed(0.3)

	local speed = GetConVar("ttt_player_movespeed"):GetInt() or 220
	ply:SetRunSpeed(speed)
	ply:SetWalkSpeed(speed)
	ply:SetMaxSpeed(speed)
end

local timeTillDrown = CreateConVar("ttt_player_timetilldrowning", "8", FCVAR_ARCHIVE, "Time in seconds for a player to be underwater till they start drowning.")

------------------------------------
-- TTT.Player.CreateDrownDamageInfo
------------------------------------
-- Desc:		Creates the DamageInfo object responsible for handling player drowning.
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

-- Called when the player presses USE on an entity while spectating.
util.AddNetworkString("TTT.Player.AttemptInspectObject")
net.Receive("TTT.Player.AttemptInspectObject", function(_, ply)
	if not ply:Alive() then
		local tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 128, ply)
		if tr.Hit and IsValid(tr.Entity) then
			if tr.Entity:IsCorpse() then
				if not ply:KeyDown(IN_WALK) then
					hook.Call("TTT.Player.WantsToSearchCorpse", nil, ply, tr.Entity)
				else
					ply:Spectate(OBS_MODE_IN_EYE)
					ply:SpectateEntity(tr.Entity)
				end
			elseif tr.Entity:IsPlayer() and tr.Entity:Alive() then
				ply:Spectate(ply.ttt_specMode or OBS_MODE_CHASE)
				ply:SpectateEntity(tr.Entity)
			end
		end
	end
end)

----------------------------------------
-- TTT.Player.HandleSpectatorKeypresses
----------------------------------------
-- Desc:		Handles a spectator's key presses to do different things.
-- Arg One:		Player who is a spectator.
-- Arg Two:		IN_ enum of the key they pressed.
function TTT.Player.HandleSpectatorKeypresses(ply, key)
	if key == IN_ATTACK then		-- Spectate random people.
		if ply:GetObserverMode() ~= OBS_MODE_ROAMING then
			ply:Spectate(OBS_MODE_ROAMING)
			ply:SpectateEntity(NULL)
		end

		local alivePlayers = TTT.Player.GetAlivePlayers()
		if #alivePlayers == 0 then
			return
		end

		ply:SetEyeAngles(angle_zero)

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
			ply:SpectateEntity(ply.ttt_specMode and target or NULL)
		end
	elseif key == IN_DUCK then		-- Go back to roaming.
		if ply:GetObserverMode() ~= OBS_MODE_ROAMING then
			ply:Spectate(OBS_MODE_ROAMING)
			ply:SpectateEntity(NULL)
		end

		local target = ply:GetObserverTarget()
		if IsValid(target) and target:IsPlayer() and target:Alive() then
			local pos = target:EyePos()
			local ang = target:EyeAngles()

			ply:SetPos(pos)
			ply:SetEyeAngles(ang)
		end
		return true
	elseif key == IN_RELOAD then
		local target = ply:GetObserverTarget()
		if not IsValid(target) or (target:IsPlayer() and not target:Alive()) or ply:GetObserverMode() == OBS_MODE_ROAMING then
			return
		end

		if not ply.ttt_specMode or ply.ttt_specMode == OBS_MODE_CHASE then
			ply.ttt_specMode = OBS_MODE_IN_EYE
		elseif ply.ttt_specMode == OBS_MODE_IN_EYE then
			ply.ttt_specMode = OBS_MODE_CHASE
		end

		ply:Spectate(ply.ttt_specMode)
	end
end

TTT.Player.DeathSounds = {
	Sound("player/death1.wav"),
	Sound("player/death2.wav"),
	Sound("player/death3.wav"),
	Sound("player/death4.wav"),
	Sound("player/death5.wav"),
	Sound("player/death6.wav"),
	Sound("vo/npc/male01/pain07.wav"),
	Sound("vo/npc/male01/pain08.wav"),
	Sound("vo/npc/male01/pain09.wav"),
	Sound("vo/npc/male01/pain04.wav"),
	Sound("vo/npc/Barney/ba_pain06.wav"),
	Sound("vo/npc/Barney/ba_pain07.wav"),
	Sound("vo/npc/Barney/ba_pain09.wav"),
	Sound("vo/npc/Barney/ba_ohshit03.wav"),
	Sound("vo/npc/Barney/ba_no01.wav"),
	Sound("vo/npc/male01/no02.wav"),
	Sound("hostage/hpain/hpain1.wav"),
	Sound("hostage/hpain/hpain2.wav"),
	Sound("hostage/hpain/hpain3.wav"),
	Sound("hostage/hpain/hpain4.wav"),
	Sound("hostage/hpain/hpain5.wav"),
	Sound("hostage/hpain/hpain6.wav")
}

function TTT.Player.PlayDeathYell(ply)
	sound.Play(table.RandomSequential(TTT.Player.DeathSounds), ply:GetShootPos(), 90, 100)
end

function TTT.Player.CreateDeathEffects(ent)
	local pos = ent:GetPos() + Vector(0, 0, 20)

	local jitterAmmount = 35.0

	local jitter = Vector(math.Rand(-jitterAmmount, jitterAmmount), math.Rand(-jitterAmmount, jitterAmmount), 0)
	util.PaintDown(pos + jitter, "Blood", ent)
end

-- Player damage related.

----------------------------------
-- TTT.Player.StoreDeathSceneData
----------------------------------
-- Desc:		Stores some data used for scene building.
-- Arg One:		Player, to store info on.
-- Arg Two:		TraceResult struct.
function TTT.Player.StoreDeathSceneData(ply, trace)
	ply.ttt_HitTrace = trace
end

-------------------------
-- PLAYER:WasHeadshotted
-------------------------
-- Desc:		Was the most recent/last shot to hit the player a headshot?
-- Returns:		Boolean.
function PLAYER:WasHeadshotted()
	return isbool(self.ttt_WasHeadshotted) and self.ttt_WasHeadshotted or false
end

----------------------------
-- PLAYER:SetWasHeadshotted
----------------------------
-- Desc:		Sets if the lost shot to hit a player was a headshot.
-- Arg One:		Boolean, was headshotted.
function PLAYER:SetWasHeadshotted(bool)
	self.ttt_WasHeadshotted = bool
end

-- Sounds to make when we fall from high heights.
TTT.Player.FallSounds = {
	Sound("player/damage1.wav"),
	Sound("player/damage2.wav"),
	Sound("player/damage3.wav")
}

-- If the player hits the ground going this speed or more then deal damage, rising exponentially.
TTT.Player.FallDamageSpeedThreshold = 420

-------------------------------
-- TTT.Player.HandleFallDamage
-------------------------------
-- Desc:		Handles fall damage.
-- Arg One:		Player, suffering from fall damange.
-- Arg Two:		Boolean, was the player in water when they landed.
-- Arg Three:	Boolean, did the player land on a floating object.
-- Arg Four:	Number, speed the player was going when they landed.
function TTT.Player.HandleFallDamage(ply, inWater, onFloater, speed)
	-- The plus 30 here is to stay consistent with how TTT1 handled fall damage.
	if inWater or speed < (TTT.Player.FallDamageSpeedThreshold + 30) or not IsValid(ply) then
		return
	end

	-- Everything over a threshold hurts you, rising exponentially with speed
	local damage = math.pow(0.05 * (speed - TTT.Player.FallDamageSpeedThreshold), 1.75)

	-- If landing on a floating object then do half damage.
	if on_floater then
		damage = damage / 2
	end

	-- If we land on a player do some damage to them.
	local groundPlayer = ply:GetGroundEntity()
	if IsValid(groundPlayer) and groundPlayer:IsPlayer() then
		if math.floor(damage) > 0 then
			local attacker = ply

			-- If the person who fell on to another person was pushed then attribute the damage to the pusher.
			local push = ply:GetPushData()
			if push then
				if math.max(push.Time or 0, push.Hurt or 0) > CurTime() - 4 then
					attacker = push.Attacker
				end
			end

			local dmg = DamageInfo()
			if attacker == ply then
				dmg:SetDamageType(DMG_CRUSH + DMG_PHYSGUN)		-- hijack physgun damage as a marker of this type of kill
			else
				dmg:SetDamageType(DMG_CRUSH)		-- if attributing to pusher, show more generic crush msg for now
			end

			dmg:SetAttacker(attacker)
			dmg:SetInflictor(attacker)
			dmg:SetDamageForce(Vector(0, 0, -1))
			dmg:SetDamage(damage)

			groundPlayer:TakeDamageInfo(dmg)
		end

		-- our own falling damage is cushioned
		damage = damage / 3
	end

	if math.floor(damage) > 0 then
		local dmg = DamageInfo()
		dmg:SetDamageType(DMG_FALL)
		dmg:SetAttacker(game.GetWorld())
		dmg:SetInflictor(game.GetWorld())
		dmg:SetDamageForce(Vector(0, 0, 1))
		dmg:SetDamage(damage)

		ply:TakeDamageInfo(dmg)

		-- Play CS:S fall sound if we got somewhat significant damage
		if damage > 5 then
			sound.Play(table.RandomSequential(TTT.Player.FallSounds), ply:GetShootPos(), 55 + math.Clamp(damage, 0, 50), 100)
		end
	end
end