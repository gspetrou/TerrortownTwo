TTT.Equipment = TTT.Equipment or {}
TTT.Equipment.Equipment = TTT.Equipment.Equipment or {}
TTT.Equipment.EquipmentHooks = TTT.Equipment.EquipmentHooks or {}
TTT.Equipment.InLoadoutCache = TTT.Equipment.InLoadoutCache or {}

-- TTT.Equipment.EquipmentItem Class.
do
	TTT.Equipment.EquipmentItem = {}
	TTT.Equipment.EquipmentItem.__index = TTT.Equipment.EquipmentItem
	local defaultmaterial = Material("phoenix_storms/plastic")	-- Should probably change later.

	----------
	-- Create
	----------
	-- Desc:		Constructs a TTT.Equipment.EquipmentItem object. Try not to call this directly and instead make a file in [addon]/lua/ttt/equipment/
	-- Arg One:		String, ID for this equipment. If made in [addons]/lua/ttt/equipment or [gamemode]/library/equipment/equipment then this will be the file name.
	-- Returns:		TTT.Equipment.EquipmentItem object.
	function TTT.Equipment.EquipmentItem:Create(id)
		local item = {}
		setmetatable(item, TTT.Equipment.EquipmentItem)
		item.ID = id
		item.Name = "UNSET"
		item.Description = "UNSET"
		item.Icon = defaultmaterial
		item.Hooks = {}
		item.InLoadoutFor = {}
		item.InStoreFor = {}
		item.OnEquip = function() end
		item.OnUnequip = function() end
		return item
	end

	-----------
	-- SetName
	-----------
	-- Desc:		Sets the name of the item. Can be a phrase id to be translated or just plain text.
	-- Arg One:		String, text.
	function TTT.Equipment.EquipmentItem:SetName(str)
		self.Name = str
	end
	
	-----------
	-- GetName
	-----------
	-- Desc:		Gets the equipment name.
	-- Returns:		String, text.
	function TTT.Equipment.EquipmentItem:GetName()
		return self.Name
	end
	
	------------------
	-- SetDescription
	------------------
	-- Desc:		Sets the description of the item. Can be a phrase id to be translated or just plain text.
	-- Arg One:		String, text.
	function TTT.Equipment.EquipmentItem:SetDescription(str)
		self.Description = str
	end
	
	------------------
	-- GetDescription
	------------------
	-- Desc:		Gets the equipment description.
	-- Returns:		String, text.
	function TTT.Equipment.EquipmentItem:GetDescription()
		return self.Description
	end

	-------------------
	-- SetInLoadoutFor
	-------------------
	-- Desc:		Sets what roles will start the round with this equipment.
	-- Arg One:		Table, of ROLE_ enums.
	function TTT.Equipment.EquipmentItem:SetInLoadoutFor(tbl)
		self.InLoadoutFor = tbl
	end

	-------------------
	-- GetInLoadoutFor
	-------------------
	-- Desc:		Gets what roles will start with the equipment.
	-- Returns:		Table, of ROLE_ enums.
	function TTT.Equipment.EquipmentItem:GetInLoadoutFor()
		return self.InLoadoutFor
	end

	-----------------
	-- SetInStoreFor
	-----------------
	-- Desc:		Sets what roles will be able to buy this equipment in their store.
	-- Arg One:		Table, of ROLE_ enums.
	function TTT.Equipment.EquipmentItem:SetInStoreFor(tbl)
		self.InStoreFor = tbl
	end

	-----------------
	-- GetInStoreFor
	-----------------
	-- Desc:		Gets what roles will be able to buy this equipment in their store.
	-- Returns:		Table, of ROLE_ enums.
	function TTT.Equipment.EquipmentItem:GetInStoreFor()
		return self.InStoreFor
	end

	-----------
	-- SetIcon
	-----------
	-- Desc:		Sets the icon to be used for this equipment.
	-- Arg One:		String, to be made into a material to use for an icon.
	function TTT.Equipment.EquipmentItem:SetIcon(matStr)
		self.Icon = Material(matStr)
	end
	
	-----------
	-- GetIcon
	-----------
	-- Desc:		Gets the icon for the equipment.
	-- Returns:		Material, used for the icon.
	function TTT.Equipment.EquipmentItem:GetIcon()
		return self.Material
	end

	-----------
	-- AddHook
	-----------
	-- Desc:		Adds a hook that the equipment will use. Nice to keep track of what equipment uses what hooks.
	-- Arg One:		String, hook name to hook on to.
	-- Arg Two:		Function, function with arguements to that hook. For example, PlayerSay would have a function with its sender, text, and teamchat arguments.
	function TTT.Equipment.EquipmentItem:AddHook(hookName, func)
		self.Hooks[hookName] = func
	end

	--------------
	-- RemoveHook
	--------------
	-- Desc:		Removes the given hook for the item object this method is ran on.
	-- Arg One:		String, hook name to remove.
	function TTT.Equipment.EquipmentItem:RemoveHook(hookName)
		self.Hooks[hookName] = nil
	end

	------------
	-- Register
	------------
	-- NOTE:		ONLY USE IF you are making an equipment somewhere that is not [addons]/ttt/equipment/ or [gamemode]/library/equipment/equipment/.
	-- Desc:		Registers a new equipment with the game, if the ID already exists then this will override it. Use this at the very end of making your equipment.
	function TTT.Equipment.EquipmentItem:Register()
		for i, role in ipairs(self.InLoadoutFor) do
			if not istable(TTT.Equipment.InLoadoutCache[role]) then
				TTT.Equipment.InLoadoutCache[role] = {}
			end
			table.insert(TTT.Equipment.InLoadoutCache[role], self.ID)
		end
		TTT.Equipment.Equipment[self.ID] = self
	end
