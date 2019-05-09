EQUIPMENT:SetName("equipment_armor_name")
EQUIPMENT:SetDescription("equipment_armor_desc")
--EQUIPMENT:SetIcon("vgui/ttt/icon_armor")
EQUIPMENT:SetInLoadoutFor({ROLE_DETECTIVE})
EQUIPMENT:SetInStoreFor({ROLE_DETECTIVE, ROLE_TRAITOR})

local equipID = EQUIPMENT.ID	-- Note: We need to backup EQUIOMENT.ID into a local variable since EQUIPMENT.ID will be invalid after initilization.

if SERVER then	
	EQUIPMENT:AddHook("ScalePlayerDamage", function(ply, _, dmginfo)
		if ply:HasEquipment(equipID) and dmginfo:IsBulletDamage() then
			dmginfo:ScaleDamage(0.7)
		end
	end)
end