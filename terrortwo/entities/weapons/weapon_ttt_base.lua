--------------------
-- weapon_ttt2_base
--------------------
-- Lots of code here has been either copied or influenced by the TTT1 base.
-- Note: If you want to override SWEP:Equip() make sure you call the baseclass function as well.

-- Default Settings
--------------------
SWEP.Base		= "weapon_base"
DEFINE_BASECLASS(SWEP.Base)

SWEP.Category	= "TTT2 Weapons"
SWEP.Spawnable	= false
SWEP.AdminOnly	= false
SWEP.PrintName	= "[TTT2] Missing Name"

SWEP.Author		= "Stalker"
SWEP.Contact	= "http://steamcommunity.com/id/your-stalker/"
SWEP.Purpose	= "A weapon for TTT2."
SWEP.Instructions = "I dunno. Just click some buttons and figure it out."

SWEP.BounceWeaponIcon	= false
SWEP.DrawWeaponInfoBox	= false
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false
SWEP.AccurateCrosshair	= false
SWEP.DisableDuplicator	= true

SWEP.RenderGroup	= RENDERGROUP_OPAQUE

SWEP.WorldModel		= "models/weapons/w_crowbar.mdl"
SWEP.ViewModel		= "models/weapons/v_crowbar.mdl"
SWEP.ViewModelFlip	= false
SWEP.ViewModelFlip1	= false
SWEP.ViewModelFlip2	= false
SWEP.ViewModelFOV	= 82	-- Default TTT1 FOV
SWEP.UseHands		= false

SWEP.AutoSwitchFrom	= false
SWEP.AutoSwitchTo	= false

SWEP.Weight		= 5
SWEP.BobScale	= 1
SWEP.SwayScale	= 1

SWEP.Slot	= 0	-- This doesn't do anything, use SWEP.Kind instead.
SWEP.SlotPos= 0	-- This doesn't do anything, use SWEP.Kind instead.

SWEP.CSMuzzleFlashes= true
SWEP.CSMuzzleX		= false

SWEP.Primary = {}
SWEP.Primary.Ammo		= "none"
SWEP.Primary.ClipSize	= -1
SWEP.Primary.DefaultClip= -1
SWEP.Primary.Automatic	= false

SWEP.Secondary = {}
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false

-- TTT2 Specific Settings
--------------------------
SWEP.IsTTTWeapon	= true
SWEP.HoldType		= "normal"
SWEP.DeploySpeed	= 1.4					-- Number, how long it takes to deploy.
SWEP.Icon			= "vgui/ttt/icon_nades"	-- String, icon path to be displayed for the weapon. Can be PNG.
SWEP.AutoSpawnable	= false					-- Can the ttt_random_weapon entity spawn this.
SWEP.SilentKiller	= false					-- When someone is killed by this weapon they won't scream.
SWEP.CanDrop		= true					-- Boolean, can they drop this weapon.
SWEP.DrawTTTCrosshair	= true				-- Boolean, should we draw the default TTT crosshair.
SWEP.NoSights		= false

SWEP.Fingerprints	= {}
SWEP.SpawnWith		= nil					-- Boolean. If true, everyone will spawn with this weapon.
SWEP.RoleWeapon		= nil					-- ROLE_ enum or table of ROLE_ enums. Any player with one of these roles will be given this weapon at the start of the round.
SWEP.Kind			= WEAPON_PRIMARY		-- WEAPON_ enum for what slot this gun takes.

-- Set the sounds to false to disable them.
SWEP.Sound_Primary	= Sound("Weapon_Pistol.Single")
SWEP.Sound_Secondary= nil
SWEP.Sound_Empty	= Sound("Weapon_Pistol.Empty")
SWEP.Sound_Reload	= Sound("Weapon_Pistol.Reload")

SWEP.ShouldDisplayAmmo = true	-- Boolean, should the weapon display ammo on the HUD.

