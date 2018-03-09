TTT.Player = TTT.Player or {}
TTT.Player.DefaultModel = TTT.Player.DefaultModel or "models/player/phoenix.mdl"
TTT.Player.DefaultColor = TTT.Player.DefaultColor or TTT.Colors.White
TTT.Player.DefaultModels = TTT.Player.DefaultModels or {
	"models/player/phoenix.mdl",
	"models/player/arctic.mdl",
	"models/player/guerilla.mdl",
	"models/player/leet.mdl"
}

local colormode = CreateConVar("ttt_playercolor_mode", "1", FCVAR_ARCHIVE, "Sets the set of colors to choose from for player spawns. 0 is off, 1 is muted colors, 2 is more colors, 3 is completely random colors.")

-- Thanks TTT.
local cols = TTT.Colors
TTT.Player.PlayerColors = TTT.Player.PlayerColors or {
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

-------------------------
-- TTT.Player.Initialize
-------------------------
-- Desc:		Set the default spawn model and color for the duration of the map.
function TTT.Player.Initialize()
	local mdl = hook.Call("TTT.Player.SetDefaultSpawnModel")
	if not isstring(mdl) then
		mdl = table.RandomSequential(TTT.Player.DefaultModels)
	end
	TTT.Player.SetDefaultSpawnModel(mdl)

	local col = hook.Call("TTT.Player.SetDefaultSpawnColor")
	if not IsColor(col) then
		col = TTT.Player.GetRandomPlayerColor()
	end
	TTT.Player.SetDefaultModelColor(col)
end

-----------------------------------
-- TTT.Player.GetRandomPlayerColor
-----------------------------------
-- Desc:		Gets a random player color.
-- Returns:		Color.
function TTT.Player.GetRandomPlayerColor()
	local mode = colormode:GetInt() or 0
	if mode == 1 then
		return table.RandomSequential(TTT.Player.PlayerColors.serious)
	elseif mode == 2 then
		return table.RandomSequential(TTT.Player.PlayerColors.all)
	elseif mode == 3 then
		return Color(math.random(0, 255), math.random(0, 255), math.random(0, 255))
	end

	return TTT.Colors.White
end

-----------------------------------
-- TTT.Player.SetDefaultSpawnModel
-----------------------------------
-- Desc:		Sets the model people will spawn in with.
-- ARg One:		String, path to the model.
function TTT.Player.SetDefaultSpawnModel(mdl)
	util.PrecacheModel(mdl)
	TTT.Player.DefaultModel = mdl
end

-----------------------
-- TTT.Player.SetModel
-----------------------
-- Desc:		Sets the player to a server default or maybe a custom one.
-- Arg One:		Player, to set the model of.
function TTT.Player.SetModel(ply)
	local mdl = hook.Call("TTT.Player.SetCustomSpawnModel", nil, ply)
	if not isstring(mdl) then
		mdl = TTT.Player.DefaultModel
	end
	ply:SetModel(mdl)
	ply:SetColor(COLOR_WHITE)
end

-----------------------------------
-- TTT.Player.SetDefaultModelColor
-----------------------------------
-- Desc:		Sets the default player spawn color to the given color.
-- Arg One:		Color, default spawn color.
function TTT.Player.SetDefaultModelColor(col)
	TTT.Player.DefaultColor = col
end

----------------------------
-- TTT.Player.SetModelColor
----------------------------
-- Desc:		Sets the model color of a player.
-- Arg One:		Player, to have model color set to.
function TTT.Player.SetModelColor(ply)
	local col = hook.Call("TTT.Player.SetCustomPlayerColor", nil, ply)
	if not IsColor(col) then
		col = TTT.Player.DefaultColor
	end
	ply:SetPlayerColor(Vector(col.r/255, col.g/255, col.b/255))
end


if CLIENT then
	---------------------------------------
	-- TTT.Player.CheckPlayerModelTextures
	---------------------------------------
	-- Desc:		So there are addons going around that override the CS:S models to ignorez.
	--				While this isn't the best fix it at least helps stop skiddies till sv_pure is fixed.
	function TTT.Player.CheckPlayerModelTextures()

	end
end