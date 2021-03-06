SWEP.Base		= "weapon_ttt_base"
DEFINE_BASECLASS(SWEP.Base)

SWEP.PrintName	= "M16"
SWEP.PhraseName = "weapon_m16"
SWEP.Kind		= WEAPON_PRIMARY
SWEP.AutoSpawnable	= true

SWEP.HoldType	= "ar2"
SWEP.WorldModel	= "models/weapons/w_rif_m4a1.mdl"
SWEP.ViewModel	= "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.UseHands		= true
SWEP.ViewModelFOV	= 64

SWEP.Primary.Automatic	= true
SWEP.Primary.Cone		= 0.018
SWEP.Primary.Damage		= 23
SWEP.Primary.Delay		= 0.19
SWEP.Primary.Recoil		= 1.6
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.ClipSize		= 20
SWEP.Primary.CarrySize		= 60
SWEP.Primary.Ammo			= "pistol_light"

SWEP.Sound_Primary	= Sound("Weapon_M4A1.Single")

SWEP.IronSightsPos	= Vector(-7.58, -9.2, 0.55)
SWEP.IronSightsAng	= Vector(2.599, -1.3, -3.6)

SWEP.ZoomFOV = 35
SWEP.ZoomInTime = 0.5
SWEP.ZoomOutTime = 0.2