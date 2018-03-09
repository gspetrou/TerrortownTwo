local PANEL = {
	RowHeight = 24,
	NameColors = {
		default = color_white,
		admin = Color(220, 100, 0, 255),
		dev = Color(100, 240, 105, 255)
	},
	RoleColors = {
		traitor = Color(255, 0, 0, 30),
		detective = Color(0, 0, 255, 30)
	}
}

function PANEL:Init()
	self:SetName("TTT.Scoreboard.Row")
	self.Columns = {}
	self.Name = ""
	self.Player = nil
	self.isopen = false
	self.InfoPanelFunction = nil	-- Function for building the dropdown panel.
	self.OpenHeight = nil
	self.Player = nil

	self.Avatar = vgui.Create("AvatarImage", self)	-- Make our avatar
	self.AvatarButton = vgui.Create("Button", self)	-- Make an invisible button on top of the avatar for openning that player's steam page.
	self.AvatarButton:SetMouseInputEnabled(true)
	self.AvatarButton:SetText("")
	self.AvatarButton.Paint = function() end
	self.AvatarButton.DoClick = function()
		local ply = self:GetPlayer()
		if IsValid(ply) and ply:IsPlayer() then
			ply:ShowProfile()
		end
	end

	self.MuteButton = vgui.Create("DImageButton", self)
	self.MuteButton:SetMouseInputEnabled(true)
	self.MuteButton.DoClick = function()
		local ply = self:GetPlayer()
		if IsValid(ply) then
			ply:SetMuted(not ply:IsMuted())
		end
		self:PerformLayout()
	end
end

-- For the dropdown menu.
function PANEL:DoClick()
	local ply = self:GetPlayer()
	if isfunction(self.InfoPanelFunction) and IsValid(TTT.Scoreboard.Scoreboard) and IsValid(ply) and ply ~= LocalPlayer() then
		local isOpen = self:IsOpen()
		self:SetOpen(not isOpen)

		if isOpen then
			surface.PlaySound("ui/buttonclickrelease.wav")
			self.OpenPanel:SetVisible(false)
		else
			surface.PlaySound("ui/buttonclick.wav")
			self.OpenPanel:SetVisible(true)
		end

		self:PerformLayout()
		self:GetParent():PerformLayout()
		TTT.Scoreboard.Scoreboard:PerformLayout()
	end
end

-- For the right-click DMenu menu.
function PANEL:DoRightClick()
	local dmenu = DermaMenu()
	local shouldCloseMenu = hook.Call("TTT.Scoreboard.PlayerRightClicked", nil, dmenu, self:GetPlayer())
	if shouldCloseMenu then
		demnu:Remove()
	else
		dmenu:Open()
	end
end

----------------
-- PANEL:IsOpen
----------------
-- Desc:		Sees if the dropdown panel is open/visible.
-- Returns:		Boolean, is that dropdown visible.
function PANEL:IsOpen()
	return self.isopen
end

-----------------
-- PANEL:SetOpen
-----------------
-- Desc:		Sets the dropdown panebl to be open/closed.
-- Arg One:		Boolean, should open or close.
function PANEL:SetOpen(b)
	self.isopen = b
	if IsValid(self:GetPlayer()) then
		self:GetPlayer():SetScoreboardRowOpen(b)
	end
	self:InvalidateLayout(true)
end

-----------------------
-- PANEL:SetOpenHeight
-----------------------
-- Desc:		Sets the height of the dropdown panel when its open.
-- Arg One:		Number, of dropdown panel's height.
function PANEL:SetOpenHeight(h)
	self.OpenHeight = h
end

------------------------------
-- PANEL:SetInfoPanelFunction
------------------------------
-- Desc:		Function called when creating the dropdown panel. Don't call directly, instead use with TTT.Scoreboard.AddGroup.
-- Arg One:		Function, to build dropdown panel.
function PANEL:SetInfoPanelFunction(func)
	self.InfoPanelFunction = func
end

----------------------------
-- PANEL:SetupDropDownPanel
----------------------------
-- Desc:		Builds the dropdown panel for the row.
function PANEL:SetupDropDownPanel()
	local ply = self:GetPlayer()
	if not IsValid(ply) then
		return
	end
	
	if IsValid(self.OpenPanel) then self.OpenPanel:Remove() end
	if self.InfoPanelFunction then
		self:InvalidateParent(true)
		self.OpenPanel = vgui.Create("DPanel", self)
		self.OpenPanel:SetMouseInputEnabled(true)
		self.OpenPanel:SetVisible(false)
		self.OpenPanel.Paint = function() end
		self.OpenPanel:SetTall(self.OpenHeight)
		self.InfoPanelFunction(ply, self, self.OpenPanel, TTT.Scoreboard.PANEL:GetScoreboardWidth())
	end

	if ply:GetScoreboardRowOpen() then
		self:SetOpen(true)
		if IsValid(self.OpenPanel) then
			self.OpenPanel:SetVisible(true)
		end
	end
end

-------------------
-- PANEL:SetPlayer
-------------------
-- Desc:		Sets the player that this row will be used for.
-- Arg One:		Player, to set the row for.
function PANEL:SetPlayer(ply)
	self.Player = ply
	self.Avatar:SetPlayer(ply, 32)
	self.Name = ply:Nick()
end

-------------------
-- PAMEL:GetPlayer
-------------------
-- Desc:		Gets the player that this row is for.
function PANEL:GetPlayer()
	return self.Player
end

-------------------
-- PANEL:AddColumn
-------------------
-- Desc:		Adds a column to the row
-- Arg One:		Table, column data.
function PANEL:AddColumn(colData)
	table.insert(self.Columns, colData)
