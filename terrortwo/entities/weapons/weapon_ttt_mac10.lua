SWEP.Base		= "weapon_ttt_base"
DEFINE_BASECLASS(SWEP.Base)

SWEP.PrintName	= "MAC10"
SWEP.PhraseName = "weapon_mac10"
SWEP.Kind		= WEAPON_PRIMARY
SWEP.AutoSpawnable	= true

SWEP.HoldType	= "pistol"
SWEP.WorldModel	= "models/weapons/w_smg_mac10.mdl"
SWEP.ViewModel	= "models/weapons/cstrike/c_smg_mac10.mdl"
SWEP.UseHands		= true
SWEP.ViewModelFOV	= 54

SWEP.Primary.Automatic	= true
SWEP.Primary.Cone		= 0.03
SWEP.Primary.Damage		= 12
SWEP.Primary.Delay		= 0.065
SWEP.Primary.Recoil		= 1.15
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.ClipSize		= 30
SWEP.Primary.CarrySize		= 60
SWEP.Primary.Ammo			= "ar"

SWEP.Sound_Primary	= Sound("Weapon_mac10.Single")
SWEP.DeploySpeed	= 3

SWEP.IronSightsPos	= Vector(-8.921, -9.528, 2.9)
SWEP.IronSightsAng	= Vector(0.699, -5.301, -7)

function SWEP:GetHeadshotMultiplier(victim, dmginfo)
	local att = dmginfo:GetAttacker()
	if not IsValid(att) then
		return 2
	end

	local dist = victim:GetPos():Distance(att:GetPos())
	local d = math.max(0, dist - 150)

	-- decay from 3.2 to 1.7
	return 1.7 + math.max(0, (1.5 - 0.002 * (d ^ 1.25)))
end