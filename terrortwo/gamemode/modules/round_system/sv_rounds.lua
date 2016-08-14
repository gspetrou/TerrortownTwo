util.AddNetworkString("TTT_ChangeRoundState")

function TTT.SetRoundState(state)
	GM.RoundState = state

	net.Start("TTT_ChangeRoundState")
		net.WriteUInt(state, 2)
	net.Broadcast()
end