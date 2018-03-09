TTT.Scoreboard.PANEL = {
	BackgroundColor = Color(35, 35, 40, 220),
	MinWidth = 640,
	WidthMultiplier = 0.6,
	HeightMultiplier = 0.95,

	HeaderHeight = 120,
	GroupGap = 5,
	RightPadding = 5,
	RowHeight = 24,
	ScrollbarWidth = 16,
	ColumnLabelYPos = 88,
	ExtraButtonYOffset = 25,

	BarColor = Color(220, 100, 0, 255),
	BarYPos = 22,
	BarHeight = 32,

	Logo = surface.GetTextureID("vgui/ttt/score_logo"),
	LogoSize = 256,
	LogoOffset = 72,
	LogoWhitespace = 4,

	ColorActiveSortingText = Color(175, 175, 175, 255)
}

local sortType = CreateClientConVar("ttt_scoreboard_sorting", "name", false, false, "Set the sorting setting of the scoreboard. Run 'ttt_scoreboard_list_sorting' to view sorting types.")
local sortAscending = CreateClientConVar("ttt_scoreboard_sort_ascending", "1", false, false, "Sort with the numbers going up (ascending)?")


function TTT.Scoreboard.PANEL:Init()
	self:SetName("TTT.Scoreboard")
	self.header = vgui.Create("Panel", self)
	self.hostname = vgui.Create("DLabel", self.header)
	self.playingOn = vgui.Create("DLabel", self.header)
	self.SortBy = vgui.Create("DLabel", self.header)
	self.roundInfo = vgui.Create("DLabel", self.header)
	self.roundInfo.Think = function()
		self:SetText(TTT.Languages.GetPhrase("sb_roundinfo", TTT.Rounds.GetRoundsLeft(), TTT.Rounds.GetFormattedRemainingTime()))
		self:SizeToContents()
	end

	self:InitColumns()
	self:InitGroups()
	self:InitExtraSortingOptions()

	self:UpdateScoreboard()
	self:StartUpdateTimer()
end

function TTT.Scoreboard.PANEL:InitColumns()
	self.Columns = {}
	for i, colData in ipairs(TTT.Scoreboard.Columns) do
		self:AddColumn(colData)
	end
end

function TTT.Scoreboard.PANEL:AddColumn(columnData)
	local column = {
		ID = columnData.ID,
		Order = columnData.Order,
		Width = columnData.Width,
		ColumnDataFunction = columnData.ColumnDataFunction,
		SortFunction = columnData.SortFunction,
		DLabel = vgui.Create("DLabel", self.header)
	}
	column.DLabel:SetText(TTT.Languages.GetPhrase(columnData.Phrase))

	if columnData.SortFunction then
		column.DLabel:SetCursor("hand")
		column.DLabel:SetMouseInputEnabled(true)

		column.DLabel.DoClick = function()
			surface.PlaySound("ui/buttonclick.wav")

			-- If we are already sorted this way, clicking the label should just invert the list.
			if sortType:GetString() == columnData.ID then
				sortAscending:SetBool(not sortAscending:GetBool())
			else
				sortType:SetString(columnData.ID)
			end
			self:UpdateScoreboard()
			self:ApplySortingLabelSchemeSettings()
		end
	end

	table.insert(self.Columns, column)
end

function TTT.Scoreboard.PANEL:InitGroups()
	self.GroupScrollPanel = vgui.Create("DScrollPanel", self)
	self.Groups = {}
	for i, groupData in ipairs(TTT.Scoreboard.Groups) do
		self:AddGroup(groupData)
	end

	for _, group in ipairs(self.Groups) do
		for _, columnData in ipairs(self.Columns) do
			group:AddColumn(columnData)
		end
	end
end

function TTT.Scoreboard.PANEL:AddGroup(groupData)
	local group = vgui.Create("TTT.Scoreboard.Group", self.GroupScrollPanel)
	group:SetID(groupData.ID)
	group:SetTitle(TTT.Languages.GetPhrase(groupData.Phrase))
	group:SetTitleColor(groupData.Color)
	group:SetOrder(groupData.Order)
	group:SetPlayerChooserFunction(groupData.PlayerChooserFunction)
	group:SetupInfoPanel(groupData.InfoFunction)
	group:SetRowHeight(groupData.RowOpenHeight)

	table.insert(self.Groups, group)
	self.GroupScrollPanel:AddItem(group)
end

function TTT.Scoreboard.PANEL:InitExtraSortingOptions()
	self.ExtraSortingOptions = {}
	for i, sortOption in ipairs(TTT.Scoreboard.ExtraSortingOptions) do
		self:AddExtraSortingOption(sortOption)
	end
end

