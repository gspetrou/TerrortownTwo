local getRole, getTime, getState, roundIsActive, math_floor, math_Clamp, math_min = TTT.Roles.RoleAsString, TTT.Rounds.GetFormattedRemainingTime, TTT.Rounds.GetFormattedState, TTT.Rounds.IsActive, math.floor, math.Clamp, math.min
local surface_DrawRect, surface_SetDrawColor, surface_GetTextSize, surface_DrawText, surface_SetFont, surface_SetTextPos, surface_SetTextColor = surface.DrawRect, surface.SetDrawColor, surface.GetTextSize, surface.DrawText, surface.SetFont, surface.SetTextPos, surface.SetTextColor

local health_colors = {
	bg = {100, 25, 25},
	fg = {200, 50, 50}
}

local ammo_colors = {
	bg = {70, 70, 5},
	fg = {205, 155, 0}
}

TTT.VGUI.ttt_hud_alive_scale = 5.5
TTT.VGUI.ttt_hud_alive_alpha = 220
TTT.VGUI.AddElement("ttt_hud_alive", function(ply, w, h)
	local scale_w, scale_h = math_min(math_floor(w/TTT.VGUI.ttt_hud_alive_scale), 300), math_min(math_floor(h/TTT.VGUI.ttt_hud_alive_scale), 150)
	local alpha = TTT.VGUI.ttt_hud_alive_alpha
	local alpha_text = TTT.VGUI.ttt_hud_alive_alpha * 1.2

	local bar_w = scale_w - 6			-- Width of each bar.
	local bar_h = (scale_h - 12)/3		-- Height of each bar.
	local bar_pos_x = 8
	local bar_pos_y = h - 2 - scale_h

	surface_SetTextColor(255, 255, 255, alpha_text)

	surface_SetDrawColor(35, 35, 40, alpha)
	surface_DrawRect(5, bar_pos_y - 3, scale_w, bar_h*3 + 12)

	-- Role and Time
	surface_SetFont("TTT_HudText")
	local time = getTime()
	local text_w, text_h = surface_GetTextSize(time)
	local role_col = TTT.Roles.Colors[ply:GetRole()]
	local role_x, role_w = bar_pos_x + text_w + 3, bar_w - text_w - 3
	surface_SetDrawColor(role_col.r, role_col.g, role_col.b, alpha)
	surface_DrawRect(role_x, bar_pos_y, role_w, bar_h)

	-- Time
	surface_SetTextPos(bar_pos_x, bar_pos_y + bar_h/2 - text_h/2)
	surface_DrawText(time)

	-- Role text
	local roletext
	if not roundIsActive() then
		roletext = getState()	-- If the round is not active then display the round state.
	else
		roletext = getRole(ply)	-- If the round is active display their role.
	end
	text_w, text_h = surface_GetTextSize(roletext)
	surface_SetTextPos(role_x + role_w/2 - text_w/2, bar_pos_y + bar_h/2 - text_h/2)
	surface_DrawText(roletext)

	-- Health
	local hp = ply:Health()
	text_w, text_h = surface_GetTextSize(hp)

	bar_pos_y = bar_pos_y + bar_h + 3
	surface_SetDrawColor(health_colors.bg[1], health_colors.bg[2], health_colors.bg[3], alpha)	-- Health bar background.
	surface_DrawRect(bar_pos_x, bar_pos_y, bar_w, bar_h)
	surface_SetDrawColor(health_colors.fg[1], health_colors.fg[2], health_colors.fg[3], alpha)	-- Health bar foreground.
	surface_DrawRect(bar_pos_x, bar_pos_y, bar_w * math_Clamp(hp/100, 0, 1), bar_h)

	surface_SetTextPos(bar_pos_x + bar_w - text_w - 3, bar_pos_y + bar_h/2 - text_h/2)
	surface_DrawText(hp)

	-- Ammo
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and istable(wep.Primary) then	-- We check wep.Primary because it might be a weapon written in C++. (weapon_physgun)
		if wep.ShouldDisplayAmmo == false then
			return
		end
		
		local clipAmmo = wep:Clip1()
		local storedAmmo = wep.Ammo1 and wep:Ammo1() or false

		bar_pos_y = bar_pos_y + bar_h + 3
		surface_SetDrawColor(ammo_colors.bg[1], ammo_colors.bg[2], ammo_colors.bg[3], alpha)	-- Ammo background.
		surface_DrawRect(bar_pos_x, bar_pos_y, bar_w, bar_h)
		surface_SetDrawColor(ammo_colors.fg[1], ammo_colors.fg[2], ammo_colors.fg[3], alpha)	-- Ammo foreground.
		surface_DrawRect(bar_pos_x, bar_pos_y, bar_w * math_Clamp(clipAmmo/wep.Primary.ClipSize, 0, 1), bar_h)

		local ammoText = clipAmmo
		if storedAmmo ~= false and storedAmmo > 0 then
			ammoText = ammoText.." + "..storedAmmo
		end
		text_w, text_h = surface_GetTextSize(ammoText)
		surface_SetTextPos(bar_pos_x + bar_w - text_w - 3, bar_pos_y + bar_h/2 - text_h/2)
		surface_DrawText(ammoText)
	end

end, function(ply, isalive)
	return isalive
end)