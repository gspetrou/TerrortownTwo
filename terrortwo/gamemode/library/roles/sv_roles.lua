-- Setup network strings.
util.AddNetworkString("TTT.Roles.SyncTraitors")
util.AddNetworkString("TTT.Roles.Sync")
util.AddNetworkString("TTT.Roles.Clear")
util.AddNetworkString("TTT.Roles.ChangedSpectatorMode")
util.AddNetworkString("TTT.Roles.PlayerSwitchedRole")

-- Setup the convars.
local traitor_percent = CreateConVar("ttt_traitor_percent", "0.25", FCVAR_ARCHIVE, "Percentage of players that will be traitors.")
local detective_threshold = CreateConVar("ttt_detective_threshold", "8", FCVAR_ARCHIVE, "There must be at least this many players before there can be detectives.")
local detective_percent = CreateConVar("ttt_detective_percent", "0.15", FCVAR_ARCHIVE, "Percentage of players that will be detectives.")
local PLAYER = FindMetaTable("Player")

----------------------------
-- TTT.Roles.SetupSpectator
----------------------------
-- Desc:		Sees if this player should be a spectator and sets them if they should.
function TTT.Roles.SetupSpectator(ply)
	if ply:IsSpectator() then
		ply:SetRole(ROLE_SPECTATOR)
	end
end

-----------------------------
-- TTT.Roles.GetAlivePlayers
-----------------------------
-- Desc:		Gets all the alive players.
-- Returns:		Table, containning alive players.
function TTT.Roles.GetAlivePlayers()
	return table.Filter(player.GetAll(), function(ply)
		if ply:IsInFlyMode() or ply:IsSpectator() then
			return false
		end
		return ply:Alive()
	end)
end

----------------------------
-- TTT.Roles.GetDeadPlayers
----------------------------
-- Desc:		Gets a table containning all dead players, does not include spectators.
-- Returns:		Table, all dead players that are not spectators.
function TTT.Roles.GetDeadPlayers()
	return table.Filter(player.GetAll(), function(ply)
		if not ply:Alive() or ply:IsInFlyMode() then
			return true
		end
		return false
	end)
end

------------------------------
-- TTT.Roles.GetActivePlayers
------------------------------
-- Desc:		Gets all active players. Active means they are not idle or in always spectate mode.
-- Returns:		Table, containning active players.
function TTT.Roles.GetActivePlayers()
	return table.Filter(player.GetAll(), function(ply)
		return ply:IsActive()
	end)
end

-------------------
-- PLAYER:IsActive
-------------------
-- Desc:		Does the player not have ttt_always_spectator enabled or they are not idle.
-- Return:		Boolean, are they active.
function PLAYER:IsActive()
	local num = self:GetInfo("ttt_always_spectator") or 0
	return type(num) == "number" and num or 0
end

----------------------
-- PLAYER:IsSpectator
----------------------
-- Desc:		Checks if the player is a spectator.
-- Returns:		Boolean, are they a spectator.
function PLAYER:IsSpectator()
	return not self:IsActive()
end

net.Receive("TTT.Roles.ChangedSpectatorMode", function(_, ply)
	local wants_spec = net.ReadBool()
	if wants_spec then
		self:ForceSpectator()
	else
		self:ForceWaiting()
	end
end)

------------------------------
-- TTT.Roles.GetPlayersOfRole
------------------------------
-- Desc:		Gets all players of a specified role.
-- Arg One:		ROLE_ enum of players to get.
-- Returns:		Table, players of this role.
function TTT.Roles.GetPlayersOfRole(role)
	return table.Filter(player.GetAll(), function(ply)
		return ply:GetRole() == role
	end)
end

-- Role getter functions.
function TTT.Roles.GetWaiting() return TTT.Roles.GetPlayersOfRole(ROLE_WAITING) end
function TTT.Roles.GetInnocents() return TTT.Roles.GetPlayersOfRole(ROLE_INNOCENT) end
function TTT.Roles.GetDetectives() return TTT.Roles.GetPlayersOfRole(ROLE_DETECTIVE) end
function TTT.Roles.GetTraitors() return TTT.Roles.GetPlayersOfRole(ROLE_TRAITOR) end
function TTT.Roles.GetSpectators()
	return table.Filter(player.GetAll(), function(ply)
		return ply:IsSpectator()
	end)
end

---------------------------------
-- TTT.Roles.GetPlayersNotOfRole
---------------------------------
-- Desc:		Gets all players not of the specified role.
-- Arg One:		ROLE_ enum to get players not of this role.
-- Returns:		Table, players not of the role supplied in arg one.
function TTT.Roles.GetPlayersNotOfRole(role)
	return table.Filter(player.GetAll(), function(ply)
		return ply:GetRole() ~= role
	end)
end

-- Role getter functions.
function TTT.Roles.GetNotWaiting() return TTT.Roles.GetPlayersNotOfRole(ROLE_WAITING) end
function TTT.Roles.GetNotInnocents() return TTT.Roles.GetPlayersNotOfRole(ROLE_INNOCENT) end
function TTT.Roles.GetNotDetectives() return TTT.Roles.GetPlayersNotOfRole(ROLE_DETECTIVE) end
function TTT.Roles.GetNotTraitors() return TTT.Roles.GetPlayersNotOfRole(ROLE_TRAITOR) end
function TTT.Roles.GetNotSpectators()
	return table.Filter(player.GetAll(), function(ply)
		return not ply:IsSpectator()
	end)
end

