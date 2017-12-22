-- As with the old scoreboard, this scoreboard is divided into three parts.
-- The main scoreboard, groups that go into the scoreboard, and rows that go into the groups.
local PANEL = {}
local width_multiplier, height_multiplier = 0.6, 0.95	-- Multipliers for scoreboard width and height.
local col_bg = Color(35, 35, 40, 220)					-- Background color.
local col_bar = Color(220, 100, 0, 255)					-- Color for colored bar in header.
local bar_pos_y, bar_pos_h = 22, 32						-- Y pos and bar height for colored horizontal bar.
local header_height = 120								-- Height of the header panel header
local group_gap = 5										-- Gap between groups
local right_padding = 5									-- Padding on the right side of text that is aligned right on the scoreboard.
local SB_ROW_HEIGHT = 24								-- Height of each row. If you want to change this you'll have to change it in all the other scoreboard files as well.
local scrollbar_w = 16									-- This is a constant.
local sb_min_width = 640								-- Minimum width of the scoreboard.
local column_label_y = 88								-- The Y position of all the column header labels.
local col_active_sort = Color(175, 175, 175, 255)		-- Color for the label of the active sorting setting.

-- Logo
local logo = surface.GetTextureID("vgui/ttt/score_logo")
local logo_size = 256		-- Width/Height of the logo image.
local logo_offset = 72		-- How much to offset entire scoreboard by. This many pixels of the logo will stick out.
local logo_whitespace = 4	-- Theres four pixels of nothingness at the bottom of the TTT logo.

local sortType = CreateClientConVar("ttt_scoreboard_sorting", "name", false, false, "Set the sorting setting of the scoreboard. Run 'ttt_scoreboard_list_sorting' to view sorting types.")
local sortAscending = CreateClientConVar("ttt_scoreboard_sort_ascending", "1", false, false, "Sort with the numbers going up (ascending)?")

function PANEL:Init()
	self.header = vgui.Create("Panel", self)
	self.hostname = vgui.Create("DLabel", self.header)
	self.playingOn = vgui.Create("DLabel", self.header)
	self.SortBy = vgui.Create("DLabel", self.header)
	self.roundInfo = vgui.Create("DLabel", self.header)
	self.roundInfo.Think = function()
		self:SetText(TTT.Languages.GetPhrase("sb_roundinfo", TTT.Rounds.GetRoundsLeft(), TTT.Rounds.GetFormattedRemainingTime()))
		self:SizeToContents()
	end

	self.GroupScrollPanel = vgui.Create("DScrollPanel", self)
	self.GroupScrollPanel.pnlCanvas.PerformLayout = function() end	-- Ill handle you, pal.
	self.Groups = {}
	for i, groupData in ipairs(TTT.Scoreboard.Groups) do
		self:AddGroup(groupData)
	end

	self.Columns = {}
	for i, colData in ipairs(TTT.Scoreboard.Columns) do
		self:SetupColumn(colData)
	end

	-- Add the Sort By: Name and Role buttons.
	self.ExtraSortButtons = {}
	for i, sortOption in ipairs(TTT.Scoreboard.ExtraSortingOptions) do
		self:AddExtraSortingOption(sortOption)
	end

	for _, group in ipairs(self.Groups) do
		for _, columnData in ipairs(self.Columns) do
			group:AddColumn(columnData)
		end
	end

	self:UpdateScoreboard()	-- Populate the groups and then sort them.
	self:StartUpdateTimer()	-- Start a timer to update the scoreboard info while its open.
end

function PANEL:Paint(w, h)
	-- Scoreboard background
	surface.SetDrawColor(col_bg.r, col_bg.g, col_bg.b, col_bg.a)
	surface.DrawRect(0, logo_offset, w, h)

	-- Colored Bar
	surface.SetDrawColor(col_bar.r, col_bar.g, col_bar.b, col_bar.a)
	surface.DrawRect(0, logo_offset + bar_pos_y, w, bar_pos_h)

	-- Logo
	surface.SetTexture(logo)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, logo_size, logo_size)
end

function PANEL:IsScrollBarVisible()
	if IsValid(self.GroupScrollPanel) and IsValid(self.GroupScrollPanel:GetVBar()) then
		return self.GroupScrollPanel:GetVBar().Enabled or false
	end
	return false
end

