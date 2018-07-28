TTT.Player = TTT.Player or {}
local PLAYER = FindMetaTable("Player")
local baseSpeed = CreateConVar("ttt_player_movespeed", "220", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Sets the base movement speed of players. Default: 220")

----------------------------
-- TTT.Player.SetupMovement
----------------------------
-- Desc:		Sets the movement speed of players. Call this only in predicted hooks.
-- Arg One:		Player to set movement speed of.
-- Arg Two:		CMoveData
function TTT.Player.SetupMovement(ply, mv)
	if not ply:IsSpectator() then
		local baseMoveSpeed = baseSpeed:GetInt() or 220
		local multiplier = hook.Call("TTT.Player.SpeedMultiplier", nil, ply, mv) or 1
		local speed = baseMoveSpeed * multiplier
		mv:SetMaxSpeed(speed)
		mv:SetMaxClientSpeed(speed)
	end
end


-- Colors used to indicated how injured someone is. Thanks TTT.
TTT.Player.HealthColors = {
	Healthy = Color(0, 255, 0, 255),
	Hurt    = Color(170, 230, 10, 255),
	Wounded = Color(230, 215, 10, 255),
	Badwound= Color(255, 140, 0, 255),
	Death   = Color(255, 0, 0, 255)
}

------------------------------
-- TTT.Player.GetHealthStatus
------------------------------
-- Desc:		Gets a phrase to describe the corresponding health level and color.
-- Arg One:		Number, health.
-- Arg Two:		Number, maximum health.
-- Returns:		String, phrase for the player's health status.
-- 				Color, for the player's health status.
function TTT.Player.GetHealthStatus(hp, maxHP)
	maxHP = maxHP or 100

	if hp > maxHP * 0.9 then
		return "hp_healthy", TTT.Player.HealthColors.Healthy
	elseif hp > maxHP * 0.7 then
		return "hp_hurt", TTT.Player.HealthColors.Hurt
	elseif hp > maxHP * 0.45 then
		return "hp_wounded", TTT.Player.HealthColors.Wounded
	elseif hp > maxHP * 0.2 then
		return "hp_badwound", TTT.Player.HealthColors.Badwound
	else
		return "hp_death", TTT.Player.HealthColors.Death
	end
end

-----------------------
-- PLAYER:SetInFlyMode
-----------------------
-- Desc:		Sets the player to be in fly mode or not.
-- Note:		DO NOT use this to make a player enter fly mode, instead use TTT.Player.SpawnInFlyMode and TTT.Player.ForceSpawnPlayer.
--				This function should only be used internally.
-- Arg One:		Boolean, what to set mode into.
function PLAYER:SetInFlyMode(bool)
	self.ttt_InFlyMode = bool
end

----------------------
-- PLAYER:IsInFlyMode
----------------------
-- Desc:		Is the player in fly mode.
-- Returns:		Boolean, are they in fly mode.
function PLAYER:IsInFlyMode()
	return self.ttt_InFlyMode or false
end