SWEP.Primary.Enabled		= true	-- Boolean, if false then primary attacking won't do anything,
SWEP.Primary.NumShots		= 1 	-- Number, how many shots/pellets to come out of each attack.
SWEP.Primary.TakenAmmo		= 1		-- Number, how much ammo to take each shot.
SWEP.Primary.Damage			= 1		-- Number, how much damage per shot.
SWEP.Primary.Delay			= 0.15	-- Number, time delay between each shot.
SWEP.Primary.Recoil			= 1.5	-- Number, how much the shooter's camera angles up each shot.
SWEP.Primary.Cone			= 0.02	-- Number, radius of the spread cone the gun shoots.
SWEP.Primary.DefaultClip	= 10	-- Number, how much ammo is in the clip of the gun when it is first picked up.
SWEP.Primary.ClipSize		= 10	-- Number, how many bullets go in one clip of the weapon.
SWEP.Primary.CarrySize		= 30	-- Number, how many bullets get carried on the side.
SWEP.Primary.Tracers		= 1		-- Number, of visible "tracer" shots. If set to 4 that means that one in four bullets can be seen flying from the gun.
SWEP.Primary.BulletForce	= 1		-- Number, push force with each shot.
SWEP.Primary.DryFireDelay	= 0.2	-- Number, time between each time you can dry fire. No real reason to change this unless you wan't to.
SWEP.Primary.RequiresAmmo	= true	-- Boolean, does this weapon require ammo to function.
SWEP.Primary.Ammo			= "none"-- String, type of ammo the weapon takes.

SWEP.Secondary.Enabled		= true	-- Boolean, if false then primary attacking won't do anything,
SWEP.Secondary.Damage		= 1		-- Number, how much damage per shot.
SWEP.Secondary.Delay		= 0.15	-- Number, time delay between each shot.
SWEP.Secondary.Recoil		= 1.5	-- Number, how much the shooter's camera angles up each shot.
SWEP.Secondary.Cone			= 0.02	-- Number, radius of the spread cone the gun shoots.
SWEP.Secondary.DryFireDelay	= 0.2	-- Number, time between each time you can dry fire. No real reason to change this unless you wan't to.
SWEP.Secondary.Ammo			= "none"-- String, type of ammo the weapon takes.

SWEP.ZoomFOV = 0	-- 0 to disable.
SWEP.ZoomInTime = 0.5
SWEP.ZoomOutTime = 0.5

SWEP.HeadshotMultiplier		= 2.7		-- Number, headshot damage multiplier.

SWEP.StoredAmmo_Primary		= 0		-- Used to store ammo on a weapon when it is dropped.

-- Set the animations to false to disable them.
SWEP.Animations_Primary		= ACT_VM_PRIMARYATTACK		-- Enum. animation to play when primary attacking (first person).
SWEP.Animations_Secondary	= ACT_VM_SECONDARYATTACK	-- Enum, animation to play when secondary attaking (first person).
SWEP.Animations_Reload		= ACT_VM_RELOAD				-- Enum, animation to play when reloading.
SWEP.Animations_Primary3rdPerson	= PLAYER_ATTACK1	-- Enum, animation to play when primary attacking (third person).
SWEP.Animations_Secondary3rdPerson	= PLAYER_ATTACK1	-- Enum, animation to play when secondary attacking (third person).

-- Micro-optimizations!
local CurTime, Vector, game_SinglePlayer = CurTime, Vector, game.SinglePlayer

function SWEP:Initialize()
	util.PrecacheModel(self.ViewModel)
	util.PrecacheModel(self.WorldModel)

	self:SetHoldType(self.HoldType)
	self:SetDeploySpeed(self.DeploySpeed)

	self:SetClip1(self.Primary.DefaultClip)
	self:SetIronsights(false)
end

function SWEP:Reload()
	local reloaded = self:DefaultReload(self.Animations_Reload)

	if reloaded and self.Sound_Reload then
		self:EmitSound(self.Sound_Reload)
	end

	self:SetIronsights(false)
	self:SetZoom(false)
end

function SWEP:Holster()
	self:SetIronsights(false)
	self:SetZoom(false)
	return true
end

function SWEP:Deploy()
	self:SetIronsights(false)
	self:SetZoom(false)
	return true -- Its really annoying when people forget to return true here.
end

function SWEP:OnRestore()
	self:SetIronsights(false)
	self:SetZoom(false)
end

