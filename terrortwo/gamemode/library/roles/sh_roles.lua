TTT.Roles = TTT.Roles or {}
local PLAYER = FindMetaTable("Player")

-- TTT2 treats spectators differently than TTT. Here spectators are only people with
-- ttt_always_spectator enabled. Dead players are still considered their role when they were alive but with "fly mode" enabled.
-- You can check if a player is in fly mode with ply:IsInFlyMode().

-- Role enums.
ROLE_WAITING	= 1		-- Waiting is set on all players when the conditions to start a round are not met.
ROLE_SPECTATOR	= 2		-- Only set on players with ttt_always_spectate enabled. Dead players do not have this, they are just dead in fly mode.
ROLE_UNKNOWN	= 3		-- Used clientside, set on players who the client doesn't know the role of.
ROLE_INNOCENT	= 4
ROLE_DETECTIVE	= 5
ROLE_TRAITOR	= 6

TTT.Roles.Colors = {
	[ROLE_WAITING] = TTT.Colors.Dead,
	[ROLE_SPECTATOR] = TTT.Colors.Dead,
	[ROLE_UNKNOWN] = TTT.Colors.Dead,
	[ROLE_INNOCENT] = TTT.Colors.Innocent,
	[ROLE_DETECTIVE] = TTT.Colors.Detective,
	[ROLE_TRAITOR] = TTT.Colors.Traitor
}

CreateClientConVar("ttt_detective_avoid", "0", true, true, "Set true to disable being chosen as a detective.")

------------------
-- PLAYER:SetRole
------------------
-- Desc:		Sets the of the player BUT DOES NOT NETWORK IT.
-- Arg One:		ROLE_ enum, to set the player to.
function PLAYER:SetRole(role)
	self.ttt_role = role
	hook.Call("TTT.Roles.Changed", nil, self, role)
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

-- Gets the color for the player's current role.
function PLAYER:GetRoleColor()
	return TTT.Roles.Colors[self:GetRole()]
end

------------------------------------
-- PLAYER:GetUntranslatedRoleString
------------------------------------
-- Desc:		Gets a simple, unlocalized string of the player's role. Used mainly to print debug info from the server.
-- Returns:		String, the player's role.
local roleStrings = {
	[ROLE_WAITING] = "Waiting",
	[ROLE_SPECTATOR] = "Spectator",
	[ROLE_UNKNOWN] = "Unknown",
	[ROLE_INNOCENT] = "Innocent",
	[ROLE_DETECTIVE] = "Detective",
	[ROLE_TRAITOR] = "Traitor"
}
function PLAYER:GetUntranslatedRoleString()
	return roleStrings[self:GetRole()] or "Waiting"
end

if CLIENT then
	--------------------------
	-- TTT.Roles.RoleAsString
	--------------------------
	-- Desc:		Gets a language translated version of the given player's role.
	-- Returns:		String, the player's role.
	local rolePhrases = {
		[ROLE_WAITING] = "waiting",
		[ROLE_SPECTATOR] = "spectator",
		[ROLE_UNKNOWN] = "spectator",
		[ROLE_INNOCENT] = "innocent",
		[ROLE_DETECTIVE] = "detective",
		[ROLE_TRAITOR] = "traitor"
	}
	function TTT.Roles.RoleAsString(ply)
		return TTT.Languages.GetPhrase(rolePhrases[ply:GetRole()] or "invalid")
	end
end
