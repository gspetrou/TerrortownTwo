local PANEL = {}
local SB_ROW_HEIGHT = 24

function PANEL:Init()
	self.label = vgui.Create("DLabel", self)
	self.ContainnedRows = {}
	self.order = 0
	self.SortingFunction = function() ErrorNoHalt("No sorting function set on TTT Scoreboard score group.\n") return false end
end

function PANEL:SetLabel(text)
	self.label:SetText(text)
end

function PANEL:SetOrder(odr)
	self.order = odr
end

function PANEL:SetSortingFunction(func)
	self.SortingFunction = func
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
	row:SetLighter(#self.ContainnedRows%2 == 0)	-- Make all even rows lighter.
	table.insert(self.ContainnedRows, row)
	self:InvalidateLayout()
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
	self:InvalidateLayout()
end

function PANEL:UpdatePlayers()
	-- Its faster to remove everyone and then re-add the players this group applies to
	self:ClearGroup()
	
	for i, v in ipairs(player.GetAll()) do
		if self.SortingFunction(v) then
			self:AddPlayer(v)
		end
	end
end

function PANEL:ClearGroup()
	for i, v in ipairs(self.ContainnedRows) do
		v:Remove()
		table.remove(self.ContainnedRows)
	end
	self:InvalidateLayout()
end

function PANEL:HasPlayers()
	return #self.ContainnedRows > 0
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(35, 35, 40, 220)
	surface.DrawRect(0, 0, w, h)

--	surface.SetDrawColor(255, 0, 0)
--	surface.DrawRect(0, 0, 70, SB_ROW_HEIGHT)
end

function PANEL:PerformLayout(w, h)
	self:SetWidth(self:GetParent():GetWide())

	self.label:SizeToContents()
	self.label:DockMargin(5, 5, 5, 5)
	self.label:Dock(TOP)

	for i, v in ipairs(self.ContainnedRows) do
		v:SetPos(0, SB_ROW_HEIGHT*i)
		v:SetSize(w, SB_ROW_HEIGHT)
	end

	self:SetHeight((#self.ContainnedRows+1) * SB_ROW_HEIGHT)
end
vgui.Register("TTT.Scoreboard.Group", PANEL, "Panel")