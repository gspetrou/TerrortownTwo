TTT.Equipment = TTT.Equipment or {}
TTT.Equipment.Equipment = TTT.Equipment.Equipment or {}
TTT.Equipment.EquipmentHooks = TTT.Equipment.EquipmentHooks or {}

-- Equipment Class.
do
	TTT.Equipment.EquipmentItem = {}
	TTT.Equipment.EquipmentItem.__index = TTT.Equipment.EquipmentItem
	local defaultmaterial = Material("phoenix_storms/plastic")	-- Should probably change later.
	function TTT.Equipment.EquipmentItem:Create(id)
		local item = {}
		setmetatable(item, TTT.Equipment.EquipmentItem)
		item.ID = id
		item.Name = "UNSET"
		item.Description = "UNSET"
		item.Material = defaultmaterial
		item.Hooks = {}
		item.InLoadoutFor = {}
		item.InStoreFor = {}
		item.OnEquip = function() end
		item.OnUnequip = function() end
		return item
	end

	function TTT.Equipment.EquipmentItem:SetName(str)
		self.Name = str
	end
	
	function TTT.Equipment.EquipmentItem:GetName()
		return self.Name
	end
	
	function TTT.Equipment.EquipmentItem:SetDescription(str)
		self.Description = str
	end
	
	function TTT.Equipment.EquipmentItem:GetDescription()
		return self.Description
	end

	function TTT.Equipment.EquipmentItem:SetInLoadoutFor(tbl)
		self.InLoadoutFor = tbl
	end

	function TTT.Equipment.EquipmentItem:GetInLoadoutFor()
		return self.InLoadoutFor
	end

	function TTT.Equipment.EquipmentItem:SetInStoreFor(tbl)
		self.InStoreFor = tbl
	end

	function TTT.Equipment.EquipmentItem:GetInStoreFor()
		return self.InStoreFor
	end

	function TTT.Equipment.EquipmentItem:SetMaterial(mat)
		self.Material = Material(mat)
	end
	
	function TTT.Equipment.EquipmentItem:GetMaterial()
		return self.Material
	end

	function TTT.Equipment.EquipmentItem:AddHook(hookName, func)
		self.Hooks[hookName] = func
	end

	function TTT.Equipment.EquipmentItem:RemoveHook(hookName)
		self.Hooks[hookName] = nil
	end
end

-- Equipment Initialization.
do
	-- Just call this directly shared if you want to hot-update equipment.
	function TTT.Equipment.Initialize()
		TTT.Equipment.LoadFiles()	-- Loads the equipment files.
		TTT.Equipment.UpdateHooks()	-- Sets up the hooks each equipment will want to use.
	end

	function TTT.Equipment.LoadFiles()
		local equipAddonRootPath = "ttt/equipment/"
		local equipGamemodeRootPath = GAMEMODE_NAME.."/gamemode/library/equipment/equipment/"

		local files = file.Find(equipAddonRootPath.."*.lua", "LUA")
		local loadedFiles = {}

		local oldEQUIPMENT = EQUIPMENT

		-- Load addon files first in case they want to override the gamemode's.
		for i, filename in ipairs(files) do
			local filenameNoExt = filename:sub(1, #filename - 4)
			loadedFiles[filenameNoExt] = true

			if SERVER then
				AddCSLuaFile(equipAddonRootPath..filename)
			end

			EQUIPMENT = TTT.Equipment.EquipmentItem:Create(filenameNoExt)
			include(equipAddonRootPath..filename)
			TTT.Equipment.Equipment[filenameNoExt] = EQUIPMENT
		end

		files = file.Find(equipGamemodeRootPath.."*.lua", "LUA")
		for i, filename in ipairs(files) do
			local filenameNoExt = filename:sub(1, #filename - 4)
			if not loadedFiles[filenameNoExt] then
				loadedFiles[filename] = true

				if SERVER then
					AddCSLuaFile(equipGamemodeRootPath..filename)
				end

				EQUIPMENT = TTT.Equipment.EquipmentItem:Create(filenameNoExt)
				include(equipGamemodeRootPath..filename)
				TTT.Equipment.Equipment[filenameNoExt] = EQUIPMENT
			end
		end

		EQUIPMENT = oldEQUIPMENT
	end

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
end

if SERVER then
	local PLAYER = FindMetaTable("Player")
	function PLAYER:GiveEquipment(id)
		if not istable(self.ttt_equipment) then
			self.ttt_equipment = {}
		end
		self.ttt_equipment[id] = true
		TTT.Equipment.Equipment[id].OnEquip(self)
	end

	function PLAYER:HasEquipment(id)
		return tobool(istable(self.ttt_equipment) and self.ttt_equipment[id])
	end

	function PLAYER:RemoveEquipment(id)
		if istable(self.ttt_equipment) and self.ttt_equipment[id] then
			self.ttt_equipment[id] = nil
			TTT.Equipment.Equipment[id].OnUnequip(self)
		end
	end
	
	function PLAYER:ClearEquipment()
		self.ttt_equipment = {}
	end
end