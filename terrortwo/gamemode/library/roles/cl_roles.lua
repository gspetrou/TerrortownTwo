TTT.Roles = TTT.Roles or {}

-- This command will switch the player between spectator and not spectator.
concommand.Add("ttt_always_spectator", function(ply, cmd, args)
	if #args == 0 or args[1] == "" then
		print(cmd.." currently set to '".. (ply:IsSpectator() and "1" or "0") .."'. Use this convar to toggle always spectate mode.")
	else
		local state = tonumber(args[1])
		if state and (state == 0 or state == 1) then
			net.Start("TTT.Roles.SpectatorModeChange")
				net.WriteBool(tobool(state))
			net.SendToServer()
		else
			print("Invalid argument to ".. cmd ..", must be either 0 or 1.")
		end
	end
end, function(cmd, args)	-- Displays a 1 or 0 depending on if the setting is enabled or not in the console's autocomplete.
	local num = LocalPlayer():IsSpectator() and "1" or "0"
	return {cmd.." "..num}
end, "Used to toggle states between spectator always mode and not.")

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

	for k = 1, player.GetCount() do
		local v = player.GetAll()[k]
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
	for k = 1, player.GetCount() do
		local v = player.GetAll()[k]
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

-- Received if the player was a spectator when they connected.
net.Receive("TTT.Roles.SpectatorOnConnect", function()
	if not IsValid(LocalPlayer()) then
		hook.Add("OnEntityCreated", "TTT.Roles.SpectatorOnConnect", function(ply)
			if IsValid(LocalPlayer()) then
				LocalPlayer():SetRole(ROLE_SPECTATOR)
				hook.Remove("OnEntityCreated", "TTT.Roles.SpectatorOnConnect")
			end
		end)
	else
		LocalPlayer():SetRole(ROLE_SPECTATOR)
	end
end)