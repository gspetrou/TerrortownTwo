TTT.Weapons = TTT.Weapons or {}
local wepCount = CreateConVar("ttt_weapon_spawn_count", "0", FCVAR_ARCHIVE, "How many extra weapons to spawn on unarmed CSS/TF2 maps. 0 for max player count + 3 amount.")
local useImportScripts = CreateConVar("ttt_weapon_use_import_scripts", "1", FCVAR_ARCHIVE, "Should we use weapon import scripts.")

-- If it were up to me I'd use vON or pON to store the import scripts no problem.
-- But alas, we are stuck with what Badking left us. That being said, a good portion of this code is from Badking.
-- Script file parsing code made with help from mijyuoon.

-------------------------------------
-- TTT.Weapons.PlaceWeaponsAtClasses
-------------------------------------
-- Desc:		Places weapons at the given table of entity classes till we reach ttt_weapon_spawn_count amount of weapons.
-- Arg One:		Table, of entity classes.
function TTT.Weapons.PlaceWeaponsAtClasses(entClasses)
	-- Get all entities of the given class to spawn weapons at.
	local entities = {}
	for _, entClass in ipairs(entClasses) do
		for _, ent in ipairs(ents.FindByClass(entClass)) do
			table.insert(entities, ent)
		end
	end

	-- Get all weapons we can spawn and then decide how many we should spawn.
	local weps = TTT.Weapons.GetMapSpawnableWeapons()
	local maxWeps = wepCount:GetInt()
	if maxWeps == 0 then
		maxWeps = game.MaxPlayers()
		maxWeps = maxWeps + math.max(3, 0.33 * maxWeps)
	end

	-- Spawn weapons at the given entities randomly, with a random amount of ammo between 0 and 3 for each.
	local numWeps = 0
	for k, spawnEnt in RandomPairs(entities) do
		local wepClass = table.RandomSequential(weps)
		numWeps = numWeps + 1

		if IsValid(spawnEnt) and util.IsInWorld(spawnEnt:GetPos()) then
			local wep = ents.Create(wepClass)
			local pos = spawnEnt:GetPos()
			pos.z = pos.z + 3
			wep:SetPos(pos)
			wep:SetAngles(VectorRand():Angle())
			wep:Spawn()

			local ammoClass = TTT.Weapons.GetAmmoEntityForWeapon(wepClass)
			if ammoClass then
				for i = 1, math.random(0, 3) do
					local ammo = ents.Create(ammoClass)
					pos.z = pos.z + 2
					ammo:SetPos(pos)
					ammo:SetAngles(VectorRand():Angle())
					ammo:Spawn()
					ammo:PhysWake()
				end
			end
		end

		-- TODO: Add an extra weapon spawn if we just spawned a grenade.

		-- If we spawned enough weapons, end.
		if numWeps > maxWeps then
			return
		end
	end
end

---------------------------------------
-- TTT.Weapons.PlaceExtraWeaponsForCSS
---------------------------------------
-- Desc:		Place extra weapons on CSS maps.
TTT.Weapons.CSSWeaponSpots = {
	"info_player_terrorist",
	"info_player_counterterrorist",
	"hostage_entity"
}
function TTT.Weapons.PlaceExtraWeaponsForCSS()
	MsgN("Weaponless CS:S-like map detected. Placing extra guns.")
	TTT.Weapons.PlaceWeaponsAtClasses(TTT.Weapons.CSSWeaponSpots)
end

---------------------------------------
-- TTT.Weapons.PlaceExtraWeaponsForTF2
---------------------------------------
-- Desc:		Place extra weapons on TF2 maps.
TTT.Weapons.TF2WeaponSpots = {
	"info_player_teamspawn",
	"team_control_point",
	"team_control_point_master",
	"team_control_point_round",
	"item_ammopack_full",
	"item_ammopack_medium",
	"item_ammopack_small",
	"item_healthkit_full",
	"item_healthkit_medium",
	"item_healthkit_small",
	"item_teamflag",
	"game_intro_viewpoint",
	"info_observer_point"
}
function TTT.Weapons.PlaceExtraWeaponsForTF2()
	MsgN("Weaponless TF2-like map detected. Placing extra guns.")
	TTT.Weapons.PlaceWeaponsAtClasses(TTT.Weapons.TF2WeaponSpots)
end

--------------------------------------------
-- TTT.Weapons.PlaceWeaponsForOtherGameMaps
--------------------------------------------
-- Desc:		If the map has no weapons, isn't a TTT map, has no arming script, and is a CS:S/TF2 map then arm it with random weapons.
function TTT.Weapons.PlaceWeaponsForOtherGameMaps()
	-- If the map has any weapons/ammo assume its already armed and don't place more weapons. If a info_player_deathmatch exists then its a TTT map for sure.
	for i, ent in ipairs(ents.GetAll()) do
		if ent:GetClass() == "info_player_deathmatch" or ent.AutoSpawnable and not IsValid(ent:GetOwner()) then
			return
		end
	end

	-- If we detect a CS:S map, arm it.
	if #ents.FindByClass("info_player_counterterrorist") > 0 then
		TTT.Weapons.PlaceExtraWeaponsForCSS()
		print("Weaponless CS:S-like map detected. Placing extra guns.")
	elseif #ents.FindByClass("info_player_teamspawn") > 0 then
		TTT.Weapons.PlaceExtraWeaponsForTF2()
		print("Weaponless TF2-like map detected. Placing extra guns.")
	end
