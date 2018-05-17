AddCSLuaFile()
ENT.Base = "ttt_grenade_base"
DEFINE_BASECLASS(ENT.Base)
ENT.Type = "anim"
ENT.Model = Model("models/weapons/w_eq_flashbang_thrown.mdl")

function ENT:SetRadius(r) self.Radius = r end
function ENT:GetRadius() return self.Radius end
function ENT:SetDamage(d) self.Damage = d end
function ENT:GetDamage() return self.Damage end

function ENT:Initialize()
	if not self:GetRadius() then self:SetRadius(256) end
	if not self:GetDamage() then self:SetDamage(25) end
	BaseClass.Initialize(self)
end

function ENT:Explode(tr)
	if SERVER then
		self:SetNoDraw(true)
		self:SetSolid(SOLID_NONE)

		-- Pull out of the surface.
		if tr.Fraction ~= 1.0 then
			self:SetPos(tr.HitPos + tr.HitNormal * 0.6)
		end

		local pos = self:GetPos()
		if util.PointContents(pos) == CONTENTS_WATER then
			self:Remove()
			return
		end

		local effect = EffectData()
		effect:SetStart(pos)
		effect:SetOrigin(pos)
		effect:SetScale(self:GetRadius() * 0.3)
		effect:SetRadius(self:GetRadius())
		effect:SetMagnitude(self:GetDamage())

		if tr.Fraction ~= 1.0 then
			effect:SetNormal(tr.HitNormal)
		end

		util.Effect("Explosion", effect, true, true)
		util.BlastDamage(self, self:GetThrower(), pos, self:GetRadius(), self:GetDamage())

		StartFires(pos, tr, 10, 20, false, self:GetThrower())

		self:SetDetonateExact(0)
		self:Remove()
	else
		local startPos = self:GetPos()
		local trs = util.TraceLine({
			start = startPos + Vector(0, 0, 64),
			endpos = startPos + Vector(0, 0, -128),
			filter = self
		})

		util.Decal("Scorch", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)      
		self:SetDetonateExact(0)
	end
end
