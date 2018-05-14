-- "shotgun_buckshot" ammo. Buckshot shells for shotguns.
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ttt_ammo_base"

ENT.AutoSpawnable = true
ENT.AmmoType	= "shotgun_buckshot"
ENT.AmmoGive	= 8
ENT.AmmoMax		= 24
ENT.Model		= Model("models/items/boxbuckshot.mdl")