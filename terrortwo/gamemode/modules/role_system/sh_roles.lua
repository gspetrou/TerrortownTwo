GM.PlayerRoles = GM.PlayerRoles or {
	[ROLE_INVALID] = {},
	[ROLE_SPECTATOR] = {},
	[ROLE_INNOCENT] = {},
	[ROLE_DETECTIVE] = {},
	[ROLE_TRAITOR] = {}
}

function ClearRoles()
	GM.PlayerRoles = {
		[ROLE_INVALID] = {},
		[ROLE_SPECTATOR] = {},
		[ROLE_INNOCENT] = {},
		[ROLE_DETECTIVE] = {},
		[ROLE_TRAITOR] = {}
	}

	for i, v in ipairs(player.GetAll()) do
		v.role = ROLE_INVALID
	end
end

if CLIENT then
	local function SetRole(ply, new_role)
		GM.PlayerRoles[new_role][ply] = true
		ply.role = new_role
	end

	net.Receive("TTT_SendRole", function()
		local ply = net.ReadPlayer()
		if IsValid(ply) then
			local new_role = net.ReadUInt(3)
			SetRole(ply, new_role)
		end
	end)

	net.Receive("TTT_SendRole", function()
		local num_players = net.ReadUInt(7)
		local role = net.ReadUInt(3)

		for i = 1, num_players do
			local ply = net.ReadPlayer()
			SetRole(ply, role)
		end
	end)
end