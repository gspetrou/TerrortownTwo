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
SWEP.Primary.Delay		= 1
SWEP.NoSights			= true

SWEP.RoleWeapons = ROLE_DETECTIVE

-- DNA Scanner specific settings
SWEP.StoredSamples = {}				-- Where all DNA samples are stored.
SWEP.Range = 175					-- Maximum range an item can be from us to scan it.
SWEP.MaximumStorableSamples = 30	-- Maximum amount of samples we can store.
SWEP.ChargeDelay = 0.1				-- While recharging, a single tick takes this long to recover on the charge meter.
SWEP.ChargeRate = 3					-- While recharging, this is the amount we increment by.
SWEP.ChargeMax = 1250				-- The maximum amount of charge we can store.
SWEP.SoundMiss = Sound("player/suit_denydevice.wav")	-- Sound played when we tried DNA scanning nothing.
SWEP.SoundHit = Sound("button/blip2.wav")				-- Sound played when we succesfully DNA scanned something.

DNASCANNER_NOINDEX = 0	-- Global used to indicate when a scanner is not currently set to scan anything. Don't change to anything above 0.

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "Charge")				-- Our current scanner charge.
	self:NetworkVar("Int", 1, "CurrentScanIndex")	-- The index of the item in SWEP.StoredSamples that we are currently scanning.

	return BaseClass.SetupDataTables(self)
end


if CLIENT then
	CreateClientConVar("ttt_dna_scan_repeat", 1, true, true, "Should we auto-update the scanner when its fully charged.")
else
	function SWEP:AutoRepeat()
		return IsValid(self:GetOwner()) and self:GetOwner("ttt_dna_scan_repeat") == 1
	end
end

function SWEP:Initialize()
	self:SetCharge(self.ChargeMax)
	self:SetCurrentScanIndex(DNASCANNER_NOINDEX)

	return BaseClass.Initialize(self)
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	local ply = self:GetOwner()
	if not IsValid(ply) then
		return
	end

	ply:LagCompensation(true)

	local startPos = ply:GetShootPos()
	local endPos = startPos + (ply:GetAimVector() * self.Range)
	local hitEntity = util.TraceLine({
		start = startPos,
		endpos = endPos,
		filter = ply,
		mask = MASK_SHOT
	}).Entity

	if IsValid(hitEntity) and not hitEntity:IsPlayer() then
		if SERVER then
			-- Hit ragdoll.
			if hitEntity:IsCorpse() and hitEntity:HasTTTBodyData() then
				local sampleData = TTT.Corpse.GetSample(corpse)
				
			-- Hit weapon with prints on it.
			elseif hitEntity.HasFingerprints and hitEntity:HasFingerprints() then
				
			-- Couldn't find any DNA sample.
			else

			end
		end
	elseif CLIENT then
		ply:EmitSound(self.SoundMiss)
	end

	ply:LagCompensation(false)
end










