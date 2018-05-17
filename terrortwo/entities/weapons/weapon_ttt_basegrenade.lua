---------------------------
-- weapon_ttt2_basegrenade
---------------------------
-- Again, lots of code used from Badking.

-- Default Settings
--------------------
AddCSLuaFile()
SWEP.Base		= "weapon_ttt_base"
DEFINE_BASECLASS(SWEP.Base)

SWEP.Category	= "TTT2 Weapons"
SWEP.Spawnable	= false
SWEP.AdminOnly	= false
SWEP.PrintName	= "[TTT2] Missing Name Grenade"

SWEP.Author		= "Stalker"
SWEP.Contact	= "http://steamcommunity.com/id/your-stalker/"
SWEP.Purpose	= "A grenade for TTT2."
SWEP.Instructions = "I dunno. Just click some buttons and figure it out."

SWEP.BounceWeaponIcon	= false
SWEP.DrawWeaponInfoBox	= false
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false
SWEP.AccurateCrosshair	= false
SWEP.DisableDuplicator	= true

SWEP.RenderGroup	= RENDERGROUP_OPAQUE

SWEP.WorldModel		= "models/weapons/w_eq_flashbang.mdl"
SWEP.ViewModel		= "models/weapons/v_eq_flashbang.mdl"
SWEP.ViewModelFlip	= false
SWEP.ViewModelFlip1	= false
SWEP.ViewModelFlip2	= false
SWEP.ViewModelFOV	= 82	-- Default TTT1 FOV
SWEP.UseHands		= false

SWEP.AutoSwitchFrom	= false
SWEP.AutoSwitchTo	= false

SWEP.Weight		= 5
SWEP.BobScale	= 1
SWEP.SwayScale	= 1

SWEP.Slot	= 0	-- This doesn't do anything, use SWEP.Kind instead.
SWEP.SlotPos= 0	-- This doesn't do anything, use SWEP.Kind instead.

SWEP.CSMuzzleFlashes= true
SWEP.CSMuzzleX		= false

SWEP.Primary = {}
SWEP.Primary.Ammo		= "none"
SWEP.Primary.ClipSize	= -1
SWEP.Primary.DefaultClip= -1
SWEP.Primary.Automatic	= false

SWEP.Secondary = {}
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false

-- TTT2 Grenade Settings
-------------------------
SWEP.IsGrenade		= true
SWEP.HoldTypeNormal	= "slam"
SWEP.HoldTypeReady	= "grenade"
SWEP.DeploySpeed	= 1.5					-- Number, how long it takes to deploy.
SWEP.Kind			= WEAPON_GRENADE		-- WEAPON_ enum for what slot this gun takes.
SWEP.WasThrown		= false 				-- Boolean, was the grenade thrown.
SWEP.GrenadeName 	= "UNSET"				-- String, make sure you set this to your grenade entity!

SWEP.Primary.Delay			= 1		-- Number, time delay between each shot.
SWEP.Primary.Ammo			= "none"-- String, type of ammo the weapon takes.
SWEP.Secondary.Enabled		= false -- Boolean, decides if secondary attack does anything.
SWEP.TimeFromThrowToExplode	= 5		-- Number, time from after being thrown to when it explodes.

SWEP.Animations_Primary		= ACT_VM_PULLPIN			-- Enum. animation to play when primary attacking (first person).

local canThrowDuringPrep = CreateConVar("ttt_no_nade_throw_during_prep", "0", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Can players throw grenades during round prep.")

function SWEP:SetDetonationTime(t)
	self.DetonationTime = t
end
function SWEP:GetDetonationTime()
	return self.DetonationTime
end


function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "PinPulled")
	self:NetworkVar("Int", 0, "ThrowTime")
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if not canThrowDuringPrep:GetBool() or not TTT.Rounds.IsPrep() then
		self:PullPin()
	end
end

function SWEP:PullPin()
	if self:GetPinPulled() then
		return
	end

	local ply = self:GetOwner()
	if not IsValid(ply) then
		return
	end

	self:SendWeaponAnim(self.Animations_Primary)
	self:SetHoldType(self.HoldTypeReady)
	self:SetPinPulled(true)
	self:SetDetonationTime(CurTime() + self.TimeFromThrowToExplode)
end

function SWEP:Think()
	BaseClass.Think(self)
	local ply = self:GetOwner()
	if not IsValid(ply) then
		return
	end

	if self:GetPinPulled() then
		if not ply:KeyDown(IN_ATTACK) then
			self:StartThrow()
			self:SetPinPulled(false)
			self:SendWeaponAnim(self.Animations_Primary)

			if SERVER then
				self:GetOwner():SetAnimation(self.Animations_Primary3rdPerson)
			end
		else
			if SERVER and self:GetDetonationTime() <= CurTime() then
				self:BlowInFace()
			end
		end
	elseif self:GetThrowTime() > 0 and self:GetThrowTime() < CurTime() then
		self:Throw()
	end
