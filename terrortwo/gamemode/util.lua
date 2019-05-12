-- This is a small utility library loaded before the gamemode's library and used throughout the gamemode.
TTT = TTT or {}	-- Used for almost everything.

-- Thanks TTT.
TTT.Colors = {
	Dead		= Color(90, 90, 90, 230),
	Innocent	= Color(39, 174, 96, 230),
	Detective	= Color(41, 128, 185, 230),
	Traitor		= Color(192, 57, 43, 230),
	PunchYellow	= Color(205, 155, 0),

	White		= Color(255, 255, 255),
	Black		= Color(0, 0, 0),
	Green		= Color(0, 255, 0),
	DarkGreen	= Color(0, 100, 0),
	Red			= Color(255, 0, 0),
	Yellow		= Color(200, 200, 0),
	LightGray	= Color(200, 200, 200),
	Blue		= Color(0, 0, 255),
	Navy		= Color(0, 0, 100),
	Pink		= Color(255, 0, 255),
	Orange		= Color(250, 100, 0),
	Olive		= Color(100, 100, 0)
}

-------------------
-- net.WritePlayer
-------------------
-- Desc:		A more optimized version of net.WriteEntity specifically for players.
-- Arg One:		Player entity to be networked.
if not net.WritePlayer then
	function net.WritePlayer(ply)
		if IsValid(ply) then
			net.WriteUInt(ply:EntIndex(), 7)
		else
			net.WriteUInt(0, 7)
		end
	end
end

------------------
-- net.ReadPlayer
------------------
-- Desc:		Optimized version of net.ReadEntity specifically for players.
-- Returns:		Player entity thats been written.
if not net.ReadPlayer then
	function net.ReadPlayer()
		local i = net.ReadUInt(7)
		if not i then
			return
		end
		return Entity(i)
	end
end