function SWEP:SetIronsights(b)
	self:SetIronsightsPredicted(b)
	self:SetIronsightsTime(CurTime())
	if CLIENT then
		self:CalcViewModel()
	end
end

function SWEP:GetIronsights()
	return self:GetIronsightsPredicted()
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "IronsightsPredicted")
	self:NetworkVar("Float", 0, "IronsightsTime")
end

function SWEP:CalcViewModel()
	if not CLIENT or not IsFirstTimePredicted() then
		return
	end

	self.bIron = self:GetIronsights()
	self.fIronTime = self:GetIronsightsTime()
	self.fCurrentTime = CurTime()
	self.fCurrentSysTime = SysTime()
end

-- Note that if you override Think in your SWEP, you should call
-- BaseClass.Think(self) so as not to break ironsights
function SWEP:Think()
	self:CalcViewModel()
end

-- Largely copied from weapon_tttbase.
local SF_WEAPON_START_CONSTRAINED = 1
function SWEP:Equip(newOwner)
	if SERVER then
		-- Check if the weapon is on fire when picked up.
		if self:IsOnFire() then
			self:Extinguish()
		end

		-- If this weapon started constrained, unset that spawnflag, or the weapon will be re-constrained and float.
		if self:HasSpawnFlags(SF_WEAPON_START_CONSTRAINED) then
			local flags = self:GetSpawnFlags()
			local newflags = bit.band(flags, bit.bnot(SF_WEAPON_START_CONSTRAINED))
			self:SetKeyValue("spawnflags", newflags)
		end

		-- Add fingerprints to the weapon if necessary.
		self:SetFingerprints()

		if IsValid(newOwner) and self.Primary.Ammo ~= "none" and self.StoredAmmo_Primary > 0 then
			
		end
	end
end

-- Called right before a weapon is dropped and is still considered to be in the player's hands.
function SWEP:PreDrop()
	self.StoredAmmo_Primary = self:Clip1()
	self:SetZoom(false)
end

-----------------------
-- Attacking Functions
-----------------------
function SWEP:PrimaryAttack(globalSound)
	if not self:CanPrimaryAttack() then
		return
	end

	if self.Sound_Primary then
		if globalSound then
			sound.Play(self.Sound_Primary, self:GetPos(), self.Primary.SoundLevel)
		else
			self:EmitSound(self.Sound_Primary, self.Primary.SoundLevel)
		end
	end
	
	if self.Animations_Primary then
		self:SendWeaponAnim(self.Animations_Primary)
	end
	if self.Animations_Primary3rdPerson then
		self:GetOwner():SetAnimation(self.Animations_Primary3rdPerson)
	end

	self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone, self.Primary.Recoil, self.Primary.Tracers, self.Primary.BulletForce)
	
	if self.Primary.Delay > 0 then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	end

	if self.Primary.RequiresAmmo then
		self:TakePrimaryAmmo(self.Primary.TakenAmmo)
	end
end

function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then
		return
	end

	if self.Sound_Secondary then
		self:EmitSound(self.Sound_Secondary)
	end

	local s = not self:GetIronsights()
	self:SetIronsights(s)

	if self.ZoomFOV ~= 0 then
		self:SetZoom(s)
	end

	self:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:CanPrimaryAttack()
	local ply = self:GetOwner()
	if not self.Primary.Enabled or not IsValid(ply) or not ply:Alive() then
		return false
	end

	if self.Primary.RequiresAmmo and self:Clip1() <= 0 then
		self:EmitSound(self.Sound_Empty)
		self:SetNextPrimaryFire(CurTime() + self.Primary.DryFireDelay)
		return false
	end

	return true
end

function SWEP:CanSecondaryAttack()
	if self.NoSights or not self.IronSightsPos then
		return false
	end
	
	return true
end

function SWEP:SetZoom(state)
	if not (IsValid(self:GetOwner()) and self:GetOwner():IsPlayer()) then return end
	if state then
		self:GetOwner():SetFOV(self.ZoomFOV, self.ZoomInTime)
	else
		self:GetOwner():SetFOV(0, self.ZoomOutTime)
	end
end

