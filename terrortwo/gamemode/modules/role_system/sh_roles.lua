TTT.Roles = TTT.Roles or {}

ROLE_WAITING	= 0
ROLE_SPECTATOR	= 1
ROLE_INNOCENT	= 2
ROLE_DETECTIVE	= 3
ROLE_TRAITOR	= 4

local PLAYER = FindMetaTable("Player")
function PLAYER:GetRole()
	return self.ttt_role or ROLE_WAITING
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
function TTT.Roles.RoleAsString(ply)
	return TTT.Languages.GetPhrase(role_phrase[ply:GetRole()] or "invalid")
end

TTT.Roles.Colors = {
	[ROLE_WAITING] = Color(90, 90, 90, 230),
	[ROLE_SPECTATOR] = Color(90, 90, 90, 230),
	[ROLE_INNOCENT] = Color(39, 174, 96, 230),
	[ROLE_DETECTIVE] = Color(41, 128, 185, 230),
	[ROLE_TRAITOR] = Color(192, 57, 43, 230)
}

if CLIENT then
	CreateClientConVar("ttt_always_spectator", "0", true, true, "Setting this to true will always make you a spectator.")

	net.Receive("TTT_Roles_Clear", function()
		local numspecs = net.ReadUInt(7)
		local specs = {}
		for i = 1, numspecs do
			specs[net.ReadPlayer()] = true
		end

		for i, v in ipairs(player.GetAll()) do
			if specs[v] then
				v.ttt_role = ROLE_SPECTATOR
			else
				v.ttt_role = ROLE_WAITING
			end
		end
	end)

	net.Receive("TTT_Roles_Sync", function()
		local newrole = net.ReadUInt(3)
		local numplys = net.ReadUInt(7)

		for i = 1, numplys do
			local ply = net.ReadPlayer()
			if IsValid(ply) then
				ply.ttt_role = newrole
			end
		end
	end)

	-- Dont get all excited. This only gets sent to Traitors and Spectators.
	net.Receive("TTT_Roles_PlayerDied", function()
		local ply = net.ReadEntity()
		ply.ttt_role = ROLE_SPECTATOR
	end)
end