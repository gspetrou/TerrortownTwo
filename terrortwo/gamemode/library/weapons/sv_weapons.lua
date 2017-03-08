TTT.Weapons = TTT.Weapons or {}
local PLAYER = FindMetaTable("Player")

----------------------------------
-- TTT.Weapons.GiveStarterWeapons
----------------------------------
-- Desc:		Gives the player the weapons they should spawn with.
-- Arg One:		Player, to be armed.
function TTT.Weapons.GiveStarterWeapons(ply)
	local giveDefaults = hook.Call("TTT.Weapons.GiveStarterWeapons", nil, ply)
	if giveDefaults ~= false then
		--[[
		ply:Give("weapon_ttt2_crowbar")
		ply:Give("weapon_ttt2_magneto")
		ply:Give("weapon_ttt2_holster")
		]]
	end
end