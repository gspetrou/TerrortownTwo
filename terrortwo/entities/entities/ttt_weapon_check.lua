ENT.Type = "brush"
ENT.Base = "base_brush"

function ENT:KeyValue(key, value)
	if key == "WeaponsFound" then
		self:StoreOutput(key, value)
	end
end

local function hasWeaponOfType(ply, wepType)
	for k, wep in pairs(ply:GetWeapons()) do
		if wep.Kind and wep.Kind == wepType then
			return true
		end
	end
	return false
end

local checkFunctions = {
	HasPrimary = function(ply)
		return hasWeaponOfType(ply, WEAPON_PRIMARY)
	end,
	HasSecondary = function(ply)
		return hasWeaponOfType(ply, WEAPON_SECONDARY)
	end,
	HasEquipment = function(ply)
		return #ply:GetEquipment() > 0
	end,
	HasNade = function(ply)
		return hasWeaponOfType(ply, WEAPON_GRENADE)
	end,
	HasAny = function(ply)
		return hasWeaponOfType(ply, WEAPON_PRIMARY) or hasWeaponOfType(ply, WEAPON_SECONDARY) or hasWeaponOfType(ply, WEAPON_GRENADE)
	end,
	HasNamed = function(ply, name)
		return ply:HasWeapon(name)
	end
}

local checkers = {
	checkFunctions.HasPrimary,
	checkFunctions.HasSecondary,
	checkFunctions.HasEquipment,
	checkFunctions.HasNade,
	checkFunctions.HasAny
}

function ENT:TestWeapons(weapon)
	local mins = self:LocalToWorld(self:OBBMins())
	local maxs = self:LocalToWorld(self:OBBMaxs())
	local checkFunc

	if isnumber(weapon) then
		checkFunc = checkers[weapon]
	elseif isstring(weapon) then
		checkFunc = checkFunctions.HasNamed
	else
		ErrorNoHalt("ttt_weapon_check: invalid parameter\n")
		return 0
	end

	for i, ply in ipairs(player.GetAll()) do
		if IsValid(ply) and ply:Alive() then
			local pos = ply:GetPos()
			local center = ply:LocalToWorld(ply:OBBCenter())
			if TTT.IsInMinMax(pos, mins, maxs) or TTT.IsInMinMax(center, mins, maxs) then
				if checkFunc(ply, weapon) then
					return 1
				end
			end
		end
	end
end

function ENT:AcceptInput(name, activator, caller, data)
	if name == "CheckForType" or name == "CheckForClass" then
		local weapon = tonumber(data) or tostring(data)

		if weapon == nil then
			ErrorNoHalt("ttt_weapon_check: Invalid parameter to CheckForWeapons input!\n")
			return false
		end

		local weapons = self:TestWeapons(weapon)

		self:TriggerOutput("WeaponsFound", activator, weapons)

		return true
	end
end
