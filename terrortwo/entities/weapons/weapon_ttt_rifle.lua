SWEP.Base		= "weapon_ttt2_base"
DEFINE_BASECLASS(SWEP.Base)

SWEP.PrintName	= "Scout"
SWEP.Kind		= WEAPON_PRIMARY
SWEP.AutoSpawnable	= true

SWEP.HoldType	= "pistol"
SWEP.WorldModel	= "models/weapons/w_snip_scout.mdl"
SWEP.ViewModel	= "models/weapons/cstrike/c_snip_scout.mdl"
SWEP.UseHands		= true
SWEP.ViewModelFOV	= 54

SWEP.Primary.Automatic	= true
SWEP.Primary.Cone		= 0.005
SWEP.Primary.Damage		= 50
SWEP.Primary.Delay		= 1.5
SWEP.Primary.Recoil		= 7
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.ClipSize		= 10
SWEP.Primary.CarrySize		= 20
SWEP.Primary.Ammo			= "sniper"

SWEP.Sound_Primary	= Sound("Weapon_Scout.Single")
SWEP.HeadshotMultiplier = 4