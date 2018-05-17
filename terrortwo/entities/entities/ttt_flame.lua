-- Creates fire with a damage owner.
AddCSLuaFile()
ENT.Type = "anim"
ENT.Model = Model("models/weapons/w_eq_flashbang_thrown.mdl")

AccessorFunc(ENT, "dmgparent", "DamageParent")
AccessorFunc(ENT, "die_explode", "ExplodeOnDeath")
AccessorFunc(ENT, "dietime", "DieTime")

ENT.FireChild = nil
ENT.DieTime = 0
ENT.NextHurt = 0
ENT.HurtInterval = 1	-- Number, how frequently does the fire burn you.
ENT.BurnTime = 20		-- Number, how long the fire stays.
ENT.FireSize = 120
ENT.FireGrowth = 1

local useFallbackDraw = CreateClientConVar("ttt_fire_fallback", "0", FCVAR_ARCHIVE, "Use fallback fire in case it doesn't show up for you.")

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Burning")
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:DrawShadow(false)
	self:SetNoDraw(true)


	if CLIENT and useFallbackDraw:GetBool() then
		self.Draw = self.BackupDraw
		self:SetNoDraw(false)
	end

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetHealth(99999)

	self.NextHurt = CurTime() + self.HurtInterval + math.Rand(0, 3)
	self:SetBurning(false)

	if self.DieTime == 0 then
		self.DieTime = CurTime() + self.BurnTime
	end
end

function StartFires(pos, tr, numFlames, lifetime, shouldExplode, dmgowner)
	for i = 1, numFlames do
		local ang = Angle(-math.Rand(0, 180), math.Rand(0, 360), math.Rand(0, 360))
		local vstart = pos + tr.HitNormal * 64
		local flame = ents.Create("ttt_flame")
		flame:SetPos(pos)

		if IsValid(dmgowner) and dmgowner:IsPlayer() then
			flame:SetDamageParent(dmgowner)
			flame:SetOwner(dmgowner)
		end

		flame:SetDieTime(CurTime() + lifetime + math.Rand(-2, 2))
		flame:SetExplodeOnDeath(shouldExplode)

		flame:Spawn()
		flame:PhysWake()

		local phys = flame:GetPhysicsObject()
		if IsValid(phys) then
			-- The balance between mass and force is subtle, be careful adjusting.
			phys:SetMass(2)
			phys:ApplyForceCenter(ang:Forward() * 500)
			phys:AddAngleVelocity(Vector(ang.p, ang.r, ang.y))
		end
	end
end

function SpawnFire(pos, size, attack, fuel, owner, parent)
	local fire = ents.Create("env_fire")
	if not IsValid(fire) then return end

	fire:SetParent(parent)
	fire:SetOwner(owner)
	fire:SetPos(pos)
	
	fire:SetKeyValue("spawnflags", tostring(128 + 32 + 4 + 2 + 1)) --no glow + delete when out + start on + last forever
	fire:SetKeyValue("firesize", (size * math.Rand(0.7, 1.1)))
	fire:SetKeyValue("fireattack", attack)
	fire:SetKeyValue("health", fuel)
	fire:SetKeyValue("damagescale", "-10") -- Only negative, value prevents dmg.

	fire:Spawn()
	fire:Activate()

	return fire
end

-- greatly simplified version of SDK's game_shard/gamerules.cpp:RadiusDamage
-- does no block checking, radius should be very small
function RadiusDamage(dmginfo, pos, radius, inflictor)
	local victims = ents.FindInSphere(pos, radius)

	local tr = nil
	for k, vic in pairs(victims) do
		if IsValid(vic) and inflictor:Visible(vic) then
			if vic:IsPlayer() and vic:Alive() then
				vic:TakeDamageInfo(dmginfo)
			end
		end
	end
end

function ENT:OnRemove()
	if IsValid(self.FireChild) then
		self.FireChild:Remove()
	end
end

function ENT:OnTakeDamage()
end

function ENT:Explode()
	local pos = self:GetPos()

	local effect = EffectData()
	effect:SetStart(pos)
	effect:SetOrigin(pos)
	effect:SetScale(256)
	effect:SetRadius(256)
	effect:SetMagnitude(50)

	util.Effect("Explosion", effect, true, true)

	local dmgowner = self:GetDamageParent()
	if not IsValid(dmgowner) then
	  dmgowner = self
	end
	util.BlastDamage(self, dmgowner, pos, 300, 40)
end

function ENT:Think()
	if CLIENT then return end

	if self.DieTime < CurTime() then
		if self:GetExplodeOnDeath() then
			local success, err = pcall(self.Explode, self)

			if not success then
				ErrorNoHalt("ERROR CAUGHT: ttt_flame: " .. err .. "\n")
			end
		end

		if IsValid(self.FireChild) then
			self.FireChild:Remove()
		end

		self:Remove()
		return
	end

	if IsValid(self.FireChild) then
		if self.NextHurt < CurTime() then
			if self:WaterLevel() > 0 then
				self.DieTime = 0
				return
			end

			-- Deal Damage
			local dmg = DamageInfo()
			dmg:SetDamageType(DMG_BURN)
			dmg:SetDamage(math.random(4, 6))

			if IsValid(self:GetDamageParent()) then
				dmg:SetAttacker(self:GetDamageParent())
			else
				dmg:SetAttacker(self)
			end

			dmg:SetInflictor(self.FireChild)
			RadiusDamage(dmg, self:GetPos(), 132, self)
			self.NextHurt = CurTime() + self.HurtInterval
		end
		return
	elseif self:GetVelocity() == Vector(0,0,0) then
	if self:WaterLevel() > 0 then
		self.DieTime = 0
		return
		end

		self.FireChild = SpawnFire(self:GetPos(), self.FireSize, self.FireGrowth, 999, self:GetDamageParent(), self)
		self:SetBurning(true)
	end
end

if CLIENT then
	local fakefire = Material("cable/smoke")
	local side = Angle(-90, 0, 0)
	function ENT:BackupDraw()
		if not self:GetBurning() then return end

		local vstart = self:GetPos()
		local vend = vstart + Vector(0, 0, 90)

		side.r = side.r + 0.1

		cam.Start3D2D(vstart, side, 1)
		draw.DrawText("FIRE! IT BURNS!", "Default", 0, 0, TTT.Colors.Red, TEXT_ALIGN_CENTER)
		cam.End3D2D()

		render.SetMaterial(fakefire)
		render.DrawBeam(vstart, vend, 80, 0, 0, TTT.Colors.Red)
	end

	function ENT:Draw()
	end
end