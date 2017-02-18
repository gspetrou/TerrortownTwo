do -- The container
	surface.CreateFont("ttt_sb_hostname", {
		font = "coolvetica",
		size = 32,
		weight = 400
	})
	surface.CreateFont("ttt_sb_roundinfo", {
		font = "coolvetica",
		size = 20,
		weight = 200
	})

	local PANEL = {}

	function PANEL:Init()
		self:SetSize(ScrW()/1.85, ScrH()/1.1)
		self:Center()

		self.hostname = vgui.Create("DLabel", self)
		self.hostname:SetFont("ttt_sb_hostname")
		self.hostname:SetText(GetHostName())
		self.hostname:SetTextColor(color_black)
		self.hostname:SizeToContents()
		self.hostname:SetPos(0, 6)
		self.hostname:CenterHorizontal()

		self.roundinfo = vgui.Create("DLabel", self)
		self.roundinfo:SetFont("ttt_sb_roundinfo")
		self.roundinfo:SetText(TTT.Languages.GetPhrase("sb_roundinfo", "8", "00:00:00"))
		self.roundinfo:SetTextColor(color_white)
		self.roundinfo:SetExpensiveShadow(1, color_black)
		self.roundinfo:SizeToContents()
		self.roundinfo:SetPos(8, 43)
	end
	function PANEL:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 250))
		draw.RoundedBox(0, 0, 0, w, 40, Color(228, 196, 0))
		draw.RoundedBox(0, 0, 40, w, 25, Color(200, 156, 0))
	end
	vgui.Register("ttt_scoreboard", PANEL)


	-- Debug
	concommand.Add("test", function()
		if IsValid(ttt_test_panel) then
			ttt_test_panel:Remove()
		else
			ttt_test_panel = vgui.Create("ttt_scoreboard")
		end
	end)
	if IsValid(ttt_test_panel) then
		ttt_test_panel:Remove()
		ttt_test_panel = vgui.Create("ttt_scoreboard")
	end
end

