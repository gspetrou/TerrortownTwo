TTT.Karma = TTT.Karma or {
	RememberedPlayers = {},
	ConVars = {}
}

TTT.Karma.ConVars.Strict = CreateConVar("ttt_karma_strict", "1", FCVAR_ARCHIVE, "Should we punish players more for team damage.")
TTT.Karma.ConVars.Ratio = CreateConVar("ttt_karma_ratio", "0.001", FCVAR_ARCHIVE, "This CVar * Victim's Karma * Damage Dealt = Number of karma to punish the attacker with. Used for Traitor on Traitor damage.")
TTT.Karma.ConVars.KillPenalty = CreateConVar("ttt_karma_kill_penalty", "15", FCVAR_ARCHIVE, "Karma penalty for team killing.")
TTT.Karma.ConVars.Increment = CreateConVar("ttt_karma_round_incremenet", "5", FCVAR_ARCHIVE, "Default Karma bonus for making it through a round.")
TTT.Karma.ConVars.CleanBonus = CreateConVar("ttt_karma_clean_bonus", "30", FCVAR_ARCHIVE, "Karma bonus for making it through the round without giving any team damage.")
TTT.Karma.ConVars.TraitorKillBonus = CreateConVar("ttt_karma_traitorkill_bonus", "40", FCVAR_ARCHIVE, "Karma bonus for killing a traitor")
TTT.Karma.ConVars.TraitorDamageRatio = CreateConVar("ttt_karma_traitordmg_ratio", "0.0003", FCVAR_ARCHIVE, "Scales how much karma you get for damaging a traitor as an innocent.")
TTT.Karma.ConVars.DebugPrints = CreateConVar("ttt_karma_debugspam", "0", nil, "Print lots of debug info relating to karma distribution.")

TTT.Karma.ConVars.Persist = CreateConVar("ttt_karma_persist", "0", FCVAR_ARCHIVE, "Should we store karma between map changes.")
TTT.Karma.ConVars.CleanHalf = CreateConVar("ttt_karma_clean_half", "0.25", FCVAR_ARCHIVE, "Scales how it becomes more difficult to gain more karma as you reach past the starting point.")
TTT.Karma.ConVars.DetectiveKarmaMin = CreateConVar("ttt_karma_detective_minimum", "600", FCVAR_ARCHIVE, "Minimum karma needed to be a detective.")

TTT.Karma.ConVars.LowKick = CreateConVar("ttt_karma_low_autokick", "1", FCVAR_ARCHIVE, "Should we kick people with low karma.")
TTT.Karma.ConVars.LowAmount = CreateConVar("ttt_karma_low_amount", "450", FCVAR_ARCHIVE, "At what karma amount and below should we start kicking.")
TTT.Karma.ConVars.LowBan = CreateConVar("ttt_karma_low_ban", "1", FCVAR_ARCHIVE, "Should we ban for low karma.")
TTT.Karma.ConVars.LowBanMinutes = CreateConVar("ttt_karma_low_ban_minutes", "60", FCVAR_ARCHIVE, "How long to ban for low karma.")

local PLAYER = FindMetaTable("Player")

-----------------------
-- PLAYER:GetLiveKarma
-----------------------
-- Desc:		Gets the player's live updated karma.
-- Returns:		Number, the player's live karma.
function PLAYER:GetLiveKarma()
	return isnumber(self.ttt_LiveKarma) and self.ttt_LiveKarma or TTT.Karma:GetStartingKarma()
end

-----------------------
-- PLAYER:SetLiveKarma
-----------------------
-- Desc:		Sets the player's live updated karma.
-- Arg One:		Number, the player's new live karma.
function PLAYER:SetLiveKarma(num)
	self.ttt_LiveKarma = num
end

--------------------------
-- PLAYER:GetDamageFactor
--------------------------
-- Desc:		Gets the damage factor, the scale of the damage this player deals.
-- Returns:		Number, gets the player's damage factor.
function PLAYER:GetDamageFactor()
	return isnumber(self.ttt_DamageFactor) and self.ttt_DamageFactor or 1.0
