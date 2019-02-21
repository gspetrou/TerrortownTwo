TTT.Corpse = TTT.Corpse or {}
local PLAYER = FindMetaTable("Player")
local ENTITY = FindMetaTable("Entity")

-------------------------
-- TTT.Corpse.CreateBody
-------------------------
-- Desc:		Creates a death body for the given player with death information stored on the body.
-- Arg One:		Player, who died.
-- Arg Two:		Entity, attacker that dealed the fatal blow.
-- Arg Three:	CTakeDamageInfo, object which stores info about how the player died.
-- Returns:		Entity, body of the player.
function TTT.Corpse.CreateBody(ply, attacker, dmginfo)
	local shouldMakeBody = hook.Call("TTT.Corpse.ShouldCreateBody", nil, ply, attacker, dmginfo)
	if shouldMakeBody == false then
		return
	end

	ply.ttt_deathragdoll = TTT.Corpse.CreateRagdoll(ply)

	-- Can be used on corpses to get the dmginfo for when they died.
	function ply.ttt_deathragdoll:GetDeathDamageInfo()
		return dmginfo
	end

	TTT.Corpse.SetBodyData(ply, ply.ttt_deathragdoll, attacker, dmginfo)
	hook.Call("TTT.Corpse.BodyCreated", nil, ply, ply.ttt_deathragdoll)

	return ply.ttt_deathragdoll
end

--------------------
-- PLAYER.GetCorpse
--------------------
-- Desc:		Gets the corpse of a player, or false if none exists.
-- Returns:		Entity or Boolean. Ragdoll if it exists, false if not.
function PLAYER:GetCorpse()
	return IsValid(self.ttt_deathragdoll) and self.ttt_deathragdoll or false
end

-------------------
-- ENTITY.IsCorpse
-------------------
-- Desc:		Sees if the entity is a corpse or not.
-- Returns:		Boolean, true if they're a corpse.
function ENTITY:IsCorpse()
	return isbool(self.ttt_isbody) and true or false
end

---------------------
-- ENTITY:HasTTTBody
---------------------
-- Desc:		Sees if the corpse has killer info set on it. If not then we cant collect DNA samples from it.
-- Returns:		Boolean.
function ENTITY:HasTTTBodyData()
	if isbool(self.SetTTTBodyData) then
		return self.SetTTTBodyData
	end

	return false
end

----------------------------
-- TTT.Corpse.CreateRagdoll
----------------------------
-- Desc:		Creates the physical ragdoll of a player. Tries to look identical (skin, color, model, etc).
-- Arg One:		Player to make a ragdoll for.
-- Returns:		Entity, ragdoll to mimic player.
function TTT.Corpse.CreateRagdoll(ply)
	local ragdoll = ents.Create("prop_ragdoll")
	ragdoll:SetPos(ply:GetPos())
	ragdoll:SetAngles(ply:GetAngles())
	ragdoll:SetModel(ply:GetModel())
	ragdoll:SetSkin(ply:GetSkin())
	ragdoll:SetColor(ply:GetColor())
	for k, bodygroup in pairs(ply:GetBodyGroups()) do
		ragdoll:SetBodygroup(bodygroup.id, ply:GetBodygroup(bodygroup.id))	
	end

	ragdoll:Spawn()
	ragdoll:Activate()

	ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)	-- TTT had an option for this but it can cause crashes too easily.

	TTT.Corpse.AddToBodyInfoCache(ragdoll)
	ragdoll.ttt_isbody = true

	return ragdoll
end

local ttt_killer_dna_basetime = CreateConVar("ttt_killer_dna_basetime", "100", FCVAR_ARCHIVE, "Killers DNA sample decay time dependent on the killer's distance from the victim.")
local ttt_killer_dna_range = CreateConVar("ttt_killer_dna_range", "550", FCVAR_ARCHIVE, "The maximum distance a killer can be from a victim at the time of murder for DNA to be left.")

