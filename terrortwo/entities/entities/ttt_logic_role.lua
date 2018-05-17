-- Map entity which can check if a player is a certain role.
ENT.Type = "point"
ENT.Base = "base_point"

local ROLE_ANY = 3
ENT.Role = ROLE_ANY

function ENT:KeyValue(key, value)
	if key == "OnPass" or key == "OnFail" then
		self:StoreOutput(key, value)
	elseif key == "Role" then
		self.Role = tonumber(value)

		if not self.Role then
			ErrorNoHalt("TTT Logic Role: Bad value for Role key, not a number.\n")
			self.Role = ROLE_ANY
		end
	end
end

function ENT:AcceptInput(name, activator)
	if name == "TestActivator" and IsValid(activator) and activator:IsPlayer() then		-- Feels like we should also check if the player is Alive here but so far nobody has complained so maybe its intentional?
		local activatorRole = (TTT.Rounds.IsPrep()) and ROLE_INNOCENT or activator:GetRole()

		if self.Role == ROLE_ANY or self.Role == activatorRole then
			TTT.Debug.Print("TTT Logic Role: Player '"..ply:Nick().."' passed logic_role test from entity '"..self:EntIndex().."'")
			self:TriggerOutput("OnPass", activator)
		else
			TTT.Debug.Print("TTT Logic Role: Player '"..ply:Nick().."' failed logic_role test from entity '"..self:EntIndex().."'")
			self:TriggerOutput("OnFail", activator)
		end
	end
end