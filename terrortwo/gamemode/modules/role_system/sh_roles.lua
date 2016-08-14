ROLE_WAITING	= 0
ROLE_SPECTATOR	= 1
ROLE_INNOCENT	= 2
ROLE_DETECTIVE	= 3
ROLE_TRAITOR	= 4

if CLIENT then
	net.Receive("TTT_SyncRoles", function()
		local newrole = net.ReadUInt(3)
		local numplys = net.ReadUInt(7)

		for i = 1, numplys do
			local ply = net.ReadPlayer()
			if IsValid(ply) then
				ply.role = newrole
			end
		end
	end)

	net.Receive("TTT_ClearRoles", function()
		for i, v in ipairs(player.GetAll()) do
			v.role = ROLE_WAITING
		end
	end)
end