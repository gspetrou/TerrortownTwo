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

if SERVER then
	return
end

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

function TTT.Scoreboard.Open()
	if IsValid(TTT.Scoreboard.Scoreboard) then
		TTT.Scoreboard.Scoreboard:SetVisible(true)
	else
		TTT.Scoreboard.Scoreboard = vgui.Create("TTT.Scoreboard")
	end
	gui.EnableScreenClicker(true)	-- We could use PANEL.MakePopup instead but you can start walking with the scoreboard open this way.
end

function TTT.Scoreboard.Close()
	gui.EnableScreenClicker(false)
	if IsValid(TTT.Scoreboard.Scoreboard) then
		--TTT.Scoreboard.Scoreboard:Remove()
		TTT.Scoreboard.Scoreboard:SetVisible(false)
	end
end

function TTT.Scoreboard.GetPanel()
	if IsValid(TTT.Scoreboard.Scoreboard) then
		return TTT.Scoreboard.Scoreboard
	end
	return false
end

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

function TTT.Scoreboard.AddExtraSortingOption(id, phrase, order, sortfunction)
	table.insert(TTT.Scoreboard.ExtraSortingOptions, {
		ID = id,
		Phrase = phrase,
		Order = order,
		SortFunction = sortfunction
	})
end