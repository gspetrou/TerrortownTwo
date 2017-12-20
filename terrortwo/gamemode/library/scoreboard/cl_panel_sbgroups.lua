local PANEL = {}
local SB_ROW_HEIGHT = 24
local group_bg = Color(20, 20, 20, 190)		-- Color of the background of a group.
local light_row_bg = Color(75, 75, 75, 100)	-- Color of the light rows in a group.
local dark_column_bg = Color(0, 0, 0, 150)	-- Color of the darker columns in the group.

function PANEL:Init()
	self.label = ""
	self.Columns = {}
	self.ContainnedRows = {}
	self.order = 0
	self.color = Color(255, 255, 255, 0)
	self.SortingFunction = function() ErrorNoHalt("No sorting function set on TTT Scoreboard score group.\n") return false end
end

function PANEL:SetLabel(text)
	self.label = text
end

function PANEL:SetOrder(odr)
	self.order = odr
end

function PANEL:SetSortingFunction(func)
	self.SortingFunction = func
end

function PANEL:SetLabelColor(col)
	self.color = col
end

-------------------
-- PANEL:AddPlayer
-------------------
-- Desc:		Adds a row with the given player's information to the group.
-- Arg One:		Player, to add to group.
function PANEL:AddPlayer(ply)
	local row = vgui.Create("TTT.Scoreboard.Row", self)
	row:SetPlayer(ply)
	row:SetContentAlignment(1)

	for i, colData in ipairs(self.Columns) do
		row:AddColumn(colData)
	end

	table.insert(self.ContainnedRows, row)
end

function PANEL:HasPlayer(ply)
	for i, v in ipairs(self.ContainnedRows) do
		if v:GetPlayer() == v then
			return true
		end
	end
	return false
end

function PANEL:RemovePlayer(ply)
	for i, v in ipairs(self.ContainnedRows) do
		if v:GetPlayer() == ply then
			v:Remove()
			table.remove(self.ContainnedRows)
		end
	end
end

function PANEL:UpdatePlayers()
	-- Its faster to remove everyone and then re-add the players this group applies to
	self:ClearGroup()
	
	for i, v in ipairs(player.GetAll()) do
		if self.SortingFunction(v) then
			self:AddPlayer(v)
		end
	end

	if not self:IsVisible() then
		if #self.ContainnedRows > 0 then
			self:SetVisible(true)
		end
	elseif #self.ContainnedRows < 0 then
		self:SetVisible(false)
	end
end

function PANEL:ClearGroup()
	for i, v in ipairs(self.ContainnedRows) do
		v:Remove()
	end
	self.ContainnedRows = {}
end

function PANEL:HasPlayers()
	return #self.ContainnedRows > 0
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(group_bg.r, group_bg.g, group_bg.b, group_bg.a)
	surface.DrawRect(0, 0, w, h)

	-- Give a dark background to every other column.
	surface.SetDrawColor(dark_column_bg.r, dark_column_bg.g, dark_column_bg.b, dark_column_bg.a)
	local offset = SB_ROW_HEIGHT	-- Width of mute player column is SB_ROW_HEIGHT.
	for i = 1, #self.Columns - 1, 2 do
		local width = self.Columns[i].width
		surface.DrawRect(w - width - offset, 0, width, h)
		offset = offset + width + self.Columns[i+1].width
	end	

	-- Give a light background to every other row.
	surface.SetDrawColor(light_row_bg.r, light_row_bg.g, light_row_bg.b, light_row_bg.a)
	for i = 1, #self.ContainnedRows, 2 do
		surface.DrawRect(0, SB_ROW_HEIGHT*i, w, SB_ROW_HEIGHT)
	end

	-- Draw the group label with shadow.
	surface.SetFont("treb_small")
	local text = self.label.." ("..#self.ContainnedRows..")"
	local text_w, text_h = surface.GetTextSize(text)
	local text_y = SB_ROW_HEIGHT/2 - text_h/2

	-- Colors the background of the group label.
	local c = self.color
	surface.SetDrawColor(c.r, c.g, c.b, c.a)
	surface.DrawRect(0, 0, text_w + 10, SB_ROW_HEIGHT)

	-- Draw label shadow.
	surface.SetTextPos(6, text_y + 1)
	surface.SetTextColor(0, 0, 0, 255)
	surface.DrawText(text)

	-- Draw label colored.
	surface.SetTextPos(5, text_y)
	surface.SetTextColor(255, 255, 255, 255)
	surface.DrawText(text)
end

function PANEL:PerformLayout(w, h)
	self:SetWidth(self:GetParent():GetWide())

	for i, v in ipairs(self.ContainnedRows) do
		v:SetPos(0, SB_ROW_HEIGHT*i)
		v:SetSize(w, SB_ROW_HEIGHT)
	end

	self:SetHeight((#self.ContainnedRows+1) * SB_ROW_HEIGHT)
end

function PANEL:AddColumn(colData)
	table.insert(self.Columns, colData)
end
vgui.Register("TTT.Scoreboard.Group", PANEL, "Panel")