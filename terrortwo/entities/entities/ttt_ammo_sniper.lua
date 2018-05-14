-- "sniper" ammo. Used for sniper rifles. We keep the ammo names simple.
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ttt_ammo_base"

ENT.IsTTTAmmo	= true
ENT.AutoSpawnable = true
ENT.AmmoType	= "sniper"
ENT.AmmoGive	= 10
ENT.AmmoMax		= 20
ENT.Model		= Model("models/items/357ammo.mdl")