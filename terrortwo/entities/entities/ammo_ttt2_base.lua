-- Base TTT2 ammo, don't worry about modifying this unless you know what youre doing. And yes, this heavily copies TTT1.
AddCSLuaFile()
ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.Category 	= "TTT2 Ammo"
ENT.Spawnable	= false
ENT.Editable	= false
ENT.AdminOnly	= false

ENT.PrintName	= "TTT2 Ammo"
ENT.Author		= "Stalker"
ENT.Contact		= "http://steamcommunity.com/id/your-stalker/"
ENT.Purpose		= "A TTT ammo base."
ENT.Instructions= "Make cool guns using this ammo base."
ENT.RenderGroup	= RENDERGROUP_OPAQUE
ENT.DisableDuplicator	= false

ENT.IsTTTAmmo = true
ENT.Precached = false
ENT.WeaponsUsingThisAmmo = {}

-- Customize these values for each ammo type.
ENT.AmmoType	= "smg"
ENT.AmmoGive	= 30		-- How much ammo to give in a full ammo box.
ENT.AmmoMax		= 60		-- Maximum amount of this ammo they can carry not in the gun.
ENT.Model		= Model("models/items/boxmrounds.mdl")

if SERVER then
	function ENT:Think()
		if not self.first_think then
			self.first_think = true
			self:PhysWake()
			self.Think = nil
		end
	end

	--------------------
	-- ENT.PrecacheAmmo
	--------------------
	-- Desc:		Precache this ammo type so that checking for it on players later is much faster.
	function ENT:PrecacheAmmo()
		local weps = {}
		for i, v in ipairs(weapons.GetList()) do
			if v.Primary.Ammo == self.AmmoType or v.Secondary.Ammo == self.AmmoType then
				table.insert(weps, v.ClassName)
			end
		end
		self.WeaponsUsingThisAmmo = weps
		self.Precached = true
	end

	------------------------
	-- ENT.HasWeaponForAmmo
	------------------------
	-- Desc:		Sees if the given entity has a weapon that takes this type of ammo.
	-- Arg One:		Entity, to check ammo of.
	-- Returns:		Boolean, if they have a weapon that takes this ammo.
	function ENT:HasWeaponForAmmo(ent)
		if not self.Precached then
			self:PrecacheAmmo()
		end

		for i, v in ipairs(self.WeaponsUsingThisAmmo) do
			if ent:HasWeapon(v) then
				return true
			end
		end
		return false
	end

	-------------------
	-- ENT.CanBeReached
	-------------------
	-- Desc:		Sees if anything like fences are in the way of grabbing the ammo.
	-- Arg One:		Entity
	-- Returns:		Boolean, are they close enough.
	function ENT:CanBeReached(ply)
		if ply == self:GetOwner() then
			return false
		end
		
		local physObj = self:GetPhysicsObject()
		local tr = util.TraceLine({
			start	= physObj:IsValid() and physObj:GetPos() or self:OBBCenter(),
			endpos	= ply:GetShootPos(),
			filter	= {self, ply},
			mask	= MASK_SOLID
		})

		return tr.Fraction == 1.0
	end

	--------------------------
	-- ENT.CanBePickedUpByEnt
	--------------------------
	-- Desc:		Returns whether the given entity can pickup the ammo.
	-- Arg One:		Entity, to see if it can pickup the ammo.
	function ENT:CanBePickedUpByEnt(ply)
		if not self.PickedUp and IsValid(ply) and ply:IsPlayer() then
			local result = hook.Call("TTT.Ammo.CanPickUp", nil, ent, self)		-- Can be called plenty of times so be careful.
			if result then
				return result
			end

			if ply:Alive() and self:HasWeaponForAmmo(ply) and self:CanBeReached(ply) then
				return true
			end
		end

		return false
	end

	function ENT:Touch(ply)
		if self:CanBePickedUpByEnt(ply) then
			local ammo = ply:GetAmmoCount(self.AmmoType)
			if self.AmmoMax >= (ammo + math.ceil(self.AmmoGive * 0.25)) then
				local given = self.AmmoGive
				given = math.min(given, self.AmmoMax - ammo)
				ply:GiveAmmo(given, self.AmmoType)

				self:Remove()

				-- Just in case remove does not happen soon enough.
				self.PickedUp = true
				hook.Call("TTT.Ammo.PickedUp", nil, ply, self)
			end
		end
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end

function ENT:Initialize()
	self:SetModel(self.Model)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_BBOX)

	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	local b = 26
	self:SetCollisionBounds(Vector(-b, -b, -b), Vector(b,b,b))

	if SERVER then
		self:SetTrigger(true)
	end

	self.PickedUp = false
end