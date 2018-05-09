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
