-- This weapon switcher uses Code_GS's (Kefta's) Weapon Switcher Skeleton found here: https://github.com/Kefta/Weapon-Switcher-Skeleton
-- Copyright (c) 2017 Collin (code_gs)

-- Config
TTT.VGUI.ttt_weapon_switcher_scale = 5.0				-- Hud scale size.
TTT.VGUI.ttt_weapon_switcher_alpha = 170				-- Hud alpha.
TTT.VGUI.ttt_weapon_switcher_alpha_selected = 1.6		-- Alpha multiplier for the highlighted weapon bar..
local MAX_SLOTS		= 6									-- Maximum number of weapon slots.
local CACHE_TIME	= 1									-- How often to precache weapons in seconds.
local OPEN_TIME		= 3									-- How many seconds to stay open after no activity.
local MOVE_SOUND	= "Player.WeaponSelectionMoveSlot"	-- Sound to play when flipping through weapons.
local SELECT_SOUND	= "Player.WeaponSelected"			-- Sound to play when a weapon is selected.
-- End Config


-- Micro-optimize
local pairs, RealTime, LocalPlayer, math_floor, math_Clamp, math_min, tonumber, string_lower = pairs, RealTime, LocalPlayer, math.floor, math.Clamp, math.min, tonumber, string.lower
local surface_DrawRect, surface_SetDrawColor, surface_GetTextSize, surface_DrawText, surface_SetFont, surface_SetTextPos, surface_SetTextColor = surface.DrawRect, surface.SetDrawColor, surface.GetTextSize, surface.DrawText, surface.SetFont, surface.SetTextPos, surface.SetTextColor

-- Useful Variables
local iCurSlot = 0 -- Currently selected slot. 0 = no selection
local iCurPos = 1 -- Current position in that slot
local flNextPrecache = 0 -- Time until next precache
local flSelectTime = 3 -- Time the weapon selection changed slot/visibility states. Can be used to close the weapon selector after a certain amount of idle time
local iWeaponCount = 0 -- Total number of weapons on the player

local tCache = {}	-- Weapon cache; table of tables. tCache[Slot + 1] contains a table containing that slot's weapons. Table's length is tCacheLength[Slot + 1]
local tCacheLength = {}	-- Weapon cache length. tCacheLength[Slot + 1] will contain the number of weapons that slot has
local cl_drawhud = GetConVar("cl_drawhud")

-- Initialize tables with slot number
for i = 1, MAX_SLOTS do
	tCache[i] = {}
	tCacheLength[i] = 0
end

local function PrecacheWeps()
	-- Reset all table values
	for i = 1, MAX_SLOTS do
		for j = 1, tCacheLength[i] do
			tCache[i][j] = nil
		end

		tCacheLength[i] = 0
	end

	-- Update the cache time
	flNextPrecache = RealTime() + CACHE_TIME
	iWeaponCount = 0

	-- Discontinuous table
	for _, pWeapon in pairs(LocalPlayer():GetWeapons()) do
		iWeaponCount = iWeaponCount + 1

		-- Weapon slots start internally at "0"
		-- Here, we will start at "1" to match the slot binds
		local iSlot = pWeapon:GetSlot() + 1

		if (iSlot <= MAX_SLOTS) then
			-- Cache number of weapons in each slot
			local iLen = tCacheLength[iSlot] + 1
			tCacheLength[iSlot] = iLen
			tCache[iSlot][iLen] = pWeapon
		end
	end

	-- Make sure we're not pointing out of bounds
	if (iCurSlot ~= 0) then
		local iLen = tCacheLength[iCurSlot]

		if (iLen < iCurPos) then
			if (iLen == 0) then
				iCurSlot = 0
			else
				iCurPos = iLen
			end
		end
	end
end

