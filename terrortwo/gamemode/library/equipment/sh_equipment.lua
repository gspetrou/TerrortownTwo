TTT.Equipment = TTT.Equipment or {Gear = {}}
local PLAYER = FindMetaTable("Player")

function TTT.Equipment.Add(id, phrase, desc_phrase)
	TTT.Equipment.Gear[id] = {
		name = phrase,
		desc = desc_phrase
	}
end

function TTT.Equipment.Initialize()
	hook.Call("TTT.Equipment.InitEquipment")
end

if SERVER then
	function TTT.Equipment.InitEquipment(ply)
		ply.ttt_equipment = {}
	end

	function PLAYER:GetEquipment()
		return self.ttt_equipment
	end
	
	function PLAYER:HasEquipment(id)
		for i, v in ipairs(self.ttt_equipment) do
			if id == v then
				return true
			end
		end
		return false
	end

	function PLAYER:GiveEquipment(id)
		if not istable(TTT.Equipment.Gear[id]) then
			error("Tried to give player an invalid equipment: '".. id .."'!")
		end
		
		table.insert(self.ttt_equipment, id)
	end

	function PLAYER:TakeEquipment(id)
		for i, v in ipairs(self.ttt_equipment) do
			if v == id then
				table.remove(self.ttt_equipment, i)
				return
			end
		end
	end

	function PLAYER:ClearEquipment()
		self.ttt_equipment = {}
	end
end