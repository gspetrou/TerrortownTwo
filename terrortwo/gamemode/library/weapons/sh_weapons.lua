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

--------------------------------------
-- TTT.Weapons.GetMapSpawnableWeapons
--------------------------------------
-- Desc:		Gets all weapons that the map is allowed to spawn. Caches into TTT.Weapons.SpawnableWeaponsCache.
-- Returns:		Table, list of strings, classes of map spawnable weapons.
function TTT.Weapons.GetMapSpawnableWeapons()
	if not TTT.Weapons.SpawnableWeaponsCache then
		TTT.Weapons.SpawnableWeaponsCache = {}
		for i, wep in ipairs(weapons.GetList()) do
			if wep.AutoSpawnable then
				table.insert(TTT.Weapons.SpawnableWeaponsCache, wep.ClassName)
			end
		end
	end
	
	return TTT.Weapons.SpawnableWeaponsCache
end

-----------------------------------
-- TTT.Weapons.GetMapSpawnableAmmo
-----------------------------------
-- Desc:		Gets all ammo entities that are allowed to be spawned around a map. Cached into TTT.Weapons.SpawnableAmmoCache after first run.
-- Returns:		Table, of ammo entity class names that can spawn around the map.
function TTT.Weapons.GetMapSpawnableAmmo()
	if not TTT.Weapons.SpawnableAmmoCache then
		TTT.Weapons.SpawnableAmmoCache = {}
		for ammoClass, ammoInfo in pairs(scripted_ents.GetList()) do
			if ammoInfo.t.AutoSpawnable then 	-- Sick API Garry.
				table.insert(TTT.Weapons.SpawnableAmmoCache, ammoClass)
			end
		end
	end

	return TTT.Weapons.SpawnableAmmoCache
end

--------------------------------------
-- TTT.Weapons.GetAmmoEntityForWeapon
--------------------------------------
-- Desc:		Gets the ammo entity that would give you more ammo for the given weapon.
-- Arg One:		String, class of the weapon.
-- Returns:		String or nil. Ammo type for the given weapon, nil if the ammo type of the weapon is "none".
function TTT.Weapons.GetAmmoEntityForWeapon(wepClass)
	local wepAmmoType = weapons.Get(wepClass).Primary.Ammo
	if not wepAmmoType then
		error("Tried to get ammo type for '".. wepClass .."' where none is set!")
	elseif wepAmmoType == "none" then
		return nil
	end

	for ammoClass, ammoInfo in pairs(scripted_ents.GetList()) do
		if ammoInfo.t.IsTTTAmmo and ammoInfo.t.AmmoType == wepAmmoType then
			return ammoClass
		end
	end

	return nil
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

	----------------------------------------
	-- TTT.Weapons.RequestDropCurrentWeapon
	----------------------------------------
	-- Desc:		Client only. Asks server to drop their current weapon's ammo if they can.
	function TTT.Weapons.RequestDropCurrentAmmo()
		net.Start("TTT.Weapons.RequestDropCurrentAmmo")
		net.SendToServer()
	end

	net.Receive("TTT.Weapons.CantDropWeaponNotify", function()
		chat.AddText(Color(255, 0, 0), TTT.Languages.GetPhrase("weapon_drop_no_room"))
	end)

	net.Receive("TTT.Weapons.CantDropAmmoNotify", function()
		if net.ReadBool() then
			chat.AddText(Color(255, 0, 0), TTT.Languages.GetPhrase("ammo_not_enough"))
		else
			chat.AddText(Color(255, 0, 0), TTT.Languages.GetPhrase("ammo_drop_no_room"))
		end
	end)
end