----------------------------
-- PLAYER:SetRoleClientside
----------------------------
-- Desc:		Sets the role of a player but only for the given recipients.
-- Arg One:		ROLE_ enum, what role this player should have.
-- Arg Two:		Table, player, or true. Table if more than one player should know. Player for a single person. True for everyone to know this person's role changed.
function PLAYER:SetRoleClientside(role, recipients)
	net.Start("TTT.Roles.PlayerSwitchedRole")
		net.WriteUInt(role, 3)
		net.WritePlayer(self)

	if recipients == true then
		net.Broadcast()
	else
		net.Send(recipients)
	end
end

--------------------
-- PLAYER:ForceRole
--------------------
-- Desc:		Sets the player's role and networks it to the given recipients.
-- Arg One:		ROLE_ enum, to set the player to.
-- Arg Two:		Table, player, or true. Table if more than one player should know. Player for a single person. True for everyone to know this person's role changed.
function PLAYER:ForceRole(role, recipients)
	self:SetRole(role)
	self:SetRoleClientside(role, recipients)
end

-- Helper functions for setting a player's role after round start.
function PLAYER:ForceSpectator()
	if self:Alive() then
		self:Kill()
	end

	self:ForceRole(ROLE_SPECTATOR, true)
end
function PLAYER:ForceInnocent()
	self:SetRole(ROLE_INNOCENT)
	self:SetRoleClientside(ROLE_INNOCENT, self)

	-- Tell everyone but self that we are an unknown rank.
	local allplayers_exceptself = player.GetAll()
	for i, v in ipairs(allplayers_exceptself) do
		if v == self then
			table.remove(allplayers_exceptself, i)
			break
		end
	end

	-- Tell self that we are an innocent.
	self:SetRoleClientside(ROLE_UNKNOWN, allplayers_exceptself)
end
function PLAYER:ForceTraitor()
	-- Because other players know if self is one of these two ranks we need
	-- to tell them that self is now an unknown rank.
	if self:IsDetective() or self:IsSpectator() then
		self:SetRoleClientside(ROLE_UNKNOWN, TTT.Roles.GetPlayersNotOfRole(ROLE_TRAITOR))
	end

	-- Now tell other traitors and ourselves that we are a traitor.
	self:SetRole(ROLE_TRAITOR)
	local traitors = TTT.Roles.GetTraitors()
	table.insert(traitors, self)
	self:SetRoleClientside(ROLE_TRAITOR, traitors)
end
function PLAYER:ForceDetective()
	self:ForceRole(ROLE_DETECTIVE, true)
end
function PLAYER:ForceWaiting()
	self:ForceRole(ROLE_WAITING, true)
end

-------------------
-- TTT.Roles.Clear
-------------------
-- Desc:		Clears everyone's role, sets them to ROLE_WAITING if they are active. ROLE_SPECTATOR if they are not.
function TTT.Roles.Clear()
	local activeplayers = TTT.Roles.GetActivePlayers()

	for i, v in ipairs(activeplayers) do
		v:SetRole(ROLE_WAITING)
	end
	net.Start("TTT.Roles.Clear")
		net.WriteUInt(#activeplayers, 7)
		for i, v in ipairs(activeplayers) do
			net.WritePlayer(v)
		end
	net.Broadcast()
end

-----------------------
-- TTT.Roles.PickRoles
-----------------------
-- Desc:		Will set the roles of each player accordingly. Does not network these role changes.
function TTT.Roles.PickRoles()
	local traitors = {}
	local detectives = {}

	-- Pick traitors.
	do
		local players = TTT.Roles.GetWaiting()
		local needed_players = math.max(1, math.floor(#players * traitor_percent:GetFloat()))
		math.randomseed(os.time())

		for i = 1, needed_players do
			local ply_index = math.random(1, #players)
			local ply = players[ply_index]

			table.insert(traitors, ply)
			table.remove(players, ply_index)
		end

		-- Now that we randomly picked some traitors allow others to edit this list.
		traitors = hook.Call("TTT.Roles.PickTraitors", nil, traitors) or traitors
	end

	for i, v in ipairs(traitors) do
		v:SetRole(ROLE_TRAITOR)
	end


	-- Pick detectives.
	do
		local players = TTT.Roles.GetWaiting()
		if #players >= detective_threshold:GetInt() then
			local needed_players = math.max(1, math.floor(#players * detective_percent:GetFloat()))
			math.randomseed(os.time())

			for i = 1, needed_players do
				local ply_index = math.random(1, #players)
				local ply = players[ply_index]

				table.insert(detectives, ply)
				table.remove(players, ply_index)
			end
		end
		-- Whether or not we hit the threshold still see if they want to add detectives.
		detectives = hook.Call("TTT.Roles.PickDetectives", nil, detectives) or detectives
	end

	for i, v in ipairs(detectives) do
		v:SetRole(ROLE_DETECTIVE)
	end
end

------------------
-- TTT.Roles.Sync
------------------
-- Desc:		Informs everyone of their own rank and of the roles of other player's they should know of.
function TTT.Roles.Sync()
	-- Tell traitors about each other first.
	local traitors = TTT.Roles.GetTraitors()
	net.Start("TTT.Roles.SyncTraitors")
		net.WriteUInt(#traitors, 7)
		for i, v in ipairs(traitors) do
			net.WritePlayer(v)
		end
	net.Send(traitors)

	-- Now tell everyone what players are detectives or spectators and finalize other player's roles.
	local detectives = TTT.Roles.GetDetectives()
	local spectators = TTT.Roles.GetSpectators()
	net.Start("TTT.Roles.Sync")
		net.WriteUInt(#detectives, 7)
		for i, v in ipairs(detectives) do
			net.WritePlayer(v)
		end

		net.WriteUInt(#spectators, 7)
		for i, v in ipairs(spectators) do
			net.WritePlayer(v)
		end
	net.Broadcast()
end