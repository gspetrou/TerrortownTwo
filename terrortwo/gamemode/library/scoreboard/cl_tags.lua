TTT.Scoreboard = TTT.Scoreboard or {}

hook.Add("TTT.PostLibraryLoaded", "TTT.Scoreboard.Tags", function()
	TTT.Scoreboard.Tags = {}	-- This is done so that tags refresh on lua autorefresh.
end)

---------------------------
-- TTT.Scoreboard.DrawTags
---------------------------
-- Desc:		Used to draw the tag buttons on the row drop down panels.
-- Arg One:		TTT.Scoreboard.Row panel, for the row the player pressed to open.
-- Arg Two:		DPanel panel, the dropdown created by the scoreboard when clicking the row.
-- Arg Three:	Player, that the row belongs to.
-- Arg Four:	Number, width of the row and dpanel.
-- Arg Five:	Number, height of the dpanel.
-- Arg Six:		Number, height of the row.
function TTT.Scoreboard.DrawTags(row, infoPanel, ply, w, h, row_h)
	local btnContainner = vgui.Create("Panel", infoPanel)
	btnContainner:DockPadding(0, 5, 0, 5)
	for i, data in ipairs(TTT.Scoreboard.Tags) do
		local btn = vgui.Create("DButton", btnContainner)
		btn:SetFont("treb_small")
		btn:SetTextColor(data.color)
		btn:SetText(TTT.Languages.GetPhrase(data.phrase))
		btn:DockMargin(5, 0, 5, 0)
		btn:Dock(LEFT)
		btn:SetMouseInputEnabled(true)
		function btn:DoClick()
			local curdata = TTT.Scoreboard.GetTag(ply)
			if istable(curdata) and curdata.index == i then
				TTT.Scoreboard.ClearTag(ply)
			else
				TTT.Scoreboard.SetPlayerTag(ply, i)
			end
		end
		function btn:Paint()
			local tagdata = TTT.Scoreboard.GetTag(ply)
			if istable(tagdata) and tagdata.index == i then
				surface.SetDrawColor(255, 200, 0, 255)
				surface.DrawOutlinedRect(0, 0, btn:GetWide(), btn:GetTall())
			end
		end
	end
	btnContainner:SetSize(400, h)
	btnContainner:SetPos(w/2 - btnContainner:GetWide()/2, h/2 - btnContainner:GetTall()/2)
end

--------------------------
-- TTT.Scoreboard.AddTags
--------------------------
-- Desc:		Registers a new tag for the scoreboard.
-- Arg One:		String, phrase or text of the tag.
-- Arg Two:		Color, for the tag text.
function TTT.Scoreboard.AddTag(ph, col)
	local i = table.insert(TTT.Scoreboard.Tags, {
		phrase = ph,
		color = col
	})
	TTT.Scoreboard.Tags[i].index = i
end

-------------------------------
-- TTT.Scoreboard.SetPlayerTag
-------------------------------
-- Desc:		Sets the tag of the player via a given index.
-- Arg One:		Player, to set the tag on.
-- Arg Two:		Number, index of the tag to give.
function TTT.Scoreboard.SetPlayerTag(ply, index)
	ply.ttt_sb_tagindex = index
end

-------------------------
-- TTT.Scoreboard.GetTag
-------------------------
-- Desc:		Gets the tag data table of the player's current tag.
-- Arg One:		Player
-- Returns:		Table, {index=num, phrase=string, color=col}
function TTT.Scoreboard.GetTag(ply)
	return ply.ttt_sb_tagindex and TTT.Scoreboard.Tags[ply.ttt_sb_tagindex] or false
end

---------------------------
-- TTT.Scoreboard.ClearTag
---------------------------
-- Desc:		Removes any tag from the player.
-- Arg One:		Player
function TTT.Scoreboard.ClearTag(ply)
	ply.ttt_sb_tagindex = nil
end
