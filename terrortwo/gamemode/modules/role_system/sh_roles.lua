ROLE_WAITING	= 0
ROLE_SPECTATOR	= 1
ROLE_INNOCENT	= 2
ROLE_DETECTIVE	= 3
ROLE_TRAITOR	= 4

local PLAYER = FindMetaTable("Player")
function PLAYER:GetRole()
	return self.role or ROLE_WAITING
end

function PLAYER:IsWaiting() return self:GetRole() == ROLE_WAITING end
function PLAYER:IsSpectator() return self:GetRole() == ROLE_SPECTATOR end
function PLAYER:IsInnocent() return self:GetRole() == ROLE_INNOCENT end
function PLAYER:IsDetective() return self:GetRole() == ROLE_DETECTIVE end
function PLAYER:IsTraitor() return self:GetRole() == ROLE_TRAITOR end

local role_phrase = {
	[ROLE_WAITING] = "waiting",
	[ROLE_SPECTATOR] = "spectator",
	[ROLE_INNOCENT] = "innocent",
	[ROLE_DETECTIVE] = "detective",
	[ROLE_TRAITOR] = "traitor"
}
function TTT.GetRoleAsString(ply)
	return TTT.GetPhrase(role_phrase[ply:GetRole()] or "invalid")
end

if CLIENT then
	CreateClientConVar("ttt_always_spectator", "0", true, true, "Setting this to true will always make you a spectator.")

	net.Receive("TTT_ClearRoles", function()
		local numspecs = net.ReadUInt(7)
		local specs = {}
		for i = 1, numspecs do
			specs[net.ReadPlayer()] = true
		end

		for i, v in ipairs(player.GetAll()) do
			if specs[v] then
				v.role = ROLE_SPECTATOR
			else
				v.role = ROLE_WAITING
			end
		end
	end)

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

	net.Receive("TTT_PlayerDied", function()
		local ply = net.ReadEntity()
		ply.role = ROLE_SPECTATOR
	end)
end