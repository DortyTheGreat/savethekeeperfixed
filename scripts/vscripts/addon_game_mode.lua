-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc
require('internal/util')
require('gamemode')
require('stk_api')

-- This is a detailed example of many of the containers.lua possibilities, but only activates if you use the provided "playground" map
if GetMapName() == "8_paladins" then
  require("gamemodes/8_paladins")
elseif GetMapName() == "4_paladins" or true then -- 2025 - eh...
  require("gamemodes/4_paladins")
elseif GetMapName() == "4x4_paladins" then
  require("gamemodes/4x4_paladins")
elseif GetMapName() == "paladins_arena" then
  require("gamemodes/paladins_arena")
elseif GetMapName() == "paladins_domination" then
  require("gamemodes/paladins_domination")
end

function GameMode:OrderFilter( filterTable )
  local units = filterTable["units"]
  local orderType = filterTable["order_type"]
  local target = EntIndexToHScript(filterTable["entindex_target"])

  if orderType == DOTA_UNIT_ORDER_ATTACK_TARGET then
    for _,unitIndex in pairs(units) do
      local attacker = EntIndexToHScript(unitIndex)
      if target and attacker then
        if target:GetTeamNumber() == attacker:GetTeamNumber() then
          return false
        end
      end
    end
  end
  --if orderType == DOTA_UNIT_ORDER_GIVE_ITEM then print("GIVE ITEM") end
  --if orderType == DOTA_UNIT_ORDER_PICKUP_ITEM then print("PICKUP ITEM") end
  --if orderType == DOTA_UNIT_ORDER_DROP_ITEM then print ("DROP ITEM") end
  --if orderType == DOTA_UNIT_ORDER_PURCHASE_ITEM then print ("PURCHASE ITEM") end
  --if orderType == DOTA_UNIT_ORDER_MOVE_ITEM then print ("MOVE ITEM") end
  return true
end


function Precache( context )
	PrecacheEveryThingFromKV(context)
	PrecacheUnitByNameSync("npc_dota_hero_dragon_knight", context)
	PrecacheUnitByNameSync("npc_dota_hero_sniper", context)
	PrecacheUnitByNameSync("npc_dota_hero_vengefulspirit", context)
	PrecacheUnitByNameSync("npc_dota_hero_treant", context)
	PrecacheUnitByNameSync("npc_dota_hero_omniknight", context)
	PrecacheUnitByNameSync("npc_dota_hero_doom_bringer", context)
	PrecacheUnitByNameSync("npc_dota_Hero_crystal_maiden", context)
	PrecacheUnitByNameSync("npc_dota_hero_legion_commander", context)
	PrecacheUnitByNameSync("npc_dota_hero_zuus", context)
	PrecacheUnitByNameSync("npc_dota_hero_chen", context)
	PrecacheUnitByNameSync("npc_dota_hero_silencer", context)
	
end

function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:_InitGameMode()
end

