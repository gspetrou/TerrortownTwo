local PANEL = {
	groupBG = Color(20, 20, 20, 190),		-- Color of the background of a group.
	lightRowBG = Color(75, 75, 75, 100),	-- Color of the light rows in a group.
	darkColBG = Color(0, 0, 0, 150)			-- Color of dark column background.
}

function PANEL:Init()
	self.ID = nil
	self.Title = nil
	self.TitleColor = nil
	self.Order = nil
	self.PlayerChooserFunction = nil
	self.InfoPanelFunction = nil
	self.RowHeight = nil
	self.ContainnedRows = {}
	self.Columns = {}
end

---------------
-- PANEL:SetID
---------------
-- Decs:		Sets the unique ID of the group.
-- Arg One:		String, unique ID.
function PANEL:SetID(id)
	self.ID = id
end

------------------
-- PANEL:SetTitle
------------------
-- Desc:		Sets the title of the group.
-- Arg One:		Strin,g title.
function PANEL:SetTitle(title)
	self.Title = title
end

-----------------------
-- PANEL:SetTitleColor
-----------------------
-- Desc:		Sets the group title color.
-- Arg One:		Color, of box behind the groups title.
function PANEL:SetTitleColor(color)
	self.TitleColor = color
end

------------------
-- PANEL:SetOrder
------------------
-- Desc:		Sets the order in which this group appears.
-- Arg One:		Number, order in which this group appears.
function PANEL:SetOrder(order)
	self.Order = order
end

----------------------------------
-- PANEL:SetPlayerChooserFunction
----------------------------------
-- Desc:		Sets the function used to determine what players should appear in this group.
-- Arg One:		Function
-- 					Arg One:		Player
-- 					Returns:		Boolean, should the given player appear in this group. Careful for conditions where the same player can appear in multiple groups..
function PANEL:SetPlayerChooserFunction(func)
	self.PlayerChooserFunction = func
end

------------------------
-- PANEL:SetupInfoPanel
------------------------
-- Desc:		Sets the function used to build the dropdown info panel.
-- Arg One:		Function
-- 					Arg One:		Player, this dropdown panel belongs to.
-- 					Arg Two:		Panel, TTT.Scoreboard.Row this dropdown belongs to.
-- 					Arg Three:		Panel, the dropdown panel to parent to.
-- 					Arg Four:		Number, width of the row/dropdown since doing row:GetSize() isn't yet accurate when this function is ran,
function PANEL:SetupInfoPanel(func)
	self.InfoPanelFunction = func
end


----------------------
-- PANEL:SetRowHeight
----------------------
-- Desc:		Sets the height of the group's dropdown panel.
-- Arg One:		Number, dropdown height.
function PANEL:SetRowHeight(height)
	self.RowHeight = height
end

--------------------
-- PANEL:ClearGroup
--------------------
-- Desc:		Clears the group of players.
function PANEL:ClearGroup()
	for i, v in ipairs(self.ContainnedRows) do
		v:Remove()
	end
	self.ContainnedRows = {}
end

-----------------------
-- PANEL:UpdatePlayers
-----------------------
-- Desc:		Updates what players should and shouldn't be in this group.
function PANEL:UpdatePlayers()
	self:ClearGroup()
	
	for i, ply in ipairs(player.GetAll()) do
		if self.PlayerChooserFunction(ply) then
			self:AddPlayer(ply)
		end
	end

	self:SetVisible(self:HasPlayers())
end

-------------------
-- PANEL:HasPlayer
-------------------
-- Desc:		Sees if the group has the given player.
-- Arg One:		Player
-- Returns:		Boolean, does this group contain the given player.
function PANEL:HasPlayer(ply)
	for i, v in ipairs(self.ContainnedRows) do
		if v:GetPlayer() == ply then
			return true
		end
	end
	return false
end

--------------------
-- PANEL:HasPlayers
--------------------
-- Desc:		Sees if this group has any players.
-- Returns:		Boolea, does this group have any players.
function PANEL:HasPlayers()
	return #self.ContainnedRows > 0
