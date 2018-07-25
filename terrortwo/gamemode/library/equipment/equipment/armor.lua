EQUIPMENT:SetName("equipment_armor_name")
EQUIPMENT:SetDescription("equipment_armor_desc")
--EQUIPMENT:SetIcon("vgui/ttt/icon_armor")
EQUIPMENT:SetInLoadoutFor({ROLE_DETECTIVE})
EQUIPMENT:SetInStoreFor({ROLE_DETECTIVE, ROLE_TRAITOR})

if SERVER then
	local equipID = EQUIPMENT.ID	-- This variable will no longer exist when we need it in hooks so save it.
	
	EQUIPMENT:AddHook("ScalePlayerDamage", function(ply, _, dmginfo)
		if ply:HasEquipment(equipID) and dmginfo:IsBulletDamage() then
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