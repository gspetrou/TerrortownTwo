SWEP.Base		= "weapon_ttt_base"
DEFINE_BASECLASS(SWEP.Base)

SWEP.PrintName	= "Deagle"
SWEP.PhraseName = "weapon_deagle"
SWEP.Kind		= WEAPON_SECONDARY
SWEP.AutoSpawnable	= true

SWEP.HoldType	= "pistol"
SWEP.WorldModel	= "models/weapons/w_pist_deagle.mdl"
SWEP.ViewModel	= "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.UseHands		= true
SWEP.ViewModelFOV	= 54

SWEP.Primary.Automatic	= true
SWEP.Primary.Cone		= 0.02
SWEP.Primary.Damage		= 37
SWEP.Primary.Delay		= 0.6
SWEP.Primary.Recoil		= 6
SWEP.Primary.DefaultClip	= 8
SWEP.Primary.ClipSize		= 8
SWEP.Primary.CarrySize		= 36
SWEP.Primary.Ammo			= "pistol_heavy"

SWEP.Sound_Primary	= Sound("Weapon_Deagle.Single")
SWEP.HeadshotMultiplier = 4

SWEP.IronSightsPos	= Vector(-6.361, -3.701, 2.15)
SWEP.IronSightsAng	= Vector(0, 0, 0)