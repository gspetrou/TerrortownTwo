-- "ar" ammo. Used for assault rifles that need a bigger ammo type (Mac10). Don't think about it too much.
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ttt_ammo_base"

ENT.IsTTTAmmo	= true
ENT.AutoSpawnable = true
ENT.AmmoType	= "ar"
ENT.AmmoGive	= 30
ENT.AmmoMax		= 60
ENT.Model		= Model("models/items/boxmrounds.mdl")