TTT.Weapons = TTT.Weapons or {}
TTT.Weapons.SpawnWithWeapons = TTT.Weapons.SpawnWithWeapons or {}
TTT.Weapons.RoleWeapons = TTT.Weapons.RoleWeapons or {
	[ROLE_INNOCENT] = {},
	[ROLE_DETECTIVE] = {},
	[ROLE_TRAITOR] = {}
}

-- Weapon Slots.
WEAPON_INVALID		= 0
WEAPON_UNARMED		= 1
WEAPON_MELEE		= 2
WEAPON_CARRY		= 3
WEAPON_PRIMARY		= 4
WEAPON_SECONDARY	= 5
WEAPON_GRENADE		= 6
WEAPON_EQUIP1		= 7
WEAPON_EQUIP2		= 8
WEAPON_SPECIALEQUIP	= 9

-- Ammo Types. Values copied from Source Engine.

-- SMG1
game.AddAmmoType({
	name = "ar",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE_AND_WHIZ,
	plydmg = 0,
	npcdmg = 0,
	maxcarry = 9999,
	minsplash = 4,
	maxsplash = 8
})

-- AlyxGun
game.AddAmmoType({
	name = "pistol_heavy",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	maxcarry = 9999,
	minsplash = 4,
	maxsplash = 8
})

-- Pistol
game.AddAmmoType({
	name = "pistol_light",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE_AND_WHIZ,
	plydmg = 0,
	npcdmg = 0,
	maxcarry = 9999,
	minsplash = 4,
	maxsplash = 8
})

-- 357
game.AddAmmoType({
	name = "sniper",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE_AND_WHIZ,
	plydmg = 0,
	npcdmg = 0,
	maxcarry = 9999,
	minsplash = 4,
	maxsplash = 8
})

-- Buckshot
game.AddAmmoType({
	name = "shotgun_buckshot",
	dmgtype = bit.bor(DMG_BULLET, DMG_BUCKSHOT),
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	maxcarry = 9999,
	minsplash = 4,
	maxsplash = 8
})

-- No ammo type.
game.AddAmmoType({
	name = "none",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE_AND_WHIZ,
	plydmg = 0,
	npcdmg = 0,
	maxcarry = 9999,
	minsplash = 4,
	maxsplash = 8
})

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
-- TTT.Weapons.CreateCaches
----------------------------
-- Desc:		Precache all weapon models since nondeveloper commands can show the first time equipment has been bought.
-- 				Then also cache weaponASDASD
function TTT.Weapons.CreateCaches()
	local util_PrecacheModel = util.PrecacheModel
	for k, wep in ipairs(weapons.GetList()) do
		if wep.WorldModel then
			util_PrecacheModel(wep.WorldModel)
		end
		if wep.ViewModel then
			util_PrecacheModel(wep.ViewModel)
		end

		local wepClass = wep.ClassName
		local roleForWep = wep.RoleWeapon
		if roleForWep then
			if isnumber(roleForWep) then
				table.insert(TTT.Weapons.RoleWeapons[roleForWep], wepClass)
			elseif istable(roleForWep) then
				for i, r in ipairs(roleForWep) do
					table.insert(TTT.Weapons.RoleWeapons[r], wepClass)
				end
			end
		end

		if wep.SpawnWith then
			table.insert(TTT.Weapons.SpawnWithWeapons, wepClass)
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
	----------------------------------------
	-- TTT.Weapons.RequestDropCurrentWeapon
	----------------------------------------
	-- Desc:		Client only. Asks server to drop their weapaon if they can.
	function TTT.Weapons.RequestDropCurrentWeapon()
		net.Start("TTT.Weapons.RequestDropCurrentWeapon")
		net.SendToServer()
	end

	net.Receive("TTT.Weapons.RequestDropCurrentWeapon", function()
		chat.AddText(Color(255, 0, 0), TTT.Languages.GetPhrase("dropweapon_noroom"))
	end)
else
	-----------------------------
	-- TTT.Weapons.CanDropWeapon
	-----------------------------
	-- Desc:		Sees if the player can drop their current weapon.
	-- Arg One:		Player
	-- Arg Two:		Entity, weapon of theirs to see if it can be dropped.
	function TTT.Weapons.CanDropWeapon(ply, wep)
		if not IsValid(ply) or not IsValid(wep) or not wep.CanDrop then
			return false
		end

		local result = hook.Call("TTT.Weapons.CanDropWeapon", nil, ply, wep)
		if result == true then
			return true
		elseif result == false then
			return false
		end
		
		-- Thanks TTT.
		local tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 32, ply)
		if tr.HitWorld then
			net.Start("TTT.Weapons.RequestDropCurrentWeapon")	-- Tell them theres no room to drop their weapon, reuse the same network string.
			net.Send(ply)
			return false
		end

		return true
	end

	--------------------------
	-- TTT.Weapons.DropWeapon
	--------------------------
	-- Desc:		Drops the player's given weapon.
	-- Arg One:		Player, to drop weapon of.
	-- Arg Two:		Entity, weapon to drop.
	function TTT.Weapons.DropWeapon(ply, wep)
		if not IsValid(ply) or not IsValid(wep) then
			return
		end

		local weaponIsValid = true
		if wep.PreDrop then
			wep:PreDrop()

			if not IsValid(wep) then
				weaponIsValid = false
			end
		end

		if weaponIsValid then
			ply:DropWeapon(wep)
			wep:PhysWake()
		end
		
		ply:SelectWeapon("weapon_ttt_unarmed")
		hook.Call("TTT.Weapons.DroppedWeapon", nil, ply, wep)
	end

	net.Receive("TTT.Weapons.RequestDropCurrentWeapon", function(_, ply)
		if IsValid(ply) and IsValid(ply:GetActiveWeapon()) and TTT.Weapons.CanDropWeapon(ply, ply:GetActiveWeapon()) then
			TTT.Weapons.DropWeapon(ply, ply:GetActiveWeapon())
		end
	end)
end