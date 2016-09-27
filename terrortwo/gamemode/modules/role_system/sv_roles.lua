util.AddNetworkString("TTT_Roles_Sync")
util.AddNetworkString("TTT_Roles_Clear")
util.AddNetworkString("TTT_Roles_PlayerDied")

TTT.Roles = TTT.Roles or {}

local traitor_percent = CreateConVar("ttt_traitor_percent", "0.25", nil, "Percentage of players that will be traitors.")
local detective_threshold = CreateConVar("ttt_detective_threshold", "8", nil, "There must be at least this many players before there can be detectives.")
local detective_percent = CreateConVar("ttt_detective_percent", "0.15", nil, "Percentage of players that will be detectives.")
local PLAYER = FindMetaTable("Player")

TTT.Roles.Players = TTT.Roles.Players or {
	[ROLE_WAITING] = {},
	[ROLE_SPECTATOR] = {},
	[ROLE_INNOCENT] = {},
	[ROLE_DETECTIVE] = {},
	[ROLE_TRAITOR] = {}
}
local EmptyRoles = TTT.Roles.Players

function TTT.Roles.GetWaiting() return TTT.Roles.Players[ROLE_WAITING] end
function TTT.Roles.GetSpectators() return TTT.Roles.Players[ROLE_SPECTATOR] end
function TTT.Roles.GetInnocents() return TTT.Roles.Players[ROLE_INNOCENT] end
function TTT.Roles.GetDetectives() return TTT.Roles.Players[ROLE_DETECTIVE] end
function TTT.Roles.GetTraitors() return TTT.Roles.Players[ROLE_TRAITOR] end

function PLAYER:SetRole(r)
	local oldtable = TTT.Roles.Players[self:GetRole()]
	if type(oldtable) == "table" then
		for i, v in ipairs(oldtable) do
			if v == self then
				table.remove(TTT.Roles.Players[self:GetRole()], i)
			end
		end
	end

	self.ttt_role = r
	table.insert(TTT.Roles.Players[r], self)
end

-- Updates the role for this specific player, no need to sync everyone.
function PLAYER:ForceRole(r, targets)
	self:SetRole(r)
	net.Start("TTT_Roles_Sync")
		net.WriteUInt(r, 3)
		net.WriteUInt(1, 7)

		net.WritePlayer(self)
	net.Send(targets or self)
end

-- When a player dies before they are identified.
function TTT.Roles.SendDeath(ply)
	ply:SetRole(ROLE_SPECTATOR)
	
	local recipients = {}
	for i, v in ipairs(player.GetAll()) do
		if v:IsSpectator() or v:IsWaiting() or v:IsTraitor() then
			table.insert(recipients, v)
		end
	end

	if #recipients > 0 then
		net.Start("TTT_Roles_PlayerDied")
			net.WritePlayer(ply)
		net.Send(recipients)
	end
end

hook.Add("PlayerDeath", "TTT_Roles_SendDeath", function(ply)
	TTT.Roles.SendDeath(ply)
end)

hook.Add("PlayerInitialSpawn", "TTT_Roles_PlayerInit", function(ply)
	if ply:GetInfoNum("ttt_spectator_only", 0) == 1 then
		ply:SetRole(ROLE_SPECTATOR)
	else
		ply:SetRole(ROLE_WAITING)
	end
end)

-- Is not spec-only
function PLAYER:IsActive()
	if not IsValid(self) then
		return false
	elseif hook.Call("TTT_Roles_IsPlayerActive", GM, self) == true then
		return true
	elseif self:GetInfoNum("ttt_always_spectator", 0) == 1 then
		return false
	end

	return true
end

function TTT.Roles.GetActivePlayers()
	local players = {}
	for i, v in ipairs(player.GetAll()) do
		if v:IsActive() then
			table.insert(players, v)
		end
	end

	return players
end

function TTT.Roles.PickTraitors()
	local players = TTT.Roles.GetWaiting()	
	local needed_players = math.max(1, math.floor(#players * traitor_percent:GetFloat()))
	local traitors = {}

	for i = 1, needed_players do
		math.randomseed(os.time())
		local ply_index = math.random(1, #players)
		local ply = players[ply_index]

		table.insert(traitors, ply)
		table.remove(players, ply_index)
	end

	traitors = hook.Call("TTT_Roles_PickTraitors", GM, traitors) or traitors

	for i, v in ipairs(traitors) do
		v:SetRole(ROLE_TRAITOR)
	end
end

function TTT.Roles.PickDetectives()
	local players = TTT.Roles.GetWaiting()
	if #players > detective_threshold:GetInt() then
		local needed_players = math.max(1, math.floor(#players * detective_percent:GetFloat()))
		local detectives = {}

		for i = 1, needed_players do
			math.randomseed(os.time())
			local ply_index = math.random(1, #players)
			local ply = players[ply_index]

			table.insert(detectives, ply)
			table.remove(players, ply_index)
		end

		detectives = hook.Call("TTT_Roles_PickDetectives", GM, detectives) or detectives

		for i, v in ipairs(detectives) do
			v:SetRole(ROLE_DETECTIVE)
		end
	end
end

function TTT.Roles.PickRoles()
	for i, v in ipairs(player.GetAll()) do
		if v:GetInfoNum("ttt_spectator_only", 0) == 1 then
			v:SetRole(ROLE_SPECTATOR)
		end
	end

	TTT.Roles.PickTraitors()
	TTT.Roles.PickDetectives()
end

function TTT.Roles.Clear()
	TTT.Roles.Players = EmptyRoles
	local spec = {}

	for i, v in ipairs(player.GetAll()) do
		if v:GetInfoNum("ttt_spectator_only", 0) == 1 then
			table.insert(spec)
		end
	end

	net.Start("TTT_Roles_Clear")
		net.WriteUInt(#spec, 7)
		for i, v in ipairs(spec) do
			net.WritePlyer(v)
		end
	net.Broadcast()
end

function TTT.Roles.Sync()
	-- Send traitors
	local traitors = TTT.Roles.GetTraitors()

	net.Start("TTT_Roles_Sync")
		net.WriteUInt(ROLE_TRAITOR, 3)
		net.WriteUInt(#traitors, 7)
		for i, v in ipairs(traitors) do
			net.WritePlayer(v)
		end
	net.Send(traitors)

	-- Send Detectives
	local detectives = TTT.Roles.GetDetectives()
	if #detectives > 0 then
		net.Start("TTT_Roles_Sync")
			net.WriteUInt(ROLE_DETECTIVE, 3)
			net.WriteUInt(#detectives, 7)
			for i, v in ipairs(detectives) do
				net.WritePlayer(v)
			end
		net.Broadcast()
	end
end