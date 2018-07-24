TTT.Map = TTT.Map or {}
TTT.Map.TraitorButtons = TTT.Map.TraitorButtons or {
	Buttons = {}
}

if SERVER then
	util.AddNetworkString("TTT.Map.TraitorButtons.Activate")

	-- Received when a player wants to activate a traitor button.
	net.Receive("TTT.Map.TraitorButtons.Activate", function(_, ply)
		local btn = net.ReadEntity()

		if not IsValid(btn) or not IsValid(ply) then
			return
		end

		btn:TraitorUse(ply)
	end)
end

if CLIENT then
	-- Stores info about drawing buttons on screen.
	TTT.Map.TraitorButtons.ButtonData = {
		material_Normal = surface.GetTextureID("vgui/ttt/tbut_hand_line"),
		material_Focus = surface.GetTextureID("vgui/ttt/tbut_hand_filled"),

		size = 32,
		clickableSize = 25,

		lastUpdateTime = 0
	}

	--------------------------------------
	-- TTT.Map.TraitorButtons:UpdateCache
	--------------------------------------
	-- Desc:		Updates the cache of traitor buttons on the client.
	function TTT.Map.TraitorButtons:UpdateCache()
		self.Buttons = ents.FindByClass("ttt_traitor_button")
	end

	-- Update valid traitor buttons clientside since entities become null when not in PVS.
	-- I would have preferred to use NotifyShouldTransmit but it appears that it is not very reliable.
	timer.Create("TTT.Map.TraitorButtons.CacheButtons", 1, 0, function()
		TTT.Map.TraitorButtons:UpdateCache()
	end)

	-- After cleanup our cached traitor buttons will now be null, take care of that.
	hook.Add("PostCleanupMap", "TTT.Map.TraitorButtons.CleanupButtons", function()
		TTT.Map.TraitorButtons.Buttons = {}
	end)

	-- Micro-optimize drawing the buttons.
	local input_LookupBinding, surface_SetTexture, surface_SetDrawColor, surface_DrawTexturedRect, surface_DrawText, surface_SetTextPos, surface_SetTextColor, surface_SetFont, math_abs, math_min, CurTime, IsValid, string_upper, ipairs = input.LookupBinding, surface.SetTexture, surface.SetDrawColor, surface.DrawTexturedRect, surface.DrawText, surface.SetTextPos, surface.SetTextColor, surface.SetFont, math.abs, math.min, CurTime, IsValid, string.upper, ipairs

	-------------------------------
	-- TTT.Map.TraitorButtons:Draw
	-------------------------------
	-- Desc:		Draws the traitor buttons on the player's screen.
	-- Arg One:		Player entity, the local player.
	-- Arg Two:		Number, screen width.
	-- Arg Three:	Number, screen height.
	function TTT.Map.TraitorButtons:Draw(ply, w, h)
		if #self.Buttons == 0 then
			return
		end

		local scrCenterW, scrCenterH = w/2, h/2
		surface_SetTexture(self.ButtonData.material_Normal)

		for i, btn in ipairs(self.Buttons) do
			if not IsValid(btn) or not btn:IsUsable() then
				continue
			end

			local screenPos = btn:GetPos():ToScreen()
			local x = screenPos.x < 0 and 0 or math_min(w - self.ButtonData.size, screenPos.x)
			local y = screenPos.y < 0 and 0 or math_min(h - self.ButtonData.size, screenPos.y)
			local distanceFactor = btn:GetPos() - ply:GetPos()
			distanceFactor = distanceFactor:Dot(distanceFactor) / btn:GetUsableRange()^2

			surface_SetDrawColor(255, 255, 255, 200 * (1 - distanceFactor))
			surface_DrawTexturedRect(x, y, self.ButtonData.size, self.ButtonData.size)

			if distanceFactor < 0.6 and distanceFactor > 0 then
				if screenPos.visible and self.ButtonData.lastUpdateTime < CurTime() then
					if math_abs(scrCenterW - x) <= self.ButtonData.clickableSize and math_abs(scrCenterH - y) <= self.ButtonData.clickableSize then
						self.ButtonData.lastUpdateTime = CurTime() + 0.1

						self.HoveredButton = btn
					elseif self.HoveredButton == btn then
						self.HoveredButton = nil
					end
				end
			elseif self.HoveredButton == btn then
				self.HoveredButton = nil
			end
		end

		if IsValid(self.HoveredButton) then
			surface_SetTexture(self.ButtonData.material_Focus)
			surface_SetDrawColor(255, 255, 255, 250)

			local screenPos = self.HoveredButton:GetPos():ToScreen()
			local x = screenPos.x < 0 and 0 or math_min(w - self.ButtonData.size, screenPos.x)
			local y = screenPos.y < 0 and 0 or math_min(h - self.ButtonData.size, screenPos.y)
			surface_DrawTexturedRect(x, y, self.ButtonData.size, self.ButtonData.size)

			surface_SetTextColor(255, 50, 50, 255)
			surface_SetFont("TTT_TButtonText")

			-- Draw button description.
			x = x + 40
			y = y - 5
			surface_SetTextPos(x, y)
			surface_DrawText(self.HoveredButton:GetDescription())

			-- Draw button reusablilty information.
			y = y + 12
			surface_SetTextPos(x, y)
			if self.HoveredButton:GetDelay() < 0 then
				surface_DrawText(TTT.Languages.GetPhrase("tbutton_singleuse"))
			elseif self.HoveredButton:GetDelay() == 0 then
				surface_DrawText(TTT.Languages.GetPhrase("tbutton_reusable"))
			else
				surface_DrawText(TTT.Languages.GetPhrase("tbutton_reuse_time", self.HoveredButton:GetDelay()))
			end

			-- Draw traitor button use key info.
			y = y + 12
			surface_SetTextPos(x, y)

			local binding = input_LookupBinding("+use", true)
			if binding == nil then
				surface_DrawText(TTT.Languages.GetPhrase("tbutton_help_command", "+use"))
			else
				surface_DrawText(TTT.Languages.GetPhrase("tbutton_help", string_upper(binding)))
			end
		end
	end

	------------------------------------
	-- TTT.Map.TraitorButtons:IsHovered
	------------------------------------
	-- Desc:		Sees if the local player is hovering over a T Button.
	-- Returns:		Boolean.
	function TTT.Map.TraitorButtons:IsHovered()
		return IsValid(self.HoveredButton)
	end

	-------------------------------------------
	-- TTT.Map.TraitorButtons:UseHoveredButton
	-------------------------------------------
	-- Desc:		Uses the traitor button the player is currently hovered over.
	function TTT.Map.TraitorButtons:UseHoveredButton()
		if self.HoveredButton and IsValid(self.HoveredButton) then
			net.Start("TTT.Map.TraitorButtons.Activate")
				net.WriteEntity(self.HoveredButton)
			net.SendToServer()
		end
	end
end