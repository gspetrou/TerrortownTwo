TTT.Scoreboard = TTT.Scoreboard or {}
TTT.Scoreboard.Columns = TTT.Scoreboard.Columns or {}
TTT.Scoreboard.Groups = TTT.Scoreboard.Groups or {}
TTT.Scoreboard.RowHeight = 24

-- I've been dreading writing this module since I started this project. Here we go...

function TTT.Scoreboard.Initialize()
	hook.Call("TTT.Scoreboard.InitializeColumns", nil, self)
	hook.Call("TTT.Scoreboard.InitializeGroups", nil, self)

	table.sort(TTT.Scoreboard.Groups, function(a, b) return a.order < b.order end)
	table.sort(TTT.Scoreboard.Columns, function(a, b) return a.order < b.order end)
end

-----------------------
-- TTT.Scoreboard.Open
-----------------------
-- Desc:		Opens the scoreboard for the client.
function TTT.Scoreboard.Open()
	gui.EnableScreenClicker(true)
	TTT.Scoreboard.Scoreboard = vgui.Create("TTT.Scoreboard")
end

-----------------------
-- TTT.Scoreboard.Open
-----------------------
-- Desc:		Closes the scoreboard if its open.
function TTT.Scoreboard.Close()
	gui.EnableScreenClicker(false)
	if IsValid(TTT.Scoreboard.Scoreboard) then
		TTT.Scoreboard.Scoreboard:Remove()
	end
end

---------------------------
-- TTT.Scoreboard.GetPanel
---------------------------
-- Desc:	Gets the parent scoreboard panel, or false if the panel is invalid.
-- Returns:	Panel or Boolean. False if scoreboard is invalid, panel otherwise.
function TTT.Scoreboard.GetPanel()
	return IsValid(TTT.Scoreboard.Scoreboard) and TTT.Scoreboard.Scoreboard or false
end

----------------------------
-- TTT.Scoreboard.AddColumn
----------------------------
-- Desc:		Adds a new info column to the scoreboard.
-- Arg One:		String, unique ID to identify that column later when calling the TTT.Scoreboard.InitializeColumns hook.
-- Arg Two:		String, language phrase that will be translated into the user's langauge. Label of the column.
-- Arg Three:	(Optional) Number, width of the column. Defaults to 50 pixels if none is specified.
-- Arg Four:	(Optional) Number, order this should show up. 1 means left most, anything bigger moves more to the right.
-- 				If this arg is nil or is a number that is 0 or less it will just be tacked on at the end.
-- Arg Five:	Function, used to obtain the data to display for the player in that column.
-- 				Arg One:	Player
-- 				Return:		Number/String to display for that player in that column.
function TTT.Scoreboard.AddColumn(col_id, lbl_id, wth, ordr, fn)
	table.insert(TTT.Scoreboard.Columns, {
		id = col_id,
		label = TTT.Languages.GetPhrase(lbl_id),
		width = wth or 50,
		order = ordr or 0,	-- Anything 0 or less means we don't care.
		func = fn
	})
end

---------------------------
-- TTT.Scoreboard.AddGroup
---------------------------
-- Desc:		Adds a score group to the scoreboard.
-- Arg One:		String, unique ID to identify that group later when calling the TTT.Scoreboard.InitializeGroups hook.
-- Arg Two:		String, language phrase that will be translated into the user's langauge. Label of the group.
-- Arg Three:	(Optional) Number, order this should show up. 1 means top most, anything bigger moves more to the bottom.
-- 				If this arg is nil or is a number that is 0 or less it will just be tacked on at the bottom.
-- Arg Four:	Function, used to decide what players should be listed under this group.
-- 				Arg One: 	Player
-- 				Return:		Boolean, should they be displayed in this group.
function TTT.Scoreboard.AddGroup(group_id, lbl_id, ordr, fn)
	table.insert(TTT.Scoreboard.Groups, {
		id = group_id,
		label = TTT.Languages.GetPhrase(lbl_id),
		order = ordr or 0,	-- Anything 0 or less means we don't care.
		func = fn
	})
end