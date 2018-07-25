local minimalHud = CreateClientConVar("ttt_hud_target_minimal", "0", true, false, "Display as little info for the target hud as possible.")
local yOffset = 30	-- Y Offset so we're not blocking their crosshair.

surface.CreateFont("TargetIDSmall2", {
	font = "Verdana",
	size = 16,
	weight = 1000
})

TTT.VGUI.AddElement("ttt_hud_target", function(ply, w, h)

	-- Fire a bullet trace.
	local trData = util.GetPlayerTrace(ply)
	trData.mask = MASK_SHOT
	local tr = util.TraceLine(trData)

	-- If we don't hit anything, end it.
	if not IsValid(tr.Entity) then
		return
	end

	local hitEnt = tr.Entity
	surface.SetFont("TargetIDSmall2")

	if hitEnt:IsPlayer() then
		local name = hitEnt:Nick()
		local nameWidth, nameHeight = surface.GetTextSize(name)
		local hpPhrase, hpColor = TTT.Player.GetHealthStatus(hitEnt:Health(), hitEnt:GetMaxHealth())

		local x = w/2
		local y = h/2 + yOffset

		-- With a minimal HUD only draw their name and color it to their health.
		-- Otherwise draw their full target HUD.
		if minimalHud:GetBool() then
			draw.SimpleText(name, "TargetIDSmall2", x - nameWidth/2 + 1, y - nameHeight/2 + 1, color_black)
			draw.SimpleText(name, "TargetIDSmall2", x - nameWidth/2, y - nameHeight/2, hpColor)
		else
			draw.SimpleText(name, "TargetIDSmall2", x - nameWidth/2 + 1, y - nameHeight/2 + 1, color_black)
			draw.SimpleText(name, "TargetIDSmall2", x - nameWidth/2, y - nameHeight/2, color_white)

			local hpText = TTT.Languages.GetPhrase(hpPhrase)
			local hpTextWidth, hpTextHeight = surface.GetTextSize(hpText)
			draw.SimpleText(hpText, "TargetIDSmall2", x - hpTextWidth/2 + 1, y - hpTextHeight/2 + nameHeight + 1, color_black)
			draw.SimpleText(hpText, "TargetIDSmall2", x - hpTextWidth/2, y - hpTextHeight/2 + nameHeight, hpColor)
		end
	end

end, function(ply, isalive)
	return isalive-- Add disguiser stuff 
end)