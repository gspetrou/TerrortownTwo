local getRole, getTime, getState, getPhrase = TTT.Roles.RoleAsString, TTT.Rounds.GetFormattedRemainingTime, TTT.Rounds.GetState, TTT.Languages.GetPhrase
local math_Clamp, math_max, draw_RoundedBox, draw_SimpleText = math.Clamp, math.max, draw.RoundedBox, draw.SimpleText
local surface_GetTextSize, surface_SetFont = surface.GetTextSize, surface.SetFont

local health_colors = {
	bg = Color(100, 25, 25, 230),
	fg = Color(200, 50, 50, 230)
}

local ammo_colors = {
	bg = Color(20, 20, 5, 230),
	fg = Color(205, 155, 0, 230)
}

surface.CreateFont("TTT_HudText", {
	font = "Trebuchet24",
	size = 24,
	weight = 900
})

TTT.VGUI.AddElement("ttt_alive_hud", function(ply, w, h)
	surface_SetFont("TTT_HudText")

	local spacer = 3
	local bar_w, bar_h = 220, 25
	local barpos_h = h - spacer - bar_h

	-- Ammo
	draw_RoundedBox(0, spacer, barpos_h, bar_w, bar_h, ammo_colors.bg)
	draw_RoundedBox(0, spacer, barpos_h, bar_w, bar_h, ammo_colors.fg)

	-- Health
	barpos_h = barpos_h - bar_h - spacer
	local hp = math_max(ply:Health(), 0)
	draw_RoundedBox(0, spacer, barpos_h, bar_w, bar_h, health_colors.bg)
	draw_RoundedBox(0, spacer, barpos_h, bar_w * math_Clamp(hp/100, 0, 1), bar_h, health_colors.fg)
	draw_SimpleText(hp, "TTT_HudText", spacer + bar_w - surface_GetTextSize(hp) - 5, barpos_h)

	-- Role
	barpos_h = barpos_h - bar_h - spacer
	local timespot = 70
	draw_RoundedBox(0, spacer + timespot, barpos_h, bar_w - timespot, bar_h, TTT.Roles.Colors[ply:GetRole()])
	local state = getState()
	local role
	if state == ROUND_ACTIVE then
		role = getRole(ply)
	elseif state == ROUND_PREP then
		role = getPhrase("preperation")
	elseif state == ROUND_POST then
		role = getPhrase("roundend")
	elseif state == ROUND_WAITING then
		role = getPhrase("waiting")
	end
	draw_SimpleText(role, "TTT_HudText", bar_w - timespot, barpos_h, color_white, TEXT_ALIGN_CENTER)
	local time = getTime()
	draw_SimpleText(time, "TTT_HudText", timespot/2, barpos_h, color_white, TEXT_ALIGN_CENTER)

end, function(ply)
	return ply:Alive()
end)