-- As with the old scoreboard, this scoreboard is divided into three parts.
-- The main scoreboard, groups that go into the scoreboard, and rows that go into the groups.
local PANEL = {}
local width_multiplier, height_multiplier = 0.6, 0.95	-- Multipliers for scoreboard width and height.
local bg = Color(35, 35, 40, 220)						-- Background color.
local bar_col = Color(220, 100, 0, 255)					-- Color for colored bar in header.
local bar_y, bar_h = 22, 32								-- Y pos and bar height for colored horizontal bar.
local header_height = 120								-- Height of the header panel header
local group_gap = 5										-- Gap between groups
local right_padding = 5									-- Padding on the right side of text that is aligned right on the scoreboard.

-- Logo
local logo = surface.GetTextureID("vgui/ttt/score_logo")
local logo_height = 256		-- Height of the logo image.
local logo_offset = 72		-- How much to offset entire scoreboard by. This many pixels of the logo will stick out.

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

function PANEL:Init()
	self.header = vgui.Create("Panel", self)
	self.hostname = vgui.Create("DLabel", self.header)
	self.playingOn = vgui.Create("DLabel", self.header)
	self.roundInfo = vgui.Create("DLabel", self.header)
	function self.roundInfo:Think()
		self:SetText(TTT.Languages.GetPhrase("sb_roundinfo", TTT.Rounds.GetRoundsLeft(), TTT.Rounds.GetFormattedRemainingTime()))
		self:SizeToContents()
	end

	self.GroupScrollPanel = vgui.Create("DScrollPanel", self)
	self.Groups = {}
	for i, groupData in ipairs(TTT.Scoreboard.Groups) do
		self:AddGroup(groupData)
	end

	self.Columns = {}
	for i, colData in ipairs(TTT.Scoreboard.Columns) do
		self:AddColumn(colData)
	end
end

function PANEL:Paint(w, h)
	-- Scoreboard background
	surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
	surface.DrawRect(0, logo_offset, w, h)

	-- Colored Bar
	surface.SetDrawColor(bar_col.r, bar_col.g, bar_col.b, bar_col.a)
	surface.DrawRect(0, logo_offset + bar_y, w, bar_h)

	-- Logo
	surface.SetTexture(logo)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, logo_height, logo_height)
end

function PANEL:PerformLayout(w, h)
	local width = math.max(ScrW() * width_multiplier, 640)
	local height = ScrH() * height_multiplier
	self:SetSize(width, height)
	self:SetPos(ScrW()/2 - w/2, ScrH()/2 - h/2)

	self.header:SetSize(w, header_height)
	self.header:SetPos(0, logo_offset)
	self.header:SetContentAlignment(8)

	self.hostname:SetText(GetHostName())
	self.hostname:SizeToContents()
	self.hostname:SetPos(w - self.hostname:GetWide() - right_padding, bar_y + 5)
	self.hostname:SetContentAlignment(8)

	self.playingOn:SetText(TTT.Languages.GetPhrase("sb_playingon"))
	self.playingOn:SizeToContents()
	self.playingOn:SetPos(w - self.playingOn:GetWide() - right_padding, 2)
	self.playingOn:SetContentAlignment(8)

	self.roundInfo:SetText(TTT.Languages.GetPhrase("sb_roundinfo", TTT.Rounds.GetRoundsLeft(), TTT.Rounds.GetFormattedRemainingTime()))
	self.roundInfo:SizeToContents()
	self.roundInfo:SetPos(w - self.roundInfo:GetWide() - right_padding, bar_y + bar_h)
	self.roundInfo:SetContentAlignment(8)

	self.GroupScrollPanel:SetPos(0, logo_height - logo_offset - 5)
	self.GroupScrollPanel:SetSize(w, h - (logo_height - logo_offset - 5))

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
end

function PANEL:ApplySchemeSettings()
	self.hostname:SetFont("cool_large")
	self.playingOn:SetFont("cool_small")
	self.roundInfo:SetFont("cool_small")

	self.hostname:SetTextColor(color_black)
	self.playingOn:SetTextColor(color_white)
	self.roundInfo:SetTextColor(color_white)
end

-- It would be better to not call this function directly and instead use TTT.Scoreboard.AddGroup in the TTT.Scoreboard.InitializeGroups hook.
function PANEL:AddGroup(data)
	local group = vgui.Create("TTT.Scoreboard.Group", self.GroupScrollPanel)
	group.ID = data.id
	group:SetLabel(data.label)
	group:SetOrder(data.order)
	group:SetSortingFunction(data.func)
	group:UpdatePlayers()	-- Adds all players that should be in this group.
	table.insert(self.Groups, group)
	self.GroupScrollPanel:AddItem(group)
end

function PANEL:UpdatePlayerData()
	for i, v in ipairs(self.Groups) do
		v:UpdatePlayers()
		v:InvalidateChildren()
	end
end

function PANEL:AddColumn(data)
	table.insert(self.Columns, data)
end
vgui.Register("TTT.Scoreboard", PANEL, "Panel")