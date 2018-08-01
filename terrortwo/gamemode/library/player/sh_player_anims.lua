TTT.Player = TTT.Player or {}
local PLAYER = FindMetaTable("Player")
	
-- Implements the animation system from Badking's TTT. Mostly just copy-paste.
-- It actually turns out that this system only even works/is used for the ear-holding animation.

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
		ACT_GMOD_TAUNT_SALUTE,
		ACT_GMOD_TAUNT_CHEER ,
		ACT_SIGNAL_FORWARD,
		ACT_SIGNAL_HALT,
		ACT_SIGNAL_GROUP,
		ACT_GMOD_GESTURE_ITEM_PLACE,
		ACT_GMOD_GESTURE_ITEM_DROP,
		ACT_GMOD_GESTURE_ITEM_GIVE
	}

	-- Insert all the "simple" gestures that do not need weight control
	for i, act in pairs(simpleGestures) do
		ActRunners[act] = MakeSimpleAnimationRunner(act)
	end

	---------------------------
	-- PLAYER:AnimApplyGesture
	---------------------------
	-- Desc:		Sets up the given gesture on the player to be used.
	-- Arg One:		ACT_ enum, to be played.
	-- Arg Two:		Number, weight of the animation.
	function PLAYER:AnimApplyGesture(act, weight)
		self:AnimRestartGesture(GESTURE_SLOT_CUSTOM, act, true)
		self:AnimSetGestureWeight(GESTURE_SLOT_CUSTOM, weight)
	end

	local enabledGestures = CreateClientConVar("ttt_player_show_gestures", "1", true, false, "Should we play gestures such as ear grab when speaking.")

	-----------------------------
	-- PLAYER:AnimPerformGesture
	-----------------------------
	-- Desc:		Plays the given animation on the player with either a pre-built simple runner function or a given custom runner.
	-- Arg One:		ACT_ enum, to play.
	-- Arg Two:		(Optional) Function, custom runner for the animation. Animations in simpleGestures had this built by default and don't need a runner.
	function PLAYER:AnimPerformGesture(act, customRunnerFunc)
		if not enabledGestures:GetBool() then
			return
		end

		local runner = customRunnerFunc or ActRunners[act]
		if not runner then
			return false
		end

		self.ttt_GestureWeight = 0
		self.ttt_GestureRunner = runner

		return true
	end

	----------------------------
	-- PLAYER:AnimUpdateGesture
	----------------------------
	-- Desc:		Updates the current gesture being played on the player.
	function PLAYER:AnimUpdateGesture()
		if self.ttt_GestureRunner then
			self.ttt_GestureWeight = self:ttt_GestureRunner(self.ttt_GestureWeight)

			if self.ttt_GestureWeight <= 0 then
				self.ttt_GestureRunner = nil
			end
		end
	end

	net.Receive("TTT.Player.PerformGesture", function()
		local ply = net.ReadPlayer()
		local act = net.ReadUInt(14)

		if IsValid(ply) and act then
			ply:AnimPerformGesture(act)
		end
	end)
else
	util.AddNetworkString("TTT.Player.PerformGesture")

	-----------------------------
	-- PLAYER:AnimPerformGesture
	-----------------------------
	-- Desc:		Plays a given animation on the player.
	-- Arg One:		ACT_ enum, to be played.
	function PLAYER:AnimPerformGesture(act)
		if not act then
			return
		end

		net.Start("TTT.Player.PerformGesture")
			net.WritePlayer(self)
			net.WriteUInt(act, 14)
		net.Broadcast()
	end
end