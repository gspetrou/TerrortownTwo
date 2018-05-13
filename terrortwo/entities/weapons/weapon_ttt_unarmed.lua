-- weapon_ttt2_unarmed
SWEP.Base		= "weapon_ttt2_base"
DEFINE_BASECLASS(SWEP.Base)

SWEP.PrintName	= "Holstered"
SWEP.CanDrop		= false
SWEP.Kind			= WEAPON_UNARMED
SWEP.SpawnWith		= true

SWEP.HoldType	= "normal"
SWEP.ViewModel	= "models/weapons/v_crowbar.mdl"
SWEP.WorldModel	= "models/weapons/w_crowbar.mdl"
SWEP.ViewModelFOV	= 10

SWEP.Primary.Enabled		= false
SWEP.Secondary.Enabled		= false

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:Holster()
	return true
end

function SWEP:Reload()
end

function SWEP:DrawWorldModel()
end

function SWEP:DrawWorldModelTranslucent()
end

function SWEP:Deploy()
	if SERVER and IsValid(self:GetOwner()) then
		self:GetOwner():DrawViewModel(false)
	end

	self:DrawShadow(false)
	return true
end