----------------
-- table.Filter
----------------
-- CREDITS:		Copied from the dash library by SuperiorServers (https://github.com/SuperiorServers/dash)
-- Desc:		Will use the given function to filter out certain members from the given table. Edits the given table.
-- Arg One:		Table, to be filtered.
-- Arg Two:		Function, decides what should be filters.
-- Returns:		Table, same table as arg one but filtered.
function table.Filter(tab, func)
	local c = 1
	for i = 1, #tab do
		if func(tab[i]) then
			tab[c] = tab[i]
			c = c + 1
		end
	end
	for i = c, #tab do
		tab[i] = nil
	end
	return tab
end

--------------------
-- table.FilterCopy
--------------------
-- CREDITS:		Copied from the dash library by SuperiorServers (https://github.com/SuperiorServers/dash)
-- Desc:		Will use the given function to filter out certain members from the given table. Gives a new table that is a copy of the given table but filtered.
-- Arg One:		Table, to be filtered.
-- Arg Two:		Function, decides what should be filters.
-- Returns:		Table, same table as arg one but filtered.
function table.FilterCopy(tab, func)
	local ret = {}
	for i = 1, #tab do
		if func(tab[i]) then
			ret[#ret + 1] = tab[i]
		end
	end
	return ret
end

--------------------------
-- table.RandomSequential
--------------------------
-- Desc:		Returns a random value in a seqential table.
-- Returns:		1:	Any, value in the table.
-- 				2:	Number, where that value is found in the table.
function table.RandomSequential(tbl)
	local i = math.random(1, #tbl)
	return tbl[i], i
end

------------------
-- table.SortCopy
------------------
-- Desc:		Same as table.sort but returns a copy rather than modifying the original table.
-- Arg One:		Table, to be copied and then sorted.
-- Arg Two:		Function, to sort table by. Same setup as table.sort's second arguement.
-- Returns:		Table, sorted copy of the given table.
function table.SortCopy(original, sortFunc)
	local tbl = original
	table.sort(tbl, sortFunc)
	return tbl
end

-----------------
-- table.Shuffle
-----------------
-- Desc:		Shuffles a sequential table, straight copy from TTT.
-- Arg One:		Table, to be shuffled.
-- Returns:		Table, thats been shuffled.
function table.Shuffle(tbl)
	local n = #tbl

	while n > 2 do
		local k = math.random(n)
		tbl[n], tbl[k] = tbl[k], tbl[n]
		n = n - 1
	end

	return tbl
end

-------------------------
-- math.ExponentialDecay
-------------------------
-- Desc:		Equivalent to ExponentialDecay from Source Engine's mathlib. Used for fallof curves.
-- Arg One:		Number, half life of the curve. How long it takes for the curve to reach half of it's current value.
-- Arg Two:		Number, where on the x-axis are we, how far into the curve.
-- Returns:		Number, y-axis of the curve. How much we've decayed at this point.
function math.ExponentialDecay(halfLife, decayTime)
	return math.exp((-0.69314718 / halfLife) * decayTime)
end

------------------
-- TTT.IsInMinMax
------------------
-- Desc:		Sees if a vector is inside of the given min and max.
-- Arg One:		Vector, vector to see if its in an area.
-- Arg Two:		Vector, Min.
-- Arg Three:	Vector, Max.
-- Returns:		Boolean, is the first vector between the min and max vectors.
function TTT.IsInMinMax(vec, mins, maxs)
	return (vec.x > mins.x and vec.x < maxs.x
		and vec.y > mins.y and vec.y < maxs.y
		and vec.z > mins.z and vec.z < maxs.z)
end

----------------------------
-- TTT.WeaponFromDamageInfo
----------------------------
-- Desc:		Gets what weapon caused damage from the given damage info.
-- Arg One:		CTakeDamageInfo object.
-- Returns:		Weapon or nil. Nil if it was world or unknown.
function TTT.WeaponFromDamageInfo(dmgInfo)
	local inflictor = dmgInfo:GetInflictor()
	local weapon = nil
	
	if IsValid(inflictor) then
		if inflictor:IsWeapon() or inflictor.IsProjectile then
			weapon = inflictor
		elseif dmgInfo:IsDamageType(DMG_DIRECT) or dmgInfo:IsDamageType(DMG_CRUSH) then
			-- DMG_DIRECT is the player burning, no weapon involved
			-- DMG_CRUSH is physics or falling on someone
			weapon = nil
		elseif inflictor:IsPlayer() then
			weapon = inflictor:GetActiveWeapon()
			if not IsValid(weapon) then
				-- This may have been a dying shot, in which case we need a
				-- workaround to find the weapon because it was dropped on death
				weapon = IsValid(inflictor.DyingWeapon) and inflictor.DyingWeapon or nil
			end
		end
	end

	return weapon
end

if CLIENT then
	-----------------------
	-- TTT.IsCoordOnScreen
	-----------------------
	-- Desc:		Sees if the given coordinates are on the players screen.
	-- Arg One:		Number, x coordinate.
	-- Arg Two:		Number, y coordinate.
	-- Returns:		Boolean, would the given coordinate pair appear on the player's screen.
	function TTT.IsCoordOnScreen(x, y)
		return x >= 0 and x <= ScrW() and y >= 0 and y <= ScrH()
	end

	--------------------------
	-- TTT.BreakTextIntoLines
	--------------------------
	-- Desc:		Given a string of text and a width returns a table of substrings that will fit nicely within that width. Will not break up mid word.
	-- Arg One:		String, text to break up
	-- Arg Two:		Number, max width this the text can take before being broken to a new line.
	-- Arg Three:	(Optional=Nil) String, font used for this text. If left nil this simply uses the current set font.
	-- Returns:		Table, array of strings broken to proper width.
	-- Notice:		This function internally calls surface.SetFont if given a third arg. Make sure to re-set the font type if you want to draw with a different font after calling this function.
	--				Also note that a \n anywhere in the given string will force a new line at that position as well.
	function TTT.BreakTextIntoLines(text, windowWidth, font)
		if isstring(font) then
			surface.SetFont(font)
		end

		-- A very likely case so lets try this first before breaking apart by word.
		local fullWidth = surface.GetTextSize(text)
		if fullWidth <= windowWidth then
			return string.Explode("\n", text, false)
		end

		local spaceWidth = surface.GetTextSize(" ")
		local wordsByNewLine = string.Explode("\n", text, false)

		local curLineWidth = 0
		local curLine = 1
		local output = {}
		for _, wordGroup in ipairs(wordsByNewLine) do
			local words = string.Explode(" ", wordGroup, false)
			for i, word in ipairs(words) do
				local wordWidth = surface.GetTextSize(word)

				if curLineWidth + wordWidth + spaceWidth > windowWidth then
					curLineWidth = 0
					curLine = curLine + 1
					output[curLine] = word
				else
					curLineWidth = curLineWidth + wordWidth + spaceWidth
					output[curLine] = (isstring(output[curLine]) and output[curLine].." " or "")..word
				end
			end

			curLineWidth = 0
			curLine = curLine + 1
		end

		return output
	end
end

---------------
-- util.BitSet
---------------
-- Desc:		Sees if a given bit is set on in a given number.
-- Returns:		Boolean, is the given bit set.
function util.BitSet(value, bit)
	return bit.band(value, bit) == bit
end

------------------
-- util.PaintDown
------------------
-- Desc:		Puts a decal on whatever is below the starting point.
-- Arg One:		Vector, starting point.
-- Arg Two:		String, effect name to put.
-- Arg Three:	Entity or table of entities, to ignore hitting in our trace.
function util.PaintDown(start, effname, ignore)
	local btr = util.TraceLine({
		start = start,
		endpos = (start + Vector(0,0,-256)),
		filter = ignore,
		mask = MASK_SOLID
	})

	util.Decal(effname, btr.HitPos + btr.HitNormal, btr.HitPos - btr.HitNormal)
end

---------------------
-- TTT.StartBleeding
---------------------
-- Desc:		Makes a given entity bleed.
-- Arg One:		Entity, to bleed.
-- Arg Two:		Number, how much damage the entity recieved to scale the bleeding.
-- Arg Three:	Number, how long should they bleed for.
function TTT.StartBleeding(ent, dmg, time)
	if dmg < 5 or not IsValid(ent) or (ent:IsPlayer() and not ent:Alive()) then
		return
	end

	local times = math.Clamp(math.Round(dmg / 15), 1, 20)
	local delay = math.Clamp(time / times , 0.1, 2)

	if ent:IsPlayer() then
		times = times * 2
		delay = delay / 2
	end

	timer.Create("TTT.Bleed_" .. ent:EntIndex(), delay, times, function()
		if not IsValid(ent) or (ent:IsPlayer() and not ent:Alive()) then
			return
		end

		local jitter = VectorRand() * 30
		jitter.z = 20

		util.PaintDown(ent:GetPos() + jitter, "Blood", ent)
	end)
end

--------------------
-- TTT.StopBleeding
--------------------
-- Desc:		Stops the given entity from bleeding if they are.
-- Arg One:		Player, to stop bleeding.
function TTT.StopBleeding(ent)
	if timer.Exists("TTT.Bleed_" .. ent:EntIndex()) then
		timer.Remove("TTT.Bleed_" .. ent:EntIndex())
	end
end

-- Simple VGUI Icons.
-- Pretty much verbatim stolen from TTT, thanks Badking.
if CLIENT then
	-- This panel is a very stripped down version of the Sandbox spawnicons. It doesn't support models and most advanced features.
	do
		local PANEL = {
			HoverMaterial = Material("vgui/spawnmenu/hover")
		}

		AccessorFunc(PANEL, "m_iIconSize","IconSize")

		function PANEL:Init()
			self.Icon = vgui.Create("DImage", self)
			self.Icon:SetMouseInputEnabled(false)
			self.Icon:SetKeyboardInputEnabled(false)

			self.animPress = Derma_Anim("Press", self, self.PressedAnim)
			self:SetIconSize(64)
		end

		function PANEL:OnMousePressed(mcode)
			if mcode == MOUSE_LEFT then
				self:DoClick()
				self.animPress:Start(0.1)
			end
		end

		function PANEL:OnMouseReleased()		end
		function PANEL:DoClick()				end
		function PANEL:OpenMenu()				end
		function PANEL:ApplySchemeSettings()	end

		function PANEL:OnCursorEntered()
			self.PaintOverOld = self.PaintOver
			self.PaintOver = self.PaintOverHovered
		end

		function PANEL:OnCursorExited()
			if self.PaintOver == self.PaintOverHovered then
				self.PaintOver = self.PaintOverOld
			end
		end

		function PANEL:PaintOverHovered()
			if self.animPress:Active() then
				return
			end

			surface.SetDrawColor(255, 255, 255, 80)
			surface.SetMaterial(self.HoverMaterial)
			self:DrawTexturedRect()
		end

		function PANEL:PerformLayout()
			if self.animPress:Active() then
				return
			end
			self:SetSize(self.m_iIconSize, self.m_iIconSize)
			self.Icon:StretchToParent(0, 0, 0, 0)
		end

		function PANEL:SetIcon(icon)
			self.Icon:SetImage(icon)
		end

		function PANEL:GetIcon()
			return self.Icon:GetImage()
		end

		function PANEL:SetIconColor(clr)
			self.Icon:SetImageColor(clr)
		end

		function PANEL:Think()
			self.animPress:Run()
		end

		function PANEL:PressedAnim(anim, delta, data)
			if anim.Started then
				return
			end

			if anim.Finished then
				self.Icon:StretchToParent(0, 0, 0, 0)
				return
			end

			local border = math.sin(delta * math.pi) * (self.m_iIconSize * 0.05)
			self.Icon:StretchToParent(border, border, border, border)
		end
		vgui.Register("SimpleIcon", PANEL, "Panel")
	end

	-- This panel supports multiple images layered over each other.
	do
		local PANEL = {}

		function PANEL:Init()
			self.Layers = {}
		end

		-- Add a panel to this icon. Most recent addition will be the top layer.
		function PANEL:AddLayer(pnl)
			if not IsValid(pnl) then
				return
			end

			pnl:SetParent(self)

			pnl:SetMouseInputEnabled(false)
			pnl:SetKeyboardInputEnabled(false)

			table.insert(self.Layers, pnl)
		end

		function PANEL:PerformLayout()
			if self.animPress:Active() then
				return
			end
			self:SetSize(self.m_iIconSize, self.m_iIconSize)
			self.Icon:StretchToParent(0, 0, 0, 0)

			for _, p in ipairs(self.Layers) do
				p:SetPos(0, 0)
				p:InvalidateLayout()
			end
		end

		function PANEL:EnableMousePassthrough(pnl)
			for _, p in pairs(self.Layers) do
				if p == pnl then
					p.OnMousePressed = function(s, mc) s:GetParent():OnMousePressed(mc) end
					p.OnCursorEntered = function(s) s:GetParent():OnCursorEntered() end
					p.OnCursorExited = function(s) s:GetParent():OnCursorExited() end

					p:SetMouseInputEnabled(true)
				end
			end
		end
		vgui.Register("LayeredIcon", PANEL, "SimpleIcon")
	end

	-- Simple icon that supports avatar images of a player.
	do
		local PANEL = {}

		function PANEL:Init()
			self.imgAvatar = vgui.Create("AvatarImage", self)
			self.imgAvatar:SetMouseInputEnabled(false)
			self.imgAvatar:SetKeyboardInputEnabled(false)
			self.imgAvatar.PerformLayout = function(s) s:Center() end

			self:SetAvatarSize(32)
			self:AddLayer(self.imgAvatar)
		end

		function PANEL:SetAvatarSize(s)
			self.imgAvatar:SetSize(s, s)
		end

		function PANEL:SetPlayer(ply)
			self.imgAvatar:SetPlayer(ply)
		end
		vgui.Register("SimpleIconAvatar", PANEL, "LayeredIcon")
	end

	-- Simple icon that supports a text label.
	do
		local PANEL = {}
		AccessorFunc(PANEL, "IconText", "IconText")
		AccessorFunc(PANEL, "IconTextColor", "IconTextColor")
		AccessorFunc(PANEL, "IconFont", "IconFont")
		AccessorFunc(PANEL, "IconTextShadow", "IconTextShadow")
		AccessorFunc(PANEL, "IconTextPos", "IconTextPos")

		function PANEL:Init()
			self:SetIconText("")
			self:SetIconTextColor(Color(255, 200, 0))
			self:SetIconFont("TargetID")
			self:SetIconTextShadow({opacity=255, offset=2})
			self:SetIconTextPos({32, 32})

			-- DPanelSelect loves to overwrite its children's PaintOver hooks and such,
			-- so have to use a dummy panel to do some custom painting.
			self.FakeLabel = vgui.Create("Panel", self)
			self.FakeLabel.PerformLayout = function(s) s:StretchToParent(0,0,0,0) end

			self:AddLayer(self.FakeLabel)

			return self.BaseClass.Init(self)
		end

		function PANEL:PerformLayout()
			self:SetLabelText(self:GetIconText(), self:GetIconTextColor(), self:GetIconFont(), self:GetIconTextPos())

			return self.BaseClass.PerformLayout(self)
		end

		function PANEL:SetIconProperties(color, font, shadow, pos)
			self:SetIconTextColor(color or self:GetIconTextColor())
			self:SetIconFont(font or self:GetIconFont())
			self:SetIconTextShadow(shadow or self:GetIconShadow())
			self:SetIconTextPos(pos or self:GetIconTextPos())
		end

		function PANEL:SetLabelText(text, color, font, pos)
			if self.FakeLabel then
				local spec = {
					pos = pos,
					color = color,
					text = text,
					font = font,
					xalign = TEXT_ALIGN_CENTER,
					yalign = TEXT_ALIGN_CENTER
				}

				local shadow = self:GetIconTextShadow()
				local opacity = shadow and shadow.opacity or 0
				local offset = shadow and shadow.offset or 0

				local drawfn = shadow and draw.TextShadow or draw.Text

				self.FakeLabel.Paint = function()
					drawfn(spec, offset, opacity)
				end
			end
		end
		vgui.Register("SimpleIconLabelled", PANEL, "LayeredIcon")
	end
end