local PANEL = {}
local SB_ROW_HEIGHT = 24

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
	self.Columns = {}
	self.Avatar = vgui.Create("AvatarImage", self)	-- Make our avatar
	self.AvatarButton = vgui.Create("Button", self)	-- Make an invisible button on top of the avatar for openning that player's steam page.
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
	self.DoClickFunc = nil

	self.MuteButton = vgui.Create("DImageButton", self)
	self.MuteButton.DoClick = function()
		local ply = self:GetPlayer()
		if IsValid(ply) then
			ply:SetMuted(not ply:IsMuted())
		end
	end
end

function PANEL:SetPlayer(ply)		-- Given a player, sets up the row to have their info.
	self.Avatar:SetPlayer(ply, 32)
	self.Name = ply:Nick()
	self.Player = ply
end

function PANEL:SetupDoClickFunction(func)
	self.DoClickFunc = func
end

function PANEL:DoClick()
	if isfunction(self.DoClickFunc) then
		self.DoClickFunc(self, self:GetPlayer())
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
		local text = column.func(ply)
		text = text == nil and "" or tostring(text)

		local text_w, text_h = surface.GetTextSize(text)
		surface.SetTextPos(w - offset - column.width/2 - text_w/2, h/2 - text_h/2)
		surface.DrawText(text)
		offset = offset + column.width
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

function PANEL:PerformLayout(w, h)
	self:SetSize(w, h)

	self.Avatar:SetPos(0, 0)
	self.Avatar:SetSize(SB_ROW_HEIGHT, SB_ROW_HEIGHT)
	self.AvatarButton:SetPos(0, 0)
	self.AvatarButton:SetSize(SB_ROW_HEIGHT, SB_ROW_HEIGHT)

	local ply = self:GetPlayer()
	if IsValid(ply) then
		if ply ~= LocalPlayer() and not ply:IsBot() then
			if not ply:IsMuted() then
				self.MuteButton:SetImage("icon16/sound.png")
			else
				self.MuteButton:SetImage("icon16/sound_mute.png")
			end
			self.MuteButton:SetSize(16, 16)
			self.MuteButton:DockMargin(4, 4, 4, 4)
			self.MuteButton:Dock(RIGHT)
		else
			self.MuteButton:SetVisible(false)
		end
	end
end

function PANEL:AddColumn(colData)
	table.insert(self.Columns, colData)
end
vgui.Register("TTT.Scoreboard.Row", PANEL, "DButton")