function SWEP:ShootBullets(damage, numBullets, aimCone, recoil, tracers, force)
	-- The bullet itself.
	local bullet	= {}
	bullet.Damage	= damage
	bullet.Src		= self:GetOwner():GetShootPos()
	bullet.Dir		= self:GetOwner():GetAimVector()
	bullet.Spread	= Vector(aimCone, aimCone, 0)
	bullet.Tracer	= tracers
	bullet.Force	= force
	bullet.Num		= numBullets
	self:GetOwner():FireBullets(bullet)

	-- Recoil.
	if (game.SinglePlayer() and SERVER) or (not game.SinglePlayer() and CLIENT and IsFirstTimePredicted()) then
		recoil = self:GetIronsights() and (recoil * 0.6) or recoil

		local eyeAngs = self:GetOwner():EyeAngles()
		eyeAngs.pitch = eyeAngs.pitch - recoil
		self:GetOwner():SetEyeAngles(eyeAngs)
	end

	-- Weapon effects.
	self:ShootEffects()
end

function SWEP:ShootEffects()
	self:GetOwner():MuzzleFlash()
end

-- Crosshair
if CLIENT then
	local crosshairOpacity = CreateClientConVar("ttt_crosshair_opacity", "0.8", true, false, "How transparent is your crosshair. (From 0 to 1)")
	local crosshairBrightness = CreateClientConVar("ttt_crosshair_brightness", "1.0", true, false, "Changes the brightness/colorfulness of your crosshair. (From 0 to 1)")
	local crosshairSize = CreateClientConVar("ttt_crosshair_size", "1.0", true, false, "Size of the crosshair. (From 0 to 1)")
	local crosshairDisabled = CreateClientConVar("ttt_crosshair_disabled", "0", true, false, "Switch to 1 to disable the crosshair, 0 to enable.")

	function SWEP:DrawHUD()
		-- TODO: Hud Help
		local ply = LocalPlayer()
		local alpha = math.Clamp(crosshairOpacity:GetFloat(), 0.0, 1.0)
		if not self.DrawTTTCrosshair or crosshairDisabled:GetBool() or alpha == 0 then
			return
		end

		local x = ScrW()/2
		local y = ScrH()/2
		local scale = math.max(0.2, 10 * self:GetPrimaryCone()) * (2 - math.Clamp((CurTime() - self:LastShootTime()) * 5, 0.0, 1.0))

		local brightness = math.Clamp(crosshairBrightness:GetFloat(), 0.0, 1.0)
		if ply.IsTraitor and ply:IsTraitor() then
			surface.SetDrawColor(255 * brightness, 50 * brightness, 50 * brightness, 255 * alpha)
		elseif ply.IsDetective and ply:IsDetective() then
			surface.SetDrawColor(50 * brightness, 50 * brightness, 255 * brightness, 255 * alpha)
		else
			surface.SetDrawColor(50 * brightness, 255 * brightness, 50 * brightness, 255 * alpha)
		end

		local sights = (not self.NoSights) and self:GetIronsights()
		local gap = math.floor(20 * scale * (sights and 0.8 or 1))
		local length = math.floor(gap + (25 * crosshairSize:GetFloat()) * scale)
		surface.DrawLine(x - length, y, x - gap, y)
		surface.DrawLine(x + length, y, x + gap, y)
		surface.DrawLine(x, y - length, x, y - gap)
		surface.DrawLine(x, y + length, x, y + gap)
	end
end

-- Iron sights


-- Shooting a shot as you die.
CreateConVar("ttt_weapon_dyingshot", "0", FCVAR_ARCHIVE, "Should players shoot a shot as they die.")
function SWEP:DyingShot()
	local fired = false
	if self:GetIronsights() then
		self:SetIronsights(false)

		if self:GetNextPrimaryFire() > CurTime() then
			return fired
		end

		-- Owner should still be alive here.
		if IsValid(self:GetOwner()) then
			local punch = self:GetPrimaryRecoil() or 5

			-- Punch view to disorient aim before firing dying shot.
			local eyeAng = self:GetOwner():EyeAngles()
			eyeAng.pitch = eyeAng.pitch - math.Rand(-punch, punch)
			eyeAng.yaw = eyeAng.yaw - math.Rand(-punch, punch)
			self:GetOwner():SetEyeAngles(eyeAng)

			MsgN(self:GetOwner():Nick() .. " fired his DYING SHOT")

			self:GetOwner().DyingWeapon = self
			self:PrimaryAttack(true)
			fired = true
		end
	end

	return fired