function TTT.Scoreboard.PANEL:AddExtraSortingOption(optionData)
	local option = {
		ID = optionData.ID,
		Order = optionData.Order,
		SortFunction = optionData.SortFunction,
		DLabel = vgui.Create("DLabel", self.header)
	}
	option.DLabel:SetText(TTT.Languages.GetPhrase(optionData.Phrase))
	option.DLabel:SizeToContents()
	option.DLabel:SetCursor("hand")
	option.DLabel:SetMouseInputEnabled(true)

	option.DLabel.DoClick = function()
		surface.PlaySound("ui/buttonclick.wav")
		
		-- If we are already sorted this way, clicking the label should just invert the list.
		if sortType:GetString() == optionData.ID then
			sortAscending:SetBool(not sortAscending:GetBool())
		else
			sortType:SetString(optionData.ID)
		end

		self:UpdateScoreboard()
		self:ApplySortingLabelSchemeSettings()
	end

	table.insert(self.ExtraSortingOptions, option)
end

function TTT.Scoreboard.PANEL:UpdateScoreboard()
	self:UpdateGroups()
	self:UpdateSorting()
end

function TTT.Scoreboard.PANEL:UpdateGroups()
	local changed = false

	for _, ply in ipairs(player.GetAll()) do
		for _, group in ipairs(self.Groups) do
			if not group:HasPlayer(ply) then
				if group.PlayerChooserFunction(ply) then
					group:AddPlayer(ply)
					changed = true
				end
			else
				if not group.PlayerChooserFunction(ply) then
					group:RemovePlayer(ply)
					changed = true
				end
			end

			for i = #group.ContainnedRows, 1, -1 do
				local row = group.ContainnedRows[i]
				if IsValid(row) then
					if not IsValid(row:GetPlayer()) then
						row:Remove()
						table.remove(group.ContainnedRows, i)
					else
						row.Name = row:GetPlayer():Nick()
					end
				end
			end
		end
	end

	for _, group in ipairs(self.Groups) do
		group:SetVisible(group:HasPlayers())
	end

	if changed then
		self:PerformLayout()
	else
		self:InvalidateLayout()
	end
end

function TTT.Scoreboard.PANEL:UpdateSorting()
	local sort = sortType:GetString()
	local sortFunction

	-- First check extra sort buttons.
	for i, v in ipairs(self.ExtraSortingOptions) do
		if sort == v.ID then
			sortFunction = v.SortFunction
		end
	end

	-- Next check the column sort buttons.
	if not isfunction(sortFunction) then
		for i, v in ipairs(self.Columns) do
			if v.ID == sort then
				sortFunction = v.SortFunction
			end
		end

		-- Fallback to sorting by names if all else fails.
		if not isfunction(sortFunction) then
			sortFunction = function(plyA, plyB)
				return 0
			end
		end
	end

	local ascend = sortAscending:GetBool()
	for i, group in ipairs(self.Groups) do
		table.sort(group.ContainnedRows, function(rowA, rowB)
			if not IsValid(rowA) then return false end
			if not IsValid(rowB) then return true end

			local plyA, plyB = rowA:GetPlayer(), rowB:GetPlayer()
			
			if not IsValid(plyA) then return false end
			if not IsValid(plyB) then return true end

			local comparison = sortFunction(plyA, plyB)
			local retVal = true

			if comparison ~= 0 then
				retVal = comparison > 0
			else
				retVal = string.lower(plyA:Nick()) > string.lower(plyB:Nick())
			end

			return retVal
		end)
		
		-- TTT instead just inverts retVal to switch between ascending and descending but that was yielding annoying and confusing results. Theres also no speed difference so don't nag me for doing this.
		if ascend then
			group.ContainnedRows = table.Reverse(group.ContainnedRows)
		end

		group:InvalidateLayout()
	end
end

function TTT.Scoreboard.PANEL:StartUpdateTimer()
	if timer.Exists("TTT.Scoreboard.Updater") then
		timer.Remove("TTT.Scoreboard.Updater")
	end

	timer.Create("TTT.Scoreboard.Updater", 0.3, 0, function()
		self:UpdateScoreboard()
	end)
end

function TTT.Scoreboard.PANEL:RemoveUpdateTimer()
	if timer.Exists("TTT.Scoreboard.Updater") then
		timer.Remove("TTT.Scoreboard.Updater")
	end
end

function TTT.Scoreboard.PANEL:OnRemove()
	self:RemoveUpdateTimer()
end

function TTT.Scoreboard.PANEL:IsScrollBarVisible()
	if IsValid(self.GroupScrollPanel) and IsValid(self.GroupScrollPanel:GetVBar()) then
		return self.GroupScrollPanel:GetVBar().Enabled or false
	end
	return false
end

function TTT.Scoreboard.PANEL:ApplySchemeSettings()
	self.hostname:SetFont("TTT_SBHeaderLarge")
	self.playingOn:SetFont("TTT_SBHeaderSmall")
	self.roundInfo:SetFont("TTT_SBHeaderSmall")
	self.SortBy:SetFont("TTT_SBHeaderSmall")

	self.hostname:SetTextColor(color_black)
	self.playingOn:SetTextColor(color_white)
	self.roundInfo:SetTextColor(color_white)
	self.SortBy:SetTextColor(color_white)

	self:ApplySortingLabelSchemeSettings()
