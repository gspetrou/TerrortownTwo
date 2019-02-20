TTT.Corpse = TTT.Corpse or {}
local PLAYER = FindMetaTable("Player")

-- Represent the "found" status of a body.
BODYSTATUS_UNSET = 0	-- Can be set on players who were never alive in the current round (just connected).
BODYSTATUS_UNKNOWN = 1
BODYSTATUS_MISSING = 2
BODYSTATUS_FOUND = 3

-----------------------
-- TTT.Corpse.Statuses
-----------------------
-- Desc:		Table that keeps track of player's body status. This table will vary between server and clients depending on what they should know.
-- 				Server keeps track only of body statuses that everyone should know (e.g. Someone searching a dead body indiscreetly).
-- 				This means that on the server no body will have the missing status since only traitors will ever really see it.
-- Key:			String, SteamID32 of a player.
-- Value:		BODYSTATUS_ enum.
TTT.Corpse.Statuses = TTT.Corpse.Statuses or {}

-----------------------------
-- PLAYER:GetBodyFoundStatus
-----------------------------
-- Desc:		Gets a player's body status (missing/found/unknown).
-- Returns:		BODYSTATUS_ enum.
function PLAYER:GetBodyFoundStatus()
	return TTT.Corpse.GetStatusFromSteamID(self:SteamID())
end

------------------------
-- PLAYER:SetBodyStatus
------------------------
-- Desc:		Sets the status of the player's body.
-- Arg One:		BODYSTATUS_ enum.
function PLAYER:SetBodyStatus(status)
	TTT.Corpse.SetBodyStatusFromSteamID(self:SteamID(), status)
end

-----------------------------------
-- TTT.Corpse.GetStatusFromSteamID
-----------------------------------
-- Desc:		Gets a player's body status from their steam id. Useful if they disconnected.
-- Arg One:		String, steam id 32.
-- Returns:		BODYSTATUS_ enum.
function TTT.Corpse.GetStatusFromSteamID(steamid)
	return TTT.Corpse.Statuses[steamid] or BODYSTATUS_UNSET
end

---------------------------------------
-- TTT.Corpse.SetBodyStatusFromSteamID
---------------------------------------
-- Desc:		Sets a person's body status given their steamid32 and BODYSTATUS enum.
-- Arg One:		String, steam id 32 of the player.
-- Arg Two:		BODYSTATUS_ enum.
function TTT.Corpse.SetBodyStatusFromSteamID(steamid, status)
	TTT.Corpse.Statuses[steamid] = status
end

--------------------------------
-- TTT.Corpse.ResetBodyStatuses
--------------------------------
-- Desc:		Resets all non-specators body status to unknown and all spectators to unset.
function TTT.Corpse.ResetBodyStatuses()
	for i, ply in ipairs(player.GetAll()) do
		if ply:IsSpectator() then
			ply:SetBodyStatus(BODYSTATUS_UNSET)
		else
			ply:SetBodyStatus(BODYSTATUS_UNKNOWN)
		end
	end
end

--------------------------
-- PLAYER:IsConfirmedDead
--------------------------
-- Desc:		Sees if the player is confirmed dead (everyone knows theyre dead).
-- Returns:		Boolean.
function PLAYER:IsConfirmedDead()
	return self:GetBodyFoundStatus() == BODYSTATUS_FOUND
end

--------------------
-- PLAYER:IsMissing
--------------------
-- Desc:		Sees if the player is missing. This can vary from player to player.
-- Returns:		Boolean.
function PLAYER:IsMissing()
	return self:GetBodyFoundStatus() == BODYSTATUS_MISSING
end

if SERVER then
	-----------------------------------
	-- TTT.Corpse.SendBodyStatusUpdate
	-----------------------------------
	-- Desc:		Changes the body status of a given body for a given client or group of clients.
	-- Arg One:		String or Player. String, steamid32 of the player's body. Player, who's body status to update.
	-- Arg Two:		BODYSTATUS_ enum, new body status.
	-- Arg Three:	Player, table, or boolean. Player for single recipient to get the update, sequential table for multiple players, true for everyone.
	util.AddNetworkString("TTT.Corpse.UpdateBodyInfo")
	function TTT.Corpse.SendBodyStatusUpdate(plyID, status, recipients)
		if isentity(plyID) then
			plyID = plyID:SteamID()
		end

		if not isstring(plyID) then
			error("Invalid player given to TTT.Corpse.SendBodyStatusUpdate!")
		end

		local broadcast

		if istable(recipients) or (isentity(recipients) and recipients:IsPlayer()) then
			broadcast = false
		elseif recipients == true then
			broadcast = true
		else
			error("Invalid recipients arguement given to TTT.Corpse.SendBodyStatusUpdate!")
		end
		
		net.Start("TTT.Corpse.UpdateBodyInfo")
			net.WriteString(plyID)
			net.WriteUInt(status, 2)
		if broadcast then
			net.Broadcast()
		else
			net.Send(recipients)
		end
	end

	------------------------------------
	-- TTT.Corpse.SetMissingForTraitors
	------------------------------------
	-- Desc:		Sets the player's body status to missing for all traitors. Used when the given player dies.
	-- Arg One:		Player or SteamID32, to set missing for traitors.
	function TTT.Corpse.SetMissingForTraitors(plyID)
		TTT.Corpse.SendBodyStatusUpdate(plyID, BODYSTATUS_MISSING, TTT.Roles.GetTraitors())
	end

	-------------------------------
	-- TTT.Corpse.SetConfirmedDead
	-------------------------------
	-- Desc:		Sets the player's body status to confirmed dead for all everyone.
	-- Arg One:		Player or SteamID32, to set confirmed dead.
	function TTT.Corpse.SetConfirmedDead(plyID)
		TTT.Corpse.SendBodyStatusUpdate(plyID, BODYSTATUS_FOUND, true)
	end
end

if CLIENT then
	net.Receive("TTT.Corpse.UpdateBodyInfo", function()
		TTT.Corpse.SetBodyStatusFromSteamID(net.ReadString(), net.ReadUInt(2))
	end)
end

















