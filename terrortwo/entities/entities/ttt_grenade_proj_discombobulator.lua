AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ttt_grenade_proj_base"
ENT.Model = Model("models/weapons/w_eq_fraggrenade_thrown.mdl")

local ttt_allow_jump = CreateConVar("ttt_grenade_discombob_jump", "0", FCVAR_ARCHIVE, "Can the players throw down a discombob and use it to jump up to platforms.")

-- Pushes people in the area around randomly, "pusher" is responsible for these pushes.
local function PushPullRadius(pos, pusher)
	local radius = 400
	local phys_force = 1500
	local push_force = 256

	-- pull physics objects and push players
	for i, target in ipairs(ents.FindInSphere(pos, radius)) do
		if IsValid(target) then
			local tpos = target:LocalToWorld(target:OBBCenter())
			local dir = (tpos - pos):GetNormal()
			local phys = target:GetPhysicsObject()

			if target:IsPlayer() and (not target:IsFrozen()) and ((not target.ttt_WasPushed) or target.ttt_WasPushed.t ~= CurTime()) then

				-- Always need to push upward even a little to prevent ground friction from messing us up.
				dir.z = math.abs(dir.z) + 1

				local push = dir * push_force

				-- try to prevent excessive upwards force
				local vel = target:GetVelocity() + push
				vel.z = math.min(vel.z, push_force)

				-- mess with discomb jumps
				if pusher == target and not ttt_allow_jump:GetBool() then
					vel = VectorRand() * vel:Length()
					vel.z = math.abs(vel.z)
				end

				target:SetVelocity(vel)

				target.ttt_WasPushed = {
					attacker = pusher,
					time = CurTime(),
					weapon = "grenade_ttt_discombobulator"
				}
			elseif IsValid(phys) then
				phys:ApplyForceCenter(dir * -1 * phys_force)
			end
		end
	end

	local phexp = ents.Create("env_physexplosion")
	if IsValid(phexp) then
		phexp:SetPos(pos)
		phexp:SetKeyValue("magnitude", 100)
		phexp:SetKeyValue("radius", radius)
		phexp:SetKeyValue("spawnflags", 1 + 2 + 16) -- 1 = no dmg, 2 = push ply, 8 = los, 16 = viewpunch
		phexp:Spawn()
		phexp:Fire("Explode", "", 0.2)
	end
end

local zapsound = Sound("npc/assassin/ball_zap1.wav")
function ENT:Explode(tr)
	if SERVER then
		self:SetNoDraw(true)
		self:SetSolid(SOLID_NONE)

		-- Pull out of the surface.
		if tr.Fraction ~= 1.0 then
			self:SetPos(tr.HitPos + tr.HitNormal * 0.6)
		end

		local pos = self:GetPos()
		self:Remove()

		PushPullRadius(pos, self:GetThrower())

		local effect = EffectData()
		effect:SetStart(pos)
		effect:SetOrigin(pos)

		if tr.Fraction ~= 1.0 then
			effect:SetNormal(tr.HitNormal)
		end
		
		util.Effect("Explosion", effect, true, true)
		util.Effect("cball_explode", effect, true, true)

		sound.Play(zapsound, pos, 100, 100)
	else
		local spos = self:GetPos()
		local trs = util.TraceLine({start = spos + Vector(0,0,64), endpos = spos + Vector(0,0,-128), filter = self})
		util.Decal("SmallScorch", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)		

		self:SetDetonateExact(0)
	end
end