TTT.Weapons = TTT.Weapons or {}

-- Here we override a bunch of entities and weapons to "redirect" to our new ones.

TTT.Weapons.RedirectedEntities = {
	item_ammo_357 = {
		Base = "ttt_ammo_sniper"
	},
	item_ammo_357_large = {
		Base = "ttt_ammo_sniper"
	},
	item_ammo_357_ttt = {
		Base = "ttt_ammo_sniper",
		IsOriginalTTTEntity = true
	},
	item_ammo_ar2 = {
		Base = "ttt_ammo_pistol_light"
	},
	item_ammo_ar2_large = {
		Base = "ttt_ammo_ar"
	},
	item_ammo_crossbow = {
		Base = "ttt_ammo_shotgun_buckshot"
	},
	item_ammo_pistol = {
		Base = "ttt_ammo_pistol_light"
	},
	item_ammo_pistol_ttt = {
		Base = "ttt_ammo_pistol_light",
		IsOriginalTTTEntity = true
	},
	item_ammo_revolver = {
		Base = "ttt_ammo_pistol_heavy"
	},
	item_ammo_revolver_ttt = {
		Base = "ttt_ammo_pistol_heavy",
		IsOriginalTTTEntity = true
	},
	item_ammo_smg1 = {
		Base = "ttt_ammo_ar"
	},
	item_ammo_smg1_ttt = {
		Base = "ttt_ammo_ar",
		IsOriginalTTTEntity = true
	},
	item_battery = {
		Base = "ttt_ammo_sniper"
	},
	item_box_buckshot = {
		Base = "ttt_ammo_shotgun_buckshot"
	},
	item_box_buckshot_ttt = {
		Base = "ttt_ammo_shotgun_buckshot",
		IsOriginalTTTEntity = true
	},
	item_healthcharger = {
		Base = "ttt_ammo_pistol_heavy"
	},
	item_item_crate = {
		Base = "ttt_random_ammo"
	},
	item_rpg_round = {
		Base = "ttt_ammo_sniper"
	},
	weapon_slam = {
		Base = "ttt_ammo_pistol_light"
	}
}

TTT.Weapons.RedirectedWeapons = {
	item_ammo_ar2_altfire = {
		Base = "weapon_ttt_mac10"
	},
	item_ammo_smg1_grenade = {
		Base = "weapon_ttt_pistol"
	},
	item_healthkit = {
		Base = "weapon_ttt_shotgun"
	},
	item_suitcharger = {
		Base = "weapon_ttt_mac10"
	},
	weapon_357 = {
		Base = "weapon_ttt_sniper"
	},
	weapon_ar2 = {
		Base = "weapon_ttt_m16"
	},
	weapon_crossbow = {
		Base = "weapon_ttt_pistol"
	},
	weapon_frag = {
		Base = "weapon_ttt_deagle"
	},
	weapon_rpg = {
		Base = "weapon_ttt_huge"
	},
	weapon_shotgun = {
		Base = "weapon_ttt_shotgun"
	},
	weapon_smg1 = {
		Base = "weapon_ttt_mac10"
	},
	weapon_zm_improvised = {
		Base = "weapon_ttt_crowbar",
		IsOriginalTTTEntity = true
	},
	weapon_zm_mac10 = {
		Base = "weapon_ttt_mac10",
		IsOriginalTTTEntity = true
	},
	weapon_zm_pistol = {
		Base = "weapon_ttt_pistol",
		IsOriginalTTTEntity = true
	},
	weapon_zm_revolver = {
		Base = "weapon_ttt_deagle",
		IsOriginalTTTEntity = true
	},
	weapon_zm_rifle = {
		Base = "weapon_ttt_sniper",
		IsOriginalTTTEntity = true
	},
	weapon_zm_shotgun = {
		Base = "weapon_ttt_shotgun",
		weapon_ttt_shotgun = true
	},
	weapon_zm_sledge = {
		Base = "weapon_ttt_huge",
		IsOriginalTTTEntity = true
	}
}

