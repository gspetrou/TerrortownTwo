TTT.Weapons = TTT.Weapons or {}
util.AddNetworkString("TTT.Weapons.RequestDropCurrentWeapon")
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
	-- TODO
end