function TTT.VGUI.WeaponSwitcherHandler(pPlayer, sBind, bPressed)
	if (not pPlayer:Alive() or pPlayer:InVehicle() and not pPlayer:GetAllowWeaponsInVehicle()) then
		return
	end

	sBind = string_lower(sBind)

	-- Close the menu
	if (sBind == "cancelselect") then
		if (bPressed) then
			iCurSlot = 0
		end

		return true
	end

	-- Move to the weapon before the current
	if (sBind == "invprev") then
		if (not bPressed) then
			return true
		end

		PrecacheWeps()

		if (iWeaponCount == 0) then
			return true
		end

		local bLoop = iCurSlot == 0

		if (bLoop) then
			local pActiveWeapon = pPlayer:GetActiveWeapon()

			if (pActiveWeapon:IsValid()) then
				local iSlot = pActiveWeapon:GetSlot() + 1
				local tSlotCache = tCache[iSlot]

				if (tSlotCache[1] ~= pActiveWeapon) then
					iCurSlot = iSlot
					iCurPos = 1

					for i = 2, tCacheLength[iSlot] do
						if (tSlotCache[i] == pActiveWeapon) then
							iCurPos = i - 1

							break
						end
					end

					flSelectTime = RealTime()
					pPlayer:EmitSound(MOVE_SOUND)

					return true
				end

				iCurSlot = iSlot
			end
		end

		if (bLoop or iCurPos == 1) then
			repeat
				if (iCurSlot <= 1) then
					iCurSlot = MAX_SLOTS
				else
					iCurSlot = iCurSlot - 1
				end
			until(tCacheLength[iCurSlot] ~= 0)

			iCurPos = tCacheLength[iCurSlot]
		else
			iCurPos = iCurPos - 1
		end

		flSelectTime = RealTime()
		pPlayer:EmitSound(MOVE_SOUND)

		return true
	end

	-- Move to the weapon after the current
	if (sBind == "invnext") then
		if (not bPressed) then
			return true
		end

		PrecacheWeps()

		-- Block the action if there aren't any weapons available
		if (iWeaponCount == 0) then
			return true
		end

		-- Lua's goto can't jump between child scopes
		local bLoop = iCurSlot == 0

		-- Weapon selection isn't currently open, move based on the active weapon's position
		if (bLoop) then
			local pActiveWeapon = pPlayer:GetActiveWeapon()

			if (pActiveWeapon:IsValid()) then
				local iSlot = pActiveWeapon:GetSlot() + 1
				local iLen = tCacheLength[iSlot]
				local tSlotCache = tCache[iSlot]

				if (tSlotCache[iLen] ~= pActiveWeapon) then
					iCurSlot = iSlot
					iCurPos = 1

					for i = 1, iLen - 1 do
						if (tSlotCache[i] == pActiveWeapon) then
							iCurPos = i + 1
							break
						end
					end

					flSelectTime = RealTime()
					pPlayer:EmitSound(MOVE_SOUND)

					return true
				end

				-- At the end of a slot, move to the next one
				iCurSlot = iSlot
			end
		end

		if (bLoop or iCurPos == tCacheLength[iCurSlot]) then
			-- Loop through the slots until one has weapons
			repeat
				if (iCurSlot == MAX_SLOTS) then
					iCurSlot = 1
				else
					iCurSlot = iCurSlot + 1
				end
			until(tCacheLength[iCurSlot] ~= 0)

			-- Start at the beginning of the new slot
			iCurPos = 1
		else
			-- Bump up the position
			iCurPos = iCurPos + 1
		end

		flSelectTime = RealTime()
		pPlayer:EmitSound(MOVE_SOUND)

		return true
	end

	-- Keys 1-6
	if (sBind:sub(1, 4) == "slot") then
		local iSlot = tonumber(sBind:sub(5))

		-- If the command is slot#, use it for the weapon HUD
		-- Otherwise, let it pass through to prevent false positives
		if (iSlot == nil) then
			return
		end

		if (not bPressed) then
			return true
		end

		PrecacheWeps()

		-- Play a sound even if there aren't any weapons in that slot for "haptic" (really auditory) feedback
		if (iWeaponCount == 0) then
			pPlayer:EmitSound(MOVE_SOUND)

			return true
		end

		-- If the slot number is in the bounds
		if (iSlot <= MAX_SLOTS) then
			-- If the slot is already open
			if (iSlot == iCurSlot) then
				-- Start back at the beginning
				if (iCurPos == tCacheLength[iCurSlot]) then
					iCurPos = 1
				-- Move one up
				else
					iCurPos = iCurPos + 1
				end
			-- If there are weapons in this slot, display them
			elseif (tCacheLength[iSlot] ~= 0) then
				iCurSlot = iSlot
				iCurPos = 1
			end

			flSelectTime = RealTime()
			pPlayer:EmitSound(MOVE_SOUND)
		end

		return true
	end

	-- If the weapon selection is currently open
	if (iCurSlot ~= 0) then
		if (sBind == "+attack") then
			-- Hide the selection
			local pWeapon = tCache[iCurSlot][iCurPos]
			iCurSlot = 0

			-- If the weapon still exists and isn't the player's active weapon
			if (pWeapon:IsValid() and pWeapon ~= pPlayer:GetActiveWeapon()) then
				input.SelectWeapon(pWeapon)
			end

			flSelectTime = RealTime()
			pPlayer:EmitSound(SELECT_SOUND)

			return true
		end

		-- Another shortcut for closing the selection
		if (sBind == "+attack2") then
			flSelectTime = RealTime()
			iCurSlot = 0

			return true
		end
	end
