-- This is a small utility library loaded before the gamemode's library and used throughout the gamemode.
TTT = TTT or {}	-- Used for almost everything.

-- Thanks TTT.
TTT.Colors = {
	Dead		= Color(90, 90, 90, 230),
	Innocent	= Color(39, 174, 96, 230),
	Detective	= Color(41, 128, 185, 230),
	Traitor		= Color(192, 57, 43, 230),
	PunchYellow	= Color(205, 155, 0),

	White		= Color(255, 255, 255),
	Black		= Color(0, 0, 0),
	Green		= Color(0, 255, 0),
	DarkGreen	= Color(0, 100, 0),
	Red			= Color(255, 0, 0),
	Yellow		= Color(200, 200, 0),
	LightGray	= Color(200, 200, 200),
	Blue		= Color(0, 0, 255),
	Navy		= Color(0, 0, 100),
	Pink		= Color(255, 0, 255),
	Orange		= Color(250, 100, 0),
	Olive		= Color(100, 100, 0)
}

-------------------
-- net.WritePlayer
-------------------
-- Desc:		A more optimized version of net.WriteEntity specifically for players.
-- Arg One:		Player entity to be networked.
if not net.WritePlayer then
	function net.WritePlayer(ply)
		if IsValid(ply) then
			net.WriteUInt(ply:EntIndex(), 7)
		else
			net.WriteUInt(0, 7)
		end
	end
end

------------------
-- net.ReadPlayer
------------------
-- Desc:		Optimized version of net.ReadEntity specifically for players.
-- Returns:		Player entity thats been written.
if not net.ReadPlayer then
	function net.ReadPlayer()
		local i = net.ReadUInt(7)
		if not i then
			return
		end
		return Entity(i)
	end
end

----------------
-- table.Filter
----------------
-- CREDITS:		Copied from the dash library by SuperiorServers (https://github.com/SuperiorServers/dash)
-- Desc:		Will use the given function to filter out certain members from the given table. Edits the given table.
-- Arg One:		Table, to be filtered.
-- Arg Two:		Function, decides what should be filters.
-- Returns:		Table, same table as arg one but filtered.
function table.Filter(tab, func)
	local c = 1
	for i = 1, #tab do
		if func(tab[i]) then
			tab[c] = tab[i]
			c = c + 1
		end
	end
	for i = c, #tab do
		tab[i] = nil
	end
	return tab
end

--------------------
-- table.FilterCopy
--------------------
-- CREDITS:		Copied from the dash library by SuperiorServers (https://github.com/SuperiorServers/dash)
-- Desc:		Will use the given function to filter out certain members from the given table. Gives a new table that is a copy of the given table but filtered.
-- Arg One:		Table, to be filtered.
-- Arg Two:		Function, decides what should be filters.
-- Returns:		Table, same table as arg one but filtered.
function table.FilterCopy(tab, func)
	local ret = {}
	for i = 1, #tab do
		if func(tab[i]) then
			ret[#ret + 1] = tab[i]
		end
	end
	return ret
end

--------------------------
-- table.RandomSequential
--------------------------
-- Desc:		Returns a random value in a seqential table.
-- Returns:		1:	Any, value in the table.
-- 				2:	Number, where that value is found in the table.
function table.RandomSequential(tbl)
	local i = math.random(1, #tbl)
	return tbl[i], i
end

------------------
-- table.SortCopy
------------------
-- Desc:		Same as table.sort but returns a copy rather than modifying the original table.
-- Arg One:		Table, to be copied and then sorted.
-- Arg Two:		Function, to sort table by. Same setup as table.sort's second arguement.
-- Returns:		Table, sorted copy of the given table.
function table.SortCopy(original, sortFunc)
	local tbl = original
	table.sort(tbl, sortFunc)
	return tbl
end

-----------------
-- table.Shuffle
-----------------
-- Desc:		Shuffles a sequential table, straight copy from TTT.
-- Arg One:		Table, to be shuffled.
-- Returns:		Table, thats been shuffled.
function table.Shuffle(tbl)
	local n = #tbl

	while n > 2 do
		local k = math.random(n)
		tbl[n], tbl[k] = tbl[k], tbl[n]
		n = n - 1
	end

	return tbl
end

------------------
-- TTT.IsInMinMax
------------------
-- Desc:		Sees if a vector is inside of the given min and max.
-- Arg One:		Vector, vector to see if its in an area.
-- Arg Two:		Vector, Min.
-- Arg Three:	Vector, Max.
-- Returns:		Boolean, is the first vector between the min and max vectors.
function TTT.IsInMinMax(vec, mins, maxs)
	return (vec.x > mins.x and vec.x < maxs.x
		and vec.y > mins.y and vec.y < maxs.y
		and vec.z > mins.z and vec.z < maxs.z)
end

if CLIENT then
	-----------------------
	-- TTT.IsCoordOnScreen
	-----------------------
	-- Desc:		Sees if the given coordinates are on the players screen.
	-- Arg One:		Number, x coordinate.
	-- Arg Two:		Number, y coordinate.
	-- Returns:		Boolean, would the given coordinate pair appear on the player's screen.
	function TTT.IsCoordOnScreen(x, y)
		return x >= 0 and x <= ScrW() and y >= 0 and y <= ScrH()
	end
end