-- Some documentation:
-- Standard Messages are just an efficient way of networking a message sent often such as
--	the start round messages sent to all active players. You can easily add your own standard
--	messages using TTT.Notifications:AddStandardMsg (shared) and send it with TTT.Notifications:SendStandardMsg (server).
-- If you only want to send some text to the client's notification stack just use TTT.Notifications.SendCustomMsg (server).

TTT.Notifications = TTT.Notifications or {}
TTT.Notifications.StandardMsgs = TTT.Notifications.StandardMsgs or {}
TTT.Notifications.StandardMsgCounter = TTT.Notifications.StandardMsgCounter or 0

-- How many standard messages are supported. By default, 2^5 = 32 custom messages.
-- If you need more for some weird reason then you can increase this.
local stdNotificationBits = 5

------------------------------------
-- TTT.Notifications:AddStandardMsg
------------------------------------
-- Desc:		Adds a standard message to the notification system.
-- Arg One:		String, unique identifier for this message.
-- Arg Two:		String, phrase for the string.
-- Arg Three:	(Optional=nil) Function, ran on the client, this function is called when getting any extra strings to be subbed into the phrase.
-- Arg Four:	(Optional=Default Text Color) Color, if you want a custom text color for this notification.
-- Arg Five:	(Optional=Default BG Color) Color, color of notification background.
function TTT.Notifications:AddStandardMsg(ID, phrase, clientFunc, textColor, bgColor)
	self.StandardMsgs[ID] = {
		NWID = self.StandardMsgCounter,
		Phrase = phrase,
		ClientFunc = clientFunc,
		TextColor = textColor,
		BGColor = bgColor
	}
	self.StandardMsgCounter = self.StandardMsgCounter + 1
end

-------------------------------
-- TT.Notifications.Initialize
-------------------------------
-- Desc:		Initializes standard messages to be used later.
function TTT.Notifications.Initialize()
	hook.Call("TTT.Notifications.InitStandardMessages")
end

if SERVER then
	-----------------------------------
	-- TTT.Notifications.SendCustomMsg
	-----------------------------------
	-- Desc:		Sends a custom message to the given clients.
	-- Arg One:		String, message to send to clients.
	-- Arg Two:		Boolean, table, or Player. Recipients of the message, true broadcasts.
	-- Arg Three:	(Optional=Default Text Color) Color, text color of the message if you want a custom one.
	-- Note:		If you need more customization in the message you're better off networking it on yourself and manually invoking the notification on the client.
	util.AddNetworkString("TTT.Notifications.CustomMsg")
	function TTT.Notifications.SendCustomMsg(msg, recipients, textColor)
		net.Start("TTT.Notifications.CustomMsg")
			net.WriteString(msg)
			if IsColor(textColor) then
				net.WriteBool(true)
				net.WriteColor(textColor)
			else
				net.WriteBool(false)
			end
		if recipients == true then
			net.Broadcast()
		else
			net.Send(recipients)
		end
	end

	-------------------------------------
	-- TTT.Notifications:SendStandardMsg
	-------------------------------------
	-- Desc:		Sends a given standard message to the given clients.
	-- Arg One:		String, message identifier (set in the first arg of AddStandardMsg).
	-- Arg Two:		Boolean, table, or Player, recipients of the messge. Passing true broadcasts.
	util.AddNetworkString("TTT.Notifications.StandardMsg")
	function TTT.Notifications:SendStandardMsg(msgType, recipients)
		net.Start("TTT.Notifications.StandardMsg")
			net.WriteUInt(self.StandardMsgs[msgType].NWID, stdNotificationBits)

		if recipients == true then
			net.Broadcast()
		else
			net.Send(recipients)
		end
	end

	------------------------------------------------
	-- TTT.Notifications.DispatchStartRoundMessages
	------------------------------------------------
	-- Desc:		Sends start round messages to active players.
	function TTT.Notifications.DispatchStartRoundMessages()
		local traitors = TTT.Roles.GetTraitors()
		local innocents = TTT.Roles.GetInnocents()
		local detectives = TTT.Roles.GetDetectives()

		if #traitors == 1 then
			TTT.Notifications:SendStandardMsg("START_TRAITOR_SOLO", traitors)
		else
			TTT.Notifications:SendStandardMsg("START_TRAITOR_MULTI", traitors)
		end

		if #detectives > 0 then
		--	TTT.Notifications:SendStandardMsg("START_DETECTIVE", detectives)
		end

		--TTT.Notifications:SendStandardMsg("START_INNOCENT", innocents)
	end
end

if CLIENT then
	net.Receive("TTT.Notifications.CustomMsg", function()
		local msg = net.ReadString()
		local hasCustomTextColor = net.ReadBool()
		local textColor

		if hasCustomTextColor then
			textColor = net.ReadColor()
		end
		TTT.Notifications:Add(text, textColor)
	end)

	net.Receive("TTT.Notifications.StandardMsg", function()
		local msgNWID = net.ReadUInt(stdNotificationBits)
		local msgType
		for mType, msgData in pairs(TTT.Notifications.StandardMsgs) do
			if msgNWID == msgData.NWID then
				msgType = mType
				break
			end
		end

		if not isstring(msgType) then
			error("Invalid notification type received!")
		end

		local phrase = TTT.Notifications.StandardMsgs[msgType].Phrase
		local textColor = TTT.Notifications.StandardMsgs[msgType].TextColor
		local bgColor = TTT.Notifications.StandardMsgs[msgType].BGColor
		local func = TTT.Notifications.StandardMsgs[msgType].ClientFunc
		local text
		if isfunction(func) then
			text = TTT.Languages.GetPhrase(phrase, func())
		else
			text = TTT.Languages.GetPhrase(phrase)
		end
		TTT.Notifications:Add(text, textColor, bgColor, msgType)
	end)
end