EQUIPMENT:SetName("equipment_disguiser_name")
EQUIPMENT:SetDescription("equipment_disguiser_desc")
--EQUIPMENT:SetIcon("vgui/ttt/icon_armor")
EQUIPMENT:SetInStoreFor(ROLE_TRAITOR)

local PLAYER = FindMetaTable("Player")

if SERVER then
	local equipID = EQUIPMENT.ID	-- This variable will no longer exist when we need it in hooks so save it.
	
	util.AddNetworkString("TTT.Equipment.ToggleDisguise")

	function PLAYER:TTTToggleDisguise(bool)
		self.ttt_DisguiserEnabled = bool
		net.Start("TTT.Equipment.ToggleDisguise")
			net.WritePlayer(self)
			net.WriteBool(bool)
		net.Broadcast()
	end

	function EQUIPMENT:OnEquip(ply)
		ply:TTTToggleDisguise(true)
	end

	function EQUIPMENT:OnUnequip(ply)
		ply:TTTToggleDisguise(false)
	end
end

function PLAYER:TTTHasDisguiseOn()
	if isbool(self.ttt_DisguiserEnabled) then
		return self.ttt_DisguiserEnabled
	end
	return false
end

function TTT.Equipment.ResetDisguises()
	for i, ply in ipairs(player.GetAll()) do
		ply.ttt_DisguiserEnabled = false
	end
end

if CLIENT then
	net.Receive("TTT.Equipment.ToggleDisguise", function()
		local ply = net.ReadPlayer()
		local state = net.ReadBool()
		if IsValid(ply) then
			ply.ttt_DisguiserEnabled = state
		end
	end)
end