EQUIPMENT:SetName("equipment_armor_name")
EQUIPMENT:SetDescription("equipment_armor_desc")
--EQUIPMENT:SetIcon("vgui/ttt/icon_armor")
EQUIPMENT:SetInLoadoutFor({ROLE_DETECTIVE})
EQUIPMENT:SetInStoreFor({ROLE_DETECTIVE, ROLE_TRAITOR})

if SERVER then
	EQUIPMENT:AddHook("ScalePlayerDamage", function(ply, _, dmginfo)
		if dmginfo:IsBulletDamage() and ply:HasEquipmentItem(EQUIPMENT.ID) then
			dmginfo:ScaleDamage(0.7)
		end
	end)

	function EQUIPMENT:OnEquip(ply)
		print"equipped"
	end

	function EQUIPMENT:OnUnequip(ply)
		print"unequipped"
	end
end