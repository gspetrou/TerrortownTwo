TTT.Map = TTT.Map or {}

--------------------
-- TTT.Map.ResetMap
--------------------
-- Desc:		Resets the map to its original state and respawns players.
function TTT.Map.ResetMap()
	game.CleanUpMap()
	hook.Call("TTT.Map.OnReset")
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

	return table.Shuffle(spawns)
end

-------------------------------
-- TTT.Map.GetRandomSpawnPoint
-------------------------------
-- Desc:		Gets a random spawn point entity for the player that is safe to spawn at (E.g. nothing blocking it).
-- Returns:		Entity, the spawn point.
function TTT.Map.GetRandomSpawnPoint()
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
	if not IsValid(spawnEnt) then
		return {}
	end
	
	local pos = spawnEnt:GetPos()
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

------------------------
-- TTT.Map.CanSpawnHere
------------------------
-- Desc:		Determines if the given player can spawn at the given spawn.
-- Arg One:		Player, to see if they can spawn.
-- Arg Two:		Entity or vector, spawn point entity or position to test.
-- Arg Three:	Boolean, when checking this spot, should we kill whatever is in the way.
-- Return:		Boolean, can they spawn here.
function TTT.Map.CanSpawnHere(ply, spawn, force)
	if not IsValid(ply) or not ply:Alive() then
		return true
	end

	local spawnPos = type(spawn) == "Vector" and spawn or spawn:GetPos()
	if not util.IsInWorld(spawnPos) then
		return false
	end

	local blocking = ents.FindInBox(spawnPos + Vector(-16, -16, 0), spawnPos + Vector(16, 16, 64))
	for i, ply in ipairs(blocking) do
		if IsValid(ply) and ply:IsPlayer() and ply:Alive() then
			if force then
 				ply:Kill()
			else
				return false
			end
		end
	end
	return true
end

----------------------------
-- TTT.Map.SelectSpawnPoint
----------------------------
-- Desc:		Finds a suitable spawn point for the given player.
-- Arg One:		Player, to find a spawn for.
-- Returns:		Entity, spawn point entity.
function TTT.Map.SelectSpawnPoint(ply)
	local spawnEntities = TTT.Map.GetSpawnEntities()
	if #spawnEntities == 0 then
		error("No spawn entities found!")
		return
	end

	for i, spawn in ipairs(spawnEntities) do
		if GAMEMODE:IsSpawnpointSuitable(ply, spawn, false) then
			return spawn
		end
	end

	-- If we make it here then that means no spawns were found. Look for points around spawns.
	local foundSpawn
	for i, spawn in ipairs(spawnEntities) do
		foundSpawn = spawn
		local pointsAround = TTT.Map.PointsAroundSpawn(spawn)
		for j, point in ipairs(pointsAround) do
			if GAMEMODE:IsSpawnpointSuitable(ply, point, false) then
				local rigged_spawn = ents.Create("info_player_terrorist")
				if IsValid(rigged_spawn) then
					rigged_spawn:SetPos(point)
					rigged_spawn:Spawn()
					ErrorNoHalt("TTT WARNING: Map has too few spawn points, using a rigged spawn for ".. tostring(ply) .. "\n")
					return rigged_spawn
				end
			end
		end
	end

	-- Everything we tried failed. So lets try forcing a spawn.
	for i, spawn in ipairs(spawnEntities) do
		if GAMEMODE:IsSpawnpointSuitable(ply, spawn, true) then
			return spawn
		end
	end

	return foundSpawn -- Well... they're probably gonna be stuck.
end