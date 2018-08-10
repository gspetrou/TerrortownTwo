TTT.Karma = TTT.Karma or {
	RememberedPlayers = {},
	ConVars = {}
}

TTT.Karma.ConVars.Enabled = CreateConVar("ttt_karma", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Is the karma system enabled.")
TTT.Karma.ConVars.Maximum = CreateConVar("ttt_karma_max", "1250", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "The maximum karma reachable. Must be below 4000.")

-- Limit the maximum karma to 4000 because we are networking karma with 12 bits, a maximum karma of 4096.
cvars.AddChangeCallback("ttt_karma_max", function(name, oldVal, newVal)
	newVal = tonumber(newVal)

	if not isnumber(newVal) then
		ErrorNoHalt("[ERROR] Tried to set maximum karma to a non-number value, defaulting to 1000.\n")
		RunConsoleCommand("ttt_karma_max", 1000)
	end

	if newVal > 4000 then
		ErrorNoHalt("[ERROR] You cannot set the maximum karma to a value above 4000. Reverting to old value.\n")

		oldVal = tonumber(oldVal)
		if isnumber(oldVal) and oldVal <= 4000 then
			RunConsoleCommand("ttt_karma_max", oldVal)
		else
			RunConsoleCommand("ttt_karma_max", 1000)
		end
	end
end)

local PLAYER = FindMetaTable("Player")

-----------------------
-- PLAYER:GetBaseKarma
-----------------------
-- Desc:		Gets the player's base karma that is computed only at round start and is used for damage factor computation for the duration of the round.
-- Returns:		Number, gets the player's base karma set at round start.
function PLAYER:GetBaseKarma()
	return isnumber(self.ttt_BaseKarma) and self.ttt_BaseKarma or TTT.Karma:GetStartingKarma()
end

-----------------------
-- PLAYER:SetBaseKarma
-----------------------
-- Desc:		Sets the player's base karma. Should only be updated at round start.
-- Arg One:		Number, updates the player's base karma.
function PLAYER:SetBaseKarma(num)
	if num > 4000 then
		error("Player '"..self:Nick().."' has reached a karma above 4000, this is not allowed!")
	end
	self.ttt_BaseKarma = num
end

-----------------------
-- TTT.Karma:IsEnabled
-----------------------
-- Desc:		Sees if the karma system is enabled.
-- Returns:		Boolean.
function TTT.Karma:IsEnabled()
	return self.ConVars.Enabled:GetBool()
end

net.Receive("TTT.Karma.SyncKarma", function()
	local numplayers = net.ReadUInt(7)

	for i = 1, numplayers do
		local ply = net.ReadPlayer()
		if IsValid(ply) then
			ply:SetBaseKarma(net.ReadUInt(12))
		end
	end
end)