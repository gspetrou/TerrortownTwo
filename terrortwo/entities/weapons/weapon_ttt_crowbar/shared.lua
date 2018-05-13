-- weapon_ttt2_crowbar
SWEP.Base		= "weapon_ttt_base"
DEFINE_BASECLASS(SWEP.Base)

SWEP.PrintName	= "Crowbar"
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

local attackSound = Sound("Weapon_Crowbar.Single")
SWEP.Sound_Primary		= attackSound
SWEP.Sound_Secondary	= attackSound

SWEP.Animations_HitPerson = ACT_VM_HITCENTER
SWEP.Animations_HitWorld = ACT_VM_MISSCENTER
/*
function SWEP:OnDrop()
	self:Remove()
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then
		return
	end


end*/