function PANEL:PerformLayout(w, h)
	self:SetWide(math.max(ScrW() * width_multiplier, sb_min_width))
	self:SetPos(ScrW()/2 - w/2, math.min(72, (ScrH() - h)/4))

	self.header:SetSize(w, header_height)
	self.header:SetPos(0, logo_offset)
	self.header:SetContentAlignment(8)

	self.hostname:SetText(GetHostName())
	self.hostname:SizeToContents()
	self.hostname:SetPos(w - self.hostname:GetWide() - right_padding, bar_pos_y/2 + bar_pos_h/2)
	self.hostname:SetContentAlignment(8)

	self.playingOn:SetText(TTT.Languages.GetPhrase("sb_playingon"))
	self.playingOn:SizeToContents()
	self.playingOn:SetPos(w - self.playingOn:GetWide() - right_padding, bar_pos_y/2 - self.playingOn:GetTall()/2)
	self.playingOn:SetContentAlignment(8)

	self.roundInfo:SetText(TTT.Languages.GetPhrase("sb_roundinfo", TTT.Rounds.GetRoundsLeft(), TTT.Rounds.GetFormattedRemainingTime()))
	self.roundInfo:SizeToContents()
	self.roundInfo:SetPos(w - self.roundInfo:GetWide() - right_padding, bar_pos_y + bar_pos_h)
	self.roundInfo:SetContentAlignment(8)

	-- Position the column header labels.
	local cur_x_offset = SB_ROW_HEIGHT + (self:IsScrollBarVisible() and scrollbar_w or 0)	-- SB_ROW_HEIGHT is the width of the mute button section.
	for i, v in ipairs(self.Columns) do
		v.labelPanel:SizeToContents()
		v.labelPanel:SetPos(w - cur_x_offset - v.width/2 - v.labelPanel:GetWide()/2, column_label_y)
		cur_x_offset = cur_x_offset + v.width
	end

	-- Add extra sorting options.
	self.SortBy:SetText(TTT.Languages.GetPhrase("sb_sort_by")..":")
	self.SortBy:SizeToContents()
	self.SortBy:SetPos(logo_size, column_label_y)
	local space = 10
	local offset = self.SortBy:GetWide() + space
	for k, v in pairs(self.ExtraSortButtons) do
		v:SizeToContents()
		v:SetPos(logo_size + offset, column_label_y)
		offset = offset + v:GetWide() + space
	end

	local scrollpanel_y = logo_size - logo_offset - logo_whitespace
	self.GroupScrollPanel:SetPos(0, scrollpanel_y)
	self.GroupScrollPanel:SetSize(w, h - scrollpanel_y)

	-- Position the groups.
	local last_group_pos = 0	-- Relative pos of the last group height. Minus 5 because some extra image whitespace.
	for i, v in ipairs(self.Groups) do
		if v:HasPlayers() then
			v:SetVisible(true)
			v:SetPos(0, last_group_pos)
			v:SetContentAlignment(8)

			last_group_pos = last_group_pos + v:GetTall() + group_gap
		else
			v:SetVisible(false)
		end
	end

	self:SetHeight(math.min(ScrH() * height_multiplier, scrollpanel_y + last_group_pos - group_gap))
end

function PANEL:ApplySchemeSettings()
	self.hostname:SetFont("cool_large")
	self.playingOn:SetFont("cool_small")
	self.roundInfo:SetFont("cool_small")
	self.SortBy:SetFont("cool_small")

	self.hostname:SetTextColor(color_black)
	self.playingOn:SetTextColor(color_white)
	self.roundInfo:SetTextColor(color_white)
	self.SortBy:SetTextColor(color_white)

	self:ApplySortingLabelSchemeSettings()
end

function PANEL:ApplySortingLabelSchemeSettings()
	local sortingType = sortType:GetString()
	for i, v in pairs(self.ExtraSortButtons) do
		v:SetFont("cool_small")

		if v.id == sortingType then
			v:SetTextColor(col_active_sort)
		else
			v:SetTextColor(color_white)
		end
	end

	for i, v in ipairs(self.Columns) do
		v.labelPanel:SetFont("cool_small")

		if v.id == sortingType then
			v.labelPanel:SetTextColor(col_active_sort)
		else
			v.labelPanel:SetTextColor(color_white)
		end
	end
end

