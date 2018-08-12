
SWEP.Base		= "weapon_ttt_base"
DEFINE_BASECLASS(SWEP.Base)

SWEP.PrintName	= "DNA Scanner"
SWEP.PhraseName = "weapon_dnascanner"
SWEP.Kind		= WEAPON_SPECIALEQUIP
SWEP.AutoSpawnable	= false

SWEP.HoldType	= "normal"
SWEP.WorldModel	= "models/props_lab/huladoll.mdl"
SWEP.ViewModel	= "models/weapons/v_crowbar.mdl"
SWEP.UseHands		= true
SWEP.ViewModelFOV	= 10

SWEP.Primary.Enabled	= false
SWEP.Primary.Ammo		= "none"
self.NoSights			= true

SWEP.SpawnWith = ROLE_DETECTIVE

-- DNA Scanner specific settings
SWEP.StoredSamples = {}				-- Where all DNA samples are stored.
SWEP.Range = 175					-- Maximum range an item can be from us to scan it.
SWEP.MaximumStorableSamples = 30	-- Maximum amount of samples we can store.
SWEP.ChargeDelay = 0.1				-- While recharging, a single tick takes this long to recover on the charge meter.
SWEP.ChargeRate = 3					-- While recharging, this is the amount we increment by.
SWEP.ChargeMax = 1250				-- The maximum amount of charge we can store.

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "Charge")				-- Our current scanner charge.
	self:NetworkVar("Int", 1, "CurrentScanIndex")	-- The index of the item in SWEP.StoredSamples that we are scanning.

	return BaseClass.SetupDataTables(self)
end

