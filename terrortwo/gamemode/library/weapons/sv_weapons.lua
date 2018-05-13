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

-------------------------------
-- TTT.Weapons.GiveRoleWeapons
-------------------------------
-- Desc:		Gives the player the weapons for their role.
-- Arg One:		Player, to give weapons.
function TTT.Weapons.GiveRoleWeapons(ply)
	local role = ply:GetRole()
	local weps = TTT.Weapons.RoleWeapons[role]
	if istable(weps) then
		for i, wepClass in ipairs(weps) do
			ply:Give(wepClass)
		end
	end
end

----------------------------------
-- TTT.Weapons.GiveStarterWeapons
----------------------------------
-- Desc:		Give the given player the weapons they should spawn with.
-- Arg One:		Player, to arm with spawn weapons.
function TTT.Weapons.GiveStarterWeapons(ply)
	for i, wepClass in ipairs(TTT.Weapons.SpawnWithWeapons) do
		ply:Give(wepClass)
	end
end

-------------------------------
-- TTT.Weapons.CanPickupWeapon
-------------------------------
-- Desc:		Sees if the given player can pickup the given weapon.
-- Arg One:		Player, picking up the weapon.
-- Arg Two:		Weapon.
-- Returns:		Boolean, can they pick it up.
function TTT.Weapons.CanPickupWeapon(ply, wep)
	if not IsValid(ply) or not ply:Alive() then
		return false
	end

	-- This may be useful for some people at some point.
	if wep:GetClass() == "weapon_physgun" then
		return not ply:HasWeapon("weapon_physgun")
	end

	if wep.Kind == nil then
		error("Player tried to pickup weapon with missing SWEP.Kind. Class name: '".. wep.ClassName .."'.")
	end

	if TTT.Weapons.HasWeaponInSlot(ply, wep.Kind) then
		return false
	end

	return true
end