end

function SWEP:BlowInFace()
	local ply = self:GetOwner()
	if not IsValid(self:GetOwner()) or self.WasThrown then
		return
	end

	local ang = ply:GetAngles()
	local source = ply:GetPos() + (ply:Crouching() and ply:GetViewOffsetDucked() or ply:GetViewOffset())
	source = source + (ang:Right() * 10)

	self:CreateGrenade(source, Angle(0,0,0), Vector(0,0,1), Vector(0,0,1), ply)
	self:SetThrowTime(0)
	self:Remove()
end

function SWEP:StartThrow()
	self:SetThrowTime(CurTime() + 0.1)
end

function SWEP:Throw()
	if CLIENT then
		self:SetThrowTime(0)
	elseif SERVER then
		local ply = self:GetOwner()
		if not IsValid(ply) or self.WasThrown then
			return
		end

		self.WasThrown = true

		local ang = ply:EyeAngles()
		local src = ply:GetPos() + (ply:Crouching() and ply:GetViewOffsetDucked() or ply:GetViewOffset()) + (ang:Forward() * 8) + (ang:Right() * 10)
		local target = ply:GetEyeTraceNoCursor().HitPos
		local tang = (target - src):Angle() -- A target angle to actually throw the grenade to the crosshair instead of fowards

		-- Makes the grenade go upwards.
		if tang.p < 90 then
			tang.p = -10 + tang.p * ((90 + 10) / 90)
		else
			tang.p = 360 - tang.p
			tang.p = -10 + tang.p * -((90 + 10) / 90)
		end

		tang.p = math.Clamp(tang.p, -90, 90) -- Makes the grenade not go backwards :/
		local velocity = math.min(800, (90 - tang.p) * 6)
		local throw = tang:Forward() * velocity + ply:GetVelocity()
		self:CreateGrenade(src, Angle(0,0,0), throw, Vector(600, math.random(-1200, 1200), 0), ply)
		self:SetThrowTime(0)
		self:Remove()
	end
end

function SWEP:GetGrenadeName()
	if self.GrenadeName == "UNSET" then
		ErrorNoHalt("SWEP BASEGRENADE ERROR: GetGrenadeName not overridden! This is probably wrong!\n")
		return "ttt_firegrenade_proj"
	end
	return self.GrenadeName
end

function SWEP:CreateGrenade(source, ang, velocity, additionalVelocity, ply)
	print"ars"
	local grenade = ents.Create(self:GetGrenadeName())
	if not IsValid(grenade) then
		return
	end

	grenade:SetPos(source)
	grenade:SetAngles(ang)
	grenade:SetOwner(ply)
	grenade:SetThrower(ply)

	grenade:SetGravity(0.4)
	grenade:SetFriction(0.2)
	grenade:SetElasticity(0.45)

	grenade:Spawn()
	grenade:PhysWake()

	local phys = grenade:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(velocity)
		phys:AddAngleVelocity(additionalVelocity)
	end

	-- This has to happen AFTER Spawn() calls gren's Initialize()
	grenade:SetDetonateExact(self:GetDetonationTime())
	return grenade
end

function SWEP:PreDrop()
	-- If the owner dies while the pin is pulled drop the armed grenade anyways.
	if self:GetPinPulled() then
		self:BlowInFace()
	end
end

function SWEP:Deploy()
	self:SetHoldType(self.HoldTypeNormal)
	self:SetThrowTime(0)
	self:SetPinPulled(false)
	return true
end

function SWEP:Holster()
	if self:GetPinPulled() then
		return false -- No switching after pulling pin.
	end

	self:SetThrowTime(0)
	self:SetPinPulled(false)
	return true
end

function SWEP:Reload()
	return false
end

function SWEP:Initialize()
	util.PrecacheModel(self.ViewModel)
	util.PrecacheModel(self.WorldModel)

	self:SetHoldType(self.HoldTypeNormal)
	self:SetDeploySpeed(self.DeploySpeed)

	if SERVER then
		self:SetDetonationTime(0)
	end
	
	self:SetThrowTime(0)
	self:SetPinPulled(false)

	self.WasThrown = false
end

function SWEP:OnRemove()
	if CLIENT and IsValid(self:GetOwner()) and self:GetOwner() == LocalPlayer() and self:GetOwner():Alive() then
		input.SelectWeapon(self:GetOwner():GetWeapon("weapon_ttt_unarmed"))
	end
end