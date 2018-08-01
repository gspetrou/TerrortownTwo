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

SWEP.Sound_Push = Sound("Weapon_Crowbar.Single")
SWEP.Sound_Open = Sound("DoorHandles.Unlocked3")

SWEP.Animations_HitPerson = ACT_VM_HITCENTER
SWEP.Animations_HitWorld = ACT_VM_MISSCENTER

if SERVER then
	CreateConVar("ttt_crowbar_unlocks", "1", FCVAR_ARCHIVE, "Can the crowbar unlock doors.")
	CreateConVar("ttt_crowbar_pushforce", "395", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "With how much force can a crowbar push you with.")
end

----------------
-- SWEP:OpenEnt
----------------
-- Desc:		Tries to open an entity with the crowbar.
-- Arg One:		Entity, to try to open.
-- Returns:		OPEN_ enum, what kind of entity we tried to open, OPEN_NO if openning failed.
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

-- Try to open doors or simply just hurt people on left click.
function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if not IsValid(self:GetOwner()) then
		return
	end

	-- Not always true for some reason.
	if self:GetOwner().LagCompensation then
		self:GetOwner():LagCompensation(true)
	end

	local startPos = self:GetOwner():GetShootPos()
	local destination = startPos + (self:GetOwner():GetAimVector() * 70)

	local mainTrace = util.TraceLine({
		start = startPos,
		endpos = destination,
		filter = self:GetOwner(),
		mask = MASK_SHOT_HULL
	})
	local hitEnt = mainTrace.Entity
	self:EmitSound(self.Sound_Push)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	if IsValid(hitEnt) or mainTrace.HitWorld then
		self:SendWeaponAnim(ACT_VM_HITCENTER)

		if SERVER or IsFirstTimePredicted() then
			local effectData = EffectData()
			effectData:SetStart(startPos)
			effectData:SetOrigin(mainTrace.HitPos)
			effectData:SetNormal(mainTrace.Normal)
			effectData:SetSurfaceProp(mainTrace.SurfaceProps)
			effectData:SetHitBox(mainTrace.HitBox)
			effectData:SetEntity(hitEnt)

			if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
				util.Effect("BloodImpact", effectData)

				-- Since util.Decal doesn't work on player lets fire a fake bullet at the player to create our blood effect.
				-- We need to disable Lag Compensation since FireBullets uses its own.
				self:GetOwner():LagCompensation(false)
				self:GetOwner():FireBullets({
					Num = 1,
					Src = startPos,
					Dir = self:GetOwner():GetAimVector(),
					Spread = Vector(0, 0, 0),
					Tracer = 0,
					Force = 1,
					Damage = 0
				})
			else
				util.Effect("Impact", effectData)
			end
		end
	else
		self:SendWeaponAnim(ACT_VM_MISSCENTER)
	end

	if SERVER then
		-- Do another trace that sees nodraw stuff like func_button.
		local traceAll = util.TraceLine({
			start = startPos,
			endpos = destination,
			filter = self:GetOwner()
		})

		if IsValid(hitEnt) then
			-- See if there's a nodraw thing we should open
			if self:OpenEnt(hitEnt) == OPEN_NO and IsValid(traceAll.Entity) then
				self:OpenEnt(traceAll.Entity)
			end

			local dmgInfo = DamageInfo()
			dmgInfo:SetDamage(self.Primary.Damage)
			dmgInfo:SetAttacker(self:GetOwner())
			dmgInfo:SetInflictor(self.Weapon)
			dmgInfo:SetDamageForce(self:GetOwner():GetAimVector() * 1500)
			dmgInfo:SetDamagePosition(self:GetOwner():GetPos())
			dmgInfo:SetDamageType(DMG_CLUB)

			hitEnt:DispatchTraceAttack(dmgInfo, startPos + (self:GetOwner():GetAimVector() * 3), destination)
		else
			-- See if our nodraw trace got the goods.
			if traceAll.Entity and IsValid(traceAll.Entity) then
				self:OpenEnt(traceAll.Entity)
			end
		end
	end
	
	if self:GetOwner().LagCompensation then
		self:GetOwner():LagCompensation(false)
	end
end

-- Push people on right click.
function SWEP:SecondaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + 0.1)

	if self:GetOwner().LagCompensation then
		self:GetOwner():LagCompensation(true)
	end

	local tr = self:GetOwner():GetEyeTrace(MASK_SHOT)

	if tr.Hit and IsValid(tr.Entity) and tr.Entity:IsPlayer() and (self:GetOwner():EyePos() - tr.HitPos):Length() < 100 then
		local ply = tr.Entity

		if SERVER and not ply:IsFrozen() then
			local pushAmount = tr.Normal * GetConVar("ttt_crowbar_pushforce"):GetFloat()			
			pushAmount.z = math.Clamp(pushAmount.z, 50, 100) -- Limit the upward force to prevent launching.

			ply:SetVelocity(ply:GetVelocity() + pushAmount)
			self:GetOwner():SetAnimation(PLAYER_ATTACK1)

			ply:SetPushedData({
				Attacker = self:GetOwner(),
				Time = CurTime(),
				WeaponClass = self:GetClass(),
				Weapon = self
			})
		end

		self:EmitSound(self.Sound_Push)		
		self:SendWeaponAnim(ACT_VM_HITCENTER)

		self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	end
	
	if self:GetOwner().LagCompensation then
		self:GetOwner():LagCompensation(false)
	end
end

function SWEP:OnDrop()
	self:Remove()
end