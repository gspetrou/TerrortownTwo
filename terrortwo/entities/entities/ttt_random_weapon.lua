-- Spawns a random weapon with the option of it's corresponding ammo. Heavily based off Badking's code.
ENT.Type = "point"
ENT.Base = "base_point"
ENT.AutoAmmo = 0

-- Used to set how many ammo boxes this entity should spawn with.
function ENT:KeyValue(key, value)
	if key == "auto_ammo" then
		self.AutoAmmo = tonumber(value)
	end
end

function ENT:Initialize()
	local entities = TTT.Weapons.GetMapSpawnableWeapons()
	local wepClass = table.RandomSequential(entities)

	local wep = ents.Create(wepClass)

	if IsValid(wep) then
		local pos = self:GetPos()
		wep:SetPos(pos)
		wep:SetAngles(self:GetAngles())
		wep:Spawn()
		wep:PhysWake()

		local ammoType = wep.Primary.Ammo
		if self.AutoAmmo > 0 and ammoType and ammoType ~= "none" then
			local ammoEntClass = TTT.Weapons.GetAmmoEntityForWeapon(wepClass)	-- Get the entity class for the ammo this weapon accepts.
			if ammoEntClass then
				for i = 1, self.AutoAmmo do
					local ammo = ents.Create(ammoEntClass)
					if IsValid(ammo) then
						pos.z = pos.z + 4
						ammo:SetPos(pos)
						ammo:SetAngles(VectorRand():Angle())
						ammo:Spawn()
						ammo:PhysWake()
					end
				end
			end
		end
	end

	self:Remove()
end