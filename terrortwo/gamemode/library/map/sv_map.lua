TTT.Map = TTT.Map or {}

--------------------
-- TTT.Map.ResetMap
--------------------
-- Desc:		Resets the map to its original state and respawns players.
function TTT.Map.ResetMap()
	game.CleanUpMap()
	local plys = TTT.Roles.GetNotSpectators()
	for i, v in ipairs(plys) do
		if v.ttt_inflymode then
			v:UnSpectate()
		end

		v:Spawn()
	end
end

-- NOTICE:	A decent amount of the spawning and placement code below was adapted
--			from the original TTT. Credits to Bad King Urgrain and whoever else helped.

----------------------------
-- TTT.Map.GetSpawnEntities
----------------------------
-- Desc:		Returns a table of all spawn entities.
-- Returns:		Table, just read the damn description.
TTT.Map.PlayerSpawnEntities = {		-- Table taken from original TTT code.
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
function TTT.Map.GetSpawnEntities()
	local spawns = {}
	for _, class in ipairs(TTT.Map.PlayerSpawnEntities) do
		for i, v in ipairs(ents.FindByClass(class)) do
			if IsValid(v) then
				table.insert(spawns, v)
			end
		end
	end

	-- A comment in TTT's code said you should only really spawn at info_player_starts if necessary because TF2 maps
	-- used them for observer spawn points, which means they can be in bad positions at times.
	if #spawns == 0 then
		for i, v in ipairs(ents.FindByClass("info_player_start")) do
			if IsValid(v) then
				table.insert(spawns, v)
			end
		end
	end

	math.randomseed(os.time())
	return table.Shuffle(spawns)
end

-------------------------------
-- TTT.Map.GetRandomSpawnPoint
-------------------------------
-- Desc:		Gets a random spawn point entity for the player that is safe to spawn at (E.g. nothing blocking it).
-- Returns:		Entity, the spawn point.
function TTT.Map.GetRandomSpawnPoint()
	math.randomseed(os.time())

	local spawnpoints = TTT.Map.GetSpawnEntities()
	local spawn, index = table.RandomSequential(spawnpoints)
	table.remove(spawnpoints, index)
	
	-- TODO: Add case for when no valid spawns are left.
	while (not TTT.Map.WillPlayerFit(spawn:GetPos())) do
		spawn, index = table.RandomSequential(spawnpoints)
		table.remove(spawnpoints, index)
	end

	return spawn
end

---------------------------------------
-- TTT.Map.PutPlayerAtRandomSpawnPoint
---------------------------------------
-- Desc:		Places a player at a random spawn point that is safe to spawn at. Does not call ply:Spawn() on the player.
-- Arg One:		Player, to to be placed at a random spawn point.
function TTT.Map.PutPlayerAtRandomSpawnPoint(ply)
	local spawnpt = TTT.Map.GetRandomSpawnPoint()
	ply:SetPos(spawnpt:GetPos())
end

local NotCollideable = {
	[COLLISION_GROUP_WEAPON] = true,
	[COLLISION_GROUP_DEBRIS] = true,
	[COLLISION_GROUP_DEBRIS_TRIGGER] = true,
	[COLLISION_GROUP_INTERACTIVE_DEBRIS] = true
}
---------------------------
-- TTT.Map.EntHasCollision
---------------------------
-- Desc:		Says if an entity will collide with a player.
-- Arg One:		Entity, to see if it collides.
-- Returns:		Boolean, would this entity collide with a player.
function TTT.Map.EntHasCollisionWithPlayers(ent)
	return not tobool(NotCollideable[ent:GetCollisionGroup()])
end

-------------------------
-- TTT.Map.WillPlayerFit
-------------------------
-- Desc:		Sees if the given position has enough room to fit a player.
-- Arg One:		Vector, position they are trying to fit in.
-- Returns:		Boolean, true if they would fit, false otherwise.
function TTT.Map.WillPlayerFit(pos)
	local tr = util.TraceHull{
		start = pos,
		endpos = pos,
		maxs = Vector(16, 16, 64),
		mins = Vector(-16, -16, 0),
		mask = MASK_SOLID
	}

	if tr.Hit and (tr.HitWorld or (tr.Entity and TTT.Map.EntHasCollisionWithPlayers(tr.Entity))) then
		return false
	end

	return true
end

-----------------------------
-- TTT.Map.PointsAroundSpawn
-----------------------------
-- Desc:		Gets a bunch of points around a spawn entity. Straight copy from TTT.
-- Arg One:		Entity, spawn entity to look around.
-- Returns:		Table, of vectors of positions.
function TTT.Map.PointsAroundSpawn(spawnEnt)
	if not IsValid(spwn) then
		return {}
	end
	
	local pos = spwn:GetPos()
	local w, h = 36, 72 -- bit roomier than player hull

	return {
		pos + Vector(w,  0,  0),
		pos + Vector(0,  w,  0),
		pos + Vector(w,  w,  0),
		pos + Vector(-w,  0,  0),
		pos + Vector(0, -w,  0),
		pos + Vector(-w, -w,  0),
		pos + Vector(-w,  w,  0),
		pos + Vector(w, -w,  0)
	}
end