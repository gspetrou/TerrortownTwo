TTT.Corpse = TTT.Corpse or {}

-- Search menu.
do
	local PANEL = {}

	

	vgui.Register("TTT.Corpse.BodySearchMenu", PANEL, "DFrame")
end

-- Networking and Handling.
do
	---------------------------------
	-- TTT.Corpse.OpenBodySearchMenu
	---------------------------------
	-- Desc:		Opens the corpse search info menu.
	-- Arg One:		Entity, the corpse we want to open the menu for.
	function TTT.Corpse.OpenBodySearchMenu(corpse)
		local frame = vgui.Create("TTT.Corpse.BodySearchMenu")
		frame:Center()
	end

	net.Receive("TTT.Corpse.OpenSearchMenu", function()
		local corpseEntity = net.ReadEntity()
		
		if IsValid(corpseEntity) then
			TTT.Corpse.OpenBodySearchMenu(corpseEntity)
		end
	end)

	net.Receive("TTT.Corpse.SearchInfo", function()
		local corpseEntity = net.ReadEntity()
		local ownerName = net.ReadString()
		local ownerRole = net.ReadUInt(3)
		local deathDamageType = net.ReadUInt(31)
		local murderWeaponClass = net.ReadString()
		local wasHeadshot = net.ReadBool()
		local deathTime = net.ReadUInt(32)

		-- TODO: Read equipment
		-- TODO: Read C4 info
		-- TODO: Read DNA sample decay time
	end)
end