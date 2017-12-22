CreateConVar("ttt_scoreboard_highlight_admins", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Will admins be highlighted in the scoreboard.")
if SERVER then do return end end

TTT.Scoreboard = TTT.Scoreboard or {}
TTT.Scoreboard.Columns = TTT.Scoreboard.Columns or {}
TTT.Scoreboard.Groups = TTT.Scoreboard.Groups or {}
TTT.Scoreboard.ExtraSortingOptions = TTT.Scoreboard.ExtraSortingOptions or {}

concommand.Add("ttt_scoreboard_list_sorting", function()
	Msg("Sorting options are as listed: name role ")
	for i, v in ipairs(TTT.Scoreboard.Columns) do
		if isfunction(v.sortFunc) then
			Msg(v.id.." ")
		end
	end
	Msg("\n")
end)

surface.CreateFont("cool_large", {
	font = "coolvetica",
	size = 24,
	weight = 400
})
surface.CreateFont("cool_small", {
	font = "coolvetica",
	size = 20,
	weight = 400
})
surface.CreateFont("treb_small", {
	font = "Trebuchet18",
	size = 14,
	weight = 700
})

-- I've been dreading writing this module since I started this project. Here we go...

function TTT.Scoreboard.Initialize()
	TTT.Scoreboard.Columns = {}
	TTT.Scoreboard.Groups = {}
	TTT.Scoreboard.ExtraSortingOptions = {}

	hook.Call("TTT.Scoreboard.InitializeItems", nil, self)

	table.sort(TTT.Scoreboard.Groups, function(a, b) return a.order < b.order end)
	table.sort(TTT.Scoreboard.Columns, function(a, b) return a.order > b.order end)
	table.sort(TTT.Scoreboard.ExtraSortingOptions, function(a, b) return a.order < b.order end)
end

-----------------------
-- TTT.Scoreboard.Open
-----------------------
-- Desc:		Opens the scoreboard for the client.
function TTT.Scoreboard.Open()
	if IsValid(TTT.Scoreboard.Scoreboard) then
		TTT.Scoreboard.Scoreboard:Remove()
	end
	TTT.Scoreboard.Scoreboard = vgui.Create("TTT.Scoreboard")
	gui.EnableScreenClicker(true)	-- We could use PANEL.MakePopup instead but you can start walking with the scoreboard open this way.
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
-- Arg Six:		(Optional) Function, used to sort the players by this specific column. If set to nil or false, this row won't be sortable.
-- 				Arg One:	Player A, to sort.
-- 				Arg Two:	Player B, to compare with player A for sorting.
-- 				Return:		Boolean, should player A come before player B.
function TTT.Scoreboard.AddColumn(col_id, lbl_id, wth, ordr, fn, sortFn)
	table.insert(TTT.Scoreboard.Columns, {
		id = col_id,
		label = lbl_id,
		width = wth or 50,
		order = ordr or 0,	-- Anything 0 or less means we don't care.
		func = fn,
		sortFunc = sortFn or false
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
-- Arg Four:	(Optional) Color, for the header of the group. Transparent if left blank.
-- Arg Five:	Function, used to decide what players should be listed under this group.
-- 				Arg One: 	Player
-- 				Return:		Boolean, should they be displayed in this group.
function TTT.Scoreboard.AddGroup(group_id, lbl_id, ordr, col, fn, rowDoClick)
	table.insert(TTT.Scoreboard.Groups, {
		id = group_id,
		label = lbl_id,
		order = ordr or 0,	-- Anything 0 or less means we don't care.
		color = col or Color(255, 255, 255, 0),
		func = fn,
		rowDoClickFunc = rowDoClick
	})
end

function TTT.Scoreboard.AddExtraSortingOption(sort_id, phr, ordr, sorter)
	table.insert(TTT.Scoreboard.ExtraSortingOptions, {
		id = sort_id,
		phrase = phr,
		order = ordr,
		sortFunc = sorter
	})
end