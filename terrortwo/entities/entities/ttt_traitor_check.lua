-- Map entity which returns how many traitors were found within the bounds of the entity.
ENT.Type = "brush"
ENT.Base = "base_brush"

function ENT:KeyValue(key, value)
	if key == "TraitorsFound" then
		self:StoreOutput(key, value)
	end
end

function ENT:CountTraitors()
	local mins = self:LocalToWorld(self:OBBMins())
	local maxs = self:LocalToWorld(self:OBBMaxs())

	local traitorsInArea = 0
	for i, ply in ipairs(player.GetAll()) do
		if IsValid(ply) and ply:Alive() and ply:IsTraitor() and TTT.IsInMinMax(ply:GetPos(), mins, maxs) then
			traitorsInArea = traitorsInArea + 1
		end
	end
	return traitorsInArea
end

function ENT:AcceptInput(name, activator)
	if name == "CheckForTraitor" then
		local traitors = self:CountTraitors()
		self:TriggerOutput("TraitorsFound", activator, traitors)
		return true
	end
end