--------------------------
-- TTT.Corpse.SetBodyData
--------------------------
-- Desc:		Sets data on the ragdoll such as who, how, and what killed the player.
-- Arg One:		Player, whose body it is.
-- Arg Two:		Entity, ragdoll body.
-- Arg Three:	Entity, attacker of the player when they died.
-- Arg Four:	CTakeDamageInfo, object containning info on how the player died.
function TTT.Corpse.SetBodyData(ply, ragdoll, attacker, dmginfo)
	-- Here we set the movement of the ragdoll at the moment of the player's death.
	local numPhysObjects = ragdoll:GetPhysicsObjectCount() - 1
	local velocity = ply:GetVelocity()

	-- "Bullets have a lot of force, which feels better when shooting props, but makes bodies fly, so dampen that here."
	if dmginfo:IsDamageType(DMG_BULLET) or dmginfo:IsDamageType(DMG_SLASH) then
		velocity = velocity / 5
	end

	for i = 0, numPhysObjects do
		local bone = ragdoll:GetPhysicsObjectNum(i)
		if IsValid(bone) then
			local bonePos, boneAng = ply:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))
			if bonePos and boneAng then
				bone:SetPos(bonePos)
				bone:SetAngles(boneAng)
			end
			bone:SetVelocity(velocity)
		end
	end

	local inflictor = dmginfo:GetInflictor()
	if IsValid(inflictor) then
		if inflictor:IsNPC() then
			return
		end
	else
		if IsValid(attacker) and IsValid(wep:GetActiveWeapon()) then
			local wep = attacker:GetActiveWeapon()
			if IsValid(wep) then
				dmginfo:SetInflictor(wep)
			end
		end
	end

	local dist = ply:GetPos():Distance(attacker:GetPos())
	if dist > ttt_killer_dna_range:GetInt() then
		return nil
	end

	ragdoll.SetTTTBodyData = true	-- Used to simply see if this corpse has had body data set on it.

	-- Info at time of death. All stored rather then obtainned later through the player because they might disconnect.
	ragdoll.Owner = ply
	ragdoll.OwnerSteamID = ply:SteamID()
	ragdoll.OwnerName = ply:Nick()
	ragdoll.OwnerRole = ply:GetRole()
	ragdoll.OwnerEquipment = ply:GetEquipment()
	ragdoll.Killer = attacker
	ragdoll.KillerSteamID = attacker:SteamID()
	ragdoll.DeathTime = CurTime()
	ragdoll.SampleDecayTime = CurTime() + (-1 * (0.019 * dist)^2 + ttt_killer_dna_basetime:GetInt())
	ragdoll.DeathDamageInfo = dmginfo
end

----------------------------------
-- TTT.Corpse.GetCorpseSearchInfo
----------------------------------
-- Desc:		Gets a struct/table of a corpse's search info.
-- Arg One:		Entity, the corpse.
-- Returns:		Table or false. Table for info, false if not a valid body.
function TTT.Corpse.GetCorpseSearchInfo(corpse)
	if not IsValid(corpse) or not corpse:IsCorpse() then
		return false
	end

	return {
		Entity = corpse,
		Owner = corpse.Owner,
		OwnerSteamID = corpse.OwnerSteamID,
		OwnerName = corpse.OwnerName,
		OwnerRole = corpse.OwnerRole,
		OwnerEquipment = corpse.OwnerEquipment,
		Killer = corpse.attacker,
		KillerSteamID = corpse.KillerSteamID,
		SampleDecayTime = corpse.SampleDecayTime,
		DeathTime = corpse.DeathTime,
		DeathDamageInfo = corpse.DeathDamageInfo
	}
end

------------------------
-- TTT.Corpse.GetSample
------------------------
-- Desc:		Gets the DNA sample data from a corpse.
-- Arg One:		Entity, the corpse.
-- Returns:		Table or false. Table of DNA sample data, false if is an invalid corpse.
function TTT.Corpse.GetSample(corpse)
	if not IsValid(corpse) or not corpse:IsCorpse() then
		return false
	end

	return {
		Owner = corpse.Owner,
		OwnerSteamID = corpse.OwnerSteamID,
		Killer = corpse.Killer,
		KillerSteamID = corpse.KillerSteamID,
		SampleDecayTime = corpse.SampleDecayTime
	}
end

-- Since there is a lot of information on a body we use a cache to ensure that this information doesnt have to be networked more times than necessary.
-- The cache entry for a given body is kept until the body entity is removed.
TTT.Corpse.BodyInfoCache = TTT.Corpse.BodyInfoCache or {}

-----------------------------
-- TTT.Corpse.ClearCacheSpot
-----------------------------
-- Desc:		Removes the given corpse entity from the body info cache.
-- Arg One:		Entity, corpse.
function TTT.Corpse.ClearCacheSpot(corpse)
	TTT.Corpse.BodyInfoCache[corpse:EntIndex()] = nil
end

----------------------------------
-- TTT.Corpse.AlreadySentBodyInfo
----------------------------------
-- Desc:		Sees if the given player has already been sent the given corpse's info.
-- Arg One:		Player, who wants the body info.
-- Arg Two:		Entity, corpse with info.
-- Returns:		Boolean, do they already have the info.
function TTT.Corpse.AlreadySentBodyInfo(ply, corpse)
	for _, cachedPly in pairs(TTT.Corpse.BodyInfoCache[corpse:EntIndex()]) do	-- Using pairs here because a player could disconnect and become invalid in this cache.
		if ply == cachedPly then
			return true
		end
	end
	return false
