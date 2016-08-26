util.AddNetworkString("TTT_SyncRoles")
util.AddNetworkString("TTT_ClearRoles")

local PLAYER = FindMetaTable("Player")
local traitor_percent = CreateConVar("ttt_traitor_percent", "0.25", nil, "Percentage of players that will be traitors.")
local detective_threshold = CreateConVar("ttt_detective_threshold", "8", nil, "There must be at least this many players before there can be detectives.")
local detective_percent = CreateConVar("ttt_detective_percent", "0.15", nil, "Percentage of players that will be detectives.")

TTT.PlayerRoles = TTT.PlayerRoles or {
	[ROLE_WAITING] = {},
	[ROLE_SPECTATOR] = {},
	[ROLE_INNOCENT] = {},
	[ROLE_DETECTIVE] = {},
	[ROLE_TRAITOR] = {}
}
local EmptyRoles = TTT.PlayerRoles

function PLAYER:SetRole(roletype)
	self.role = roletype
	table.insert(GM.PlayerRoles[roletype], self)
end

function PLAYER:GetRole()
	return self.role or ROLE_WAITING
end

function PLAYER:IsWaiting() return self:GetRole() == ROLE_WAITING end
function PLAYER:IsSpectator() return self:GetRole() == ROLE_SPECTATOR end
function PLAYER:IsInnocent() return self:GetRole() == ROLE_INNOCENT end
function PLAYER:IsDetective() return self:GetRole() == ROLE_DETECTIVE end
function PLAYER:IsTraitor() return self:GetRole() == ROLE_TRAITOR end

function TTT.GetWaiting() return TTT.PlayerRoles[ROLE_WAITING] end
function TTT.GetSpectators() return TTT.PlayerRoles[ROLE_SPECTATOR] end
function TTT.GetInnocents() return TTT.PlayerRoles[ROLE_INNOCENT] end
function TTT.GetDetectives() return TTT.PlayerRoles[ROLE_DETECTIVE] end
function TTT.GetTraitors() return TTT.PlayerRoles[ROLE_TRAITOR] end

function PLAYER:IsActive()
	local isactive = hook.Call("TTT_IsPlayerActive", GM, self)

	if type(active) == "boolean" then
		return isactive
	end

	return IsValid(self) and not (self:IsSpectator() and self:IsWaiting())
end

function TTT.GetActivePlayers()
	local players = player.GetAll()

	for i = 1, #players do
		local ply = players[i]

		if not ply:IsActive() then
			table.remove(players, i)
		end
	end

	return players
end

function TTT.SyncRoles()
	-- Send traitors
	local traitors = TTT.GetTraitors()

	net.Start("TTT_SyncRoles")
		net.WriteUInt(ROLE_TRAITOR, 3)
		net.WriteUInt(#traitors, 7)
		for i, v in ipairs(traitors) do
			net.WritePlayer(v)
		end
	net.Send(traitors)

	-- Send Detectives
	local detectives = TTT.GetDetectives()
	if #detectives == 0 then return end

	net.Start("TTT_SyncRoles")
		net.WriteUInt(ROLE_DETECTIVE, 3)
		net.WriteUInt(#detectives, 7)
		for i, v in ipairs(detectives) do
			net.WritePlayer(v)
		end
	net.Broadcast()
end

-- Sets everyone to waiting
function TTT.ClearRoles()
	GM.PlayerRoles = EmptyRoles

	for i, v in ipairs(player.GetAll()) do
		v.role = ROLE_WAITING
	end

	net.Start("TTT_ClearRoles")
	net.Broadcast()
end

local function RandomRole(role, percentage)
	local plys_of_role = {}
	local allplayers = TTT.GetActivePlayers()
	local num_allplayers = #allplayers
	local num_plys_of_role = math.floor(num_allplayers * percentage)
	local conditional
	local hookname

	if role == ROLE_DETECTIVE then
		conditional = function(ply) return ply:IsTraitor() end
		hookname = "TTT_PickDetectives"
	else
		conditional = function(ply) return ply:IsDetective() end
		hookname = "TTT_PickTraitors"
	end

	for i = 1, num_plys_of_role do
		math.randomseed(os.time() - CurTime())	-- Eh, good enough

		local r = math.random(num_allplayers)
		local ply = allplayers[r]

		if conditional(ply) then
			table.insert(plys_of_role, ply)
			table.remove(allplayers, r)
		end

		num_allplayers = num_allplayers - 1
	end

	plys_of_role = hook.Call(hookname, GM, plys_of_role) or plys_of_role

	for i, v in ipairs(plys_of_role) do
		v:SetRole(role)
	end
end

function TTT.PickRoles()
	TTT.PickRandomTraitors()
	TTT.PickRandomDetectives()
end

-- Makes a table of random traitors and sets them to that role.
-- Does not network, use TTT.SyncRoles for that.
function TTT.PickRandomTraitors()
	traitor_percent = traitor_percent:GetFloat()
	if #player.GetAll() < 4 then
		traitor_percent = 0.5
	end

	RandomRole(ROLE_TRAITOR, traitor_percent)
end

function TTT.PickRandomDetectives()
	local detectives_pass_threshold = #player.GetAll() >= detective_threshold:GetInt()

	if detectives_pass_threshold then
		detective_percent = detective_percent:GetFloat()
		RandomRole(ROLE_DETECTIVE, detective_percent)
	end
end