end

function TTT.Scoreboard.PANEL:ApplySortingLabelSchemeSettings()
	local sortingType = sortType:GetString()
	for i, v in pairs(self.ExtraSortingOptions) do
		v.DLabel:SetFont("TTT_SBHeaderSmall")

		if v.ID == sortingType then
			v.DLabel:SetTextColor(self.ColorActiveSortingText)
		else
			v.DLabel:SetTextColor(color_white)
		end
	end

	for i, v in ipairs(self.Columns) do
		v.DLabel:SetFont("TTT_SBHeaderSmall")

		if v.ID == sortingType then
			v.DLabel:SetTextColor(self.ColorActiveSortingText)
		else
			v.DLabel:SetTextColor(color_white)
		end
	end
end

function TTT.Scoreboard.PANEL:Paint(w, h)
	-- Scoreboard background
	surface.SetDrawColor(self.BackgroundColor.r, self.BackgroundColor.g, self.BackgroundColor.b, self.BackgroundColor.a)
	surface.DrawRect(0, self.LogoOffset, w, h)

	-- Colored Bar
	surface.SetDrawColor(self.BarColor.r, self.BarColor.g, self.BarColor.b, self.BarColor.a)
	surface.DrawRect(0, self.LogoOffset + self.BarYPos, w, self.BarHeight)

	-- Logo
	surface.SetTexture(self.Logo)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, self.LogoSize, self.LogoSize)
end

function TTT.Scoreboard.PANEL:GetScoreboardWidth()
	return math.max(ScrW() * self.WidthMultiplier, self.MinWidth)
end

function TTT.Scoreboard.PANEL:PerformLayout()
	local w = self:GetScoreboardWidth()
	local h = self:GetTall()
	self:SetWide(w)
	self:SetPos(ScrW()/2 - w/2, math.min(72, (ScrH() - h)/4))

	self.header:SetSize(w, self.HeaderHeight)
	self.header:SetPos(0, self.LogoOffset)

	self.hostname:SetText(GetHostName())
	self.hostname:SizeToContents()
	self.hostname:SetPos(w - self.hostname:GetWide() - self.RightPadding, self.BarYPos/2 + self.BarHeight/2)

	self.playingOn:SetText(TTT.Languages.GetPhrase("sb_playingon"))
	self.playingOn:SizeToContents()
	self.playingOn:SetPos(w - self.playingOn:GetWide() - self.RightPadding, self.BarYPos/2 - self.playingOn:GetTall()/2)

	self.roundInfo:SetText(TTT.Languages.GetPhrase("sb_roundinfo", TTT.Rounds.GetRoundsLeft(), TTT.Rounds.GetFormattedRemainingTime()))
	self.roundInfo:SizeToContents()
	self.roundInfo:SetPos(w - self.roundInfo:GetWide() - self.RightPadding, self.BarYPos + self.BarHeight)

	-- Position the column header labels.
	local cur_x_offset = self.RowHeight
	for i, v in ipairs(self.Columns) do
		v.DLabel:SizeToContents()
		v.DLabel:SetPos(w - cur_x_offset - v.Width/2 - v.DLabel:GetWide()/2, self.ColumnLabelYPos)
		cur_x_offset = cur_x_offset + v.Width
	end

	-- Add extra sorting options.
	self.SortBy:SetText(TTT.Languages.GetPhrase("sb_sort_by")..":")
	self.SortBy:SizeToContents()
	self.SortBy:SetPos(self.LogoSize, self.ColumnLabelYPos - self.ExtraButtonYOffset)
	local space = 10
	local offset = self.SortBy:GetWide() + space
	for k, v in pairs(self.ExtraSortingOptions) do
		v.DLabel:SizeToContents()
		v.DLabel:SetPos(self.LogoSize + offset, self.ColumnLabelYPos - self.ExtraButtonYOffset)
		offset = offset + v.DLabel:GetWide() + space
	end

	local scrollpanel_y = self.LogoSize - self.LogoOffset - self.LogoWhitespace
	self.GroupScrollPanel:SetPos(0, scrollpanel_y)
	self.GroupScrollPanel:SetSize(w, ScrH() * self.HeightMultiplier - scrollpanel_y) -- Set to its max height so the scrollbar doesn't briefly appear whenever a player connects.

	-- Position the groups.
	local last_group_pos = 0	-- Relative pos of the last group height.
	for i, v in ipairs(self.Groups) do
		if v:HasPlayers() then
			v:SetVisible(true)
			v:SetPos(0, last_group_pos)
			v:SetWide(self.GroupScrollPanel:InnerWidth())
			v:SetContentAlignment(8)

			last_group_pos = last_group_pos + v:GetTall() + self.GroupGap
		else
			v:SetVisible(false)
		end
	end

	self:SetHeight(math.min(ScrH() * self.HeightMultiplier, scrollpanel_y + last_group_pos - self.GroupGap))
end
vgui.Register("TTT.Scoreboard", TTT.Scoreboard.PANEL, "DPanel")