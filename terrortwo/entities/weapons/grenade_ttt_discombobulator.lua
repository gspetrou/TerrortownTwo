AddCSLuaFile()

SWEP.HoldType			 = "grenade"

if CLIENT then
	SWEP.PrintName		= "Discombobulator"
	SWEP.PhraseName		= "weapon_discombob"
	SWEP.ViewModelFlip	= false
	SWEP.ViewModelFOV	= 54

	SWEP.Icon			= "vgui/ttt/icon_nades"
	SWEP.IconLetter		= "h"
end

SWEP.Base					= "grenade_ttt_base"

SWEP.Kind					= WEAPON_GRENADE

SWEP.Spawnable		= true
SWEP.AutoSpawnable		= true

SWEP.UseHands			= true
SWEP.ViewModel			= "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel			= "models/weapons/w_eq_fraggrenade.mdl"

SWEP.GrenadeName	= "ttt_grenade_proj_smoke"