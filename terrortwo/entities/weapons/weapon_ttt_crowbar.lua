-- weapon_ttt2_crowbar
SWEP.Base		= "weapon_ttt_base"
DEFINE_BASECLASS(SWEP.Base)

SWEP.PrintName	= "Crowbar"
SWEP.PhraseName	= "weapon_crowbar"
SWEP.CanDrop	= false
SWEP.Kind		= WEAPON_MELEE
SWEP.SpawnWith	= true

SWEP.HoldType	= "melee"
SWEP.WorldModel	= "models/weapons/w_crowbar.mdl"
SWEP.ViewModel	= "models/weapons/c_crowbar.mdl"
SWEP.UseHands		= true
SWEP.ViewModelFOV	= 54

SWEP.Primary.Damage		= 20
SWEP.Primary.Delay		= 0.5
SWEP.Secondary.Damage	= 20
SWEP.Secondary.Delay	= 0.5

SWEP.AttackDistance		= 70

local Sound_Push = Sound("Weapon_Crowbar.Single")
local Sound_Open = Sound("DoorHandles.Unlocked3")

SWEP.Animations_HitPerson = ACT_VM_HITCENTER
SWEP.Animations_HitWorld = ACT_VM_MISSCENTER

if SERVER then
	CreateConVar("ttt_crowbar_unlocks", "1", FCVAR_ARCHIVE, "Can the crowbar unlock doors.")
	CreateConVar("ttt_crowbar_pushforce", "395", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "With how much force can a crowbar push you with.")
end

function SWEP:OpenEnt(hitEnt)
	if SERVER and GetConVar("ttt_crowbar_unlocks"):GetBool() then
		local openType = TTT.Weapons.OpenEntity(hitEnt)

		if openType ~= OPEN_NO then
			hitEnt:EmitSound(Sound_Open)
		end

		return openType
	else
		return OPEN_NO
	end
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if not IsValid(self:GetOwner()) then
		return
	end

	if self:GetOwner().LagCompensation then -- for some reason not always true
		self:GetOwner():LagCompensation(true)
	end

	local spos = self:GetOwner():GetShootPos()
	local sdest = spos + (self:GetOwner():GetAimVector() * 70)

	local tr_main = util.TraceLine({
		start = spos,
		endpos = sdest,
		filter = self:GetOwner(),
		mask = MASK_SHOT_HULL
	})
	local hitEnt = tr_main.Entity
	self:EmitSound(Sound_Push)

	if IsValid(hitEnt) or tr_main.HitWorld then
		self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )

		if not (CLIENT and (not IsFirstTimePredicted())) then
			local edata = EffectData()
			edata:SetStart(spos)
			edata:SetOrigin(tr_main.HitPos)
			edata:SetNormal(tr_main.Normal)
			edata:SetSurfaceProp(tr_main.SurfaceProps)
			edata:SetHitBox(tr_main.HitBox)
			--edata:SetDamageType(DMG_CLUB)
			edata:SetEntity(hitEnt)

			if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
				util.Effect("BloodImpact", edata)

				-- does not work on players rah
				--util.Decal("Blood", tr_main.HitPos + tr_main.HitNormal, tr_main.HitPos - tr_main.HitNormal)

				-- do a bullet just to make blood decals work sanely
				-- need to disable lagcomp because firebullets does its own
				self:GetOwner():LagCompensation(false)
				self:GetOwner():FireBullets({Num=1, Src=spos, Dir=self:GetOwner():GetAimVector(), Spread=Vector(0,0,0), Tracer=0, Force=1, Damage=0})
			else
				util.Effect("Impact", edata)
			end
		end
	else
		self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
	end

	if SERVER then
		
		-- Do another trace that sees nodraw stuff like func_button
		local tr_all = nil
		tr_all = util.TraceLine({start=spos, endpos=sdest, filter=self:GetOwner()})
		
		self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

		if IsValid(hitEnt) then
			if self:OpenEnt(hitEnt) == OPEN_NO and IsValid(tr_all.Entity) then
				-- See if there's a nodraw thing we should open
				self:OpenEnt(tr_all.Entity)
			end

			local dmg = DamageInfo()
			dmg:SetDamage(self.Primary.Damage)
			dmg:SetAttacker(self:GetOwner())
			dmg:SetInflictor(self.Weapon)
			dmg:SetDamageForce(self:GetOwner():GetAimVector() * 1500)
			dmg:SetDamagePosition(self:GetOwner():GetPos())
			dmg:SetDamageType(DMG_CLUB)

			hitEnt:DispatchTraceAttack(dmg, spos + (self:GetOwner():GetAimVector() * 3), sdest)

--			self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )			

--			self:GetOwner():TraceHullAttack(spos, sdest, Vector(-16,-16,-16), Vector(16,16,16), 30, DMG_CLUB, 11, true)
--			self:GetOwner():FireBullets({Num=1, Src=spos, Dir=self:GetOwner():GetAimVector(), Spread=Vector(0,0,0), Tracer=0, Force=1, Damage=20})
		
		else
--			if tr_main.HitWorld then
--				self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
--			else
--				self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
--			end

			-- See if our nodraw trace got the goods
			if tr_all.Entity and tr_all.Entity:IsValid() then
				self:OpenEnt(tr_all.Entity)
			end
		end
	end
	
	if self:GetOwner().LagCompensation then
		self:GetOwner():LagCompensation(false)
	end
end

function SWEP:SecondaryAttack()
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:SetNextSecondaryFire( CurTime() + 0.1 )

	if self:GetOwner().LagCompensation then
		self:GetOwner():LagCompensation(true)
	end

	local tr = self:GetOwner():GetEyeTrace(MASK_SHOT)

	if tr.Hit and IsValid(tr.Entity) and tr.Entity:IsPlayer() and (self:GetOwner():EyePos() - tr.HitPos):Length() < 100 then
		local ply = tr.Entity

		if SERVER and (not ply:IsFrozen()) then
			local pushvel = tr.Normal * GetConVar("ttt_crowbar_pushforce"):GetFloat()

			-- limit the upward force to prevent launching
			pushvel.z = math.Clamp(pushvel.z, 50, 100)

			ply:SetVelocity(ply:GetVelocity() + pushvel)
			self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

			ply:SetPushedData({
				Attacker = self:GetOwner(),
				Time = CurTime(),
				WeaponClass = self:GetClass()
			})
		end

		self:EmitSound(Sound_Push)		
		self:SendWeaponAnim( ACT_VM_HITCENTER )

		self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	end
	
	if self:GetOwner().LagCompensation then
		self:GetOwner():LagCompensation(false)
	end
end

function SWEP:OnDrop()
	self:Remove()
end