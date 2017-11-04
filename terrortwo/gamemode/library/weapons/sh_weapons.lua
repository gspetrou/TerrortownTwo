TTT.Weapons = TTT.Weapons or {}

-- Weapon Slots.
WEAPON_UNARMED		= 0
WEAPON_MELEE		= 1
WEAPON_CARRY		= 2
WEAPON_PRIMARY		= 3
WEAPON_SECONDARY	= 4
WEAPON_GRENADE		= 5
WEAPON_EQUIP1		= 6
WEAPON_EQUIP2		= 7
WEAPON_SPECIALEQUIP	= 8

-------------------------------
-- TTT.Weapons.HasWeaponInSlot
-------------------------------
-- Desc:		Says if the player has a weapon with the given weapon kind. (SWEP.Kind)
-- Arg One:		Player, to check if they have a weapon in the given slot.
-- Arg Two:		WEAPON_ enum, check if the player has a weapon in this slot.
-- Returns:		Boolean, true if they have a weapon in the given slot, false otherwise.
function TTT.Weapons.HasWeaponInSlot(ply, kind)
	if kind == nil then
		error("Attempted to use a weapon with an invalid \"SWEP.Kind\".")
	end

	local plyWeps = ply:GetWeapons()
	for k, v in pairs(plyWeps) do
		if v.Kind == kind then
			return true
		end
	end

	return false
end

------------------------------------
-- TTT.Weapons.HasWeaponForAmmoType
------------------------------------
-- Desc:		Sees if a given player has a weapon that takes a given type of ammo.
-- Arg One:		Player, to check weapons of for a certain type of ammo.
-- Arg Two:		String, ammotype to check their weapons for.
-- Returns:		Boolean, true if they have a weapon that takes the given ammo type.
function TTT.Weapons.HasWeaponForAmmoType(ply, ammotype)
	local plyWeps = ply:GetWeapons()
	for k, v in pairs(plyWeps) do
		if v.Primary.Ammo == ammotype or v.Secondary.Ammo == ammotype then
			return true
		end
	end

	return false
end

----------------------------
-- TTT.Weapons.CacheWeapons
----------------------------
-- Desc:		Precache all weapon models since nondeveloper commands can show the first time equipment has been bought.
function TTT.Weapons.Precache()
	local util_PrecacheModel = util.PrecacheModel
	for k, wep in ipairs(weapons.GetList()) do
		if wep.WorldModel then
			util_PrecacheModel(wep.WorldModel)
		end
		if wep.ViewModel then
			util_PrecacheModel(wep.ViewModel)
		end
	end
end

-------------------------------
-- TTT.Weapons.GetWeaponInSlot
-------------------------------
-- Desc:		Gets the weapon of the player in the given slot.
-- Arg One:		Player, the person we'll be getting the weapon of.
-- Arg Two:		WEAPON_ enum, the weapon with this SWEP.Kind in the player's inventory to be gotten.
-- Returns:		Weapon or Boolean. Weapon entity if they have a weapon in the given slot. False if they don't have a weapon in that slot.
function TTT.Weapons.GetWeaponInSlot(ply, kind)
	if kind == nil then
		error("Attempted to use a weapon with an invalid \"SWEP.Kind\".")
	end

	local plyWeps = ply:GetWeapons()
	for k, v in pairs(plyWeps) do
		if v.Kind == kind then
			return v
		end
	end

	return false
end

if CLIENT then
	function TTT.Weapons.RequestDropCurrentWeapon()
		net.Start("TTT.Weapons.RequestDropCurrentWeapon")
		net.SendToServer()
	end
else
	function TTT.Weapons.CanDropWeapon(ply, wep)
		if not IsValid(ply) or not IsValid(wep) or not wep.CanDrop then
			return false
		end
		
		-- Thanks TTT.
		local tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 32, ply)
		if tr.HitWorld then
			-- TODO: Add warning message.
			return false
		end

		return true
	end

	function TTT.Weapons.DropWeapon(ply, wep)
		if not IsValid(ply) or not IsValid(wep) then
			return
		end

		if wep.PreDrop then
			wep:PreDrop()

			if not IsValid(wep) then
				return
			end
		end

		ply:DropWeapon(wep)
		wep:PhysWake()
		ply:SelectWeapon("weapon_ttt2_unarmed")
		hook.Call("TTT.Weapons.DroppedWeapon", nil, ply, wep)
	end

	net.Receive("TTT.Weapons.RequestDropCurrentWeapon", function(_, ply)
		if IsValid(ply) and IsValid(ply:GetActiveWeapon()) and TTT.Weapons.CanDropWeapon(ply, ply:GetActiveWeapon()) then
			TTT.Weapons.DropWeapon(ply, ply:GetActiveWeapon())
		end
	end)
end