-- Spawns a random ammo entity. Heavily based off Badking's code.
ENT.Type = "point"
ENT.Base = "base_point"

function ENT:Initialize()
	local ammos = TTT.Weapons.GetMapSpawnableAmmo()
	if ammos then
		local ammoClass = table.RandomSequential(ammos)
		local ammoEnt = ents.Create(ammoClass)
		if IsValid(ammoEnt) then
			ammoEnt:SetPos(self:GetPos())
			ammoEnt:SetAngles(self:GetAngles())
			ammoEnt:Spawn()
			ammoEnt:PhysWake()
		end
	end
	self:Remove()
end