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