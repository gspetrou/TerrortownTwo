TTT.Roles = TTT.Roles or {}

-- This command will switch the player between spectator and not spectator.
concommand.Add("ttt_always_spectator", function(ply)
	net.Start("TTT.Roles.SpectatorModeChange")
	net.SendToServer()
end)

------------------------
-- TTT.Roles.GetUnknown
------------------------
-- Desc:		Gets all players with unknown roles.
-- Returns:		Table, containning players with unknown roles.
function TTT.Roles.GetUnknown()
	return table.Filter(player.GetAll(), function(ply)
		return v:IsUnknown()
	end)
end

-- Received when clearing roles.
net.Receive("TTT.Roles.Clear", function()
	local numplys = net.ReadUInt(7)
	local activeplayers = {}
	for i = 1, numplys do
		activeplayers[net.ReadPlayer()] = true
	end

	for i, v in ipairs(player.GetAll()) do
		if activeplayers[v] then
			v:SetRole(ROLE_WAITING)
		else
			v:SetRole(ROLE_SPECTATOR)
		end
	end
end)

-- Received when updating roles for Traitors. Only received by traitors.
net.Receive("TTT.Roles.SyncTraitors", function()
	local numtraitors = net.ReadUInt(7)
	for i = 1, numtraitors do
		net.ReadPlayer():SetRole(ROLE_TRAITOR)
	end
end)

-- Receives all non-traitor roles.
net.Receive("TTT.Roles.Sync", function()
	local localply = LocalPlayer()

	-- Set dectives.
	local numdetectives = net.ReadUInt(7)
	for i = 1, numdetectives do
		net.ReadPlayer():SetRole(ROLE_DETECTIVE)
	end

	-- Set spectators.
	local numspectators = net.ReadUInt(7)
	for i = 1, numspectators do
		net.ReadPlayer():SetRole(ROLE_SPECTATOR)
	end

	-- Any player without a role, set to unknown
	for i, v in ipairs(player.GetAll()) do
		if v:IsWaiting() then
			v:SetRole(ROLE_UNKNOWN)
		end
	end

	-- Set our own role.
	if localply:IsUnknown() or localply:IsWaiting() then
		localply:SetRole(ROLE_INNOCENT)
	end
end)

-- Received when a player switches role mid-game to a non-traitor role.
net.Receive("TTT.Roles.PlayerSwitchedRole", function()
	local role = net.ReadUInt(3)
	local ply = net.ReadPlayer()
	ply:SetRole(role)
end)