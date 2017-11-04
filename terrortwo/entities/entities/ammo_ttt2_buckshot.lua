AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ammo_ttt2_base"

ENT.AmmoType	= "buckshot"
ENT.AmmoGive	= 8
ENT.AmmoMax		= 24
ENT.Model		= Model("models/items/boxbuckshot.mdl")

function ENT:Initialize()
	self:SetColor(Color(255, 100, 100, 255))
	return self.BaseClass.Initialize(self)
end