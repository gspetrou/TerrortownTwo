local PANEL = {}
local SB_ROW_HEIGHT = 24
local defaultOpenHeight = 100	-- How much height to add to row when its openned.

local name_cols = {
	default = color_white,
	admin = Color(220, 100, 0, 255),
	dev = Color(100, 240, 105, 255)
}

local rolecolor = {
	traitor = Color(255, 0, 0, 30),
	detective = Color(0, 0, 255, 30)
}

function PANEL:Init()
	self:SetName("TTT.Scoreboard.Row")
	self.Columns = {}
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
	
	self.Name = ""
	self.Player = nil
	self.Open = false
	self.DoClickFunc = nil

	self.OpenHeight = defaultOpenHeight
	self.OpenPanel = vgui.Create("DPanel", self)
	self.OpenPanel:SetMouseInputEnabled(true)
	self.OpenPanel:SetTall(self.OpenHeight)
	self.OpenPanel:SetVisible(false)
	self.OpenPanel.Paint = function() end

	self.MuteButton = vgui.Create("DImageButton", self)
	self.MuteButton:SetMouseInputEnabled(true)
	self.MuteButton.DoClick = function()
		local ply = self:GetPlayer()
		if IsValid(ply) then
			ply:SetMuted(not ply:IsMuted())
		end
	end
end

-------------------
-- PANEL:SetPlayer
-------------------
-- Desc:		Sets the information for the current row from the given player.
-- Arg One:		Player, to set the info for the row.
function PANEL:SetPlayer(ply)
	self.Avatar:SetPlayer(ply, 32)
	self.Name = ply:Nick()
	self.Player = ply
	self:SetOpen(ply:GetScoreboardRowOpen())
	if self:IsOpen() and isfunction(self.DoClickFunc) then
		self.DoClickFunc(self, self.OpenPanel, self:GetPlayer(), TTT.Scoreboard.InitWidth, self.OpenHeight, SB_ROW_HEIGHT)
	end
end

------------------------------
-- PANEL:SetupDoClickFunction
------------------------------
-- Desc:		Sets the function to be ran on row left-click.
-- Arg One:		Function, to be ran.
function PANEL:SetupDoClickFunction(func)
	self.DoClickFunc = func
end

function PANEL:DoClick()
	local ply = self:GetPlayer()
	if isfunction(self.DoClickFunc) and IsValid(TTT.Scoreboard.Scoreboard) and IsValid(ply) and ply ~= LocalPlayer() then
		local isOpen = self:IsOpen()
		self:SetOpen(not isOpen)
		self:GetParent():PerformLayout()
		TTT.Scoreboard.Scoreboard:PerformLayout()
		if isOpen then
			surface.PlaySound("ui/buttonclickrelease.wav")
			self.DoClickFunc(self, self.OpenPanel, ply, TTT.Scoreboard.InitWidth, self.OpenHeight, SB_ROW_HEIGHT)
			self.OpenPanel:InvalidateLayout(true)
		else
			surface.PlaySound("ui/buttonclick.wav")
			self.OpenPanel:Clear()
		end
	end
end

-------------------
-- PANEL:GetPlayer
-------------------
-- Desc:		Gets the player that this row is for.
-- Returns:		Player, that this row is for.
function PANEL:GetPlayer()
	return self.Player
end

----------------------
-- PANEL:GetNameColor
----------------------
-- Desc:		Gets the color for the player's name by first checking the TTT.Scoreboard.PlayerNameColor hook, then if the player is admin, and if all else fails, return the default.
function PANEL:GetNameColor()
	local ply = self:GetPlayer()
	if not IsValid(ply) then	-- Probably have bigger problems if this is the case but whatever.
		return name_cols.default
	end

	local col = hook.Call("TTT.Scoreboard.PlayerNameColor", nil, ply)
	if IsColor(col) then
		return col
	end

	if ply:SteamID() == "STEAM_0:0:1963640" or ply:SteamID() == "STEAM_0:1:18093014" then
		return name_cols.dev
	elseif ply:IsAdmin() and GetConVar("ttt_scoreboard_highlight_admins"):GetBool() then
		return name_cols.admin
	end

	return name_cols.default
end

