
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/Noita_HpScaling/settings.lua")
local function GetPlayerEntity()
    local players = EntityGetWithTag("player_unit") or {}
    if #players >= 1 then
        return players[1]
    else
        players = EntityGetWithTag("polymorphed_player") or {}
        if #players >= 1 then
            return players[1]
        else
            return nil
        end
    end
end

local function get_nearby_enemies(x, y, radius)
  local enemies = {}
  if not x or not y then return enemies end
  local nearby = EntityGetInRadiusWithTag(x, y, radius, "enemy") or {}
    for _, entity in ipairs(nearby) do
      table.insert(enemies, entity)
    end
    return enemies
end

function OnPlayerSpawned(player_entity)
    -- planned features;
    -- Distance to Difficulty (player_entity location to 0, 0)
    -- depth to Difficulty
    -- Parallel to difficulty (idk if this is possible)
    -- Orb to difficulty
    -- Time to difficulty
    -- kills to difficulty

function OnWorldPreUpdate() -- This is called every time the game is about to start updating the world
    local player_entity = GetPlayerEntity()
    if(player_entity == nil)then
        return
    end

    local frames = GameGetFrameNum()
    local update_rate = 360
    local range = 400
    if frames % update_rate == 0 then
        local px, py = EntityGetTransform(player_entity)
        local enemies = get_nearby_enemies(px, py, range)

        -- multiply each enemy's HP by TerroInternalHpX, if they haven't been modified yet
        for _, enemy in ipairs(enemies) do
            local was_modified = false;
            local components = EntityGetComponent(enemy, "VariableStorageComponent") or {}
            for _, comp in ipairs(components) do
                local name = ComponentGetValue2(comp, "name")
                if(name == "terro_hp_scaled")then
                    was_modified = true
                    break
                end
            end
            if(was_modified == false)then
                local health_comps = EntityGetComponent(enemy, "DamageModelComponent") or {}
                for _, health_comp in ipairs(health_comps) do
                    local max_hp = ComponentGetValue2(health_comp, "max_hp")
                    local new_hp = max_hp * terro_internal_hp_x
                    ComponentSetValue2(health_comp, "max_hp", new_hp)
                    ComponentSetValue2(health_comp, "hp", new_hp)
                end
                EntityAddComponent2(enemy, "VariableStorageComponent", {
                    name = "terro_hp_scaled",
                    value_int = 1
                })
            end
        end
    end

end
	local orbmult = ModSettingGet("Noita_HpScaling.orbs_mult")
	local orbcalc = orbmult*GameGetOrbCountThisRun()
	local unused_value2 = 1
	local unused_value3 = 1 
	local basemult = ModSettingGet("Noita_HpScaling.base_mult")
	local terro_lunacy = ModSettingGet("Noita_HpScaling.10x")
    GamePrint("Terro's HP Scaling Active!")
	terro_internal_hp_raw =  ((basemult+orbcalc) * ((terro_lunacy*9+1))*unused_value2*unused_value3)
    terro_internal_hp_x = math.floor(terro_internal_hp_raw)
	GamePrint("Terro's HP Scaling Current Value: " .. tostring(terro_internal_hp_x))
end