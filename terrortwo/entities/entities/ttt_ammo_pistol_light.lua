-- "pistol_light" ammo. Used for pistols that need a light ammo type.
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ttt_ammo_base"

ENT.IsTTTAmmo	= true
ENT.AutoSpawnable = true
ENT.AmmoType	= "pistol_light"
ENT.AmmoGive	= 20
ENT.AmmoMax		= 60
ENT.Model		= Model("models/items/boxsrounds.mdl")