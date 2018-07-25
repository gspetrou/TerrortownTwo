surface.CreateFont("TTT_TButtonText", {
	font = "Tahoma",
	size = 13,
	weight = 700,
	shadow = true,
	antialias = false
})

TTT.VGUI.AddElement("ttt_traitor_button", function(ply, w, h)
	TTT.Map.TraitorButtons:Draw(ply, w, h)
end, function(ply, isalive)
	return TTT.Rounds.IsActive() and isalive and ply:IsTraitor()
end)