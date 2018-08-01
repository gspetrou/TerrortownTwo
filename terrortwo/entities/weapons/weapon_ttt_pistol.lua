SWEP.Base		= "weapon_ttt_base"
DEFINE_BASECLASS(SWEP.Base)

SWEP.PrintName	= "Pistol"
SWEP.PhraseName = "weapon_pistol"
SWEP.Kind		= WEAPON_SECONDARY
SWEP.AutoSpawnable	= true

SWEP.HoldType	= "pistol"
SWEP.WorldModel	= "models/weapons/w_pist_fiveseven.mdl"
SWEP.ViewModel	= "models/weapons/cstrike/c_pist_fiveseven.mdl"
SWEP.UseHands		= true
SWEP.ViewModelFOV	= 54

SWEP.Primary.Automatic	= true
SWEP.Primary.Cone		= 0.02
SWEP.Primary.Damage		= 25
SWEP.Primary.Delay		= 0.38
SWEP.Primary.Recoil		= 1.5
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.ClipSize		= 20
SWEP.Primary.CarrySize		= 60
SWEP.Primary.Ammo			= "pistol_light"

SWEP.Sound_Primary	= Sound("Weapon_FiveSeven.Single")

SWEP.IronSightsPos	= Vector(-5.95, -4, 2.799)
SWEP.IronSightsAng	= Vector(0, 0, 0)