local PANEL = {}
local SB_ROW_HEIGHT = 24
local group_bg = Color(20, 20, 20, 190)		-- Color of the background of a group.
local light_row_bg = Color(75, 75, 75, 100)	-- Color of the light rows in a group.
local dark_column_bg = Color(0, 0, 0, 150)	-- Color of the darker columns in the group.

function PANEL:Init()
	self:SetName("TTT.Scoreboard.Group")
	self.label = ""
	self.Columns = {}
	self.ContainnedRows = {}
	self.order = 0
	self.color = Color(255, 255, 255, 0)
	self.RowDoClickFunc = nil
	self.OpenRowHeight = 50
	self.SortingFunction = function() ErrorNoHalt("No sorting function set on TTT Scoreboard score group.\n") return false end
end

------------------
-- PANEL:SetLabel
------------------
-- Desc:		Sets the label on the top left of the group.
-- Arg One:		String, for the label.
function PANEL:SetLabel(text)
	self.label = text
end

------------------
-- PANEL:SetOrder
------------------
-- Desc:		Sets the order for the group to appear.
-- Arg One:		Number, for the order on the list of groups.
function PANEL:SetOrder(odr)
	self.order = odr
end

----------------------------
-- PANEL:SetSortingFunction
----------------------------
-- Desc:		Sets the function to sort out what players should be in this group.
-- Arg One:		Function, used by table.sort
-- 				Arg One:	Player, player A to be compared with player B.
-- 				Arg Two:	Player, player B to compare with A.
-- 				Returns:	Boolean, should A come before B.
function PANEL:SetSortingFunction(func)
	self.SortingFunction = func
end

-------------------------------
-- PANEL:SetRowDoClickFunction
-------------------------------
-- Desc:		Sets the function for this group's rows to be called on DoClick.
-- Arg One:		Function called on DoClick.
-- 				Arg One:	TTT.Scoreboard.Row panel for the current row.
-- 				Arg Two:	DPanel, info panel openned underneath row.
-- 				Arg Three:	Player, for the row.
function PANEL:SetRowDoClickFunction(fn)
	self.RowDoClickFunc = fn
end

-----------------------
-- PANEL:SetLabelColor
-----------------------
-- Desc:		Sets the label color of the group.
-- Arg One:		Color, for that label.
function PANEL:SetLabelColor(col)
	self.color = col
end

--------------------------
-- PANEL:SetRowOpenHeight
--------------------------
-- Desc:		Sets the height of the group's rows when they are open.
-- Arg One:		Number, for the row heights.
function PANEL:SetRowOpenHeight(h)
	self.OpenRowHeight = h
end

-------------------
-- PANEL:AddColumn
-------------------
-- Desc:		Registers a panel with the group.
-- Arg One:		Table, column data.
-- Note:		Dont call this directly, don't even make groups directly like this.
function PANEL:AddColumn(colData)
	table.insert(self.Columns, colData)
end

-------------------
-- PANEL:AddPlayer
-------------------
-- Desc:		Adds a row with the given player's information to the group.
-- Arg One:		Player, to add to group.
function PANEL:AddPlayer(ply)
	local row = vgui.Create("TTT.Scoreboard.Row", self)
	row:SetupDoClickFunction(self.RowDoClickFunc)
	row:SetOpenHeight(self.OpenRowHeight)
	row:SetPlayer(ply)
	row:SetContentAlignment(1)
	row:SetText("")	-- We're based off DLabel so we need to do this.
	row:SetMouseInputEnabled(true)

	for i, colData in ipairs(self.Columns) do
		row:AddColumn(colData)
	end

	table.insert(self.ContainnedRows, row)
end

-------------------
-- PANEL:HasPlayer
-------------------
-- Desc:		Does the group contain the given player.
-- Arg One:		Player, to see if the group has.
-- Returns:		Boolean, does this group have the given player.
function PANEL:HasPlayer(ply)
	for i, v in ipairs(self.ContainnedRows) do
		if v:GetPlayer() == v then
			return true
		end
	end
	return false
end

--------------------
-- PANEL:HasPlayers
--------------------
-- Desc:		Does the group have any players in it.
-- Returns:		Boolean
function PANEL:HasPlayers()
	return #self.ContainnedRows > 0
end

----------------------
-- PANEL:RemovePlayer
----------------------
-- Desc:		Removes the given player from the group.
-- Arg One:		Player, to remove from the scoreboard group.
function PANEL:RemovePlayer(ply)
	for i, v in ipairs(self.ContainnedRows) do
		if v:GetPlayer() == ply then
			v:Remove()
			table.remove(self.ContainnedRows)
		end
	end
end

-----------------------
-- PANEL:UpdatePlayers
-----------------------
-- Desc:		Updates the players in the group.
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

--------------------
-- PANEL:ClearGroup
--------------------
-- Desc:		Clears the group of all players.
function PANEL:ClearGroup()
	for i, v in ipairs(self.ContainnedRows) do
		v:Remove()
	end
	self.ContainnedRows = {}
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
	local offset = SB_ROW_HEIGHT
	for i, v in ipairs(self.ContainnedRows) do
		local pnlTall = v:GetTall()
		if i%2 == 1 then
			surface.DrawRect(0, offset, w, pnlTall)
		end
		offset = offset + pnlTall
	end

	-- Draw the group label with shadow.
	surface.SetFont("TTT_SBBody")
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

function PANEL:PerformLayout()
	local cur_width = self:GetWide()
	local parent_w = self:GetParent():GetWide()
	self:SetWidth(parent_w)

	local offset = SB_ROW_HEIGHT
	for i, v in ipairs(self.ContainnedRows) do
		v:SetPos(0, offset)

		local newOff = v:GetTall()
		v:SetSize(cur_width, newOff)
		offset = offset + newOff
	end

	self:SetHeight(offset)
end
vgui.Register("TTT.Scoreboard.Group", PANEL, "Panel")