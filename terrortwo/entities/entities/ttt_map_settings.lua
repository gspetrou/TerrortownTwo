-- Map entity which allows the map to manipulate certain settings in the gamemode.
ENT.Type = "point"
ENT.Base = "base_point"

function ENT:Initialize()
	-- TODO: https://github.com/Facepunch/garrysmod/blob/master/garrysmod/gamemodes/terrortown/entities/entities/ttt_map_settings.lua#L9
	timer.Simple(0, function()
		self:TriggerOutput("MapSettingsSpawned", self)
	end)
end

function ENT:KeyValue(k, v)
	if k == "cbar_doors" then
		
	elseif k == "cbar_buttons" then
		
	elseif k == "cbar_other" then
		
	elseif k == "plymodel" and v ~= "" then
		if util.IsValidModel(v) then
			util.PrecacheModel(v)
			TTT.Player.SetDefaultSpawnModel(v)
			TTT.Debug.Print("Map settings: Set default player model to: \""..v.."\"")
		else
			TTT.Debug.Print("Map settings: Failed to set default player model due to invalid path: \""..v.."\"")
		end
	elseif k == "propspec_named" then
		
	elseif k == "MapSettingsSpawned" or k == "RoundEnd" or k == "RoundPreparation" or k == "RoundStart" then
		self:StoreOutput(k, v)
	end
end

-- Can send an input to set the default player model.
function ENT:AcceptInput(name, _, _, data)
	if name == "SetPlayerModels" then
		local modelName = tostring(data)

		if not modelName then
			ErrorNoHalt("Map settings: Invalid parameter to SetPlayerModels input!\n")
			return false
		elseif not util.IsValidModel(modelName) then
			ErrorNoHalt("Map settings: Invalid model given: "..modelName.."\n")
			return false
		end

		TTT.Player.SetDefaultSpawnModel(modelName)
		TTT.Debug.Print("Map settings: Input set default player model to: \""..modelName.."\"")
	end
end

function ENT:RoundStateTrigger(round, wintype)
	if round == ROUND_PREP then
		self:TriggerOutput("RoundPreparation", self)
	elseif round == ROUND_ACTIVE then
		self:TriggerOutput("RoundStart", self)
	elseif round == ROUND_POST then
		self:TriggerOutput("RoundEnd", self, tostring(wintype))	-- Also pass the wintype.
	elseif round == ROUND_WAITING then
		self:TriggerOutput("RoundWaiting", self)
	end
end