end

-------------------------
-- TTT Related Functions
-------------------------
function SWEP:SetFingerprints()
	self.Fingerprints = self.Fingerprints or {}
	local alreadyPrinted = false
	for i, v in ipairs(self.Fingerprints) do
		if v == newOwner then
			alreadyPrinted = true
		end
	end

	if not alreadyPrinted then
		table.insert(self.Fingerprints, newOwner)
	end
end

-- Called when this weapon is bought from a Traitor or Detective store.
function SWEP:OnPurchase(buyer)
end

----------------------------------
-- Gun Property Related Functions
----------------------------------
function SWEP:GetPrimaryCone() return self:GetIronsights() and self.Primary.Cone * 0.85 or self.Primary.Cone end
function SWEP:GetPrimaryRecoil() return self.Primary.Recoil end
function SWEP:GetPrimaryDamage() return self.Primary.Damage end
function SWEP:GetSecondaryCone() return self.Secondary.Cone end
function SWEP:GetSecondaryRecoil() return self.Secondary.Recoil end
function SWEP:GetSecondaryDamage() return self.Secondary.Damage end

-- TTT1 added an extra validity check to these two functions so I might as well add that extra safety here as well.
function SWEP:Ammo1()
	return IsValid(self:GetOwner()) and self:GetOwner():GetAmmoCount(self.Primary.Ammo) or false
end 
function SWEP:Ammo2()
	return IsValid(self:GetOwner()) and self:GetOwner():GetAmmoCount(self.Secondary.Ammo) or false
end

function SWEP:GetHeadshotMultiplier(ply, dmginfo)
	return self.HeadshotMultiplier
end

if CLIENT then
	function SWEP:GetTranslatedName()
		if isstring(self.PhraseName) then
			if TTT.Languages.PhraseExists(self.PhraseName) then
				return TTT.Languages.GetPhrase(self.PhraseName)
			end
		end

		return self:GetPrintName()
	end

	-- Ironsight zoom transition. This seems to use code copied from somewhere in the source engine.
	local ttt_lowered = CreateClientConVar("ttt_ironsights_loweronzoom", "1", true, false, "Should we lower the weapon when using ironsights to prevent it from blocking your view.")
	local host_timescale = GetConVar("host_timescale")
	local lowerAmount = Vector(0, 0, -2)	-- How much to lower by if ttt_ironsights_loweronzoom is enabled.
	local transitionTime = 0.25

	function SWEP:GetViewModelPosition(pos, ang)
		if not self.IronSightsPos or self.bIron == nil then
			return pos, ang
		end

		local bIron = self.bIron
		local time = self.fCurrentTime + (SysTime() - self.fCurrentSysTime) * game.GetTimeScale() * host_timescale:GetFloat()

		if bIron then
			self.SwayScale = 0.3
			self.BobScale = 0.1
		else
			self.SwayScale = 1.0
			self.BobScale = 1.0
		end

		local fIronTime = self.fIronTime
		if not bIron and fIronTime < time - transitionTime then
			return pos, ang
		end

		local mul = 1.0

		if fIronTime > time - transitionTime then
			mul = math.Clamp((time - fIronTime) / transitionTime, 0, 1)

			if not bIron then
				mul = 1 - mul
			end
		end

		local offset = self.IronSightsPos + (ttt_lowered:GetBool() and lowerAmount or vector_origin)

		if self.IronSightsAng then
			ang = ang * 1
			ang:RotateAroundAxis(ang:Right(), self.IronSightsAng.x * mul)
			ang:RotateAroundAxis(ang:Up(), self.IronSightsAng.y * mul)
			ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.z * mul)
		end

		pos = pos + offset.x * ang:Right() * mul
		pos = pos + offset.y * ang:Forward() * mul
		pos = pos + offset.z * ang:Up() * mul

		return pos, ang
	end
end