end

--------------------------
-- PLAYER:SetDamageFactor
--------------------------
-- Desc:		Sets the damage factor, the scale of the damage that this player deals.
-- Arg One:		Number, set the damage factor the of the player.
function PLAYER:SetDamageFactor(num)
	self.ttt_DamageFactor = num
end

-------------------------
-- PLAYER:GetCleanRound
-------------------------
-- Desc:		Gets if the player has had a clean round, meaning that they haven't hurt any teammates.
-- Returns:		Boolean, did they hurt any teammates in the round.
function PLAYER:GetCleanRound()
	return isbool(self.ttt_CleanRound) and self.ttt_CleanRound or true
end

------------------------
-- PLAYER:SetCleanRound
------------------------
-- Desc:		Sets if the player has had a clean round, meaning that they haven't hurt any teammates.
-- Arg One:		Boolean, have they hurt a teammate.
function PLAYER:SetCleanRound(bool)
	self.ttt_CleanRound = bool
end

---------------------
-- TTT.Karma:IsDebug
---------------------
-- Desc:		Sees if we should print debug info for the karma system.
-- Returns:		Boolean.
function TTT.Karma:IsDebug()
	return self.ConVars.DebugPrints:GetBool()
end

--------------------------------------
-- TTT.Karma:DamageToKarmaHurtPenalty
--------------------------------------
-- Desc:		If an attacker hurts a victim for X damage, how much karma does that mean we should take from the attacker.
-- 				This is used in situations where the attacker should NOT have hurt the victim. Example: Traitor to Traitor damage.
-- Arg One:		Number, the karma of the player receiving the damage.
-- Arg Two:		Number, the damage given to the player.
-- Returns:		Number, the karma to take from the attacker.
function TTT.Karma:DamageToKarmaHurtPenalty(victimsKarma, damage)
	return victimsKarma * math.Clamp(damage * self.ConVars.Ratio:GetFloat(), 0, 1)
end

--------------------------------------
-- TTT.Karma:DamageToKarmaKillPenalty
--------------------------------------
-- Desc:		Gets how much karma to punish someone with for killing someone they should not have.
-- Arg One:		Number, karma of the victim who died.
-- Returns:		Number, how much karma to take from the attacker.
function TTT.Karma:GetKillPenalty(victimsKarma)
	return self:DamageToKarmaHurtPenalty(victimsKarma, self.ConVars.KillPenalty:GetFloat())
end

-------------------------------------------
-- TTT.Karma:InnocentToTraitorDamageReward
-------------------------------------------
-- Desc:		Given an amount of damage an innocent did to a traitor compute a karma award.
-- Arg One:		Number, how much damage dealth
function TTT.Karma:InnocentToTraitorDamageReward(damage)
	return self.ConVars.Maximum:GetFloat() * math.Clamp(damage * self.ConVars.TraitorDamageRatio:GetFloat(), 0, 1)
end

-----------------------------------------
-- TTT.Karma:InnocentToTraitorKillReward
-----------------------------------------
-- Desc:		Gets how much karma to award an innocent with for killing a traitor.
-- Returns:		Number, karma that should be awarded.
function TTT.Karma:InnocentToTraitorKillReward()
	return self:InnocentToTraitorDamageReward(self.ConVars.TraitorKillBonus:GetFloat())
end

-------------------------
-- TTT.Karma:GivePenalty
-------------------------
-- Desc:		Called to give a player a karma penalty for attacking a given victim.
-- Arg One:		Player, to penalize.
-- Arg Two:		Number, of karma to take.
-- Arg Three:	Player, victim who the player attacked.
function TTT.Karma:GivePenalty(ply, penalty, victim)
	local overrideDefaultImplementation = hook.Call("TTT.Karma.GivePenalty", nil, ply, penalty, victim)

	if not overrideDefaultImplementation then
		ply:SetLiveKarma(math.max(ply:GetLiveKarma() - penalty, 0))
	end