end

-------------------
-- PANEL:AddPlayer
-------------------
-- Desc:		Adds the given player to the group.
-- Arg One:		Player, to be added.
function PANEL:AddPlayer(ply)
	local row = vgui.Create("TTT.Scoreboard.Row", self)
	row:SetInfoPanelFunction(self.InfoPanelFunction)
	row:SetOpenHeight(self.RowHeight)
	row:SetOpen(false)
	row:SetPlayer(ply)
	row:SetContentAlignment(1)
	row:SetText("")	-- We're based off DLabel so we need to do this.
	row:SetMouseInputEnabled(true)

	for i, colData in ipairs(self.Columns) do
		row:AddColumn(colData)
	end

	row:SetupDropDownPanel()

	table.insert(self.ContainnedRows, row)
	self:InvalidateLayout(true)
end

----------------------
-- PANEL:RemovePlayer
----------------------
-- Desc:		Removes the given player from the group if they're in it.
-- Arg One:		Player, to remove from the group.
function PANEL:RemovePlayer(ply)
	for i, v in ipairs(self.ContainnedRows) do
		if v:GetPlayer() == ply then
			v:Remove()
			table.remove(self.ContainnedRows, i)	-- Short story: I spent probably 2 hours fucking with this scoreboard trying to figure out the root of an issue only to realize I forgot to include the second arguement here.
		end
	end
end

-------------------
-- PANEL:AddColumn
-------------------
-- Desc:		Adds a column to the group.
-- Arg One:		Table, column data.
function PANEL:AddColumn(columnData)
	table.insert(self.Columns, columnData)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(self.groupBG.r, self.groupBG.g, self.groupBG.b, self.groupBG.a)
	surface.DrawRect(0, 0, w, h)

	-- Give a dark background to every other column.
	surface.SetDrawColor(self.darkColBG.r, self.darkColBG.g, self.darkColBG.b, self.darkColBG.a)
	local offset = TTT.Scoreboard.PANEL.RowHeight	-- Width of mute player column is SB_ROW_HEIGHT.
	for i = 1, #self.Columns do
		local width = self.Columns[i].Width
		if i%2 == 1 then
			surface.DrawRect(w - width - offset, 0, width, h)
		end
		offset = offset + width
	end

	-- Give a light background to every other row.
	surface.SetDrawColor(self.lightRowBG.r, self.lightRowBG.g, self.lightRowBG.b, self.lightRowBG.a)
	local offset = TTT.Scoreboard.PANEL.RowHeight
	for i, v in ipairs(self.ContainnedRows) do
		if IsValid(v) then
			local pnlTall = v:GetTall()
			if i%2 == 1 then
				surface.DrawRect(0, offset, w, pnlTall)
			end
			offset = offset + pnlTall
		end
	end

	-- Draw the group label with shadow.
	surface.SetFont("TTT_SBBody")
	local text = self.Title.." ("..#self.ContainnedRows..")"
	local text_w, text_h = surface.GetTextSize(text)
	local text_y = TTT.Scoreboard.PANEL.RowHeight/2 - text_h/2

	-- Colors the background of the group label.
	local c = self.TitleColor
	surface.SetDrawColor(c.r, c.g, c.b, c.a)
	surface.DrawRect(0, 0, text_w + 10, TTT.Scoreboard.PANEL.RowHeight)

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
	self:SetWidth(self:GetParent():GetWide())

	local offset = TTT.Scoreboard.PANEL.RowHeight
	for i, row in ipairs(self.ContainnedRows) do
		if IsValid(row) then
			row:SetPos(0, offset)

			local newOff = row:GetTall()
			row:SetSize(self:GetWide(), newOff)
			offset = offset + newOff
		end
	end

	self:SetHeight(offset)
end
vgui.Register("TTT.Scoreboard.Group", PANEL, "Panel")