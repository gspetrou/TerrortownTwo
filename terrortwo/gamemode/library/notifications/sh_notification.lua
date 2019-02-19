-- Some documentation:
-- Standard Messages are just an efficient way of networking a message sent often such as
--	the start round messages sent to all active players. You can easily add your own standard
--	messages using TTT.Notifications:AddStandardMsg (shared) and send it with TTT.Notifications:SendStandardMsg (server).
-- If you only want to send some text to the client's notification stack just use TTT.Notifications.SendCustomMsg (server).

TTT.Notifications = TTT.Notifications or {
	StandardMsgTypes = {},
	StandardMsgPhrases = {},
	StandardMsgCounter = 0
}

-- How many standard messages are supported. By default, 2^5 = 32 custom messages.
-- If you need more for some weird reason then you can increase this.
local stdNotificationBits = 5

------------------------------------
-- TTT.Notifications:AddStandardMsg
------------------------------------
-- Desc:		Adds a standard message to the notification system.
-- Arg One:		String, unique identifier for this message.
-- Arg Two:		String, phrase for the string.
function TTT.Notifications:AddStandardMsg(ID, phrase)
	self.StandardMsgTypes[ID] = self.StandardMsgCounter
	self.StandardMsgPhrases[self.StandardMsgTypes[ID]] = phrase
	self.StandardMessageCounter = self.StandardMessageCounter + 1
end

function TTT.Notifications.Initialize()
	hook.Call("TTT.Notifications.InitStandardMessages")
end

if SERVER then
	util.AddNetworkString("TTT.Notifications.CustomMsg")
	function TTT.Notifications.SendCustomMsg(recipients, msg, bgColor)

	end

	util.AddNetworkString("TTT.Notifications.StandardMsg")
	function TTT.Notifications:SendStandardMsg(msgType, recipients)
		net.Start("TTT.Notifications.StandardMsg")
			net.WriteUInt(self.StandardMsgTypes[msgType], stdNotificationBits)

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
			TTT.Notifications:SendStandardMsg(TTT.Notications.StandardMsgTypes.START_TRAITOR_SOLO, traitors)
		else
			TTT.Notifications:SendStandardMsg(TTT.Notications.StandardMsgTypes.START_TRAITOR_MULTI, traitors)
		end

		if #detectives > 0 then
			TTT.Notifications:SendStandardMsg(TTT.Notications.StandardMsgTypes.START_DETECTIVE, detectives)
		end

		TTT.Notifications:SendStandardMsg(TTT.Notications.StandardMsgTypes.START_INNOCENT, innocents)
		TTT.Notifications:SendStandardMsg(TTT.Notications.StandardMsgTypes.START_DURATION, TTT.Roles.GetActivePlayers())
	end
end

if CLIENT then
	net.Receive("TTT.Notifications.CustomMsg", function()

	end)

	net.Receive("TTT.Notifications.StandardMsg", function()
		local msgType = net.ReadUInt(stdNotificationBits)
		local phrase = TTT.Notifications.StandardMsgPhrases[msgType]
		print(phrase)
	end)
end