TTT.Scoreboard = TTT.Scoreboard or {}
CreateConVar("ttt_scoreboard_highlight_admins", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Will admins be highlighted in the scoreboard.")

-----------------------------
-- TTT.Scoreboard.Initialize
-----------------------------
-- Desc:		Loads the panels, groups, columns, and extra sorting options.
-- Notice:		Rather than changing maps to test your new scoreboard stuff, just call this.
function TTT.Scoreboard.Initialize()
	TTT.Library.LoadOverridableFolder("library/scoreboard/panels/", "ttt/scoreboardpanels/", "client")

	if CLIENT then
		if IsValid(TTT.Scoreboard.Scoreboard) then
			TTT.Scoreboard.Scoreboard:Remove()
		end
		TTT.Scoreboard.Scoreboard = nil
		TTT.Scoreboard.Columns = {}
		TTT.Scoreboard.Groups = {}
		TTT.Scoreboard.ExtraSortingOptions = {}
		TTT.Scoreboard.Tags = {}

		hook.Call("TTT.Scoreboard.Initialize", nil)

		table.sort(TTT.Scoreboard.Groups, function(a, b) return a.Order < b.Order end)
		table.sort(TTT.Scoreboard.Columns, function(a, b) return a.Order > b.Order end)
		table.sort(TTT.Scoreboard.ExtraSortingOptions, function(a, b) return a.Order < b.Order end)
	end
end

if SERVER then	------------------------------------------
	return		-- Everything below here is clientside! --
end 			------------------------------------------




-- Scoreboard fonts.
surface.CreateFont("TTT_SBHeaderLarge", {
	font = "Coolvetica",
	size = 24,
	weight = 400
})
surface.CreateFont("TTT_SBHeaderSmall", {
	font = "Coolvetica",
	size = 20,
	weight = 400
})
surface.CreateFont("TTT_SBBody", {
	font = "Verdana",
	size = 16,
	weight = 900
})

-----------------------
-- TTT.Scoreboard.Open
-----------------------
-- Desc:		Opens the scoreboard.
function TTT.Scoreboard.Open()
	if IsValid(TTT.Scoreboard.Scoreboard) then
		TTT.Scoreboard.Scoreboard:SetVisible(true)
	else
		TTT.Scoreboard.Scoreboard = vgui.Create("TTT.Scoreboard")
	end
	gui.EnableScreenClicker(true)
end

------------------------
-- TTT.Scoreboard.Close
------------------------
-- Desc:		Closes the scoreboard if its open.
-- Arg One:		(Optional=nil) Boolean, if true will completely remove the scoreboard panel so it can be rebuilt later. Nil or false simply hide the scoreboard.
function TTT.Scoreboard.Close(forced)
	gui.EnableScreenClicker(false)
	if IsValid(TTT.Scoreboard.Scoreboard) then
		if forced then
			TTT.Scoreboard.Scoreboard:Remove()
			TTT.Scoreboard.Scoreboard = nil
		else
			TTT.Scoreboard.Scoreboard:SetVisible(false)
		end
	end
end

---------------------------
-- TTT.Scoreboard.GetPanel
---------------------------
-- Desc:		Gets the scoreboard panel if it exists.
-- Returns:		Panel or Boolean, scoreboard panel or false if it doesn't exist.
function TTT.Scoreboard.GetPanel()
	if IsValid(TTT.Scoreboard.Scoreboard) then
		return TTT.Scoreboard.Scoreboard
	end
	return false
end

----------------------------
-- TTT.Scoreboard.AddColumn
----------------------------
-- Desc:		Adds a column to the scoreboard.
-- Arg One:		String, unique id for the column. Used in a ConVar so keep it simple, no spaces or numbers.
-- Arg Two:		String, phrase for the column header label. If not a valid phrase, will not be translate and just appear as normal text.
-- Arg Three:	Number, width of the column.
-- Arg Four:	Number, order for the column. Smaller is more to the left. Larger is more to the right.
-- Arg Five:	Function, used to get data for the player in that column.
-- 					Arg One:		Player, of the row.
-- 					Returns:		String, to display for that player's row's column. Confusing, right?
-- Arg Six:		(Optional=nil) Function, used to sort the scoreboard by that column. nil disables sorting.
-- 					Arg One:		Player, A to be compared with B.
-- 					Arg Two:		Player, B to be compared with A.
-- 					Returns:		Number, greater than 0 means A before B, less than 0 means B before A. Returning 0 will sort by name.
function TTT.Scoreboard.AddColumn(id, phrase, width, order, columndatafunction, sortfunction)
	table.insert(TTT.Scoreboard.Columns, {
		ID = id,
		Phrase = phrase,
		Width = width,
		Order = order,
		ColumnDataFunction = columndatafunction,
		SortFunction = sortfunction
	})
end

---------------------------
-- TTT.Scoreboard.AddGroup
---------------------------
-- Desc:		Adds a group to the scoreboard.
-- Arg One:		String, unique id for the group. Keep it simple, no spaces or numbers.
-- Arg Two:		String, phrase for the group's title. If not a valid phrase, will not be translate and just appear as normal text.
-- Arg Three:	Color, for the background of the group's title.
-- Arg Four:	Number, order for the groups to appear. The larger, the further down.
-- Arg Five:	Function, to pick what players should be in this group.
-- 					Note:		Its very easy for players to appear in multiple groups if you don't do this right.
-- 					Arg One:	Player
-- 					Returns:	Boolean, should they appear in this group.
-- Arg Six:		(Optional=nil) Creates the dropdown panel when clicking on a row in the given group. nil to not have a dropdown menu.
-- Arg Seven:	(Optional=nil) Height of open dropdown panel. Can be nil if arg six is nil.
function TTT.Scoreboard.AddGroup(id, phrase, color, order, selectorfunction, infofunction, rowopenheight)
	table.insert(TTT.Scoreboard.Groups, {
		ID = id,
		Phrase = phrase,
		Color = color,
		Order = order,
		PlayerChooserFunction = selectorfunction,
		InfoFunction = infofunction,
		RowOpenHeight = rowopenheight
	})
end

----------------------------------------
-- TTT.Scoreboard.AddExtraSortingOption
----------------------------------------
-- Desc:		Adds an extra sorting button alongside "Sort By: Name  Color"
-- Arg One:		String, unique ID for this sorting option. Keep it simple, no spaces or numbers. Used in a ConVar.
-- Arg Two:		String, phrase, translated for the sorting option button. If not a valid phrase, will not be translate and just appear as normal text.
-- Arg Three:	Number, order of the button to appear. Larger is more rightmost.
-- Arg Four:	Function, to sort the scoreboard by.
-- 					Arg One:		Player, A to be compared with B.
-- 					Arg Two:		Player, B to be compared with A.
-- 					Returns:		Number, greater than 0 means A before B, less than 0 means B before A. Returning 0 will sort by name.
function TTT.Scoreboard.AddExtraSortingOption(id, phrase, order, sortfunction)
	table.insert(TTT.Scoreboard.ExtraSortingOptions, {
		ID = id,
		Phrase = phrase,
		Order = order,
		SortFunction = sortfunction
	})
end