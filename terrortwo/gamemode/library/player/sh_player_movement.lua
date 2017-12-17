TTT.Player = TTT.Player or {}
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

if SERVER then
	------------------------
	-- TTT.Player.SetSpeeds
	------------------------
	-- Desc:		Sets the player's movement settings.
	-- Arg One:		Player, to set movement settings up.
	function TTT.Player.SetSpeeds(ply)
		ply:SetCanZoom(false)	
		ply:SetJumpPower(160)
		ply:SetCrouchedWalkSpeed(0.3)

		local speed = baseSpeed:GetInt() or 220
		ply:SetRunSpeed(speed)
		ply:SetWalkSpeed(speed)
		ply:SetMaxSpeed(speed)
	end
end