function PANEL:Paint(w, h)
	local ply = self:GetPlayer()
	if not IsValid(ply) then return end

	-- Make Detectives and Traitors the color of their role.
	if ply:IsTraitor() then
		local c = rolecolor.traitor
		surface.SetDrawColor(c.r, c.g, c.b, c.a)
		surface.DrawRect(0, 0, w, h)
	elseif ply:IsDetective() then
		local c = rolecolor.detective
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
	local name_y = SB_ROW_HEIGHT/2 - name_h/2
	surface.SetFont("treb_small")

	-- Name shadow
	surface.SetTextColor(0, 0, 0, 255)
	surface.SetTextPos(SB_ROW_HEIGHT + 6, name_y + 1)
	surface.DrawText(self.Name)
	-- Name Colored
	surface.SetTextColor(name_col.r, name_col.g, name_col.b, name_col.a)
	surface.SetTextPos(SB_ROW_HEIGHT + 5, name_y)
	surface.DrawText(self.Name)

	-- We really don't need a DLabel for each column data entry. Instead, lets just use the surface library.
	surface.SetTextColor(255, 255, 255, 255)
	local offset = SB_ROW_HEIGHT	-- Offset by SB_ROW_HEIGHT since the mute button column is SB_ROW_HEIGHT width.
	for i, column in ipairs(self.Columns) do
		local text, col = column.func(ply)
		text = text == nil and "" or tostring(text)
		if col then
			surface.SetTextColor(col.r, col.g, col.b, col.a)
		end

		local text_w, text_h = surface.GetTextSize(text)
		surface.SetTextPos(w - offset - column.width/2 - text_w/2, SB_ROW_HEIGHT/2 - text_h/2)
		surface.DrawText(text)
		offset = offset + column.width
		surface.SetTextColor(255, 255, 255, 255)
	end
end

function PANEL:DoRightClick()
	local dmenu = DermaMenu()
	local shouldCloseMenu = hook.Call("TTT.Scoreboard.PlayerRightClicked", nil, dmenu, self:GetPlayer())
	if shouldCloseMenu then
		demnu:Remove()
	else
		dmenu:Open()
	end
end

function PANEL:PerformLayout()
	local w  = self:GetWide()
	self:SetSize(w, self:IsOpen() and SB_ROW_HEIGHT + self.OpenPanel:GetTall() or SB_ROW_HEIGHT)
	self.OpenPanel:SetPos(0, SB_ROW_HEIGHT)
	self.OpenPanel:SetSize(w, self.OpenPanel:GetTall())

	self.Avatar:SetPos(0, 0)
	self.Avatar:SetSize(SB_ROW_HEIGHT, SB_ROW_HEIGHT)
	self.AvatarButton:SetPos(0, 0)
	self.AvatarButton:SetSize(SB_ROW_HEIGHT, SB_ROW_HEIGHT)

	local ply = self:GetPlayer()
	if IsValid(ply) then
		if ply ~= LocalPlayer() then --and not ply:IsBot() then
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

-------------------
-- PANEL:AddColumn
-------------------
-- Desc:		Adds a column to the row. Since you shouldn't be making rows directly, you shouldn't really call this directly either.
function PANEL:AddColumn(colData)
	table.insert(self.Columns, colData)
end

-----------------
-- PANEL:SetOpen
-----------------
-- Desc:		Sets the row to be open to show more data, or closed.
-- Arg One:		Boolean, should be open.
function PANEL:SetOpen(isopen)
	self.Open = isopen
	self:GetPlayer():SetScoreboardRowOpen(isopen)
	self:InvalidateLayout(true)

	self.OpenPanel:SetVisible(isopen)
end

----------------
-- PANEL:IsOpen
----------------
-- Desc:		Is the row open.
-- Returns:		Boolean, read the description.
function PANEL:IsOpen()
	return self.Open
end

-----------------------
-- PANEL:SetOpenHeight
-----------------------
-- Desc:		Sets the height of the info panel when the row is open.
-- Arg One:		Number, height of info panel.
function PANEL:SetOpenHeight(h)
	self.OpenHeight = h
	self.OpenPanel:SetTall(h)
	self:InvalidateLayout()
end

local PLAYER = FindMetaTable("Player")

-------------------------------
-- PLAYER:SetScoreboardRowOpen
-------------------------------
-- Desc:		Sets if the scoreboard row for this player should be open.
-- Arg One:		Boolean, should it be open.
function PLAYER:SetScoreboardRowOpen(isopen)
	self.ttt_sb_rowOpen = isopen
end

-------------------------------
-- PLAYER:GetScoreboardRowOpen
-------------------------------
-- Desc:		Gets if the scoreboard row for this player should be open.
-- Returns:		Boolean
function PLAYER:GetScoreboardRowOpen()
	return self.ttt_sb_rowOpen or false
end
vgui.Register("TTT.Scoreboard.Row", PANEL, "DButton")