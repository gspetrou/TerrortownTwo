local surface_DrawRect, surface_SetDrawColor, surface_GetTextSize, surface_DrawText, surface_SetFont, surface_SetTextPos, surface_SetTextColor = surface.DrawRect, surface.SetDrawColor, surface.GetTextSize, surface.DrawText, surface.SetFont, surface.SetTextPos, surface.SetTextColor
local getTime = TTT.Rounds.GetFormattedRemainingTime

TTT.VGUI.ttt_hud_dead_scale = 1
TTT.VGUI.AddElement("ttt_hud_dead", function(ply, w, h)
	local pnl_w, pnl_h = 150 * TTT.VGUI.ttt_hud_dead_scale, 40 * TTT.VGUI.ttt_hud_dead_scale

	local inset = 5
	local pnl_x = inset
	local pnl_y = h - inset - pnl_h
	surface_SetTextColor(255, 255, 255)

	-- Draw the dark outer frame.
	surface_SetDrawColor(35, 35, 40)
	surface_DrawRect(pnl_x, pnl_y, pnl_w, pnl_h)
	-- Draw the yellow inner frame.
	surface_SetDrawColor(205, 155, 0)
	surface_DrawRect(pnl_x + inset, pnl_y + inset, pnl_w - inset*2, pnl_h - inset*2)

	-- Draw the time.
	surface_SetFont("TTT_HudText")
	local time = getTime()
	local text_w, text_h = surface_GetTextSize(time)
	surface_SetTextPos(pnl_x + inset*2, pnl_y + pnl_h/2 - text_h/2)
	surface_DrawText(time)
end, function(ply, isspecmode)
	return not ply:Alive() or isspecmode
end)