end

------------------------
-- TTT.Karma:GiveReward
------------------------
-- Desc:		Gives the given player the given karma reward.
-- Arg One:		Player, who is getting the given karma.
-- Arg Two:		Number, how much karma to give.
-- Returns:		Number, the karma awarded to the player that has been adjusted for decay.
function TTT.Karma:GiveReward(ply, reward)
	local scaledReward = self:GetDecayedMultiplier(ply) * reward
	ply:SetLiveKarma(math.min(ply:GetLiveKarma() + scaledReward), self.ConVars.Maximum:GetFloat())
	return scaledReward
end

----------------------------------
-- TTT.Karma:GetDecayedMultiplier
----------------------------------
-- Desc:		As a player's karma rises above the starting karma make it slow get harder and harder to get more karma following an expontential decay curve.
-- Arg One:		Player.
-- Returns:		Number, modifier of how much karma the player should receive.
function TTT.Karma:GetDecayedMultiplier(ply)
	local maxKarma = self.ConVars.Maximum:GetFloat()
	local startKarma = self:GetStartingKarma()
	local plyKarma = ply:GetLiveKarma()

	if self.ConVars.CleanHalf:GetInt() <= 0 or plyKarma < startKarma  then
		return 1
	elseif plyKarma < maxKarma then
		local baseDifference = maxKarma - startKarma
		local playerDifference = plyKarma - startKarma
		local half = math.Clamp(self.ConVars.CleanHalf:GetFloat(), 0.01, 0.99)

		return math.ExponentialDecay(baseDifference * half, playerDifference)
	end

	return 1
end

--------------------------------
-- TTT.Karma:UpdateDamageFactor
--------------------------------
-- Desc:		Updates the damage factor for the given player.
-- 				The damage factor is how much to modify the given player's weapon damage.
-- Arg One:		Player, to update their damage factor for.
function TTT.Karma:UpdateDamageFactor(ply)
	local damageFactor = 1.0

	if ply:GetBaseKarma() < self:GetStartingKarma() then
		local karmaDifference = ply:GetBaseKarma() - self:GetStartingKarma()
		if self.ConVars.Strict:GetBool() then
			damageFactor = 1 + (0.0007 * karmaDifference) + (-0.000002 * karmaDifference^2)	-- This penalty curve sinks more quickly, less parabolic.
		else
			damageFactor = 1 + -0.0000025 * (karmaDifference^2)
		end
	end

	ply:SetDamageFactor(math.Clamp(damageFactor, 0.1, 1.0))

	if self:IsDebug() then
		print(string.format("%s has karma %f and gets df %f", ply:Nick(), ply:GetBaseKarma(), damageFactor))
	end
end

---------------------------------
-- TTT.Karma:WasDamaageAvoidable
---------------------------------
-- Desc:		Was the damage that the attacker gave to the victim easily avoidable.
-- Arg One:		Player, attacker.
-- Arg Two:		Player, victim.
-- Arg Three:	CTakeDamageInfo, damage info dealt.
-- Returns:		Boolean, was the damage avoidable.
function TTT.Karma:WasDamaageAvoidable(attacker, victim, dmgInfo)
	local inflictor = dmgInfo:GetInflictor()
	if attacker:IsTraitor() and victim:IsTraitor() and IsValid(inflictor) and inflictor.Avoidable then
		return true
	end

	return false
end