-- It would be better to not call this function directly and instead use TTT.Scoreboard.AddGroup in the TTT.Scoreboard.InitializeGroups hook.
function PANEL:AddGroup(data)
	local group = vgui.Create("TTT.Scoreboard.Group", self.GroupScrollPanel)
	group.ID = data.id
	group:SetLabel(TTT.Languages.GetPhrase(data.label))
	group:SetOrder(data.order)
	group:SetLabelColor(data.color)
	group:SetSortingFunction(data.func)
	group:SetRowDoClickFunction(data.rowDoClickFunc)
	table.insert(self.Groups, group)
	self.GroupScrollPanel:AddItem(group)
end

-- Creates the column header label and sets up for sorting.
function PANEL:SetupColumn(data)
	local col_label = vgui.Create("DLabel", self.header)
	col_label:SetText(TTT.Languages.GetPhrase(data.label))

	if data.sortFunc then
		col_label:SetCursor("hand")
		col_label:SetMouseInputEnabled(true)

		col_label.DoClick = function()
			surface.PlaySound("ui/buttonclick.wav")

			-- If we are already sorted this way, clicking the label should just invert the list.
			if sortType:GetString() == data.id then
				sortAscending:SetBool(not sortAscending:GetBool())
			else
				sortType:SetString(data.id)
			end
			self:UpdateSorting()
			self:ApplySortingLabelSchemeSettings()
		end
	end

	data.labelPanel = col_label
	table.insert(self.Columns, data)
end

function PANEL:AddExtraSortingOption(data)
	local label = vgui.Create("DLabel", self.header)
	label:SetText(TTT.Languages.GetPhrase(data.phrase))
	label:SizeToContents()
	label:SetCursor("hand")
	label:SetMouseInputEnabled(true)
	label.sorter = data.SortFunc
	label.id = data.id
	label.DoClick = function()
		surface.PlaySound("ui/buttonclick.wav")

		-- If we are already sorted this way, clicking the label should just invert the list.
		if sortType:GetString() == data.id then
			sortAscending:SetBool(not sortAscending:GetBool())
		else
			sortType:SetString(data.id)
		end
		self:UpdateSorting()
		self:ApplySortingLabelSchemeSettings()
	end
	table.insert(self.ExtraSortButtons, label)
end

function PANEL:StartUpdateTimer()
	if timer.Exists("TTT.Scoreboard.Updater") then
		timer.Remove("TTT.Scoreboard.Updater")
	end

	timer.Create("TTT.Scoreboard.Updater", 0.3, 0, function()
		self:UpdateScoreboard()
	end)
end

function PANEL:RemoveUpdateTimer()
	if timer.Exists("TTT.Scoreboard.Updater") then
		timer.Remove("TTT.Scoreboard.Updater")
	end
end

function PANEL:OnRemove()
	self:RemoveUpdateTimer()
end

function PANEL:UpdateGroupData()
	for i, group in ipairs(self.Groups) do
		group:UpdatePlayers()
	end
end

-- Updates the sorting to the current sorting type.
function PANEL:UpdateSorting()
	local sort = sortType:GetString()
	local sortFunction

	-- First check extra sort buttons.
	for i, v in ipairs(self.ExtraSortButtons) do
		if sort == v.id then
			sortFunction = v.sorter
		end
	end

	-- Next check the column sort buttons.
	if not isfunction(sortFunction) then
		for i, v in ipairs(self.Columns) do
			if v.id == sort then
				sortFunction = v.sortFunc
			end
		end

		-- Fallback to sorting by names if all else fails.
		if not isfunction(sortFunction) then
			sortFunction = function(plyA, plyB)
				return string.lower(plyA:Nick()) > string.lower(plyB:Nick())
			end
		end
	end

	local ascend = sortAscending:GetBool()
	for i, group in ipairs(self.Groups) do
		table.sort(group.ContainnedRows, function(rowA, rowB)
			local plyA, plyB = rowA:GetPlayer(), rowB:GetPlayer()
			local retVal = sortFunction(plyB, plyA)
			if not isbool(retVal) then
				error("Non-boolean value returned for TTT Scoreboard sorting option with ID of '".. sort .."'")
			end

			if ascend then
				return retVal
			end
			return not retVal
		end)
	end
end

function PANEL:UpdateScoreboard()
	self:UpdateGroupData()
	self:UpdateSorting()
	self:InvalidateLayout()
end
vgui.Register("TTT.Scoreboard", PANEL, "Panel")