AddCSLuaFile()

SWEP.HoldType			= "grenade"

if CLIENT then
	SWEP.PrintName		 = "Smoke Grenade"
	SWEP.PhraseName		 = "weapon_smokenade"

	SWEP.ViewModelFlip	= false
	SWEP.ViewModelFOV	= 54

	SWEP.Icon				= "vgui/ttt/icon_nades"
	SWEP.IconLetter		= "Q"
end

SWEP.Base					= "grenade_ttt_base"

SWEP.Kind					= WEAPON_GRENADE

SWEP.UseHands			= true
SWEP.ViewModel			= "models/weapons/cstrike/c_eq_smokegrenade.mdl"
SWEP.WorldModel			= "models/weapons/w_eq_smokegrenade.mdl"
SWEP.AutoSpawnable		= true
SWEP.GrenadeName		= "ttt_grenade_proj_smoke"