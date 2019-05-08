TTT.Notifications = TTT.Notifications or {}

local Notification = {
	ScreenScaleFactor = 3,
	LifeTime = 5,
	Margin = 5,
	Font = "DefaultBold"
	Background = {
		r = 60,
		g = 60,
		b = 60,
		a = 150
	},
	CreationTime = 0.
}

function Notification:New(initObj)
	initObj = initObj or {}
	setmetatable(initObj, self)
	self.__index = self
	return initObj
end

function Notification:GetMaxNotificationWidth()
	return math.min(math.floor(ScrW()/ScreenScaleFactor), 300)
end

--[[TTT.Notifications.PanelData = TTT.Notifications.PanelData or {
	Active = {},
	NScale = 3,
	LifeTime = 5,
	Margin = 5,
	Font = "DefaultBold"
}
TTT.Notifications.DefaultBG = TTT.Notifications.DefaultBG or {
	r = 60,
	g = 60,
	b = 60,
	a = 180
}





function TTT.Notifications:GetMaxNotificationWidth()
	return math.min(math.floor(ScrW()/self.PanelData.NScale), 300)
end

function TTT.Notifications:Add(text, color)
	local ct = CurTime()
	local brokenUpText = TTT.BreakTextIntoLines(text, self:GetMaxNotificationWidth())
	table.insert(self.PanelData.Active, {
		textRaw = text,
		textLines = brokenUpText
		height = 200,	// TODO: change me later
		addTime = ct,
		removeTime = ct + self.PanelData.LifeTime
	})
end

function TTT.Notifications:HUDPaint()
	local scrW, scrH = ScrW(), ScrH()
	local scaled_W = self:GetMaxNotificationWidth()
	local scaled_H = math.min(math.floor(scrH/self.PanelData.NScale), 100)
	local text_padding = 3
	local pnlX = scrW - scaled_W - rightMargin
	local pnlY = self.PanelData.Margin

	local panelListY = self.PanelData.Margin

	-- Loop backwards so oldest stuff is drawn at bottom.
	for i = #self.PanelData.Active, 1, -1 do
		local pnlData = self.PanelData.Active[i]

		if CurTime() >= pnlData.removeTime then
			table.remove(self.PanelData.Active, i)
			i = i + 1
			continue
		end

		surface.SetDrawColor(60, 60, 60, 180)
		surface.DrawRect(pnlX, panelListY, scaled_W, pnlData.height)
		surface.SetTextPos(pnlX + text_padding, panelListY + text_padding)
		surface.DrawText(pnlData.text)
		panelListY = panelListY + self.PanelData.Margin + pnlData.height
	end
end

function TTT.DrawNotification(pnlData, x, y)
	surface.SetDrawColor(60, 60, 60, 180)
	surface.DrawRect(x, y, )
end

]]--


