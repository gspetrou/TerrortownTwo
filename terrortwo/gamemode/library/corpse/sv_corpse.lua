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
	return isbool(self.isbody) and true or false
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

	ragdoll.isbody = true
	ragdoll.OwnerSteamID = ply:SteamID()
	ragdoll.OwnerEntID = ply:EntIndex()

	return ragdoll
end

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
	local numPhysObjects = ragdoll:GetPhysicsObjectCount()-1
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
end