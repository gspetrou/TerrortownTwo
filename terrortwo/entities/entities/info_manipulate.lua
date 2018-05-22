-- Dummy entity to convert ZM info_manipulate traps to TTT ones
ENT.Type = "point"
ENT.Base = "base_point"

function ENT:Think()
	if not self.Replaced then
		self:CreateReplacement()
		self:Remove()
	end
end

function ENT:KeyValue(key, value)
	if key == "OnPressed" then
		self.RawOutputs = self.RawOutputs or {}
		table.insert(self.RawOutputs, value)
	elseif key == "Cost" then
		self[key] = tonumber(value)
	elseif key == "Active" or key == "RemoveOnTrigger" then
		self[key] = tobool(value)
	elseif key == "Description" then
		self[key] = tostring(value)
	end
end

function ENT:CreateReplacement()
	local target = ents.Create("ttt_traitor_button")
	if not IsValid(target) then
		return
	end

	self.Replaced = true

	target:SetPos(self:GetPos())

	-- Replacements for ZM info_manipulate to TTT traitor button.

	target:SetKeyValue("targetname", self:GetName())

	if not self.Active then
		target:SetKeyValue("spawnflags", tostring(2048)) -- start locked
	end

	if self.Description and self.Description != "" then
		target:SetKeyValue("description", self.Description)
	end

	if self.Cost then
		target:SetKeyValue("wait", tostring(self.Cost))
	end

	if self.RemoveOnTrigger then
		target:SetKeyValue("RemoveOnPress", tostring(true))
	end

	if self.RawOutputs then
		for i, v in ipairs(self.RawOutputs) do
			target:SetKeyValue("OnPressed", tostring(v))
		end
	end

	target:Spawn()
end