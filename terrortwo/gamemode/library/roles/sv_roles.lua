TTT.Roles = TTT.Roles or {}

-- Setup network strings.
util.AddNetworkString("TTT.Roles.SyncTraitors")
util.AddNetworkString("TTT.Roles.Sync")
util.AddNetworkString("TTT.Roles.Clear")
util.AddNetworkString("TTT.Roles.SpectatorModeChange")
util.AddNetworkString("TTT.Roles.PlayerSwitchedRole")
util.AddNetworkString("TTT.Roles.SpectatorOnConnect")

-- Setup the convars.
local traitor_percent = CreateConVar("ttt_traitor_percent", "0.25", FCVAR_ARCHIVE, "Percentage of players that will be traitors.")
local detective_threshold = CreateConVar("ttt_detective_threshold", "8", FCVAR_ARCHIVE, "There must be at least this many players before there can be detectives.")
local detective_percent = CreateConVar("ttt_detective_percent", "0.15", FCVAR_ARCHIVE, "Percentage of players that will be detectives.")
local PLAYER = FindMetaTable("Player")

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

---------------------------------
-- TTT.Roles.SetupAlwaysSpectate
---------------------------------
-- Desc:		Sees if the player has always spectate enabled on this server, and if they do make them a spectator.
-- Arg One:		Player, to see if they should be a spectator.
function TTT.Roles.SetupAlwaysSpectate(ply)
	local q = sql.Query("SELECT `is_spec` from `ttt` WHERE id=".. sql.SQLStr(ply:SteamID64()) ..";")[1].is_spec
	local should_spec = q == "1" and true or false
	if should_spec then
		ply:SetRole(ROLE_SPECTATOR)
		net.Start("TTT.Roles.SpectatorOnConnect")
		net.Send(ply)

		ply:Kill()	-- Killing them after setting their role to spectator will spawn them properly as a spectator.
	else
		ply:SetRole(ROLE_WAITING)
	end
end

---------------------------
-- TTT.Roles.MakeSpectator
---------------------------
-- Desc:		Makes the player into a spectator or takes them out if they do not want to be.
-- Arg One:		Player, to change spectator status of.
-- Arg Two:		Boolean, true to make them a spectator. False to remove their spectator.
function TTT.Roles.MakeSpectator(ply, is_spec)
	local id = sql.SQLStr(ply:SteamID64())
	local sql_is_spec = is_spec and "1" or "0"
	sql.Query("UPDATE `ttt` SET is_spec = ".. sql_is_spec .." WHERE id = ".. id ..";")

	if is_spec then
		ply:ForceSpectator()
		hook.Call("TTT.Roles.PlayerBecameSpectator", nil, ply)
	else
		ply:ForceWaiting()
		hook.Call("TTT.Roles.PlayerExittedSpectator", nil, ply)
	end
end

-- When received toggle the player's spectator status.
net.Receive("TTT.Roles.SpectatorModeChange", function(_, ply)
	if IsValid(ply) then
		local wantsSpec = net.ReadBool()
		if ply:IsSpectator() and not wantsSpec then
			TTT.Roles.MakeSpectator(ply, false)
		elseif wantsSpec and not ply:IsSpectator() then
			TTT.Roles.MakeSpectator(ply, true)
		end
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
-- Arg Two:		Table, player, true or nil. Table if more than one player should know. Player for a single person. True for everyone to know this person's role changed. Nil for the player the function is called on.
function PLAYER:SetRoleClientside(role, recipients)
	net.Start("TTT.Roles.PlayerSwitchedRole")
		net.WriteUInt(role, 3)
		net.WritePlayer(self)

	if recipients == true then
		net.Broadcast()
	else
		if not recipients then
			recipients = self
		end
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
	local allplayers_exceptself = player.GetAll()
	for i, v in ipairs(allplayers_exceptself) do
		if v == self then
			table.remove(allplayers_exceptself, i)
			break
		end
	end

	-- Tell self that we are an innocent, tell everyone else that we're unknown.
	self:ForceRole(ROLE_INNOCENT, self)
	self:SetRoleClientside(ROLE_UNKNOWN, allplayers_exceptself)
end
function PLAYER:ForceTraitor()
	self:SetRole(ROLE_TRAITOR)
	self:SetRoleClientside(ROLE_TRAITOR, TTT.Roles.GetTraitors())
	self:SetRoleClientside(ROLE_UNKNOWN, TTT.Roles.GetNotTraitors())
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

	math.randomseed(os.time())	-- Probably not necessary but makes me feel good.

	-- Pick traitors.
	do
		local players = TTT.Roles.GetWaiting()
		local needed_players = math.max(1, math.floor(#players * traitor_percent:GetFloat()))

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