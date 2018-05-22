ENT.Type = "point"
ENT.Base = "base_point"

ENT.Damager = nil
ENT.KillName = nil

function ENT:KeyValue(key, value)
	if key == "damager" then
		self.Damager = tostring(value)
	elseif key == "killname" then
		self.KillName = tostring(value)
	end
end

function ENT:AcceptInput(name, activator, caller, data)
	if not isstring(self.Damager) then
		return true
	end

	if name == "SetActivatorAsDamageOwner" then
		if IsValid(activator) and activator:IsPlayer() then
			for i, ent in ipairs(ents.FindByName(self.Damager)) do
				if IsValid(ent) and ent.SetDamageOwner then
					ent:SetDamageOwner(activator)
				end
			end
		end
	elseif name == "ClearDamageOwner" then
		for _, ent in pairs(ents.FindByName(self.Damager)) do
			if IsValid(ent) and ent.SetDamageOwner then
				ent:SetDamageOwner(nil)
			end
		end
	end

	return true
end