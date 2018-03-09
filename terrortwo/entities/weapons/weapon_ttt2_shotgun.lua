SWEP.Base		= "weapon_ttt2_base"
DEFINE_BASECLASS(SWEP.Base)

SWEP.PrintName	= "Shotgun"
SWEP.Kind		= WEAPON_PRIMARY
SWEP.AutoSpawnable	= true

SWEP.HoldType	= "pistol"
SWEP.WorldModel	= "models/weapons/w_shot_xm1014.mdl"
SWEP.ViewModel	= "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.UseHands		= true
SWEP.ViewModelFOV	= 54

SWEP.Primary.Automatic	= true
SWEP.Primary.Cone		= 0.085
SWEP.Primary.Damage		= 11
SWEP.Primary.Delay		= 0.8
SWEP.Primary.Recoil		= 7
SWEP.Primary.DefaultClip	= 8
SWEP.Primary.ClipSize		= 8
SWEP.Primary.CarrySize		= 24
SWEP.Primary.NumShots		= 8
SWEP.Primary.Ammo			= "shotgun_buckshot"

SWEP.Sound_Primary	= Sound("Weapon_XM1014.Single")
SWEP.HeadshotMultiplier = 4

-- Shotguns need special stuff to reload properly.
function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Reloading")
	self:NetworkVar("Float", 0, "ReloadTimer")

	return self.BaseClass.SetupDataTables(self)
end

function SWEP:Reload()
	if self:GetReloading() or (self:Clip1() < self.Primary.ClipSize and self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0) then
		self:StartReload()
	end
end

function SWEP:StartReload()
	if self:GetReloading() then
		return false
	end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	local ply = self:GetOwner()
	if not ply or not IsValid(ply) or ply:GetAmmoCount(self.Primary.Ammo) <= 0 or self:Clip1() >= self.Primary.ClipSize then
		return false
	end

	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
	self:SetReloadTimer(CurTime() + self:SequenceDuration())
	self:SetReloading(true)

	return true
end

function SWEP:PerformReload()
	local ply = self:GetOwner()

	-- prevent normal shooting in between reloads
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if not ply or not IsValid(ply) or ply:GetAmmoCount(self.Primary.Ammo) <= 0 or self:Clip1() >= self.Primary.ClipSize then
		return
	end

	self:GetOwner():RemoveAmmo(1, self.Primary.Ammo, false)
	self:SetClip1(self:Clip1() + 1)
	self:SendWeaponAnim(ACT_VM_RELOAD)
	self:SetReloadTimer(CurTime() + self:SequenceDuration())
end

function SWEP:Think()
	self.BaseClass.Think(self)
	if self:GetReloading() then
		if self:GetOwner():KeyDown(IN_ATTACK) then
			self:FinishReload()
			return
		end

		if self:GetReloadTimer() <= CurTime() then
			if self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0 and self:Clip1() < self.Primary.ClipSize then
				self:PerformReload()
			else
				self:FinishReload()
			end
		end
	end
end

function SWEP:FinishReload()
	self:SetReloading(false)
	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
	self:SetReloadTimer(CurTime() + self:SequenceDuration())
end

function SWEP:Deploy()
	self:SetReloading(false)
	self:SetReloadTimer(0)
	return self.BaseClass.Deploy(self)
end