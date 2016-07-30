local PLAYER = FindMetaTable("Player")

util.AddNetworkString("TTT_SendRole")
util.AddNetworkString("TTT_SyncRoles")

local function SendRole(ply, role, recipients)
	net.Start("TTT_SendRole")
		net.WritePlayer(ply)
		net.WriteUInt(role, 3)
	net.Send(recipients)
end

function PLAYER:SetSpectator(ShouldNetwork)
	self.role = ROLE_SPECTATOR
	GM.PlayerRoles[ROLE_SPECTATOR][self] = true

	if ShouldNetwork then
		local spectators = TTT.GetSpectators()
		local traitors = TTT.GetTraitors()
		local recipients = spectators
		for i, v in ipairs(traitors) do
			table.insert(recipients, v)
		end

		SendRole(self, ROLE_SPECTATOR, recipients)
	end
end
function PLAYER:SetInnocent(ShouldNetwork)
	self.role = ROLE_INNOCENT
	GM.PlayerRoles[ROLE_INNOCENT][self] = true

	if ShouldNetwork then
		SendRole(self, ROLE_INNOCENT, self)
	end
end
function PLAYER:SetDetective(ShouldNetwork)
	self.role = ROLE_DETECTIVE
	GM.PlayerRoles[ROLE_DETECTIVE][self] = true

	if ShouldNetwork then
		SendRole(self, ROLE_DETECTIVE, player.GetAll())
	end
end
function PLAYER:SetTraitor(ShouldNetwork)
	self.role = ROLE_TRAITOR
	GM.PlayerRoles[ROLE_TRAITOR][self] = true

	if ShouldNetwork then
		SendRole(self, ROLE_TRAITOR, TTT.GetTraitors())
	end
end

function PLAYER:GetRole()
	return self.role or ROLE_INVALID
end
function PLAYER:SetRole(role)
	if role == ROLE_SPECTATOR then
		self:SetSpectator()
	elseif role == ROLE_INNOCENT then
		self:SetInnocent()
	elseif role == ROLE_DETECTIVE then
		self:SetDetective()
	elseif role == ROLE_TRAITOR then
		self:SetTraitor()
	else
		error("Tried to set an invalid role '"..role.."' on player '"..role.."'.")
	end
end

function PLAYER:IsInvalid()
	return self:GetRole() == ROLE_INVALID
end
function PLAYER:IsSpectator()
	return self:GetRole() == ROLE_SPECTATOR
end
function PLAYER:IsInnocent()
	return self:GetRole() == ROLE_INNOCENT
end
function PLAYER:IsDetective()
	return self:GetRole() == ROLE_DETECTIVE
end
function PLAYER:IsTraitor()
	return self:GetRole() == ROLE_TRAITOR
end

function TTT.GetSpectators()
	local spectators = {}

	for i, v in ipairs(player.GetAll()) do
		if v:IsSpectator() then
			table.insert(spectators, v)
		end
	end
	return spectators
end
function TTT.GetInnocents()
	local innocents = {}

	for i, v in ipairs(player.GetAll()) do
		if v:IsInnocent() then
			table.insert(innocents, v)
		end
	end
	return innocents
end
function TTT.GetDetectives()
	local detectives = {}

	for i, v in ipairs(player.GetAll()) do
		if v:IsDetective() then
			table.insert(detectives, v)
		end
	end
	return detectives
end
function TTT.GetTraitors()
	local traitors = {}

	for i, v in ipairs(player.GetAll()) do
		if v:IsTraitor() then
			table.insert(traitors, v)
		end
	end
	return traitors
end

function TTT.SyncSpectators()
	local spectators = TTT.GetSpectators()
	local traitors = TTT.GetTraitors()
	local recipients = spectators
	for i, v in ipairs(traitors) do
		table.insert(recipients, v)
	end

	net.Start("TTT_SyncRoles")
		net.WriteUInt(#spectators, 7)
		net.WriteUInt(ROLE_SPECTATOR, 3)
		for i, v in ipairs(spectators) do
			net.WritePlayer(v)
		end
	net.Send(recipients)
end
function TTT.SyncInnocents()
	for i, v in ipairs(TTT.GetInnocents()) do
		SendRole(v, ROLE_INNOCENT, v)
	end
end
function TTT.SyncDetectives()
	local detectives = TTT.GetDetectives()

	net.Start("TTT_SyncRoles")
		net.WriteUInt(#detectives, 7)
		net.WriteUInt(ROLE_DETECTIVE, 3)
		for i, v in ipairs(detectives) do
			net.WritePlayer(v)
		end
	net.Broadcast()
end
function TTT.SyncTraitors()
	local traitors = TTT.GetTraitors()

	net.Start("TTT_SyncRoles")
		net.WriteUInt(#traitors, 7)
		net.WriteUInt(ROLE_TRAITOR, 3)
		for i, v in ipairs(traitors) do
			net.WritePlayer(v)
		end
	net.Send(traitors)
end
function TTT.SyncAllRoles()
	TTT.SyncSpectators()
	TTT.SyncInnocents()
	TTT.SyncDetectives()
	TTT.SyncTraitors()
end