------------------
-- TTT.Karma:Hurt
------------------
-- Desc:		Handles the karma change when the player gets hurt by another player.
-- Arg One:		Player, the attacker.
-- Arg Two:		Player, victim.
-- Arg Three:	CTakeDamageInfo, that hurt the player.
function TTT.Karma:Hurt(attacker, victim, dmgInfo)
	if not IsValid(attacker) or not IsValid(victim) or attacker == victim or not attacker:IsPlayer() or not victim:IsPlayer() then
		return
	end

	-- Ignore excess damage
	local hurtAmount = math.min(victim:Health(), dmgInfo:GetDamage())

	-- If they were the same team then penalize, otherwise reward.
	local onSameTeam = attacker:IsTraitor() and victim:IsTraitor() or (not victim:IsTraitor())

	if onSameTeam then
		if self:WasDamaageAvoidable(attacker, victim, dmgInfo) then
			return
		end

		local penalty = self:DamageToKarmaHurtPenalty(victim:GetLiveKarma(), hurtAmount)
		self:GivePenalty(attacker, penalty, victim)

		attacker:SetCleanRound(false)

		if self:IsDebug() then
			print(string.format("%s (%f) attacked %s (%f) for %d and got penalised for %f", attacker:Nick(), attacker:GetLiveKarma(), victim:Nick(), victim:GetLiveKarma(), hurtAmount, penalty))
		end
	elseif not attacker:IsTraitor() then
		local reward = self:InnocentToTraitorDamageReward(hurtAmount)
		reward = self:GiveReward(attacker, reward)

		if self:IsDebug() then
			print(string.format("%s (%f) attacked %s (%f) for %d and got REWARDED %f", attacker:Nick(), attacker:GetLiveKarma(), victim:Nick(), victim:GetLiveKarma(), hurtAmount, reward))
		end
	end
end

--------------------
-- TTT.Karma:Killed
--------------------
-- Desc:		Handles the karma change when killing a player.
-- Arg One:		Player, attacker.
-- Arg Two:		Player, victim that died.
-- Arg Three:	CTakeDamageInfo, how they died.
function TTT.Karma:Killed(attacker, victim, dmginfo)
	if not IsValid(attacker) or not IsValid(victim) or attacker == victim or not attacker:IsPlayer() or not victim:IsPlayer() then
		return
	end

	-- If they were the same team then penalize, otherwise reward.
	local onSameTeam = attacker:IsTraitor() and victim:IsTraitor() or (not victim:IsTraitor())

	if onSameTeam then
		-- Don't penalize players for stupid victims.
		if self:WasDamaageAvoidable(attacker, victim, dmginfo) then
			return
		end

		local penalty = self:GetKillPenalty(victim:GetLiveKarma())
		self:GivePenalty(attacker, penalty, victim)

		attacker:SetCleanRound(false)

		if self:IsDebug() then
			print(string.format("%s (%f) killed %s (%f) and gets penalised for %f", attacker:Nick(), attacker:GetLiveKarma(), victim:Nick(), victim:GetLiveKarma(), penalty))
		end
	else
		local reward = self:InnocentToTraitorKillReward()
		reward = self:GiveReward(attacker, reward)

		if self:IsDebug() then
			print(string.format("%s (%f) killed %s (%f) and gets REWARDED %f", attacker:Nick(), attacker:GetLiveKarma(), victim:Nick(), victim:GetLiveKarma(), reward))
		end
	end
end

----------------------------
-- TTT.Karma:RoundIncrement
----------------------------
-- Desc:		Give everyone their designated karma bonuses.
function TTT.Karma:RoundIncrement()
	local healBonus = self.ConVars.Increment:GetFloat()
	local cleanBonus = self.ConVars.CleanBonus:GetFloat()

	for i, ply in ipairs(player.GetAll()) do
		if not ply:Alive() then
			local dmgInfo = ply:GetDeathDamageInfo()

			-- If they didn't die by suicide then...
			if not (dmgInfo:GetAttacker() == ply or dmgInfo:GetInflictor() == ply) then
				local bonus = healBonus + (ply:GetCleanRound() and cleanBonus or 0)
				self:GiveReward(ply, bonus)

				if self:IsDebug() then
					print(string.format("%s gets the round increment of %f", ply:Nick(), bonus))
				end
			end
		end
	end
end