function GameMode:OnUnitThink()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

        local deadUnitCount = 0
        for ind, unit in pairs(GameMode.UnitThinkerList) do
            if unit:IsNull() or not unit:IsAlive() then
                table.remove(GameMode.UnitThinkerList, ind - deadUnitCount)
                deadUnitCount = deadUnitCount + 1
            elseif GameRules:GetGameTime() > unit.NextOrderTime then
				local curvar = 5
                if unit.ThinkerType == "wander" then

                    local x = math.random(unit.wanderBounds.XMin, unit.wanderBounds.XMax)
                    local y = math.random(unit.wanderBounds.YMin, unit.wanderBounds.YMax)
                    local z = GetGroundHeight(Vector(x, y, 128), nil)

                    print("wandering to x: " .. x .. " y: " .. y)

                    -- Issue the movement order to the unit
                    unit:MoveToPosition(Vector(x, y, z))

                elseif unit.ThinkerType == "target_caster" then
                    --print("casting heal ability " .. EntIndexToHScript(unit.CastAbilityIndex):GetName())
					local utarget
					local eability = EntIndexToHScript(unit.CastAbilityIndex)
					if eability:IsFullyCastable() then
						local tarunits = FindUnitsInRadius(unit:GetTeam(), unit:GetAbsOrigin(), nil, unit:GetAcquisitionRange(),eability:GetAbilityTargetTeam(), eability:GetAbilityTargetType(), eability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
						--DeepPrintTable(tarCDOTA_PlayerResource:GetUnitlist)
						for kev, funit in pairs(tarunits) do
							if funit:IsAlive() then
								if not utarget then 
									utarget = funit
								elseif funit:GetHealthPercent() < utarget:GetHealthPercent() then
									utarget = funit
								end
							end
						end
						if utarget and utarget:IsAlive() and unit:GetMana() >= eability:GetManaCost(eability:GetLevel()-1) and utarget ~= nil then
							utarget = utarget:GetEntityIndex()
							local order = {
								UnitIndex = unit:entindex(),
								AbilityIndex = unit.CastAbilityIndex,
								OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
								TargetIndex = utarget,
								Queue = false
							}
							ExecuteOrderFromTable(order)
						end
					end
					curvar = math.ceil(eability:GetCooldownTimeRemaining())

                elseif unit.ThinkerType == "point_target_caster" then
                    --print("casting heal ability " .. EntIndexToHScript(unit.CastAbilityIndex):GetName())
					local utarget
					local eability = EntIndexToHScript(unit.CastAbilityIndex)
					if eability:IsFullyCastable() then
						local tarunits = FindUnitsInRadius(unit:GetTeam(), unit:GetAbsOrigin(), nil, unit:GetAcquisitionRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
						--DeepPrintTable(tarCDOTA_PlayerResource:GetUnitlist)
						for kev, funit in pairs(tarunits) do
							if funit:IsAlive() then
								if not utarget then 
									utarget = funit
								elseif funit:GetHealthPercent() < utarget:GetHealthPercent() then
									utarget = funit
								end
							end
						end
						if utarget and utarget:IsAlive() and unit:GetMana() >= eability:GetManaCost(eability:GetLevel()-1) and utarget ~= nil then
							utarget = utarget:GetEntityIndex()
							local order = {
								UnitIndex = unit:entindex(),
								AbilityIndex = unit.CastAbilityIndex,
								OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
								TargetIndex = utarget,
								Queue = false
							}
							ExecuteOrderFromTable(order)
						end
					end
					curvar = math.ceil(eability:GetCooldownTimeRemaining())
					
                elseif unit.ThinkerType == "target_point" then
                    --print("casting heal ability " .. EntIndexToHScript(unit.CastAbilityIndex):GetName())
					local utarget
					local eability = EntIndexToHScript(unit.CastAbilityIndex)
					if eability:IsFullyCastable() then
						local tarunits = FindUnitsInRadius(unit:GetTeam(), unit:GetAbsOrigin(), nil, unit:GetAcquisitionRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
						--DeepPrintTable(tarCDOTA_PlayerResource:GetUnitlist)
						for kev, funit in pairs(tarunits) do
							if funit:IsAlive() then
								if not utarget then 
									utarget = funit
								elseif funit:GetHealthPercent() < utarget:GetHealthPercent() then
									utarget = funit
								end
							end
						end
						if utarget and utarget:IsAlive() and unit:GetMana() >= eability:GetManaCost(eability:GetLevel()-1) and utarget ~= nil then
							local order = {
								UnitIndex = unit:entindex(),
								AbilityIndex = unit.CastAbilityIndex,
								OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
								Position = utarget:GetOrigin(),
								TargetIndex = utarget:GetEntityIndex(),
								Queue = false
							}
							ExecuteOrderFromTable(order)
						end
					end
					curvar = math.ceil(eability:GetCooldownTimeRemaining())
					
                elseif unit.ThinkerType == "healer" then
                    --print("casting heal ability " .. EntIndexToHScript(unit.CastAbilityIndex):GetName())
					local utarget
					local eability = EntIndexToHScript(unit.CastAbilityIndex)
					if eability:IsFullyCastable() then
						local tarunits = FindUnitsInRadius(unit:GetTeam(), unit:GetAbsOrigin(), nil, unit:GetAcquisitionRange(),eability:GetAbilityTargetTeam(), eability:GetAbilityTargetType(), eability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
						for kev, funit in pairs(tarunits) do
							if funit:IsAlive() then
								if not utarget then 
									utarget = funit
								elseif funit:GetHealthPercent() < utarget:GetHealthPercent() then
									utarget = funit
								end
							end
						end
						if utarget and utarget:IsAlive() and utarget:GetHealthPercent() < 100 then
							utarget = utarget:GetEntityIndex()
							local order = {
								UnitIndex = unit:entindex(),
								AbilityIndex = unit.CastAbilityIndex,
								OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
								TargetIndex = utarget,
								Queue = false
							}
							ExecuteOrderFromTable(order)
						end
					end
					curvar = math.ceil(eability:GetCooldownTimeRemaining())
                end
				
                unit.NextOrderTime = GameRules:GetGameTime() + curvar
                --print(curvar)
            end
        end   

    elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        return nil
    end
    return 1
end

function GameMode:util_OnTakeDamage( filterTable )
    local damage = filterTable["damage"] --Post reduction
   --local ability = EntIndexToHScript( filterTable["entindex_inflictor_const"] )
    local victim = EntIndexToHScript( filterTable["entindex_victim_const"] )
	local attacker = filterTable["entindex_attacker_const"]
    if attacker then
		attacker = EntIndexToHScript( filterTable["entindex_attacker_const"] )
		if not attacker:IsHero() and not attacker:IsAncient() then
			local uaby = victim:FindAbilityByName("ve_paladins_arena_unit_buff")
			local at_uaby = attacker:FindAbilityByName("ve_paladins_arena_unit_buff")
			if uaby then
				local reduce_damage_pct = 100-uaby:GetSpecialValueFor("damage_reduce") 
				damage = damage * reduce_damage_pct/100
				--GameRules:SendCustomMessage("hp: "..victim:GetHealth().." damage: "..filterTable["damage"].." reduced_damage: "..reduce_damage_pct.." health: "..damage, 0,0)
				filterTable["damage"] = damage
			elseif uaby == nil and at_uaby and victim:IsHero() then
				local taken_damage_pct = 100-at_uaby:GetSpecialValueFor("damage_taken") 
				damage = damage * taken_damage_pct/100
				filterTable["damage"] = damage
				--GameRules:SendCustomMessage("hp: "..victim:GetHealth().." damage: "..filterTable["damage"].." reduced_damage: "..taken_damage_pct.." health: "..damage, 0,0)
			end
		end
	end
    --local damagetype = filterTable["damagetype_const"]



	return true
end



function GameMode:FilterModifyGold( filterTable )
		DeepPrintTable(filterTable)
        if filterTable["reason_const"] == DOTA_ModifyGold_CreepKill then
            filterTable["gold"] = 1.75*filterTable["gold"]
        end
    return true
end

function util_onPlayerReConnect(keys)
	DebugPrint( '[BAREBONES] OnPlayerReconnect' )
	--DeepPrintTable(keys)
	local newState = GameRules:State_Get()
	if newState >= DOTA_GAMERULES_STATE_STRATEGY_TIME then  
		--print(PlayerResource:GetSelectedHeroID(keys.PlayerID))
		if PlayerResource:GetSelectedHeroID(keys.PlayerID) == -1 then
			PlayerResource:GetPlayer(keys.PlayerID):MakeRandomHeroSelection()
		end
	end	
 	--if PlayerResource:HasSelectedHero(keys.PlayerID) then
	--	local playerID = keys.PlayerID
	--	local unit = PlayerResource:GetSelectedHeroEntity(playerID)
  	--	local team = unit:GetTeam()
	--	local keeper_s = FindUnitsInRadius(team, unit:GetAbsOrigin() ,nil, 1200.0,DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	--	for _,keep in pairs(keeper_s) do
	--		local unitname = keep:GetUnitName()  
	--		if unitname:find("npc_dota_ve_keeper") ~= nil then
	--			keep:RemoveModifierByName('modifier_smoke_of_deceit')
	--			break
	--		end
	--	end
	--	unit:RemoveModifierByName("modifier_smoke_of_deceit")
	--end
end
    
function PrecacheEveryThingFromKV( context )
    local kv_files = {  "scripts/npc/npc_units_custom.txt",
                            "scripts/npc/npc_abilities_custom.txt",
                            "scripts/npc/npc_heroes_custom.txt",
                            "scripts/npc/npc_abilities_override.txt",
                            "npc_items_custom.txt"
                          }
    for _, kv in pairs(kv_files) do
        local kvs = LoadKeyValues(kv)
        if kvs then
            print("BEGIN TO PRECACHE RESOURCE FROM: ", kv)
            PrecacheEverythingFromTable( context, kvs)
        end
    end
	
	-- This isn't the nicest way to PRECACHE things, but I want to hope that it at least works
	local units_kv = LoadKeyValues("scripts/npc/npc_units_custom.txt")
	
	for unitname, unitdata in pairs(units_kv) do
		print(unitdata)
		if type(unitdata) == "table" then -- not exactly sure, but sometimes there could be no model, I guess...
			
			if unitdata["Model"] then
				print('precaching ' .. unitdata["Model"] .. " : " .. unitname)
				PrecacheModel(unitdata["Model"], context)
			else
				print('precaching [NO MODEL] : ' .. unitname)
			end
		end
		PrecacheUnitByNameSync(unitname, context, nil)
	end
end

function PrecacheEverythingFromTable( context, kvtable)
    for key, value in pairs(kvtable) do
        if type(value) == "table" then
            PrecacheEverythingFromTable( context, value )
        else
            if string.find(value, "vpcf") then
                PrecacheResource( "particle",  value, context)
                print("PRECACHE PARTICLE RESOURCE", value)
            end
            if string.find(value, "vmdl") then  
                PrecacheResource( "model",  value, context)
                print("PRECACHE MODEL RESOURCE", value)
            end
            if string.find(value, "vsndevts") then
                PrecacheResource( "soundfile",  value, context)
                print("PRECACHE SOUND RESOURCE", value)
            end
        end
    end
end