end

---------------------------------------
-- TTT.Corpse.AddPersonToBodyInfoCache
---------------------------------------
-- Desc:		Adds a person to a corpse's body info cache. Pretty much means "this person has already been sent the info for this corpse so dont bother sending it again."
-- Arg One:		Player, to add to a corpse's cache.
-- Arg Two:		Entity, corpse.
function TTT.Corpse.AddPersonToBodyInfoCache(ply, corpse)
	table.insert(TTT.Corpse.BodyInfoCache[corpse:EntIndex()], ply)
end

---------------------------------
-- TTT.Corpse.AddToBodyInfoCache
---------------------------------
-- Desc:		Adds a corpse to be tracked in the body info cache.
-- Arg One:		Entity, corpse.
function TTT.Corpse.AddToBodyInfoCache(corpse)
	TTT.Corpse.BodyInfoCache[corpse:EntIndex()] = {}
end

-----------------------------
-- TTT.Corpse.SendSearchInfo
-----------------------------
-- Desc:		Sends all info necessary to a client in order to display the body search screen.
-- Arg One:		Entity, the corpse of the player being searched.
-- Arg Two:		Player, Table, or Boolean. If player will send body info to just them, table for multiple people, true to send body info to every player.
util.AddNetworkString("TTT.Corpse.SearchInfo")
function TTT.Corpse.SendSearchInfo(corpse, recipients)
	if not IsValid(corpse) or not corpse:IsCorpse() then
		return
	end

	-- Get coprse info.
	local corpseInfo = TTT.Corpse.GetCorpseSearchInfo(corpse)
	local dmgInfo = corpseInfo.DeathDamageInfo
	local damageType, weaponClass = dmgInfo:GetDamageType(), TTT.WeaponFromDamageInfo(dmgInfo)
	if weaponClass == nil then
		weaponClass = ""
	end

	-- Send that corpse's info.
	net.Start("TTT.Corpse.SearchInfo")
		net.WriteEntity(corpseInfo.Entity)			-- Which entity is our corpse.
		net.WriteString(corpseInfo.OwnerName)		-- Name of the player at death incase it changes or they disconenct.
		net.WriteUInt(corpseInfo.OwnerRole, 3)		-- Even though they client might already know this player's role we have to assume they have no info on them.
		net.WriteUInt(damageType, 31)				-- Write the damage type.
		net.WriteString(weaponClass)				-- Weapon/entity class that killed them.
		net.WriteBool(corpseInfo.OwnerWasHeadshotted)		-- Were they killed via headshot.
		net.WriteUInt(math.floor(corpseInfo.DeathTime), 32)	-- What time did they die.

		-- TODO: Write equipment
		-- TODO: Write C4 info
		-- TODO: Write DNA sample decay time
		-- TODO: Last words

	if recipients == true then
		net.Broadcast()

		for i, ply in ipairs(player.GetAll()) do
			TTT.Corpse.AddPersonToBodyInfoCache(ply, corpse)
		end
	else
		net.Send(recipients)

		if istable(recipients) then
			for i, ply in ipairs(recipients) do
				TTT.Corpse.AddPersonToBodyInfoCache(ply, corpse)
			end
		else
			TTT.Corpse.AddPersonToBodyInfoCache(recipients, corpse)
		end
	end
end

---------------------
-- TTT.Corpse.Search
---------------------
-- Desc:		Sets up and opens the body search menu for a player on a corpse.
-- Arg One:		Player, who is doing the seaching.
-- Arg Two:		Entity, ttt body to search.
-- Arg Three:	(Optional=false) Boolean, true makes this a covert search. Nobody will know you've searched it.
util.AddNetworkString("TTT.Corpse.OpenSearchMenu")
function TTT.Corpse.Search(ply, corpse, covert)
	if not corpse:IsCorpse() or not corpse:HasTTTBodyData() then
		error("Player '".. (ply:Nick() or "INVALID-NAME") .."' (".. (ply:SteamID() or "INVALID-STEAMID") ..") tried to search an invalid corpse!")
	end
	if not TTT.Corpse.AlreadySentBodyInfo(ply, corpse) then
		TTT.Corpse.SendSearchInfo(corpse, ply)
	end

	net.Start("TTT.Corpse.OpenSearchMenu")
		net.WriteEntity(corpse)
	net.Send(ply)

	if covert == false and TTT.Corpse.GetStatusFromSteamID(corpse.OwnerSteamID) != BODYSTATUS_FOUND then
		TTT.Corpse.SetConfirmedDead(corpse.OwnerSteamID)
	end
end






