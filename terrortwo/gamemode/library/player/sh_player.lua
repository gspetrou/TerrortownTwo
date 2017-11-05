TTT.Player = TTT.Player or {}

local baseSpeed = CreateConVar("ttt_player_movespeed", "220", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Sets the base movement speed of players. Default: 220")

--------------------------
-- TTT.Player.SetMovement
--------------------------
-- Desc:		Sets the movement speed of players. Call this only in predicted hooks.
-- Arg One:		Player to set movement speed of.
-- Arg Two:		CMoveData
-- Arg Three:	CUserCmd
function TTT.Player.SetupMovement(ply, mv, cmd)
	if not ply:IsSpectator() then
		local baseMoveSpeed = baseSpeed:GetInt() or 220
		local multiplier = hook.Call("TTT.Player.SpeedMultiplier", nil, ply, mv, cmd) or 1
		mv:SetMaxClientSpeed(baseMoveSpeed * multiplier)
	end
end