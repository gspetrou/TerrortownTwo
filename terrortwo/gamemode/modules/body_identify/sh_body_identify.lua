TTT.BodyIdentify = TTT.BodyIdentify or {}

local PLAYER = FindMetaTable("Player")
function PLAYER:IsIdentified()
	return self.ttt_identified or false
end

-- If called on client only will only change for that client.
function PLAYER:SetIdentified(bool)
	self.ttt_identified = bool

	if SERVER then
		net.Start("TTT_Identify_IDPlayer")
			net.WritePlayer(self)
			net.WriteBool(bool)
		net.Broadcast()
	end
end

if SERVER then
	util.AddNetworkString("TTT_Identify_IDPlayer")
	util.AddNetworkString("TTT_Identify_Clear")

	function TTT.BodyIdentify.ClearIDs()
		for i, v in ipairs(player.GetAll()) do
			v.ttt_identified = false
		end

		net.Start("TTT_Identify_Clear")
		net.Broadcast()
	end
else
	net.Receive("TTT_Identify_IDPlayer", function()
		local ply = net.ReadPlayer()
		local identified = net.ReadBool()

		ply:SetIdentified(identified)
	end)

	net.Receive("TTT_Identify_Clear", function()
		for i, v in ipairs(player.GetAll()) do
			v.ttt_identified = false
		end
	end)
end