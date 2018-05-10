TTT.Player = TTT.Player or {}

------------------------------------
-- TTT.Player.AttemptSpectateObject
------------------------------------
-- Desc:		Ask to server to sees if theres anything in front of the player to spectate and spectates it.
function TTT.Player.AttemptSpectateObject()
	net.Start("TTT.Player.AttemptSpectateObject")
	net.SendToServer()
end

-- If the local player enters fly mode let their game know.
net.Receive("TTT.Player.SwitchedFlyMode", function()
	LocalPlayer().ttt_InFlyMode = net.ReadBool()
end)

-------------------------------------
-- TTT.Player.ModifyRagdollInEyeView
-------------------------------------
-- Desc:		Modifies the player's view when in the "in eye" oberver mode of a ragdoll so that their camera is actually in the ragdoll's eyes.
-- Arg One:		Player, whose view will be modified.
-- Arg Two:		Table, view data to be used in CalcView.
-- Returns:		Table, modified view data.
function TTT.Player.ModifyRagdollInEyeView(ply, view)
	if ply:GetObserverMode() == OBS_MODE_IN_EYE then
		local target = ply:GetObserverTarget()
		if IsValid(target) and target:GetClass() == "prop_ragdoll" then
			local eyes = target:LookupAttachment("eyes") or 0
			eyes = target:GetAttachment(eyes)
			if eyes then
				view.origin = eyes.Pos
				view.angles = eyes.Ang
			end
		end
	end
	return view
end