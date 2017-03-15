TTT.PlayerSettings = TTT.PlayerSettings or {}
TTT.PlayerSettings.DefaultModel = TTT.PlayerSettings.DefaultModel or "models/player/phoenix.mdl"
TTT.PlayerSettings.DefaultColor = TTT.PlayerSettings.DefaultColor or TTT.Colors.White
TTT.PlayerSettings.DefaultModels = TTT.PlayerSettings.DefaultModels or {
	"models/player/phoenix.mdl",
	"models/player/arctic.mdl",
	"models/player/guerilla.mdl",
	"models/player/leet.mdl"
}

-- Thanks TTT.
local cols = TTT.Colors
TTT.PlayerSettings.PlayerColors = TTT.PlayerSettings.PlayerColors or {
	all = {
		cols.White,
		cols.Black,
		cols.Green,
		cols.DarkGreen,
		cols.Red,
		cols.Yellow,
		cols.LightGray,
		cols.Blue,
		cols.Navy,
		cols.Pink,
		cols.Olive,
		cols.Orange
	},

	serious = {
		cols.White,
		cols.Black,
		cols.Navy,
		cols.LightGray,
		cols.DarkGreen,
		cols.Olive
	}
}

local colormode = CreateConVar("ttt_playercolor_mode", "1", FCVAR_ARCHIVE, "Sets the set of colors to choose from for player spawns. 0 is off, 1 is muted colors, 2 is more colors, 3 is completely random colors.")

---------------------------------
-- TTT.PlayerSettings.Initialize
---------------------------------
-- Desc:		Sets the active player model for the map.
function TTT.PlayerSettings.Initialize()
	-- Set the map default spawn model.
	local mdl = hook.Call("TTT.PlayerSettings.SetSpawnModel")
	if not isstring(mdl) then
		mdl = table.RandomSequential(TTT.PlayerSettings.DefaultModels)
	end
	TTT.PlayerSettings.SetSpawnModel(mdl)

	-- Set the map default spawn color.
	TTT.PlayerSettings.DefaultColor = TTT.PlayerSettings.GetRandomPlayerColor()
end

-------------------------------------------
-- TTT.PlayerSettings.GetRandomPlayerColor
-------------------------------------------
-- Desc:		Gets a random player color.
-- Returns:		Color, random player color.
function TTT.PlayerSettings.GetRandomPlayerColor()
	local col = hook.Call("TTT.PlayerSettings.SetSpawnColor")
	if not IsColor(col) then
		local mode = colormode:GetInt() or 0
		if mode == 1 then
			col = table.RandomSequential(TTT.PlayerSettings.PlayerColors.serious)
		elseif mode == 2 then
			col = table.RandomSequential(TTT.PlayerSettings.PlayerColors.all)
		elseif mode == 3 then
			math.randomseed(os.time())
			col = Color(math.random(0, 255), math.random(0, 255), math.random(0, 255))
		else
			col = TTT.Colors.White
		end
	end
	return col
end

------------------------------------
-- TTT.PlayerSettings.SetSpawnModel
------------------------------------
-- Desc:		Sets the model people will spawn in with.
-- ARg One:		String, path to the model.
function TTT.PlayerSettings.SetSpawnModel(mdl)
	util.PrecacheModel(mdl)
	TTT.PlayerSettings.DefaultModel = mdl
end

-------------------------------
-- TTT.PlayerSettings.SetModel
-------------------------------
-- Desc:		Sets the player to a server default or maybe a custom one.
-- Arg One:		Player, to set the model of.
function TTT.PlayerSettings.SetModel(ply)
	local mdl = hook.Call("TTT.PlayerSettings.SetCustomSpawnModel", nil, ply)
	if not isstring(mdl) then
		mdl = TTT.PlayerSettings.DefaultModel
	end
	ply:SetModel(mdl)
	ply:SetColor(COLOR_WHITE)
	TTT.PlayerSettings.SetModelColor(ply)
end

-------------------------------------------
-- TTT.PlayerSettings.SetDefaultModelColor
-------------------------------------------
-- Desc:		Sets the default player spawn color to the given color.
-- Arg One:		Color, default spawn color.
function TTT.PlayerSettings.SetDefaultModelColor(col)
	TTT.PlayerSettings.DefaultColor = col
end

------------------------------------
-- TTT.PlayerSettings.SetModelColor
------------------------------------
-- Desc:		Sets the model color of a player.
-- Arg One:		Player, to have model color set to.
function TTT.PlayerSettings.SetModelColor(ply)
	local col = hook.Call("TTT.PlayerSettings.SetCustomPlayerColor", nil, ply)
	if not IsColor(col) then
		col = TTT.PlayerSettings.DefaultColor
	end
	ply:SetPlayerColor(Vector(col.r/255, col.g/255, col.b/255))
end