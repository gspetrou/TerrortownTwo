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
-- Desc:		Sets the active player model for the map.
function TTT.Player.Initialize()
	-- Set the map default spawn model.
	local mdl = hook.Call("TTT.Player.SetSpawnModel")
	if not isstring(mdl) then
		math.randomseed(os.time())
		mdl = table.RandomSequential(TTT.Player.DefaultModels)
	end
	TTT.Player.SetSpawnModel(mdl)

	-- Set the map default spawn color.
	TTT.Player.DefaultColor = TTT.Player.GetRandomPlayerColor()
end

-----------------------------------
-- TTT.Player.GetRandomPlayerColor
-----------------------------------
-- Desc:		Gets a random player color.
-- Returns:		Color, random player color.
function TTT.Player.GetRandomPlayerColor()
	local col = hook.Call("TTT.Player.SetSpawnColor")
	if not IsColor(col) then
		math.randomseed(os.time())
		
		local mode = colormode:GetInt() or 0
		if mode == 1 then
			col = table.RandomSequential(TTT.Player.PlayerColors.serious)
		elseif mode == 2 then
			col = table.RandomSequential(TTT.Player.PlayerColors.all)
		elseif mode == 3 then
			col = Color(math.random(0, 255), math.random(0, 255), math.random(0, 255))
		else
			col = TTT.Colors.White
		end
	end
	return col
end

----------------------------
-- TTT.Player.SetSpawnModel
----------------------------
-- Desc:		Sets the model people will spawn in with.
-- ARg One:		String, path to the model.
function TTT.Player.SetSpawnModel(mdl)
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
	TTT.Player.SetModelColor(ply)
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