-- This is a small miscellaneous library

function net.WritePlayer(ply)
	if IsValid(ply) then
		net.WriteUInt(ply:EntIndex(), 7)
	else
		net.WriteUInt(0, 7)
	end
end

function net.ReadPlayer()
	local i = net.ReadUInt(7)
	if not i then
		return
	end
	return Entity(i)
end

function DebugPrint(text)
	MsgC(Color(200, 20, 20), "TTT DEBUG: ", color_white, text.."\n")

	text = os.date("%d/%m/%Y - %H:%M:%S", os.time()).."\t"..text.."\n"
	if not file.Exists("ttt/debug_prints.txt", "DATA") then
		file.Write("ttt/debug_prints.txt", text)
	else
		file.Append("ttt/debug_prints.txt", text)
	end
end