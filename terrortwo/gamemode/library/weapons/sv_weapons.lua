TTT.Weapons = TTT.Weapons or {}
local PLAYER = FindMetaTable("Player")

-------------------------------
-- TTT.Weapons.StripCompletely
-------------------------------
-- Desc:		Strips a player of everything. *wink wink*
-- Arg One:		Player, to be stripped.
function TTT.Weapons.StripCompletely(ply)
	ply:StripWeapons()
	ply:StripAmmo()
end

----------------------------------
-- TTT.Weapons.GiveStarterWeapons
----------------------------------
-- Desc:		Gives the player the weapons they should spawn with.
-- Arg One:		Player, to be armed.
function TTT.Weapons.GiveStarterWeapons(ply)
	-- This hook can be used to give the player starter weapon as well as disable the stock ones.
	local giveDefaults = hook.Call("TTT.Weapons.GiveStarterWeapons", nil, ply)
	if giveDefaults ~= false then
		--[[
		ply:Give("weapon_ttt2_crowbar")
		ply:Give("weapon_ttt2_magneto")
		ply:Give("weapon_ttt2_holster")
		]]
	end
end