end

-- Drawing constants.
local bar_width = 300									-- Weapon bar max width (before accounting for scaling).
local bar_height = 20									-- Weapon bar max height (before accounting for scaling).
local spacing_bottom = 5								-- Keep this many pixel spacing under each weapon bar.
local spacing_right = 5									-- Keep this many pixel spacing to the right of each bar.

local alpha -- Dont change.

-- Draw.
TTT.VGUI.AddElement("ttt_weapon_switcher", function(ply, w, h)
	if flSelectTime + OPEN_TIME < RealTime() then
		return
	end

	local plyWeapons = tCache[iCurSlot]			-- Weapons the player has on them.
	local numWeapons = tCacheLength[iCurSlot]	-- Number weapons the player has on them.
	local bar_w, bar_h = math_min(math_floor(w/TTT.VGUI.ttt_weapon_switcher_scale), bar_width), math_min(math_floor(h/TTT.VGUI.ttt_weapon_switcher_scale), bar_height)
	local bar_pos_x = w - bar_w - spacing_right					-- The x pos of the first bar
	local bar_pos_y = h - ((bar_h + spacing_bottom)*numWeapons)	-- The y pos of the first bar
	local gapForEachBar = bar_h + spacing_bottom -- Bump this many pixels down for each new bar

	surface_SetFont("TTT_WeaponSwitchText")

	for i = 1, numWeapons do
		local i_minusone = i-1	-- Is this excessive? Probably.

		-- Set the transparency of each bar. More transparent for unhighlighted bars.
		if iCurPos == i then
			alpha = TTT.VGUI.ttt_weapon_switcher_alpha * TTT.VGUI.ttt_weapon_switcher_alpha_selected
		else
			alpha = TTT.VGUI.ttt_weapon_switcher_alpha
		end
		surface_SetTextColor(255, 255, 255, (alpha-50)*1.3) -- Make the text a little more readable.
		surface_SetDrawColor(35, 35, 40, alpha)

		-- Draw background.
		surface_DrawRect(bar_pos_x, bar_pos_y + gapForEachBar*i_minusone, bar_w, bar_h)
		surface_SetDrawColor(35, 35, 40, alpha)

		-- Draw number box background.
		local numbox_w = bar_w/12
		local role_col = TTT.Roles.Colors[ply:GetRole()]
		surface_SetDrawColor(role_col.r, role_col.g, role_col.b, alpha)
		surface_DrawRect(bar_pos_x, bar_pos_y + gapForEachBar*i_minusone, numbox_w, bar_h)

		-- Draw weapon number text.
		local wepSlot = plyWeapons[i].Kind or WEAPON_INVALID
		local slottext_w, slottext_h = surface_GetTextSize(wepSlot)
		surface_SetTextPos(bar_pos_x + numbox_w/2 - slottext_w/2, bar_pos_y + i_minusone*(bar_h+spacing_bottom) + bar_h/2 - slottext_h/2)
		surface_DrawText(wepSlot)

		-- Draw the weapon names.
		local weaponName = isfunction(plyWeapons[i].GetTranslatedName) and plyWeapons[i]:GetTranslatedName() or plyWeapons[i]:GetPrintName()
		local weptext_w, weptext_h = surface_GetTextSize(weaponName)
		surface_SetTextPos(bar_pos_x + bar_w/2 - weptext_w/2, bar_pos_y + i_minusone*(bar_h+spacing_bottom) + bar_h/2 - weptext_h/2)
		surface_DrawText(weaponName)
	end
end, function(ply, isalive)
	if (iCurSlot == 0 or not cl_drawhud:GetBool()) then
		return false
	end

	-- Don't draw in vehicles unless weapons are allowed to be used
	-- Also, don't draw while dead!
	if (ply:IsValid() and isalive and (not ply:InVehicle() or ply:GetAllowWeaponsInVehicle())) then
		if (flNextPrecache <= RealTime()) then
			PrecacheWeps()
		end
		return true
	else
		iCurSlot = 0
		return false
	end
	return true
end)