------------------------
-- TTT.Karma:UpdateBase
------------------------
-- Desc:		Updates every player's base karma to their current live karma.
function TTT.Karma:UpdateBase()
	for i, ply in ipairs(player.GetAll()) do
		if self:IsDebug() then
			print(string.format("%s rebased from %f to %f", ply:Nick(), ply:GetBaseKarma(), ply:GetLiveKarma()))
		end

		ply:SetBaseKarma(ply:GetLiveKarma())
	end
end

-----------------------------------
-- TTT.Karma:UpdateDamageFactorAll
-----------------------------------
-- Desc:		Updates everyone's damage factor.
function TTT.Karma:UpdateDamageFactorAll()
	for i, ply in ipairs(player.GetAll()) do
		self:UpdateDamageFactor(ply)
	end
end

----------------------
-- TTT.Karma:RoundEnd
----------------------
-- Desc:		Handles actions performed at round end relating to karma.
function TTT.Karma:RoundEnd()
	if self:IsEnabled() then
		self:RoundIncrement()
		self:UpdateBase()
		self:RememberAll()
		self:SyncKarma()

		if self.ConVars.LowKick:GetBool() then
			for i, ply in ipairs(player.GetAll()) do
				self:CheckForAutoKick(ply)
			end
		end
	end
end

------------------------
-- TTT.Karma:RoundBegin
------------------------
-- Desc:		Handles actions performed at round start relating to karma.
function TTT.Karma:RoundBegin()
	if self:IsEnabled() then
		for i, ply in ipairs(player.GetAll()) do
			self:UpdateDamageFactor(ply)
			-- TODO: Notify
		end
	end
end

------------------------
-- TTT.Karma:InitPlayer
------------------------
-- Desc:		Preps a new player for use with the karma system.
-- Arg One:		Player.
function TTT.Karma:InitPlayer(ply)
	local karma = self:Recall(ply)

	karma = math.Clamp(karma, 0, self.ConVars.Maximum:GetFloat())

	ply:SetBaseKarma(karma)
	ply:SetLiveKarma(karma)
	ply:SetCleanRound(true)
	ply:SetDamageFactor(1.0)

	-- Compute the damagefactor based on actual (possibly loaded) karma.
	self:UpdateDamageFactor(ply)
end

