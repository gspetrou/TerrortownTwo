-- "pistol_light" ammo. Used for pistols that need a light ammo type.
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ammo_ttt_base"

ENT.AmmoType	= "pistol_light"
ENT.AmmoGive	= 20
ENT.AmmoMax		= 60
ENT.Model		= Model("models/items/boxsrounds.mdl")