end

-- Equipment Initialization.
do
	----------------------------
	-- TTT.Equipment.Initialize
	----------------------------
	-- Desc:		Initializes the equipment system. Just call this directly shared if you want to hot-update equipment.
	function TTT.Equipment.Initialize()
		TTT.Equipment.LoadFiles()	-- Loads the equipment files.
		TTT.Equipment.UpdateHooks()	-- Sets up the hooks each equipment will want to use.
	end

	---------------------------
	-- TTT.Equipment.LoadFiles
	---------------------------
	-- Desc:		Loads the equipment files.
	function TTT.Equipment.LoadFiles()
		local equipAddonRootPath = "ttt/equipment/"
		local equipGamemodeRootPath = GAMEMODE_NAME.."/gamemode/library/equipment/equipment/"

		local oldEQUIPMENT = EQUIPMENT
		local filesToLoad = {}

		-- Get all of the files we want to load. If an equipment in the addon area has the same name as a gamemode one then override that gamemode equipment.
		local files = file.Find(equipAddonRootPath.."*.lua", "LUA")
		for i, addonFileName in ipairs(files) do
			filesToLoad[addonFileName] = equipAddonRootPath..addonFileName
		end
		files = file.Find(equipGamemodeRootPath.."*.lua", "LUA")
		for i, gmFileName in ipairs(files) do
			filesToLoad[gmFileName] = equipGamemodeRootPath..gmFileName
		end

		for fileName, fullPath in pairs(filesToLoad) do
			if SERVER then
				AddCSLuaFile(fullPath)
			end

			local fileNameNoExt = fileName:sub(1, #fileName - 4)

			EQUIPMENT = TTT.Equipment.EquipmentItem:Create(fileNameNoExt)	-- Create a new equipment object, it's ID is the filename of the equipment we're about to load.
			include(fullPath)												-- Load the equipment file.
			TTT.Equipment.Equipment[fileNameNoExt] = EQUIPMENT				-- Store the object for later.

			-- Create a cache sorted by ROLE_ enums to easily decide what roles should have what equipment at round start.
			for i, role in ipairs(EQUIPMENT.InLoadoutFor) do
				if not istable(TTT.Equipment.InLoadoutCache[role]) then
					TTT.Equipment.InLoadoutCache[role] = {}
				end
				table.insert(TTT.Equipment.InLoadoutCache[role], fileNameNoExt)
			end
		end

		EQUIPMENT = oldEQUIPMENT
	end

	-----------------------------
	-- TTT.Equipment.UpdateHooks
	-----------------------------
	-- Desc:		Updates the hooks for all of the equipment.
	function TTT.Equipment.UpdateHooks()
		-- Remove all current equipment hooks.
		for hookName, _ in pairs(TTT.Equipment.EquipmentHooks) do
			hook.Remove(hookName, "TTT.Equipment")
		end
		TTT.Equipment.EquipmentHooks = {}

		-- Add new equipment hooks into the EquipmentHooks table.
		for equipName, info in pairs(TTT.Equipment.Equipment) do
			for hookName, fn in pairs(info.Hooks) do
				if not istable(TTT.Equipment.EquipmentHooks[hookName]) then
					TTT.Equipment.EquipmentHooks[hookName] = {}
				end

				TTT.Equipment.EquipmentHooks[hookName][equipName] = fn
			end
		end

		-- Set up our new hooks to run.
		for hookName, equipHooks in pairs(TTT.Equipment.EquipmentHooks) do
			hook.Add(hookName, "TTT.Equipment", function(...)
				for equipName, func in pairs(equipHooks) do
					local a, b, c, d, e, f = TTT.Equipment.EquipmentHooks[hookName][equipName](...)

					-- Hooks can only return a maximum of 6 values.
					-- Be careful returning here since it will override any other equipment trying to return a value in the same hook.
					if a or b or c or d or e or f then
						return a, b, c, d, e, f
					end
				end
			end)
		end
	end

	------------------------------------
	-- TTT.Equipment.CreateNewEquipment
	------------------------------------
	-- Note:		ONLY USE IF youre not creating your equipment in one of the two normal places, [addons]/ttt/equipment/ and [gamemode]/library/equipment/equipment/.
	-- Desc:		Creates a new equipment object that you can build your equipment with. Use :Register() to register the equipment with the gamemode.
	-- Returns:		TTT.Equipment.EquipmentItem Object.
	function TTT.Equipment.CreateNewEquipment(ID)
		return TTT.Equipment.EquipmentItem:Create(ID)
	end
end

if SERVER then	
	function TTT.Equipment.GiveRoleEquipment(ply)
		local role = ply:GetRole()
		if istable(TTT.Equipment.InLoadoutCache[role]) then
			for i, equip in ipairs(TTT.Equipment.InLoadoutCache[role]) do
				ply:GiveEquipment(equip)
			end
		end
	end


	local PLAYER = FindMetaTable("Player")

	------------------------
	-- PLAYER:GiveEquipment
	------------------------
	-- Desc:		Gives the player the given equipment via its ID.
	-- Arg One:		String, ID of the equipment we're giving.
	function PLAYER:GiveEquipment(id)
		if not istable(self.ttt_equipment) then
			self.ttt_equipment = {}
		end
		self.ttt_equipment[id] = true
		TTT.Equipment.Equipment[id].OnEquip(self)
	end

	-----------------------
	-- PLAYER:HasEquipment
	-----------------------
	-- Desc:		Sees if the player has the given equipment.
	-- Arg One:		String, equipment ID. Usually the file name of the equipment.
	-- Returns:		Boolean, do they have it or not.
	function PLAYER:HasEquipment(id)
		return tobool(istable(self.ttt_equipment) and self.ttt_equipment[id])
	end

	-----------------------
	-- PLAYER:GetEquipment
	-----------------------
	-- Desc:		Gets a table of all the player's equipment.
	-- Returns:		Table, full of string of their current equipment.
	function PLAYER:GetEquipment()
		if not istable(self.ttt_equipment) then
			self.ttt_equipment = {}
		end

		return self.ttt_equipment
	end

	--------------------------
	-- PLAYER:RemoveEquipment
	--------------------------
	-- Desc:		Removes the equipment of the given ID from the player.
	-- Arg One:		String, ID of the equipment to remove.
	function PLAYER:RemoveEquipment(id)
		if istable(self.ttt_equipment) and self.ttt_equipment[id] then
			self.ttt_equipment[id] = nil
			TTT.Equipment.Equipment[id].OnUnequip(self)
		end
	end
	
	-------------------------
	-- PLAYER:ClearEquipment
	-------------------------
	-- Desc:		Removes all the equipment a player has.
	function PLAYER:ClearEquipment()
		self.ttt_equipment = {}
	end
end