-----------------------
-- TTT.Karma:SyncKarma
-----------------------
-- Desc:		Sends all the players every player's base karma.
util.AddNetworkString("TTT.Karma.SyncKarma")
function TTT.Karma:SyncKarma()
	net.Start("TTT.Karma.SyncKarma")
		local players = player.GetAll()
		net.WriteUInt(#players, 7)

		for i, ply in ipairs(players) do
			net.WritePlayer(ply)
			net.WriteUInt(math.floor(ply:GetBaseKarma() + 0.5), 12)
		end
	net.Broadcast()
end

----------------------
-- TTT.Karma:Remember
----------------------
-- Desc:		Updates the stored karma for the given player. Uses persistent SQL storage if enabled.
-- Arg One:		Player, to store the karma of.
function TTT.Karma:Remember(ply)
	if ply.ttt_KarmaKicked or not ply:IsFullyAuthenticated() then
		return
	end

	-- Store their karma with SQL if persist is on.
	if self.ConVars.Persist:GetBool() then
		TTT.Karma:UpdatePlayersStoredKarma(ply, ply:GetLiveKarma())
	end

	-- If persist is on, this is purely a backup method.
	self.RememberedPlayers[ply:SteamID()] = ply:GetLiveKarma()
end

-------------------------
-- TTT.Karma:RememberAll
-------------------------
-- Desc:		Runs TTT.Karma:Remember on every player, stores their karma both temporarily and in SQL if enabled.
function TTT.Karma:RememberAll()
	for i, ply in ipairs(player.GetAll()) do
		self:Remember(ply)
	end
end

--------------------
-- TTT.Karma:Recall
--------------------
-- Desc:		Gets a given player's stored karma, optionall from SQL storage if enabled.
-- Arg One:		Player, to get karma of.
-- Returns:		Number, live karma amount.
function TTT.Karma:Recall(ply)
	if self.ConVars.Persist:GetBool()then
		ply.ttt_DelayKarmaRecall = not ply:IsFullyAuthenticated()

		if ply:IsFullyAuthenticated() then
			local karma = TTT.Karma:GetPlayersStoredKarma(ply)

			if karma then
				return karma
			end
		end
	end

	if self.RememberedPlayers[ply:SteamID()] then
		return self.RememberedPlayers[ply:SteamID()]
	end

	return self.ConVars.Starting:GetFloat()
end

------------------------------
-- TTT.Karma:LateRecallAndSet
------------------------------
-- Desc:		Called when the player loads initial spawn before they've finished authentication (edge case) to load their karma late.
-- Arg One:		Player.
function TTT.Karma:LateRecallAndSet(ply)
	local karma = TTT.Karma:GetPlayersStoredKarma(ply)

	if karma and karma < ply:GetLiveKarma() then
		ply:SetBaseKarma(karma)
		ply:SetLiveKarma(karma)
	end
end

--------------------------------------
-- TTT.Karma:UpdatePlayersStoredKarma
--------------------------------------
-- Desc:		Updates the player's stored SQL karma to the given number.
-- Arg One:		Player, to set the karma of.
-- Arg Two:		Number, the karma to set.
function TTT.Karma:UpdatePlayersStoredKarma(ply, karma)
	sql.Query("UPDATE `ttt` SET karma = ".. sql.SQLStr(karma) .." WHERE id = ".. sql.SQLStr(ply:SteamID64()) ..";")
end

-----------------------------------
-- TTT.Karma:GetPlayersStoredKarma
-----------------------------------
-- Desc:		Gets the player's karma stored in SQL.
-- Arg One:		Player, to get their karma.
-- Returns:		Number, their karma.
function TTT.Karma:GetPlayersStoredKarma(ply)
	local query = sql.Query("SELECT `karma` from `ttt` WHERE id=".. sql.SQLStr(ply:SteamID64()) ..";")[1].karma
	if query then
		return tonumber(query)
	end
end

------------------------------
-- TTT.Karma:CheckForAutoKick
------------------------------
-- Desc:		Checks if the given player's karma has fallen to low and kicks or bans them accordingly.
-- Arg One:		Player, to check.
local reason = "Karma too low"
function TTT.Karma:CheckForAutoKick(ply)
	if ply:GetBaseKarma() <= self.ConVars.LowAmount:GetInt() then
		if hook.Call("TTT.Karma.Low", GAMEMODE, ply) == false then
			return
		end

		ServerLog(ply:Nick() .." (".. ply:SteamID() ..") autokicked/banned for low karma.\n")

		-- Flag player as autokicked so we don't perform the normal player disconnect logic.
		ply.ttt_KarmaKicked = true

		if self.ConVars.Persist:GetBool() then
			local karma = math.Clamp(self.ConVars.Starting:GetFloat() * 0.8, self.ConVars.LowAmount:GetFloat() * 1.1, self.ConVars.Maximum:GetFloat())
			TTT.Karma:UpdatePlayersStoredKarma(ply, karma)
			self.RememberedPlayers[ply:SteamID()] = karma
		end

		if self.ConVars.LowBan:GetBool() then
			--ply:KickBan(self.ConVars.LowBanMinutes:GetInt(), reason)
			-- TODO: detect admin mod, CAMI compliance?
		else
			ply:Kick(reason)
		end
	end
end

----------------------
-- TTT.Karma:PrintAll
----------------------
-- Desc:		Prints every player's live karma, base karma, and damage factor as a percent.
function TTT.Karma:PrintAll()
	for i, ply in ipairs(player.GetAll()) do
		print(string.format("%s : Live = %f -- Base = %f -- Dmg = %f\n", ply:Nick(), ply:GetLiveKarma(), ply:GetBaseKarma(), ply:GetDamageFactor() * 100))
	end
end