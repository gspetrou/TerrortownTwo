TTT.Weapons = TTT.Weapons or {}
util.AddNetworkString("TTT.Weapons.RequestDropCurrentWeapon")
CreateConVar("ttt_weapons_default", "weapon_ttt2_unarmed", FCVAR_ARCHIVE, "The weapon to equip when every player spawns. Should be a weapon with SWEP.SpawnsWith set.")
local PLAYER = FindMetaTable("Player")

-------------------------------
-- TTT.Weapons.StripCompletely
-------------------------------
-- Desc:		Strips a player of everything. *wink wink*
-- Arg One:		Player, to be stripped.
function TTT.Weapons.StripCompletely(ply)
	ply:StripWeapons()
	ply:StripAmmo()
end

----------------------------------
-- TTT.Weapons.GiveRoleWeapons
----------------------------------
-- Desc:		Gives the player the weapons their role should start with.
function TTT.Weapons.GiveRoleWeapons()
	for _, ply in ipairs(player.GetAll()) do
		local role = ply:GetRole()
		for _, wep in ipairs(weapons.GetList()) do
			if wep.RoleWeapon then
				if wep.RoleWeapon == role then
					ply:Give(wep:GetClass())
				elseif istable(wep.RoleWeapon) then
					for _, roles in ipairs(wep.RoleWeapon) do
						if roles == role then
							ply:Give(wep.ClassName)
						end
					end
				end
			end
		end
	end
end

----------------------------------
-- TTT.Weapons.GiveStarterWeapons
----------------------------------
-- Desc:		Give the given player the weapons they should spawn with.
-- Arg One:		Player, to arm with spawn weapons.
function TTT.Weapons.GiveStarterWeapons(ply)
	for i, wep in ipairs(weapons.GetList()) do
		if wep.SpawnWith then
			ply:Give(wep.ClassName)
		end
	end
end