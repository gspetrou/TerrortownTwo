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