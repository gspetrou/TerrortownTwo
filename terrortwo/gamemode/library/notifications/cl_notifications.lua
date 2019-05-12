TTT.Notifications = TTT.Notifications or {
	ActiveNotifications = {},
	DrawingInfo = {
		ScaleMultiplier = 3,	-- Screen scale, changing this will make the notification panels larger/smaller.
		MinWidth = 300,			-- Min notification width.
		Margin = 6,				-- Margin between notifs.
		LifeTime = 12,			-- How long a notification displays for.
		FadeInTime = 0.1,			-- How long the fade in time is.
		FadeOutTime = 0.6,		-- How long fade out time is.
		LineSpacing = 3,		-- Vertical spacing between new lines.
		Padding = 3,			-- Text padding inside the notif.
		BlackColorTbl = {r = 0, g = 0, b = 0, a = 255},	-- Simply the color black but in table form.
		NotifSound = Sound("Hud.Hint")	-- Sound a notification makes when it pops up.
	}
}

surface.CreateFont("TTT_Notification", {
	font = "Tahoma",
	size = 13,
	weight = 1000
})

---------------------------
-- TTT.Notifications:Clear
---------------------------
-- Desc:		Clears the screen of any active notifications.
function TTT.Notifications:Clear()
	self.ActiveNotifications = {}
end

------------------------------------------
-- TTT.Notifications:GetNotificationWidth
------------------------------------------
-- Decs:		Gets the width of the notification elements.
-- Returns:		Number.
function TTT.Notifications:GetNotificationWidth()
	return math.min(math.floor(ScrW()/self.DrawingInfo.ScaleMultiplier), self.DrawingInfo.MinWidth)
end

-------------------------
-- TTT.Notifications:Add
-------------------------
-- Desc:		Adds a notification to the screen.
-- Arg One:		String, text for the notification to show.
-- Arg Two:		(Optional) Color, text color.
-- Arg Three:	(Optional) Color, background color.
-- Arg Four:	(Optional) String, standard message ID if this is a standard notification.
-- Returns:		TTT.Notifications.Notification object. You can use this to edit more advanced settings of the settings object.
function TTT.Notifications:Add(text, textColor, bgColor, type)
	local notif = self.Notification:New(text, textColor, bgColor)
	table.insert(self.ActiveNotifications, 1, notif)
	print("TTT: "..text)
	hook.Call("TTT.Notifcations.Added", nil, notif, msgType)
	return notif
end

--------------------------------------------
-- TTT.Notifications:GetActiveNotifications
--------------------------------------------
-- Desc:		Returns an array of the active notification objects.
-- Returns:		Table, of TTT.Notifications.Notification objects.
function TTT.Notifications:GetActiveNotifications()
	return self.ActiveNotifications
end

------------------------------------
-- TTT.Notifications:GetDrawingInfo
------------------------------------
-- Desc:		Returns a table of global notification drawing settings (like fade in/out time for example).
-- Returns:		Table.
function TTT.Notifications:GetDrawingInfo()
	return self.DrawingInfo
end

