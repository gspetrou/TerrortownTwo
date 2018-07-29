SWEP.Base		= "weapon_ttt_base"
DEFINE_BASECLASS(SWEP.Base)

SWEP.PrintName	= "Glock"
SWEP.PhraseName	= "weapon_glock"
SWEP.Kind		= WEAPON_SECONDARY
SWEP.AutoSpawnable	= true

SWEP.HoldType	= "pistol"
SWEP.WorldModel	= "models/weapons/w_pist_glock18.mdl"
SWEP.ViewModel	= "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.UseHands		= true
SWEP.ViewModelFOV	= 54

SWEP.Primary.Automatic	= true
SWEP.Primary.Cone		= 0.028
SWEP.Primary.Damage		= 12
SWEP.Primary.Delay		= 0.1
SWEP.Primary.Recoil		= 0.9
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.ClipSize		= 20
SWEP.Primary.CarrySize		= 60
SWEP.Primary.Ammo			= "pistol_light"

SWEP.Sound_Primary	= Sound("Weapon_Glock.Single")
SWEP.HeadshotMultiplier = 1.75
SWEP.IronSightsPos	= Vector(-5.79, -3.9982, 2.8289)