-- All we need to manually include library-wise.
AddCSLuaFile("library/_prelib.lua")
include("library/_prelib.lua")

AddCSLuaFile("shared.lua")
include("shared.lua")

function GM:PlayerInitialSpawn(ply)
	TTT.Languages.SendServerDefault(ply)-- Tell the player what the server default language is.
	TTT.SetRoleOnInitialSpawn(ply)		-- Set the player's role once they spawn.
end

function GM:PlayerSpawn(ply)
	ply:SetupHands()					-- Get c_ hands working.
end

function GM:PlayerDeath(ply)
	TTT.Roles.SendDeath(ply)			-- Let everyone (who should know) that the player who died, died.
end

function GM:PostPlayerDeath(ply)
	TTT.Rounds.CheckWinOnDeath(ply)		-- Check if the round should end now that this player has died.
end

function GM:PlayerSetHandsModel(ply, ent)

	-- Get c_ hands working.
	local simplemodel = player_manager.TranslateToPlayerModelName(ply:GetModel())
	local info = player_manager.TranslatePlayerHands(simplemodel)
	if info then
		ent:SetModel(info.model)
		ent:SetSkin(info.skin)
		ent:SetBodyGroups(info.body)
	end
end

hook.Add("TTT.Rounds.MapEnd", "TTT", function()
	TTT.MapHandler.HandleMapSwitch()
end)

hook.Add("TTT.Rounds.RoundEnded", "TTT", function(wintype)
	TTT.Roles.Clear()
end)