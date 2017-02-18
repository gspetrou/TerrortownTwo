TTT.BodyIdentify = TTT.BodyIdentify or {}

local PLAYER = FindMetaTable("Player")
function PLAYER:IsIdentified()
	return self.ttt_identified or false
end

-- If called on client then this only will only change for that client.
function PLAYER:SetIdentified(bool)
	self.ttt_identified = bool

	if SERVER then
		net.Start("TTT.BodyIdentify.IDPlayer")
			net.WritePlayer(self)
			net.WriteBool(bool)
		net.Broadcast()
	end
end

if SERVER then
	util.AddNetworkString("TTT.BodyIdentify.IDPlayer")
	util.AddNetworkString("TTT.BodyIdentify.IDPlayer")

	function TTT.BodyIdentify.ClearIDs()
		for i, v in ipairs(player.GetAll()) do
			v.ttt_identified = false
		end

		net.Start("TTT.BodyIdentify.Clear")
		net.Broadcast()
	end
else
	net.Receive("TTT.BodyIdentify.IDPlayer", function()
		local ply = net.ReadPlayer()
		local identified = net.ReadBool()

		ply:SetIdentified(identified)
	end)

	net.Receive("TTT.BodyIdentify.Clear", function()
		for i, v in ipairs(player.GetAll()) do
			v.ttt_identified = false
		end
	end)
end