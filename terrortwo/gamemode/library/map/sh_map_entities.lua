TTT.Map = TTT.Map or {}

-- Badking's TTT dummifies these entities for use later. We do the same to ensure compatability.
local dummyEntities = {
	-- CS:S
	"hostage_entity",
	-- TF2
	"item_ammopack_full",
	"item_ammopack_medium",
	"item_ammopack_small",
	"item_healthkit_full",
	"item_healthkit_medium",
	"item_healthkit_small",
	"item_teamflag",
	"game_intro_viewpoint",
	"info_observer_point",
	"team_control_point",
	"team_control_point_master",
	"team_control_point_round",
	-- ZM
	"item_ammo_revolver"
}
for i, class in ipairs(dummyEntities) do
	scripted_ents.Register({
		Type = "point",
		IsWeaponDummy = true
	}, class, false)
end

--------------------------------------
-- TTT.Map.RunImportScriptMapSettings
--------------------------------------
-- Desc:		Import scripts have a feature where you can pass settings to it in the format: "setting: mysetting myvar".
-- 				This function runs the TTT.Map.HandleImportScriptSetting hook for those settings to be handled.
function TTT.Map.RunImportScriptMapSettings()
	if istable(TTT.Weapons.ImportScriptMapSettings) then
		for k, v in pairs(TTT.Weapons.ImportScriptMapSettings) do
			hook.Call("TTT.Map.HandleImportScriptSetting", nil, k, v)
		end
	end
end

local ENTITY = FindMetaTable("Entity")

-------------------------
-- ENTITY:SetDamageOwner
-------------------------
-- Desc:		Sets the owner of the damage caused by this entity.
-- Arg One:		Player, who owns the damage.
function ENTITY:SetDamageOwner(ply)
	self.ttt_DamageOwner = {
		Player = ply,
		Time = CurTime()
	}
end

-------------------------
-- ENTITY:GetDamageOwner
-------------------------
-- Desc:		Gets the damage owner of the given entity along with the time this owner was set.
-- Returns:		Player or nil. Nil if no damage owner is set, player otherwise.
-- Returns:		Number or nil. Nil if no damage owner is set, time damage owner was set otherwise.
function ENTITY:GetDamageOwner()
	if self.ttt_DamageOwner then
		return self.ttt_DamageOwner.Player, self.ttt_DamageOwner.Time
	end
	return nil, nil
end

if SERVER then
	local VectorRand, ipairs, ents_GetAll = VectorRand, ipairs, ents.GetAll

	--------------------
	-- TTT.Map.ResetMap
	--------------------
	-- Desc:		Resets the map to its original state, makes needed changes, and respawns players.
	function TTT.Map.ResetMap()
		TTT.Map.FixParentedEntitesPreCleanup()		-- Keep track of certain entities with parents before cleanup.
		game.CleanUpMap()							-- Restores the map to its original state.
		TTT.Map.FixParentedEntitiesPostCleanup()	-- Fix certain parented entities after cleanup.

		-- Remove Zombie Master (ZM) crowbars since they are found on ZM maps and players spawn with them anyways. 
		for i, ent in ipairs(ents.FindByClass("weapon_zm_improvised")) do
			ent:Remove()
		end

		-- Assuming the mapper correctly placed ttt1 and tt2 entities, go through converted entities (hl2, css, etc) and settle them.
		-- Simply raise them 2 units and drop them in-case they spawn clipping in/through the floor and walls.
		for i, wep in ipairs(ents_GetAll()) do
			if wep.IsConvertedEntity and not wep.IsOriginalTTTEntity then
				local pos = wep:GetPos()
				pos.z = pos.z + 2
				wep:SetPos(pos)
				wep:SetAngles(VectorRand():Angle())	-- Just like TTT1 does it.
			end
		end

		hook.Call("TTT.Map.OnReset")
	end

	-- This is a list of entities who will have broken parents after a cleanup. Have a list of them to fix pre/post cleanup.
	TTT.Map.BrokenParentedEntities = {
		"move_rope",
		"keyframe_rope",
		"info_target",
		"func_brush"
	}

	----------------------------------------
	-- TTT.Map.FixParentedEntitesPreCleanup
	----------------------------------------
	-- Desc:		Tracks certain entities that will have broken parents after cleanup. (Copied from TTT)
	function TTT.Map.FixParentedEntitesPreCleanup()
		for _, entType in ipairs(TTT.Map.BrokenParentedEntities) do
			for _, ent in ipairs(ents.FindByClass(entType)) do
				if ent.GetParent and IsValid(ent:GetParent()) then
					ent.ttt_ParentName = ent:GetParent():GetName()
					ent:SetParent(nil)

					if not ent.ttt_OriginalPosition then
						ent.ttt_OriginalPosition = ent:GetPos()
					end
				end
			end
		end
	end

	------------------------------------------
	-- TTT.Map.FixParentedEntitiesPostCleanup
	------------------------------------------
	-- Desc:		Fixes parented entities after a cleanup. (Copied from TTT)
	function TTT.Map.FixParentedEntitiesPostCleanup()
		for _, entType in ipairs(TTT.Map.BrokenParentedEntities) do
			for _, ent in ipairs(ents.FindByClass(entType)) do
				if ent.ttt_ParentName then
					if ent.ttt_OriginalPosition then
						ent:SetPos(ent.ttt_OriginalPosition)
					end

					local parent = ents.FindByName(v.CachedParentName)
					if #parent == 1 then
						ent:SetParent(parent[1])
					end
				end
			end
		end
	end

	-------------------------------------
	-- TTT.Map.TriggerRoundStateOutsputs
	-------------------------------------
	-- Desc:		Triggers an output on ttt_map_settings entities to let the map know that a round has ended.
	function TTT.Map.TriggerRoundStateOutsputs(result, data)
		result = result or TTT.Rounds.GetState()

		for i, ent in ipairs(ents.FindByClass("ttt_map_settings")) do
			if IsValid(ent) then
				ent:RoundStateTrigger(result, data)
			end
		end
	end
end
