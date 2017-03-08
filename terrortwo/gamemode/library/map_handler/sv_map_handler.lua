TTT.MapHandler = TTT.MapHandler or {}

---------------------------
-- TTT.MapHandler.ResetMap
---------------------------
-- Desc:		Resets the map to its original state and respawns players.
function TTT.MapHandler.ResetMap()
	game.CleanUpMap()
	local plys = TTT.Roles.GetNotSpectators()
	for i, v in ipairs(plys) do
		if v.ttt_inflymode then
			v:UnSpectate()
		end

		v:Spawn()
		v:StripAmmo()
		v:StripWeapons()
	end
end

-- NOTICE:	A decent amount of the spawning and placement code below was adapted
--			from the original TTT. Credits to Bad King Urgrain and whoever else helped.

-----------------------------------
-- TTT.MapHandler.GetSpawnEntities
-----------------------------------
-- Desc:		Returns a table of all spawn entities.
-- Returns:		Table, just read the damn description.
local validspawns = {		-- Table taken from original TTT code.
	"info_player_deathmatch",
	"info_player_combine",
	"info_player_rebel",
	"info_player_counterterrorist",
	"info_player_terrorist",
	"info_player_axis",
	"info_player_allies",
	"gmod_player_start",
	"info_player_teamspawn"
}
function TTT.MapHandler.GetSpawnEntities()
	local spawns = {}
	for _, class in ipairs(validspawns) do
		for i, v in ipairs(ents.FindByClass(class)) do
			if IsValid(v) then
				table.insert(spawns, v)
			end
		end
	end

	-- A comment in TTT's code said you should only really spawn at info_player_starts if necessary because TF2 maps
	-- used them for observer spawn points, which means they can be bad at times.
	if #spawns == 0 then
		for i, v in ipairs(ents.FindByClass("info_player_start")) do
			if IsValid(v) then
				table.insert(spawns, v)
			end
		end
	end

	return spawns
end

--------------------------------------
-- TTT.MapHandler.GetRandomSpawnPoint
--------------------------------------
-- Desc:		Gets a random spawn point entity for the player that is safe to spawn at (E.g. nothing blocking it).
-- Returns:		Entity, the spawn point.
function TTT.MapHandler.GetRandomSpawnPoint()
	local spawnpoints = TTT.MapHandler.GetSpawnEntities()
	local spawn, index = table.RandomSequential(spawnpoints)
	table.remove(spawnpoints, index)
	
	-- TO DO: Add case for when no valid spawns are left.
	while (not TTT.MapHandler.WillPlayerFit(spawn:GetPos())) do
		spawn, index = table.RandomSequential(spawnpoints)
		table.remove(spawnpoints, index)
	end

	return spawn
end

------------------------------------------------
-- TTT.MapHandler.PutPlayerAtRandomSpawnPoint
------------------------------------------------
-- Desc:		Places a player at a random spawn point that is safe to spawn at. Does not call ply:Spawn() on the player.
-- Arg One:		Player, to to be placed at a random spawn point.
function TTT.MapHandler.PutPlayerAtRandomSpawnPoint(ply)
	local spawnpt = TTT.MapHandler.GetRandomSpawnPoint()
	ply:SetPos(spawnpt:GetPos())
end

local NotCollideable = {
	[COLLISION_GROUP_WEAPON] = true,
	[COLLISION_GROUP_DEBRIS] = true,
	[COLLISION_GROUP_DEBRIS_TRIGGER] = true,
	[COLLISION_GROUP_INTERACTIVE_DEBRIS] = true
}
----------------------------------
-- TTT.MapHandler.EntHasCollision
----------------------------------
-- Desc:		Says if an entity will collide with a player.
-- Arg One:		Entity, to see if it collides.
-- Returns:		Boolean, would this entity collide with a player.
function TTT.MapHandler.EntHasCollisionWithPlayers(ent)
	return not tobool(NotCollideable[ent:GetCollisionGroup()])
end

--------------------------------
-- TTT.MapHandler.WillPlayerFit
--------------------------------
-- Desc:		Sees if the given position has enough room to fit a player.
-- Arg One:		Vector, position they are trying to fit in.
-- Returns:		Boolean, true if they would fit, false otherwise.
function TTT.MapHandler.WillPlayerFit(pos)
	local tr = util.TraceHull{
		start = pos,
		endpos = pos,
		maxs = Vector(16, 16, 64),
		mins = Vector(-16, -16, 0),
		mask = MASK_SOLID
	}

	if tr.Hit and (tr.HitWorld or (tr.Entity and TTT.MapHandler.EntHasCollisionWithPlayers(tr.Entity))) then
		return false
	end

	return true
end