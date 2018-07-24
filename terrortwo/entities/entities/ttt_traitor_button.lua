AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.DefaultUsableRange = 500
local UseSound = Sound("buttons/button24.wav")

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "Delay")
	self:NetworkVar("Float", 1, "NextUseTime")
	self:NetworkVar("Bool", 0, "Locked")
	self:NetworkVar("String", 0, "Description")
	self:NetworkVar("Int", 0, "UsableRange", {KeyName = "UsableRange"})
end

function ENT:IsUsable()
	return not self:GetLocked() and self:GetNextUseTime() < CurTime()
end

if SERVER then
	util.AddNetworkString("TTT.Entities.TraitorButtonUsed")

	ENT.RemoveOnPress = false
	ENT.Model = Model("models/weapons/w_bugbait.mdl")

	function ENT:Initialize()
		self:SetModel(self.Model)

		self:SetNoDraw(true)
		self:DrawShadow(false)
		self:SetSolid(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)

		self:SetDelay(self.RawDelay or 1)

		-- func_button can be made single use by setting delay to be negative, so mimic that here.
		if self:GetDelay() < 0 then
			self.RemoveOnPress = true
		end

		if self.RemoveOnPress then
			self:SetDelay(-1) -- Tells client we're single use
		end

		if self:GetUsableRange() < 1 then
			self:SetUsableRange(self.DefaultUsableRange)
		end

		self:SetNextUseTime(0)
		self:SetLocked(self:HasSpawnFlags(2048))

		self:SetDescription(self.RawDescription or "Unset Traitor Button Description")

		self.RawDelay = nil
		self.RawDescription = nil
	end

	function ENT:KeyValue(key, value)
		if key == "OnPressed" then
			self:StoreOutput(key, value)
		elseif key == "wait" then -- as Delay Before Reset in func_button
			self.RawDelay = tonumber(value)
		elseif key == "description" then
			self.RawDescription = tostring(value)

			if self.RawDescription and string.len(self.RawDescription) < 1 then
				self.RawDescription = nil
			end
		elseif key == "RemoveOnPress" then
			self.RemoveOnPress = tobool(value)
		else
			self:SetNetworkKeyValue(key, value)
		end
	end

	function ENT:AcceptInput(name, activator)
		if name == "Toggle" then
			self:SetLocked(not self:GetLocked())
			return true
		elseif name == "Hide" or name == "Lock" then
			self:SetLocked(true)
			return true
		elseif name == "Unhide" or name == "Unlock" then
			self:SetLocked(false)
			return true
		end
	end

	function ENT:TraitorUse(ply)
		if not (IsValid(ply) and ply:IsTraitor() and self:IsUsable()) then
			return false
		end

		local use = hook.Call("TTT.Map.TraitorButtons.CanUse", nil, ply, self)
		if use == false then
			return false
		end

		net.Start("TTT.Entities.TraitorButtonUsed")
		net.Send(ply)

		-- Send output to all entities linked to us.
		self:TriggerOutput("OnPressed", ply)

		if self.RemoveOnPress then
			self:SetLocked(true)
			self:Remove()
		else
			self:SetNextUseTime(CurTime() + self:GetDelay()) -- Lock ourselves until we should be usable again.
		end

		hook.Call("TTT.TraitorButton.Activated", nil, self, ply)
		return true
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end
else
	net.Receive("TTT.Entities.TraitorButtonUsed", function()
		surface.PlaySound(UseSound)
		TTT.Map.TraitorButtons:UpdateCache()
	end)
end