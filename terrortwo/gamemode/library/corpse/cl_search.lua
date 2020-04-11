TTT.Corpse = TTT.Corpse or {}

-- Networking and Handling.
do
	---------------------------------
	-- TTT.Corpse.OpenBodySearchMenu
	---------------------------------
	-- Desc:		Opens the corpse search info menu.
	-- Arg One:		Entity, the corpse we want to open the menu for.
	function TTT.Corpse.OpenBodySearchMenu(corpse)
		local frame = vgui.Create("TTT.Corpse.BodySearchMenu")
		frame:SetBodyData(corpse.SearchData)
		frame:Center()
	end

	net.Receive("TTT.Corpse.OpenSearchMenu", function()
		local corpseEntity = net.ReadEntity()
		
		if IsValid(corpseEntity) then
			TTT.Corpse.OpenBodySearchMenu(corpseEntity)
		end
	end)

	------------------------------
	-- TTT.Corpse.ProcessBodyData
	------------------------------
	-- Desc:		Given the raw info about the corpse convert it into easily human-readable data.
	function TTT.Corpse.ProcessBodyData(rawData)
		local data = {}
		
	end

	net.Receive("TTT.Corpse.SearchInfo", function()
		local corpseEntity = net.ReadEntity()
		local ownerName = net.ReadString()
		local ownerRole = net.ReadUInt(3)
		local deathDamageType = net.ReadUInt(31)
		local murderWeaponClass = net.ReadString()
		local wasHeadshot = net.ReadBool()
		local deathTime = net.ReadUInt(32)

		corpseEntity.SearchData = {
			OwnerName = ownerName,
			OwnerRole = ownerRole,
			DeathDamageType = deathDamageType,
			MurderWeaponClass = murderWeaponClass,
			WasHeadshotted = wasHeadshot,
			DeathTime = deathTime
		}

		-- TODO: Read equipment
		-- TODO: Read C4 info
		-- TODO: Read DNA sample decay time
		-- TODO: Last words
	end)
end

-- Search menu.
do
	local PANEL = {
		Frame_Width = 425,
		Frame_Height = 260,
		Frame_Header_Height = 25,
		Margin = 8,
		IconSizes = 64
	}

	function PANEL:Init()
		self:SetTitle(TTT.Languages.GetPhrase("body_search_results").." - ")
		self:SetVisible(true)
		self:ShowCloseButton(true)
		self:SetMouseInputEnabled(true)
		self:SetKeyboardInputEnabled(true)

		-- Panel in the frame containning the actual content.
		self.ContentPanel = vgui.Create("DPanel", self)
		self.ContentPanel:SetPaintBackground(false)

		-- Icon list detailing what happenned to this body.
		self.IconList = vgui.Create("TTT.Corpse.IconList", self.ContentPanel)
		self.IconList:SetIconSize(self.IconSizes)
	end

	function PANEL:SetBodyData(bodyData)
		--self.
	end
	
	function PANEL:GetBodyData()
		return self.BodyData
	end

	function PANEL:PerformLayout(w, h)
		self:SetSize(self.Frame_Width, self.Frame_Height)
		self.ContentPanel:SetSize(self.Frame_Width - self.Margin*2, self.Frame_Height - self.Frame_Header_Height - self.Margin*2)
		self.ContentPanel:SetPos(self.Margin, self.Frame_Header_Height + self.Margin)
		self.IconList:SetPos(0, 0)
		self.IconList:SetSize(64,300)
		return self.BaseClass.PerformLayout(self, w, h)
	end
	vgui.Register("TTT.Corpse.BodySearchMenu", PANEL, "DFrame")
end

-- Stores the types of body info icons that exist. Feel free to add more to this as you wish.
-- Make sure to return the icon you made.
TTT.Corpse.BodyInfoIcons = {
	["Owner"] = function(iconData)
		local icon = vgui.Create("SimpleIconAvatar")
		icon:SetPlayer(LocalPlayer())
		return icon
	end,
	["LastSeenWith"] = function(iconData)

	end,
	["Image"] = function(iconData)

	end,
	["ImageWithLabel"] = function(iconData)

	end
}

-- Icon list detailing body info.
do
	local PANEL = {
		DefaultIconSize = 32
	}

	function PANEL:Init()
		self:EnableHorizontal(true)
		self:SetSpacing(1)
		self:SetPadding(2)

		if self.VBar then
			self.VBar:Remove()
			self.VBar = nil
		end

		self.IconSize = self.DefaultIconSize
		self.ScrollBar = vgui.Create("DHorizontalScroller", self)
	end

	function PANEL:SetIconSize(size)
		self.IconSize = size
	end

	function PANEL:GetIconSize()
		return self.IconSize
	end

	function PANEL:AddIcon(iconType, iconData)
		local icon = TTT.Corpse.BodyInfoIcons[iconType](iconData)
		icon:SetParent(self)
		icon.InfoType = iconType
		icon:SetIconSize(self:GetIconSize())

		self:AddPanel(icon)
		self.ScrollBar:AddPanel(icon)
	end

	function PANEL:PerformLayout(w, h)
		self.ScrollBar:SetSize(w, h)
		return self.BaseClass.PerformLayout(self, w, h)
	end

	vgui.Register("TTT.Corpse.IconList", PANEL, "DPanelSelect")
end