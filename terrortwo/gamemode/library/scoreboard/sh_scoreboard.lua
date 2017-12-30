-- I've been dreading writing this module since I started this project. Here we go...
TTT.Scoreboard = TTT.Scoreboard or {}
CreateConVar("ttt_scoreboard_highlight_admins", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Will admins be highlighted in the scoreboard.")

-----------------------------
-- TTT.Scoreboard.Initialize
-----------------------------
-- Desc:		Loads the panels, groups, columns, and extra sorting options.
-- Notice:		Rather than changing maps to test your new scoreboard stuff, just call this.
function TTT.Scoreboard.Initialize()
	-- Load files in addons/library/scoreboard/panels.
	local path = "library/scoreboard/panels/"
	local loadedfiles = {}
	local files, _ = file.Find(path.."*.lua", "LUA")
	for i, v in ipairs(files) do
		if SERVER then
			AddCSLuaFile(path..v)
		else
			include(path..v)
		end
		loadedfiles[v] = true
	end

	-- Now load files in terrortwo/gamemode/ibrary/scoreboard/panels and if there
	-- is a file with the same name as a file in the addons folder then skip over it.
	path = GAMEMODE.FolderName.."/gamemode/library/scoreboard/panels/"
	files, _ = file.Find(path.."*.lua", "LUA")
	for i, v in ipairs(files) do
		if not loadedfiles[v] then
			if SERVER then
				AddCSLuaFile(path..v)
			else
				include(path..v)
			end
			loadedfiles[v] = true
		end
	end

	if CLIENT then
		TTT.Scoreboard.Columns = {}
		TTT.Scoreboard.Groups = {}
		TTT.Scoreboard.ExtraSortingOptions = {}

		hook.Call("TTT.Scoreboard.Initialize", nil)

		table.sort(TTT.Scoreboard.Groups, function(a, b) return a.order < b.order end)
		table.sort(TTT.Scoreboard.Columns, function(a, b) return a.order > b.order end)
		table.sort(TTT.Scoreboard.ExtraSortingOptions, function(a, b) return a.order < b.order end)
	end
end



if SERVER then do return end end



-- Prints all available sorting options.
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
-- 				Arg One:				Player
-- 				Return 1:				Number/String to display for that player in that column. If nil the text will be "".
-- 				Return 2 (Optional):	Color, color to show that column text in. If nil the text will be white.
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
-- Arg Six:		(Optional) Function, called when the row is left clicked to display more info. If nil, left clicking wont do anything.
-- 				Arg One:	TTT.Scoreboard.Row panel, of the pressed row.
-- 				Arg Two:	DPanel, for the info area openned underneath,
-- 				Arg Three:	Player, that this row belongs to.
-- 				Arg Four:	Number, width of arg two and the row its on.	-- NOTE: The width and height of arg one and arg two are incorrect at this point which is why I've provided the following arguements.
-- 				Arg Five:	Number, height of arg two.
-- 				Arg Six:	Number, height of arg one.
-- Arg Seven:	(Optional) Number, height of the info panel openned when left-clicking a row. Default is 100.
function TTT.Scoreboard.AddGroup(group_id, lbl_id, ordr, col, fn, rowDoClick, oH)
	table.insert(TTT.Scoreboard.Groups, {
		id = group_id,
		label = lbl_id,
		order = ordr or 0,	-- Anything 0 or less means we don't care.
		color = col or Color(255, 255, 255, 0),
		func = fn,
		rowDoClickFunc = rowDoClick,
		openHeight = oH or 100
	})
end

----------------------------------------
-- TTT.Scoreboard.AddExtraSortingOption
----------------------------------------
-- Desc:		Adds extra buttons to sort the scoreboard by, Next to the Sort By: Name and Role buttons.
-- Arg One:		String, unique ID to refer to this button.
-- Arg Two:		String, phrase to be translated or plain text for the button if no phrase is found.
-- Arg Three:	Number, order in which this button will appear. Lesser is more to the left.
-- Arg Four:	Function, used in table.sort to sort the players by.
-- 				Arg One:	Player, to be compare with the other player.
-- 				Arg Two:	To be compared with the arg one player.
-- 				Return:		Boolean, should the player in arg one come before the player for arg two.
function TTT.Scoreboard.AddExtraSortingOption(sort_id, phr, ordr, sorter)
	table.insert(TTT.Scoreboard.ExtraSortingOptions, {
		id = sort_id,
		phrase = phr,
		order = ordr,
		sortFunc = sorter
	})
end