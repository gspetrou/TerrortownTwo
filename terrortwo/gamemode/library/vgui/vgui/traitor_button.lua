TTT.VGUI.AddElement("ttt_traitor_button", function(ply, w, h)
	--TTT.Map.TraitorButtons:Draw(ply, w, h)
end, function(ply, isalive)
	return isalive and ply:IsTraitor()
end