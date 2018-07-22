TTT.Map = TTT.Map or {
	TraitorButtons = {
		Buttons = {}
	}
}

TTT.Map.TraitorButtons.ButtonData = {
	material_Normal = surface.GetTextureID("vgui/ttt/tbut_hand_line"),
	material_Focus = surface.GetTextureID("vgui/ttt/tbut_hand_filled"),

	size = 32,
	clickableSize = 25,

	lastUpdateTime = 0
}

-- Update valid traitor buttons clientside since entities become null when not in PVS.
hook.Add("NotifyShouldTransmit", "TTT.Map.TraitorButtons.Updater", function(ent, isTransmitted)
	if isTransmitted and IsValid(ent) and ent:GetClass() == "ttt_traitor_button" then
		TTT.Map.TraitorButtons.Buttons[ent] = true
	end
end)

-- After cleanup our cached traitor buttons will now be null, take care of that.
hook.Add("PostCleanupMap", "TTT.Map.TraitorButtons.CleanupButtons", function()
	TTT.Map.TraitorButtons.Buttons = {}
end)

-- Draws the traitor buttons on the player's screen.
function TTT.Map.TraitorButtons:Draw(ply, w, h)
	if table.Count(self.Buttons) == 0 then
		return
	end

	local scrCenterW, scrCenterH = w/2, h/2
	surface.SetTexture(self.ButtonData.material_Normal)

	for btn in pairs(self.Buttons) do
		if not IsValid(btn) or not btn:IsUsable() then
			return
		end

		local screenPos = btn:GetPos():ToScreen()
		local x = screenPos.x < 0 and 0 or math.min(w - self.ButtonData.size, screenPos.x)
		local y = screenPos.y < 0 and 0 or math.min(h - self.ButtonData.size, screenPos.y)
		local distanceFactor = btn:GetPos() - ply:GetPos()
		distanceFactor = distanceFactor:Dot(distanceFactor) / btn:GetUsableRange()^2

		surface.SetDrawColor(255, 255, 255, 200 * (1 - distanceFactor))
		surface.DrawTexturedRect(x, y, self.ButtonData.size, self.ButtonData.size)

		if distanceFactor < 0.6 and distanceFactor > 0 then
			if screenPos.visible and self.ButtonData.lastUpdateTime < CurTime() then
				if math.abs(scrCenterW - x) <= self.ButtonData.clickableSize and math.abs(scrCenterH - y) <= self.ButtonData.clickableSize then
					self.ButtonData.lastUpdateTime = CurTime() + 0.1

					self.HoveredButton = btn
				elseif self.HoveredButton == btn then
					self.HoveredButton = nil
				end
			end
		else
			if self.HoveredButton == btn then
				self.HoveredButton = nil
			end
		end
	end

	if IsValid(self.HoveredButton) then
		surface.SetTexture(self.ButtonData.material_Focus)
		surface.SetDrawColor(255, 255, 255, 250)

		local screenPos = self.HoveredButton:GetPos():ToScreen()
		local x = screenPos.x < 0 and 0 or math.min(w - self.ButtonData.size, screenPos.x)
		local y = screenPos.y < 0 and 0 or math.min(h - self.ButtonData.size, screenPos.y)
		surface.DrawTexturedRect(x, y, self.ButtonData.size, self.ButtonData.size)

		surface.SetTextColor(255, 50, 50, 255)
		surface.SetFont("TTT_TButtonText")

		-- Draw button description.
		x = x + 40
		y = y - 5
		surface.SetTextPos(x, y)
		surface.DrawText(self.HoveredButton:GetDescription())

		-- Draw button reusablilty information.
		y = y + 12
		surface.SetTextPos(x, y)
		if self.HoveredButton:GetDelay() < 0 then
			surface.DrawText(TTT.Languages.GetPhrase("tbutton_singleuse"))
		elseif self.HoveredButton:GetDelay() == 0 then
			surface.DrawText(TTT.Languages.GetPhrase("tbutton_reusable"))
		else
			surface.DrawText(TTT.Languages.GetPhrase("tbutton_reuse_time", self.HoveredButton:GetDelay()))
		end

		-- Draw traitor button use key info.
		y = y + 12
		surface.SetTextPos(x, y)
		surface.DrawText(TTT.Languages.GetPhrase("tbutton_help", string.upper(input.LookupBinding("+use", true))))
	end
end