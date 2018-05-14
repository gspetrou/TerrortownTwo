TTT.Weapons = TTT.Weapons or {}
local wepCount = CreateConVar("ttt_weapon_spawn_count", "0", FCVAR_ARCHIVE, "How many extra weapons to spawn on unarmed CSS/TF2 maps. 0 for max player count + 3 amount.")

-- If it were up to me I'd use vON or pON to store the import scripts no problem.
-- But alas, we are stuck with what Badking left us.

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

---------------------------------
-- TTT.Weapons.PlaceExtraWeapons
---------------------------------
-- Desc:		If the map has no weapons, isn't a TTT map, has no arming script, and is a CS:S/TF2 map then arm it with random weapons.
function TTT.Weapons.PlaceExtraWeapons()
	-- If the map has any weapons/ammo assume its already armed and don't place more weapons. If a info_player_deathmatch exists then its a TTT map for sure.
	for i, ent in ipairs(ents.GetAll()) do
		if ent:GetClass() == "info_player_deathmatch" or ent.AutoSpawnable and not IsValid(ent:GetOwner()) then
			return
		end
	end

	-- If we detect a CS:S map, arm it.
	if #ents.FindByClass("info_player_counterterrorist") > 0 then
		TTT.Weapons.PlaceExtraWeaponsForCSS()
	elseif #ents.FindByClass("info_player_teamspawn") > 0 then
		TTT.Weapons.PlaceExtraWeaponsForTF2()
	end
end