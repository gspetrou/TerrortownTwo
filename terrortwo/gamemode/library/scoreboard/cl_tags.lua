TTT.Scoreboard = TTT.Scoreboard or {}
TTT.Scoreboard.Tags = TTT.Scoreboard.Tags or {
	TagWidth = 60
}

---------------------------
-- TTT.Scoreboard.DrawTags
---------------------------
-- Desc:		Draws the player's tags on their row and adds the dropdown menu for it.
-- Arg One:		Player, for that row.
-- Arg Two:		Panel, TTT.Scoreboard.Row panel of that player's row.
-- Arg Three:	Panel, the dropdown panel you can parent to.
-- Arg Four:	Number, width of the dropdown panel. Given since row:GetWide() isn't set when this function gets called.
function TTT.Scoreboard.DrawTags(ply, row, openPanel, width)
	-- First calculate how much space is taken up by columns and the mute button.
	local columnWidths = 16
	for i, v in ipairs(row.Columns) do
		columnWidths = columnWidths + v.Width
	end

	-- Add a helper function to get the tag text for the player.
	local function getTagText()
		local tagdata = TTT.Scoreboard.GetTag(ply)
		if ply:Alive() and tagdata then
			return TTT.Languages.GetPhrase(tagdata.phrase), tagdata.color
		end
		return "", color_white
	end
	
	-- Create our label tag.
	local tagText = vgui.Create("DLabel", row)
	tagText:SetFont("TTT_SBBody")
	function tagText:Update()
		local text, col = getTagText()
		self:SetText(text)
		self:SetColor(col)

		surface.SetFont("TTT_SBBody")
		local t_w, t_h = surface.GetTextSize(text)
		self:SetPos(width - columnWidths - TTT.Scoreboard.Tags.TagWidth - t_w/2, TTT.Scoreboard.PANEL.RowHeight/2 - t_h/2)
	end
	tagText:Update()


	timer.Create("TTT.Scoreboard.UpdateTag", 0.3, 0, function()
		if IsValid(ply) then
			tagText:Update()
		else
			timer.Remove("TTT.Scoreboard.UpdateTag")
		end
	end)

	function tagText:OnRemove()
		timer.Remove("TTT.Scoreboard.UpdateTag")
	end

	local btnContainner = vgui.Create("Panel", openPanel)
	btnContainner:DockPadding(0, 5, 0, 5)
	for i, data in ipairs(TTT.Scoreboard.Tags) do
		local btn = vgui.Create("DButton", btnContainner)
		btn:SetFont("TTT_SBBody")
		btn:SetTextColor(data.color)
		btn:SetText(TTT.Languages.GetPhrase(data.phrase))
		btn:DockMargin(5, 0, 5, 0)
		btn:Dock(LEFT)
		btn:SetMouseInputEnabled(true)
		function btn:DoClick()
			local curdata = TTT.Scoreboard.GetTag(ply)
			if istable(curdata) and curdata.index == i then
				TTT.Scoreboard.ClearTag(ply)
				tagText:Update()
			else
				TTT.Scoreboard.SetPlayerTag(ply, i)
				tagText:Update()
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
	btnContainner:SetSize(400, openPanel:GetTall())
	btnContainner:SetPos(width/2 - btnContainner:GetWide()/2, openPanel:GetTall()/2 - btnContainner:GetTall()/2)
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
