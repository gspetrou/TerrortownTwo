-- "pistol_heavy" ammo. Used for pistols that need a heavier ammo.
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ammo_ttt2_base"

ENT.AmmoType	= "pistol_heavy"
ENT.AmmoGive	= 12
ENT.AmmoMax		= 36
ENT.Model		= Model("models/items/357ammo.mdl")

function ENT:Initialize()
	self:SetColor(Color(255, 100, 100, 255))
	return self.BaseClass.Initialize(self)
end