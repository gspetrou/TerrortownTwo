SWEP.Base		= "weapon_ttt2_base"
DEFINE_BASECLASS(SWEP.Base)

SWEP.PrintName	= "H.U.G.E-249"
SWEP.Kind		= WEAPON_PRIMARY
SWEP.AutoSpawnable	= true

SWEP.HoldType	= "crossbow"
SWEP.WorldModel	= "models/weapons/w_mach_m249para.mdl"
SWEP.ViewModel	= "models/weapons/cstrike/c_mach_m249para.mdl"
SWEP.UseHands		= true
SWEP.ViewModelFOV	= 54

SWEP.Primary.Automatic	= true
SWEP.Primary.Cone		= 0.09
SWEP.Primary.Damage		= 7
SWEP.Primary.Delay		= 0.06
SWEP.Primary.Recoil		= 1.9
SWEP.Primary.DefaultClip	= 150
SWEP.Primary.ClipSize		= 150
SWEP.Primary.CarrySize		= 150
SWEP.Primary.Ammo			= "none"

SWEP.Sound_Primary	= Sound("Weapon_m249.Single")
SWEP.HeadshotMultiplier = 2.2