end

----------------------
-- PANEL:GetNameColor
----------------------
-- Desc:		Gets what should be the player's name color for that row.
-- Returns:		Color, for their name.
function PANEL:GetNameColor()
	local ply = self:GetPlayer()
	if not IsValid(ply) then	-- Probably have bigger problems if this is the case but whatever.
		return self.NameColors.default
	end

	local col = hook.Call("TTT.Scoreboard.PlayerNameColor", nil, ply)
	if IsColor(col) then
		return col
	end

	if ply:SteamID() == "STEAM_0:0:1963640" or ply:SteamID() == "STEAM_0:1:18093014" then 		-- Badking or Stalker.
		return self.NameColors.dev
	elseif ply:IsAdmin() and GetConVar("ttt_scoreboard_highlight_admins"):GetBool() then
		return self.NameColors.admin
	end

	return self.NameColors.default
end

function PANEL:Paint(w, h)
	local ply = self:GetPlayer()
	if not IsValid(ply) then return end

	-- Make Detectives and Traitors the color of their role.
	if ply:IsTraitor() then
		local c = self.RoleColors.traitor
		surface.SetDrawColor(c.r, c.g, c.b, c.a)
		surface.DrawRect(0, 0, w, h)
	elseif ply:IsDetective() then
		local c = self.RoleColors.detective
		surface.SetDrawColor(c.r, c.g, c.b, c.a)
		surface.DrawRect(0, 0, w, h)
	end

	-- Make our own row glow.
	if ply == LocalPlayer() then
		surface.SetDrawColor(200, 200, 200, math.Clamp(math.sin(RealTime() * 2) * 50, 0, 100))
		surface.DrawRect(0, 0, w, h)
	end

	-- Draw their name with a shadow.
	local name_col = self:GetNameColor()
	local _, name_h = surface.GetTextSize(self.Name)
	local name_y = TTT.Scoreboard.PANEL.RowHeight/2 - name_h/2
	surface.SetFont("TTT_SBBody")

	-- Name shadow
	surface.SetTextColor(0, 0, 0, 255)
	surface.SetTextPos(TTT.Scoreboard.PANEL.RowHeight + 6, name_y + 1)
	surface.DrawText(self.Name)
	-- Name Colored
	surface.SetTextColor(name_col.r, name_col.g, name_col.b, name_col.a)
	surface.SetTextPos(TTT.Scoreboard.PANEL.RowHeight + 5, name_y)
	surface.DrawText(self.Name)

	-- We really don't need a DLabel for each column data entry. Instead, lets just use the surface library.
	surface.SetTextColor(255, 255, 255, 255)
	local offset = TTT.Scoreboard.PANEL.RowHeight	-- Offset by TTT.Scoreboard.PANEL.RowHeight since the mute button column is TTT.Scoreboard.PANEL.RowHeight width.
	for i, column in ipairs(self.Columns) do
		local text, col = column.ColumnDataFunction(ply)
		text = text == nil and "" or tostring(text)
		if col then
			surface.SetTextColor(col.r, col.g, col.b, col.a)
		end

		local text_w, text_h = surface.GetTextSize(text)
		surface.SetTextPos(w - offset - column.Width/2 - text_w/2, TTT.Scoreboard.PANEL.RowHeight/2 - text_h/2)
		surface.DrawText(text)
		offset = offset + column.Width
		surface.SetTextColor(255, 255, 255, 255)
	end
end

function PANEL:PerformLayout()
	local w  = self:GetWide()
	if IsValid(self.OpenPanel) and self:IsOpen() then
		self:SetSize(w, TTT.Scoreboard.PANEL.RowHeight + self.OpenPanel:GetTall())
		self.OpenPanel:SetPos(0, TTT.Scoreboard.PANEL.RowHeight)
		self.OpenPanel:SetSize(w, self.OpenPanel:GetTall())
	else
		self:SetSize(w, TTT.Scoreboard.PANEL.RowHeight)
	end

	self.Avatar:SetPos(0, 0)
	self.Avatar:SetSize(TTT.Scoreboard.PANEL.RowHeight, TTT.Scoreboard.PANEL.RowHeight)
	self.AvatarButton:SetPos(0, 0)
	self.AvatarButton:SetSize(TTT.Scoreboard.PANEL.RowHeight, TTT.Scoreboard.PANEL.RowHeight)

	local ply = self:GetPlayer()
	if IsValid(ply) then
		if ply ~= LocalPlayer() and not ply:IsBot() then
			if not ply:IsMuted() then
				self.MuteButton:SetImage("icon16/sound.png")
			else
				self.MuteButton:SetImage("icon16/sound_mute.png")
			end
			self.MuteButton:SetSize(16, 16)
			self.MuteButton:SetPos(w - 20, 4)
		else
			self.MuteButton:SetVisible(false)
		end
	end
end

local PLAYER = FindMetaTable("Player")

-------------------------------
-- PLAYER:SetScoreboardRowOpen
-------------------------------
-- Desc: 		Sets if the player's dropdown menu should be open for their row.
-- Arg One:		Boolean, should the given player's dropdown (info) menu be open.
function PLAYER:SetScoreboardRowOpen(isopen)
	self.ttt_sb_rowOpen = isopen
end

-------------------------------
-- PLAYER:GetScoreboardRowOpen
-------------------------------
-- Desc: 		Gets if the player's dropdown (info) menu should be open for their row in the scoreboard.
-- Returns:		Boolean, should their row be open.
function PLAYER:GetScoreboardRowOpen()
	return self.ttt_sb_rowOpen or false
end
vgui.Register("TTT.Scoreboard.Row", PANEL, "DButton")