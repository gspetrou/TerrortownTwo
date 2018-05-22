AddCSLuaFile()
ENT.Type = "anim"
ENT.Model = Model("models/weapons/w_eq_flashbang_thrown.mdl")

function ENT:GetThrower()
	return self.Thrower
end

function ENT:SetThrower(ply)
	self.Thrower = ply
end

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "ExplodeTime")
end

function ENT:Initialize()
	self:SetModel(self.Model)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	if SERVER then
		self:SetExplodeTime(0)
	end
end

function ENT:SetDetonateTimer(length)
	self:SetDetonateExact(CurTime() + length)
end

function ENT:SetDetonateExact(time)
	self:SetExplodeTime(time or CurTime())
end

-- Should be overriden. Called when its time for the grenade to explode.
function ENT:Explode(tr)
	ErrorNoHalt("ERROR: ttt_grenade_base explosion code not overridden!\n")
end

function ENT:Think()
	local explosionTime = self:GetExplodeTime() or 0
	if explosionTime == 0 or explosionTime > CurTime() then
		return
	end

	-- If thrower disconnects before grenade explodes, don't explode.
	if SERVER and not IsValid(self:GetThrower()) then
		self:Remove()
		explosionTime = 0
		return
	end

	-- Find the ground if it's near and pass it to the explosion.
	local startPos = self:GetPos()
	local tr = util.TraceLine({
		start = startPos,
		endpos = startPos + Vector(0, 0, -32),
		mask = MASK_SHOT_HULL,
		filter = self:GetThrower()
	})

	local success, err = pcall(self.Explode, self, tr)
	if not success then
		self:Remove()
		ErrorNoHalt("ERROR CAUGHT: ttt_grenade_base: "..err.."\n")
	end
end