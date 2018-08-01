SWEP.Base		= "weapon_ttt_base"
DEFINE_BASECLASS(SWEP.Base)

SWEP.PrintName	= "Scout"
SWEP.PhraseName = "weapon_scout"
SWEP.Kind		= WEAPON_PRIMARY
SWEP.AutoSpawnable	= true

SWEP.HoldType	= "ar2"
SWEP.WorldModel	= "models/weapons/w_snip_scout.mdl"
SWEP.ViewModel	= "models/weapons/cstrike/c_snip_scout.mdl"
SWEP.UseHands		= true
SWEP.ViewModelFOV	= 54

SWEP.Primary.Automatic	= true
SWEP.Primary.Cone		= 0.005
SWEP.Primary.Damage		= 50
SWEP.Primary.Delay		= 1.5
SWEP.Primary.Recoil		= 7
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.ClipSize		= 10
SWEP.Primary.CarrySize		= 20
SWEP.Primary.Ammo			= "sniper"

SWEP.Sound_Primary	= Sound("Weapon_Scout.Single")
SWEP.Sound_Secondary = Sound("Default.Zoom")
SWEP.HeadshotMultiplier = 4

SWEP.IronSightsPos	= Vector(5, -15, -2)
SWEP.IronSightsAng	= Vector(2.6, 1.37, 3.5)

SWEP.ZoomFOV = 20
SWEP.ZoomInTime = 0.3
SWEP.ZoomOutTime = 0.2

-- Add a delay to secondary fire when we primary fire.
function SWEP:PrimaryAttack(worldSound)
	BaseClass.PrimaryAttack(self, worldSound)
	self:SetNextSecondaryFire(CurTime() + 0.1)
end

if CLIENT then
	local scope = surface.GetTextureID("sprites/scope")
	function SWEP:DrawHUD()
		if self:GetIronsights() then
			surface.SetDrawColor(0, 0, 0, 255)
			
			local scrW = ScrW()
			local scrH = ScrH()

			local x = scrW / 2.0
			local y = scrH / 2.0
			local scope_size = scrH

			-- crosshair
			local gap = 80
			local length = scope_size
			surface.DrawLine(x - length, y, x - gap, y)
			surface.DrawLine(x + length, y, x + gap, y)
			surface.DrawLine(x, y - length, x, y - gap)
			surface.DrawLine(x, y + length, x, y + gap)

			gap = 0
			length = 50
			surface.DrawLine(x - length, y, x - gap, y)
			surface.DrawLine(x + length, y, x + gap, y)
			surface.DrawLine(x, y - length, x, y - gap)
			surface.DrawLine(x, y + length, x, y + gap)

			-- cover edges
			local sh = scope_size / 2
			local w = (x - sh) + 2
			surface.DrawRect(0, 0, w, scope_size)
			surface.DrawRect(x + sh - 2, 0, w, scope_size)
			
			-- cover gaps on top and bottom of screen
			surface.DrawLine(0, 0, scrW, 0)
			surface.DrawLine(0, scrH - 1, scrW, scrH - 1)

			surface.SetDrawColor(255, 0, 0, 255)
			surface.DrawLine(x, y, x + 1, y + 1)

			-- scope
			surface.SetTexture(scope)
			surface.SetDrawColor(255, 255, 255, 255)

			surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)
		else
			return BaseClass.DrawHUD(self)
		end
	end

	function SWEP:AdjustMouseSensitivity()
		return self:GetIronsights() and 0.2 or nil
	end
end