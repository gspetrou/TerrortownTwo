TTT.Roles = TTT.Roles or {}

-- TTT2 treats spectators differently than TTT. Here spectators are only people with
-- ttt_always_spectator enabled. Dead players are just dead traitors/detectives/innocents.
ROLE_WAITING	= 0
ROLE_SPECTATOR	= 1
ROLE_UNKNOWN	= 3
ROLE_INNOCENT	= 4
ROLE_DETECTIVE	= 5
ROLE_TRAITOR	= 6

TTT.Roles.Colors = {
	[ROLE_WAITING] = Color(90, 90, 90, 230),
	[ROLE_SPECTATOR] = Color(90, 90, 90, 230),
	[ROLE_UNKNOWN] = Color(90, 90, 90, 230),
	[ROLE_INNOCENT] = Color(39, 174, 96, 230),
	[ROLE_DETECTIVE] = Color(41, 128, 185, 230),
	[ROLE_TRAITOR] = Color(192, 57, 43, 230)
}

local PLAYER = FindMetaTable("Player")

------------------
-- PLAYER:SetRole
------------------
-- Desc:		Sets the of the player BUT DOES NOT NETWORK IT.
-- Arg One:		ROLE_ enum, to set the player to.
function PLAYER:SetRole(role)
	self.ttt_role = role
end

------------------
-- PLAYER:GetRole
------------------
-- Desc:		Gets the player's role.
-- Returns:		ROLE_ enum of their role.
function PLAYER:GetRole()
	return self.ttt_role or ROLE_WAITING
end

-- Role checker functions.
function PLAYER:IsWaiting() return self:GetRole() == ROLE_WAITING end
function PLAYER:IsSpectator() return self:GetRole() == ROLE_SPECTATOR end
function PLAYER:IsUnknown() return self:GetRole() == ROLE_UNKNOWN end
function PLAYER:IsInnocent() return self:GetRole() == ROLE_INNOCENT end
function PLAYER:IsDetective() return self:GetRole() == ROLE_DETECTIVE end
function PLAYER:IsTraitor() return self:GetRole() == ROLE_TRAITOR end

if CLIENT then
	--------------------------
	-- TTT.Roles.RoleAsString
	--------------------------
	-- Desc:		Gets a language translated version of the given player's role.
	-- Returns:		String, the player's role.
	local role_phrase = {
		[ROLE_WAITING] = "waiting",
		[ROLE_SPECTATOR] = "spectator",
		[ROLE_UNKNOWN] = "spectator",
		[ROLE_INNOCENT] = "innocent",
		[ROLE_DETECTIVE] = "detective",
		[ROLE_TRAITOR] = "traitor"
	}
	function TTT.Roles.RoleAsString(ply)
		return TTT.Languages.GetPhrase(role_phrase[ply:GetRole()] or "invalid")
	end
end
