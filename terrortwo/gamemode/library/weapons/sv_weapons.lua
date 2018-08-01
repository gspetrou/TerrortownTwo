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

	-- This snippet taken from Badking's code looks weird but actually makes wepons get picked up without having to wake them up first. Not sure why.
	local tr = util.TraceEntity({
		start = wep:GetPos(),
		endpos = ply:GetShootPos(),
		mask = MASK_SOLID
	}, wep)
	if tr.Fraction == 1.0 or tr.Entity == ply then
		wep:SetPos(ply:GetShootPos())
	end

	return true
end

--------------------------
-- TTT.Weapons.CreateFire
--------------------------
-- Desc:		Creates a fire!
-- Arg One:		Vector, center of the fire.
-- Arg Two:		Number, of flames (ttt_flame entities).
-- Arg Three:	Number, how long the fire should burn for.
-- Arg Four:	Boolean, should the fire explode when it dies out.
-- Arg Five:	Player, who should be responsible for the damage dealth by this fire.
function TTT.Weapons.CreateFire(position, numberFlames, burnTime, shouldExplode, dmgOwner)
	for i = 1, numberFlames do
		local ang = Angle(-math.Rand(0, 180), math.Rand(0, 360), math.Rand(0, 360))
		local flame = ents.Create("ttt_flame")
		flame:SetPos(position)

		if IsValid(dmgOwner) and dmgOwner:IsPlayer() then
			flame:SetDamageParent(dmgOwner)
			flame:SetOwner(dmgOwner)
		end

		flame:SetDieTime(CurTime() + burnTime + math.Rand(-2, 2))
		flame:SetExplodeOnDeath(shouldExplode)

		flame:Spawn()
		flame:PhysWake()

		-- The balance between mass and force is subtle, be careful adjusting.
		local phys = flame:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(2)
			phys:ApplyForceCenter(ang:Forward() * 500)
			phys:AddAngleVelocity(Vector(ang.p, ang.r, ang.y))
		end
	end
end

---------------------------
-- PLAYER:SetCanDryingShot
---------------------------
-- Desc:		Sets if the player is allowed to shoot a dying shot. Even with this enabled they still wont shoot if they have a melee weapon or got headshotted.
-- Arg One:		Boolean, can the player dying shot.
function PLAYER:SetCanDyingShot(bool)
	self.ttt_CanDyingShot = bool
end

-----------------------
-- PLAYER:CanDyingShot
-----------------------
-- Desc:		Can the player shoot their dying shot. Does not check for the ttt_weapon_dyingshot convar.
-- Returns:		Boolean, can they shoot their dying shot.
function PLAYER:CanDyingShot()
	return isbool(self.ttt_CanDyingShot) and self.ttt_CanDyingShot or false
end

------------------------
-- PLAYER:SetPushedData
------------------------
-- Desc:		Sets info on a player about who last pushed them.
-- Arg One:		Table, push data.
function PLAYER:SetPushedData(data)
	self.ttt_PushedData = data
end

------------------------
-- PLAYER:GetPushedData
------------------------
-- Desc:		Gets the data on the most recent time a player was pushed.
-- Returns:		Table or nil, table of push data or nil if they weren't pushed.
function PLAYER:GetPushedData()
	return self.ttt_PushedData
end

------------------------
-- PLAYER:ClearPushData
------------------------
-- Desc:		Clears the info about a player's last push.
function PLAYER:ClearPushData()
	self.ttt_PushedData = nil
end