end

----------------------------
-- TTT.Weapons.PlaceWeapons
----------------------------
-- Desc:		Arms the map. First see if the map needs extra weapons, then if theres a weapon script use that, if its a CS:S/TF2 map and no script exists, arm it randomly.
function TTT.Weapons.PlaceEntities()
	local successefulArmFromScript = false

	if istable(TTT.Weapons.ImportScriptWeapons) and #TTT.Weapons.ImportScriptWeapons > 0 then
		successefulArmFromScript = TTT.Weapons.ArmMapFromImportScript()
	end
	
	if not successefulArmFromScript then
		TTT.Weapons.PlaceWeaponsForOtherGameMaps()	-- Only does something if the current map has no TTT entities already and its a CS:S or TF2 map.
	end
end

---------------------------------------
-- TTT.Weapons.LoadImportWeaponsScript
---------------------------------------
-- Desc:		Loads the import scripts. Settings go into TTT.Weapons.ImportScriptMapSettings and entity positions go into TTT.Weapons.ImportScriptWeapons.
-- 				Thanks to mijyuoon for help with the gmatch code here. This is much better/faster than the way Badking was doing it.
local string_gmatch, string_Explode, table_insert, ipairs = string.gmatch, string.Explode, table.insert, ipairs
function TTT.Weapons.LoadImportWeaponsScript()
	local map = game.GetMap()
	if not TTT.Weapons.CanUseImportScript(map) then
		return
	end

	TTT.Weapons.ImportScriptMapSettings = {}

	local script = file.Read("maps/"..map.."_ttt.txt", "GAME")
	script = script:gsub("%b#\n", "")	-- Remove comments (lines starting with a #).

	-- Read settings from the import script.
	local success, err = pcall(function()
		for setting, value in string_gmatch(script, "setting:%s*(%S+)%s+(%S+)") do
			TTT.Weapons.ImportScriptMapSettings[setting] = value
		end
	end)

	-- If we messed up loading the scripts then fail.
	if not success then
		print("Failed to load import script settings, improper formatting. Error throw:\n"..err)
		TTT.Weapons.ImportScriptMapSettings = nil
		return
	end

	script = script:gsub("setting:%s+%S+%s%S+", "")	-- Remove settings before reading weapons.
	TTT.Weapons.ImportScriptWeapons = {}

	-- For speed we'll use this table of functions to dictate what we should do with the text in each line.
	local stringOperation = {
		function(itemInfo, txt)
			if txt == "ttt_playerspawn" then
				txt = "info_player_deathmatch"	-- This is kind of stupid, don't you think Badking?
			end

			itemInfo.Class = txt
		end,
		function(itemInfo, txt)
			itemInfo.Pos = Vector(txt)	-- Lua string coercion helping us out here.
		end,
		function(itemInfo, txt)
			itemInfo.Ang = Angle(txt)
		end,
		function(itemInfo, txt)
			itemInfo.KeyValues = {}
			for k, v in string.gmatch(txt, "(%S+)%s+(%d+)") do
				table.insert(itemInfo.KeyValues, {
					Key = k,
					Value = v
				})
			end
		end
	}

	-- Sadly we can't do everything with patterns because the key-value part is optional.
	local lines = string_Explode("\n", script)
	for i = 2, #lines - 1 do
		local info = string_Explode("\t", lines[i])
		local itemInfo = {}
		for j, text in ipairs(info) do
			stringOperation[j](itemInfo, text)
		end
		table_insert(TTT.Weapons.ImportScriptWeapons, itemInfo)
	end

	if not success then
		print("Failed to load import script weapons, improper formatting. Error throw:\n"..err)
		TTT.Weapons.ImportScriptWeapons = nil
		TTT.Weapons.ImportScriptMapSettings = nil
		return
	end

	print("Weapon import script succesfully loaded!")
end

----------------------------------
-- TTT.Weapons.CanUseImportScript
----------------------------------
-- Desc:		Sees if the given map has a weapon import script we can load.
-- Arg One:		String, map to check for an import script.
-- Returns:		Boolean.
function TTT.Weapons.CanUseImportScript(map)
	return file.Exists("maps/"..map.."_ttt.txt", "GAME") and hook.Call("TTT.Weapons.ShouldUseImportScript", nil, map) ~= false and useImportScripts:GetBool()
end

--------------------------------------
-- TTT.Weapons.ArmMapFromImportScript
--------------------------------------
-- Desc:		Arms a map with data loaded from an import script. Make sure to load the import script before using this.
-- Returns:		Boolean, were we successful in arming the map.
function TTT.Weapons.ArmMapFromImportScript()
	if not istable(TTT.Weapons.ImportScriptWeapons) or #TTT.Weapons.ImportScriptWeapons == 0 then
		return false
	end

	for i, info in ipairs(TTT.Weapons.ImportScriptWeapons) do
		local ent = ents.Create(info.Class)
		if IsValid(ent) then
			ent:SetPos(info.Pos)
			ent:SetAngles(info.Ang)
			ent.IsImportedFromScript = true
			if istable(info.KeyValues) then
				for i, keyValData in ipairs(info.KeyValues) do
					ent:SetKeyValue(keyValData.Key, keyValData.Value)
				end
			end
			ent:Spawn()
			ent:PhysWake()
		end
	end

	return true
end
