-- Draws active notifications.
TTT.VGUI.AddElement("ttt_notifications", function(ply, w, h)
	-- Don't continue if theres no active notifications.
	local activeNotifications = TTT.Notifications:GetActiveNotifications()
	if #activeNotifications == 0 then
		return
	end

	local scaledWidth = TTT.Notifications:GetNotificationWidth()
	local drawingInfo = TTT.Notifications:GetDrawingInfo()

	local xPos = w - scaledWidth - drawingInfo.Margin
	local nextYPos = drawingInfo.Margin
	for i = 1, #activeNotifications do
		local notif = activeNotifications[i]

		if notif and not notif:ShouldBeRemoved() then
			nextYPos = notif:Draw(xPos, nextYPos, scaledWidth, drawingInfo)
		else
			table.remove(TTT.Notifications:GetActiveNotifications(), i)
		end
	end
end)