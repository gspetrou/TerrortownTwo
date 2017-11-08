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
local oldAlive = PLAYER.Alive

-- We say flying mode here to not confused being a spectator and spectating with being dead and spectating.
------------------------------
-- TTT.Roles.SpawnInFlyMode
------------------------------
-- Desc:		Spawns the player in a flying mode.
-- Arg One:		Player, to be set as a spectator.
function TTT.Roles.SpawnInFlyMode(ply)
	-- If the player is actually dead, spawn them first.
	if not oldAlive(ply) then
		ply.ttt_OverrideSpawn = true
		ply:Spawn()
		ply.ttt_OverrideSpawn = false
	end

	if not ply.ttt_InFlyMode then
		ply:Spectate(OBS_MODE_ROAMING)
		ply.ttt_InFlyMode = true
	end

	-- If the player spawns in fly mode after dying as a player, spawm them at their death position.
	if ply.ttt_deathpos_set then
		ply:SetPos(ply.ttt_deathpos)
		ply:SetAngles(ply.ttt_deathang)
		ply.ttt_deathpos_set = false
	end
end

----------------------
-- PLAYER:IsInFlyMode
----------------------
-- Desc:		Is the player in fly mode.
-- Returns:		Boolean, are they in fly mode.
function PLAYER:IsInFlyMode()
	return self.ttt_InFlyMode or false
end

------------------------------
-- TTT.Roles.ForceSpawnPlayer
------------------------------
-- Desc:		Forces a player to spawn.
-- Arg One:		Player, to be spawned.
-- Arg Two:		Boolean, should we reset their spawn position to a map spawn spot.
-- Arg Three:	Boolean, should we arm the player with the default weapons when they spawn. Optional, true by default.
function TTT.Roles.ForceSpawnPlayer(ply, resetspawn, shouldarm)
	if not oldAlive(ply) then
		local pos = ply:GetPos()
		local ang = ply:GetAngles()
		ply:Spawn()
		if not resetspawn then
			ply:SetPos(pos)
			ply:SetEyeAngles(ang)
		end
	end
	ply:UnSpectate()
	ply.ttt_InFlyMode = false
	ply:SetNoDraw(false)
	hook.Call("TTT.Roles.ForceSpawnedPlayer", nil, ply, resetspawn, shouldarm or true)
end

----------------------------
-- TTT.Roles.SetupSpectator
----------------------------
-- Desc:		Sees if this player should be a spectator and sets them if they should.
-- 				Used when a player joins a server with spectate always on.
-- Arg One:		Player, to setup as spectator.
function TTT.Roles.SetupSpectator(ply)
	if ply:IsSpectator() then
		ply:SetRole(ROLE_SPECTATOR)
	end
end

function PLAYER:Alive()
	if self:IsSpectator() or self:IsInFlyMode() then
		return false
	end
	return oldAlive(self)
end

-----------------------------
-- TTT.Roles.GetAlivePlayers
-----------------------------
-- Desc:		Gets all the alive players.
-- Returns:		Table, containning alive players.
function TTT.Roles.GetAlivePlayers()
	return table.Filter(player.GetAll(), function(ply)
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
		return not oldAlive(ply) and not ply:IsSpectator()
	end)
end

------------------------------
-- TTT.Roles.GetActivePlayers
------------------------------
-- Desc:		Gets all active players. Active means they are not in always spectate mode.
-- Returns:		Table, containning active players.
function TTT.Roles.GetActivePlayers()
	return table.Filter(player.GetAll(), function(ply)
		return not ply:IsSpectator()
	end)
end

----------------------
-- PLAYER:IsSpectator
----------------------
-- Desc:		Checks if the player is a spectator.
-- Returns:		Boolean, are they a spectator.
function PLAYER:IsSpectator()
	if self.ttt_IsSpectator ~= nil then
		return self.ttt_IsSpectator
	end
	return true
end

net.Receive("TTT.Roles.ChangedSpectatorMode", function(_, ply)
	local wants_spec = net.ReadBool()
	if wants_spec then
		ply:ForceSpectator()
		ply.ttt_IsSpectator = true
		hook.Call("TTT.Roles.PlayerBecameSpectator", nil, ply)
	else
		ply:ForceWaiting()
		ply.ttt_IsSpectator = false
		hook.Call("TTT.Roles.PlayerExittedSpectator", nil, ply)
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

	for i, v in ipairs(TTT.Roles.GetWaiting()) do
		v:SetRole(ROLE_INNOCENT)
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