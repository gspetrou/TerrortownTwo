local PANEL = {}
local SB_ROW_HEIGHT = 24

function PANEL:Init()
	self.Avatar = vgui.Create("AvatarImage", self)	-- Make our avatar
	self.Name = vgui.Create("DLabel", self)			-- Then our name label
	self.islight = false
	self.Player = nil

	self.MuteButton = vgui.Create("DImageButton", self)
end

function PANEL:SetPlayer(ply)		-- Given a player, sets up the row to have their info.
	self.Avatar:SetPlayer(ply, 32)
	self.Name:SetText(ply:Nick())
	self.Player = ply
	self:InvalidateLayout()
end

-------------------
-- PANEL:GetPlayer
-------------------
-- Desc:		Gets the player that this row is for.
-- Returns:		Player, that this row is for.
function PANEL:GetPlayer()
	return self.Player
end

--------------------
-- PANEL:SetLighter
--------------------
-- Desc:		Sets the background to be lighter if the first arg evaluates to true.
-- Arg One:		Boolean, true sets the background lighter.
function PANEL:SetLighter(is_lighter)
	self.islight = tobool(is_lighter)
end

function PANEL:IsLighter()
	return self.islight
end

function PANEL:Paint(w, h)
	if self:IsLighter() then
		surface.SetDrawColor(100, 100, 100, 255)
	else
		surface.SetDrawColor(0, 0, 0, 0)
	end
	surface.DrawRect(0, 0, w, h)
end

function PANEL:DoClick()
	chat.AddText("clicked")
end

function PANEL:PerformLayout(w, h)
	self:SetSize(w, h)

	self.Avatar:SetPos(0, 0)
	self.Avatar:SetSize(SB_ROW_HEIGHT, SB_ROW_HEIGHT)

	self.Name:SizeToContents()
	self.Name:SetPos(SB_ROW_HEIGHT + 5, 0)

	local ply = self:GetPlayer()
	if IsValid(ply) and ply ~= LocalPlayer() then
		if not ply:IsMuted() then
			self.MuteButton:SetImage("icon16/sound.png")
		else
			self.MuteButton:SetImage("icon16/sound_mute.png")
		end
		self.MuteButton:SetSize(16, 16)
		self.MuteButton:DockMargin(4, 4, 4, 4)
		self.MuteButton:Dock(RIGHT)
	end
end
vgui.Register("TTT.Scoreboard.Row", PANEL, "DButton")