-- Defines the notification object.
do
	local Notification = {
		Font = "TTT_Notification",
		CreationTime = 0,
		DeathTime = 0,
		RawText = "",
		ProcessedText = {},
		Height = 0,
		MoveY = 0,
		MadeSound = false,
		Background = {
			r = 0,
			g = 0,
			b = 0,
			a = 200
		},
		TextColor = {
			r = 255,
			g = 255,
			b = 255,
			a = 255
		}
	}

	local CurTime = CurTime

	--------------------
	-- Notification:New
	--------------------
	-- Desc:		Creates a new notification object. Note, to have this appear youll have to manually add it to TTT.Notifications.ActiveNotifications.
	-- Arg One:		String, text for the notification to show.
	-- Arg Two:		(Optional) Color, text color.
	-- Arg Three:	(Optional) Color, background color.
	-- Returns:		TTT.Notifications.Notification object. You can use this to edit more advanced settings of the settings object.
	function Notification:New(text, textColor, bgColor)
		initObj = {}
		setmetatable(initObj, self)
		self.__index = self

		if text then
			initObj.RawText = text
			initObj.ProcessedText = TTT.BreakTextIntoLines(text, TTT.Notifications:GetNotificationWidth() - (2 * TTT.Notifications.DrawingInfo.Padding), initObj.Font)
		end
		if textColor then
			initObj.TextColor = {
				r = textColor.r,
				g = textColor.g,
				b = textColor.b,
				a = textColor.a
			}
		end
		if bgColor then
			initObj.Background = {
				r = bgColor.r,
				g = bgColor.g,
				b = bgColor.b,
				a = bgColor.a
			}
		end
		initObj.CreationTime = CurTime()
		initObj.DeathTime = CurTime() + TTT.Notifications.DrawingInfo.LifeTime
		initObj:CalculateHeight()
		initObj.MoveY = -initObj:GetHeight()

		return initObj
	end

	--------------------------------
	-- Notification:CalculateHeight
	--------------------------------
	-- Desc:		Updates the height of the notification object. Note, if you just need the height and not to recalculate the height then use Notification:GetHeight()
	-- Returns:		Number, height in pixels.
	function Notification:CalculateHeight()
		local fontHeight = draw.GetFontHeight(self.Font)
		local numLines = #self.ProcessedText
		local drawingInfo = TTT.Notifications:GetDrawingInfo()
		self.Height = (fontHeight*numLines) + (drawingInfo.LineSpacing * (numLines-1)) + (drawingInfo.Padding * 2)
		return self.Height
	end

	--------------------------
	-- Notification:GetHeight
	--------------------------
	-- Desc:		Gets the height of the notification panel.
	-- Returns:		Number, height.
	function Notification:GetHeight()
		return self.Height
	end

	--------------------------------
	-- Notification:ShouldBeRemoved
	--------------------------------
	-- Desc:		Sees if the notification is ready to be removed.
	-- Returns:		Boolean, true if should be removed.
	function Notification:ShouldBeRemoved()
		if (self.DeathTime - CurTime()) <= 0 then
			return true
		end

		return false
	end

	-----------------------------------
	-- Notification:GetAlphaMultiplier
	-----------------------------------
	-- Desc:		Gets the alpha multiplier of the given notification.
	-- Returns:		Number, between 0 and 1.
	function Notification:GetAlphaMultiplier()
		local drawingInfo = TTT.Notifications:GetDrawingInfo()
		local curTime = CurTime()
		
		local initDiff = curTime - self.CreationTime
		if initDiff <= drawingInfo.FadeInTime then
			return (initDiff/drawingInfo.FadeInTime)
		end

		local deathDiff = self.DeathTime - curTime
		if deathDiff <= 0 then
			return 0
		elseif deathDiff <= drawingInfo.FadeOutTime then
			return (deathDiff/drawingInfo.FadeOutTime)
		end

		return 1
	end

	-- Micro-optimize the drawing function.
	local LocalPlayer, ipairs, surface_SetAlphaMultiplier, draw_RoundedBox, surface_SetFont, surface_SetTextColor, surface_GetTextSize, surface_SetTextPos, surface_DrawText = LocalPlayer, ipairs, surface.SetAlphaMultiplier, draw.RoundedBox, surface.SetFont, surface.SetTextColor, surface.GetTextSize, surface.SetTextPos, surface.DrawText

	---------------------
	-- Notification:Draw
	---------------------
	-- Desc:		Draws the given notification object given a certain set of info.
	-- Arg One:		Number, X position to draw the notification.
	-- Arg Two:		Number, the Y position to draw the notification.
	-- Arg Three:	Number, the width of the notification (can be found with TTT.Notifications:GetNotificationWidth()).
	-- Arg Four:	Table, drawing parameters for the notification. (Default can be found with TTT.Notifications:GetDrawingInfo()).
	-- Returns:		Number, position below the notification where a next notification can be drawn.
	function Notification:Draw(x, nextYPos, w, drawingInfo)
		-- Make a sound when the notification is first displayed.
		if not self.MadeSound then
			LocalPlayer():EmitSound(drawingInfo.NotifSound, 80, 250)
			self.MadeSound = true
		end

		-- Set the fade in/fade out alpha for the rest of the drawing of our notification.
		surface_SetAlphaMultiplier(self:GetAlphaMultiplier())

		local h = self:GetHeight()

		-- Get the Y position we will be drawing this notification.
		local y = nextYPos + self.MoveY + drawingInfo.Margin
		if self.MoveY < 0 then
			self.MoveY = self.MoveY + 2
		end

		draw_RoundedBox(8, x, y, w, h, self.Background)	-- Draw background.

		local textY = y + drawingInfo.Padding
		surface_SetFont(self.Font)
		
		-- Draw text line by line.
		for i, text in ipairs(self.ProcessedText) do
			local textSizeW, textSizeH = surface_GetTextSize(text)
			local textX = x + w/2 - textSizeW/2

			-- Draw shadow.
			surface_SetTextColor(drawingInfo.BlackColorTbl)
			surface_SetTextPos(textX + 1, textY + 1)
			surface_DrawText(text)

			-- Draw actual text.
			surface_SetTextColor(self.TextColor)
			surface_SetTextPos(textX, textY)
			surface_DrawText(text)

			textY = textY + drawingInfo.LineSpacing + textSizeH
		end

		surface_SetAlphaMultiplier(1)	-- Undo our alpha multiplier otherwise we could affect other VGUI elements too.
		return y + h
	end

	TTT.Notifications.Notification = Notification	-- Make our notification object public.
end