if SERVER then
	util.AddNetworkString("TTT.Weapons.RequestDropCurrentWeapon")
	util.AddNetworkString("TTT.Weapons.RequestDropCurrentAmmo")
	util.AddNetworkString("TTT.Weapons.CantDropWeaponNotify")
	util.AddNetworkString("TTT.Weapons.CantDropAmmoNotify")

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
		if util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 32, ply).HitWorld then
			net.Start("TTT.Weapons.CantDropWeaponNotify")
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
	function TTT.Weapons.DropWeapon(ply, wep, isDeathDrop)
		if not IsValid(ply) or not IsValid(wep) or not TTT.Weapons.CanDropWeapon(ply, wep) then
			return
		end

		local weaponIsValid = true
		if wep.PreDrop then
			wep:PreDrop(isDeathDrop)

			if not IsValid(wep) then
				weaponIsValid = false
			end
		end

		if weaponIsValid then
			wep.IsDropped = true
			ply:DropWeapon(wep)
			wep:PhysWake()

			ply:AnimPerformGesture(ACT_GMOD_GESTURE_ITEM_PLACE)
		end
		
		ply:SelectWeapon("weapon_ttt_unarmed")
		hook.Call("TTT.Weapons.DroppedWeapon", nil, ply, wep)
	end

	net.Receive("TTT.Weapons.RequestDropCurrentWeapon", function(_, ply)
		if IsValid(ply) and IsValid(ply:GetActiveWeapon()) then
			TTT.Weapons.DropWeapon(ply, ply:GetActiveWeapon())
		end
	end)

	---------------------------------
	-- TTT.Weapons.CanDropActiveAmmo
	---------------------------------
	-- Desc:		Sees if the given player can drop the ammo of their current weapon.
	-- Arg One:		Player, to drop their ammo.
	-- Returns:		Boolean, can they drop their ammo.
	function TTT.Weapons.CanDropActiveAmmo(ply)
		if not IsValid(ply) then
			return false
		end

		local weapon = ply:GetActiveWeapon()
		if not IsValid(weapon) then
			return false
		end

		local ammoEnt = TTT.Weapons.GetAmmoEntityForWeapon(weapon:GetClass())
		if not isstring(ammoEnt) then
			return false
		end

		local ammoAmount = weapon:Clip1()
		if ammoAmount < 1 or ammoAmount <= (weapon.Primary.ClipSize * 0.25) then
			net.Start("TTT.Weapons.CantDropAmmoNotify")
				net.WriteBool(true)
			net.Send(ply)
			return false
		elseif util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 32, ply).HitWorld then
			net.Start("TTT.Weapons.CantDropAmmoNotify")
				net.WriteBool(false)
			net.Send(ply)
			return false
		end

		local hookResult = hook.Call("TTT.Weapons.CanDropActiveAmmo", nil, ply, weapon, ammoEnt)
		if hookResult == false then
			return false
		end

		return true
	end

	------------------------------
	-- TTT.Weapons.DropActiveAmmo
	------------------------------
	-- Desc:		Drops a player's current ammo.
	-- Arg One:		Player, who wants to drop ammo.
	-- Returns:		Entity, created ammo box. Nil if it was able to be created.
	function TTT.Weapons.DropActiveAmmo(ply)
		if not TTT.Weapons.CanDropActiveAmmo(ply) then
			return
		end

		local weapon = ply:GetActiveWeapon()
		local ammoEnt = TTT.Weapons.GetAmmoEntityForWeapon(weapon:GetClass())
		local ammoAmount = weapon:Clip1()
		
		local plyPos, ang = ply:GetShootPos(), ply:EyeAngles()
		local throwDirection = (ang:Forward() * 32) + (ang:Right() * 6) + (ang:Up() * -5)

		local tr = util.QuickTrace(plyPos, throwDirection, ply)
		if tr.HitWorld then return end
		weapon:SetClip1(0)
		ply:AnimPerformGesture(ACT_GMOD_GESTURE_ITEM_GIVE)

		local box = ents.Create(ammoEnt)
		if not IsValid(box) then return end

		box:SetPos(plyPos + throwDirection)
		box:SetOwner(ply)
		box:Spawn()

		box:PhysWake()

		local phys = box:GetPhysicsObject()
		if IsValid(phys) then
			phys:ApplyForceCenter(ang:Forward() * 1000)
			phys:ApplyForceOffset(VectorRand(), vector_origin)
		end

		box:SetAmmoAmount(ammoAmount)

		-- Not sure why TTT does this but I feel like it might be for good reason.
		timer.Simple(2, function()
			if IsValid(box) then
				box:SetOwner(nil)
			end
		end)

		hook.Call("TTT.Weapons.PlayerDroppedActiveAmmo", nil, ply, weapon, box)
		return box
	end

	net.Receive("TTT.Weapons.RequestDropCurrentAmmo", function(_, ply)
		if IsValid(ply) then
			TTT.Weapons.DropActiveAmmo(ply)
		end
	end)
end