TTT.Player = TTT.Player or {}
local PLAYER = FindMetaTable("Player")
	
-- Implements the animation system from Badking's TTT. Mostly just copy-paste.

if CLIENT then
	-- Instead of making a seperate function for each animation we instead do this. It makes a simple function for each given ACT_ enum to perform the animation.
	local function MakeSimpleAnimationRunner(act)
		return function(ply, weight)
			if weight == 0 then
				ply:AnimApplyGesture(act, 1)
				return 1
			else
				return 0
			end
		end
	end

	-- This table will store functions to perform a certain ACT.
	local ActRunners = {
		-- We need to specficially add the ear grab animation because it has weight control.
		[ACT_GMOD_IN_CHAT] = function (ply, weight)
			local dest = ply:IsSpeaking() and 1 or 0
			weight = math.Approach(weight, dest, FrameTime() * 10)
			if weight > 0 then
				ply:AnimApplyGesture(ACT_GMOD_IN_CHAT, weight)
			end
			return weight
		end
	}

	-- Gestures we can get away with simply using our animation runner.
	local simpleGestures = {
		ACT_GMOD_GESTURE_AGREE,
		ACT_GMOD_GESTURE_DISAGREE,
		ACT_GMOD_GESTURE_WAVE,
		ACT_GMOD_GESTURE_BECON,
		ACT_GMOD_GESTURE_BOW,
		ACT_GMOD_GESTURE_SALUTE,
		ACT_GMOD_CHEER,
		ACT_SIGNAL_FORWARD,
		ACT_SIGNAL_HALT,
		ACT_SIGNAL_GROUP,
		ACT_ITEM_PLACE,
		ACT_ITEM_DROP,
		ACT_ITEM_GIVE
	}

	-- Insert all the "simple" gestures that do not need weight control
	for i, act in pairs(simpleGestures) do
		ActRunners[act] = MakeSimpleAnimationRunner(act)
	end

	function PLAYER:AnimApplyGesture(act, weight)
		self:AnimRestartGesture(GESTURE_SLOT_CUSTOM, act, true) -- true = autokill
		self:AnimSetGestureWeight(GESTURE_SLOT_CUSTOM, weight)
	end

	local enabledGestures = CreateClientConVar("ttt_player_show_gestures", "1", true, false, "Should we play gestures such as ear grab when speaking.")

	-- Perform the gesture using the GestureRunner system. If custom_runner is
	-- non-nil, it will be used instead of the default runner for the act.
	function PLAYER:AnimPerformGesture(act, custom_runner)
		if not enabledGestures:GetBool() then
			return
		end

		local runner = custom_runner or ActRunners[act]
		if not runner then return false end

		self.GestureWeight = 0
		self.GestureRunner = runner

		return true
	end

	-- Perform a gesture update
	function PLAYER:AnimUpdateGesture()
		if self.GestureRunner then
			self.GestureWeight = self:GestureRunner(self.GestureWeight)

			if self.GestureWeight <= 0 then
				self.GestureRunner = nil
			end
		end
	end

	function GM:UpdateAnimation(ply, vel, maxseqgroundspeed)
		ply:AnimUpdateGesture()

		return self.BaseClass.UpdateAnimation(self, ply, vel, maxseqgroundspeed)
	end

	function GM:GrabEarAnimation(ply) end

	net.Receive("TTT_PerformGesture", function()
		local ply = net.ReadEntity()
		local act = net.ReadUInt(16)

		if IsValid(ply) and act then
			ply:AnimPerformGesture(act)
		end
	end)
else -- SERVER
	util.AddNetworkString("TTT_PerformGesture")
	-- On the server, we just send the client a message that the player is
	-- performing a gesture. This allows the client to decide whether it should
	-- play, depending on eg. a cvar.
	function PLAYER:AnimPerformGesture(act)
		if not act then
			return
		end

		net.Start("TTT_PerformGesture")
			net.WriteEntity(self)
			net.WriteUInt(act, 16)
		net.Broadcast()
	end
end