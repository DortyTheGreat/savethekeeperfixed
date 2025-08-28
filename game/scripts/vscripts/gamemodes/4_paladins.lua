 

TYPE_VOTES = {}

function GameMode:InitGameMode()
	--ListenToGameEvent("player_connect_full", Dynamic_Wrap(CDOTA_PlayerResource, "util_onPlayerConnect"), self)
	ListenToGameEvent("player_reconnected", Dynamic_Wrap(CDOTA_PlayerResource, 'util_onPlayerReConnect'), self)
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(GameMode, "OrderFilter"), self)
	GameRules:GetGameModeEntity():SetDamageFilter( Dynamic_Wrap( GameMode, "util_OnTakeDamage" ), self )
	--GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(GameMode,"FilterModifyGold"),self)
	GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride( 8 )
	LinkLuaModifier( "modifier_aether_staff_lua", "items/aether_staff_modifier.lua",LUA_MODIFIER_MOTION_NONE )
	
    print( "Loading AI Testing Game Mode." )
    -- SEEDING RNG IS VERY IMPORTANT
    math.randomseed(Time())

    -- Set up a table to hold all the units we want to spawn
    GameMode.UnitThinkerList = {}
    GameRules:GetGameModeEntity():SetThink( "OnUnitThink", self, "UnitThink", 1 )
end

function GameMode:OnPlayerVoteReady(event)
	TYPE_VOTES[event.PlayerID] = event.type
	
	local fastCount, classicCount, longCount = countVoteTypes()
	CustomGameEventManager:Send_ServerToAllClients("vote_load", {fastCount = fastCount, classicCount = classicCount, longCount = longCount})
	local total_count_str = " (<font color='green'>".. fastCount .."</font> " .. "<font color='gold'>".. classicCount .."</font> " .. "<font color='purple'>".. longCount .."</font>)"
	
	if event.type == 0 then GameRules:SendCustomMessage("Игрок <font color='#58ACFA'>".. PlayerResource:GetPlayerName(event.PlayerID) .."</font> выбрал режим <font color='green'>".. "Быстрый" .."</font>" .. total_count_str, 0, 0)
	elseif event.type == 1 then GameRules:SendCustomMessage("Игрок <font color='#58ACFA'>".. PlayerResource:GetPlayerName(event.PlayerID) .."</font> выбрал режим <font color='gold'>".. "Классический" .."</font>" .. total_count_str, 0, 0)
	elseif event.type == 2 then GameRules:SendCustomMessage("Игрок <font color='#58ACFA'>".. PlayerResource:GetPlayerName(event.PlayerID) .."</font> выбрал режим <font color='red'>".. "Долгий" .."</font>" .. total_count_str, 0, 0) end
	--elseif event.type == 2 then GameRules:SendCustomMessage("Игрок <font color='#58ACFA'>".. PlayerResource:GetPlayerName(event.PlayerID) .."</font> выбрал режим <font color='purple'>".. "Modern" .."</font>" .. total_count_str, 0, 0) end
end


function spawnOneCreep(unit, start_point, target_point, team)	
		local r_unit = CreateUnitByName( unit, start_point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, team )
		r_unit:SetInitialGoalEntity( target_point )	
end

function GameMode:UnitPanelDebug(data)
	if GameMode:game_IsValidPlayer(data.PlayerID, true)	then
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(data.PlayerID), "load_allunits", GameRules.unitdata )
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(data.PlayerID), "load_allupgrades", CDOTA_PlayerResource:GetUpgradelist(data.PlayerID) )
		Msg("Unitpanel debug has called;")
	end
end

function GameMode:OnPlayerPanoramaReady(data)
	print("PANORAMA READY")
	GameMode:LoadPlayerBasics(data.PlayerID)
end


function GameMode:OnDirectionChanged(data)
	CDOTA_PlayerResource:SetCreepDirectionBasic(data.PlayerID, data.direction)
end

function GameMode:OnFirstPlayerLoaded()
	CustomGameEventManager:RegisterListener( "player_vote_ready", Dynamic_Wrap(GameMode, "OnPlayerVoteReady") )	
end

require("gamemodes/wavemodes")


-- it seems that game_IsValidPlayer check doesn't work properly during loading, so I removed that check. Hope that there are no abuses
function countVoteTypes()
    local fastCount = 0
    local classicCount = 0
    local longCount = 0

    for playerID = 0, 24-1 do
        --if GameMode:game_IsValidPlayer(playerID, false) then
            if TYPE_VOTES[playerID] == 0 then
                fastCount = fastCount + 1
            elseif TYPE_VOTES[playerID] == 1 then
                classicCount = classicCount + 1
            elseif TYPE_VOTES[playerID] == 2 then
                longCount = longCount + 1
            end
        --end
    end

    return fastCount, classicCount, longCount
end

function GameMode:ChangeSettings(TYPE_VOTES)

	local fastCount, classicCount, longCount = countVoteTypes()
	
	if fastCount == 0 and classicCount == 0 and longCount == 0 then 
		init_classic_wavemode()
	else
		if fastCount >= classicCount and fastCount >= longCount then
			init_fast_wavemode()
		elseif classicCount >= fastCount and classicCount >= longCount then
			init_classic_wavemode()
		elseif longCount >= fastCount and longCount >= classicCount then
			--init_modern_wavemode()
			init_long_wavemode()
		end	
	end
end

function GameMode:OnGameRulesStateChange(keys)
  local newState = GameRules:State_Get()
  if newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
  	GameMode:ChangeSettings(TYPE_VOTES)	
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		--if PlayerResource:GetPlayer(playerID) ~= nil and PlayerResource:IsValidPlayer(playerID) then
		if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
			--print(PlayerResource:GetSelectedHeroID(playerID))
			if PlayerResource:GetSelectedHeroID(playerID) == -1 then
				PlayerResource:GetPlayer(playerID):MakeRandomHeroSelection()
			end
		end
	end
  end
  if newState == DOTA_GAMERULES_STATE_PRE_GAME then		
	print("CHANGES READY")
	print("changed INCOME "..INCOME_COUNT)

	ROUND_TIME = 30.0
	INCOME_TIME = 30.0
  end
end

function GameMode:OnAllPlayersLoaded()
	CustomGameEventManager:RegisterListener( "player_panorama_ready", Dynamic_Wrap(GameMode, "OnPlayerPanoramaReady") )	
	
	CustomGameEventManager:RegisterListener( "buy_unit", Dynamic_Wrap(GameMode, "OnBuyUnit") )
	CustomGameEventManager:RegisterListener( "buy_upgrade", Dynamic_Wrap(GameMode, "OnBuyUpgrade") )
	CustomGameEventManager:RegisterListener( "sell_unit", Dynamic_Wrap(GameMode, "OnSellUnit") )
	CustomGameEventManager:RegisterListener( "change_direction", Dynamic_Wrap(GameMode, "OnDirectionChanged") )
	
	

	
	--CustomGameEventManager:RegisterListener( "unitpanel_debug", Dynamic_Wrap(GameMode, "UnitPanelDebug") )
	
	Timers:CreateTimer(0.1,function()
		keyvalue = LoadKeyValues("scripts/npc/npc_units_custom.txt")
		Msg("Keyvalues loaded;")		
		for a, unit in pairs(GameMode.data_UnitList) do 
			GameRules.unitdata[unit.name] = {UnitType = keyvalue[unit.name].UnitType, unitindex = keyvalue[unit.name].UnitIndex, AItype = keyvalue[unit.name].AItype, ancient = keyvalue[unit.name].AncientUnit, unitclass = keyvalue[unit.name].UnitClass, cost = CREEP_COST_MULT * keyvalue[unit.name].UnitCost, income = keyvalue[unit.name].UnitIncome, food = keyvalue[unit.name].NeedFood, health = keyvalue[unit.name].StatusHealth, page = keyvalue[unit.name].UnitPage, mindamage = keyvalue[unit.name].AttackDamageMin, maxdamage = keyvalue[unit.name].AttackDamageMax, attackrange = keyvalue[unit.name].AttackRange, armor = keyvalue[unit.name].ArmorPhysical, mingold = keyvalue[unit.name].BountyGoldMin, maxgold = keyvalue[unit.name].BountyGoldMax, ability1 = keyvalue[unit.name].Ability1, ability2 = keyvalue[unit.name].Ability2, ability3 = keyvalue[unit.name].Ability3, ability4 = keyvalue[unit.name].Ability4, ability5 = keyvalue[unit.name].Ability5}
		end
	end)
	

	Timers:CreateTimer(0.1, function()
			if CURRENT_STATE_TIME == 0 then
				CURRENT_STATE_TIME = STATECHANGE_TIME_CONSTANT
				GAME_STATE_NUMBER = GAME_STATE_NUMBER + 1
				for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
					if GameMode:game_IsValidPlayer(playerID, false) then
						CDOTA_PlayerResource:SetMaxFood(playerID, CDOTA_PlayerResource:GetMaxFood(playerID) + BONUS_FOOD*GAME_STATE_NUMBER)
						if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
							CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "player_newfood", {food = CDOTA_PlayerResource:GetFood(playerID), maxfood = CDOTA_PlayerResource:GetMaxFood(playerID)} )
						end
					end
				end				
			end
			CURRENT_STATE_TIME = CURRENT_STATE_TIME - 1
			for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
				if GameMode:game_IsValidPlayer(playerID, true) then
					CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "timer_going", {round_time = ROUND_TIME, income_time = INCOME_TIME, game_state_number = GAME_STATE_NUMBER, state_time = CURRENT_STATE_TIME, game_constant = STATECHANGE_TIME_CONSTANT} )
				end 
			end
			if INCOME_TIME > 0 then INCOME_TIME = INCOME_TIME - 1 end
			if ROUND_TIME > 0 then ROUND_TIME = ROUND_TIME - 1 end
		return 1.0
	end)
end

function GameMode:OnBuyUnit(event)
	
	local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
	local curunitlist = CDOTA_PlayerResource:GetUnitlist(hero:GetPlayerOwnerID())
	local unitcount = 0;

	for a, unit in pairs(curunitlist) do

		if unit.count > 0 then unitcount = unitcount + unit.count end
	end

	
	if event.count ~= nil then
		local myfood = CDOTA_PlayerResource:GetFood(event.PlayerID)
		if hero:GetGold() >= GameRules.unitdata[event.name].cost and myfood + GameRules.unitdata[event.name].food <= CDOTA_PlayerResource:GetMaxFood(event.PlayerID) and unitcount < 40 then -- unit hardlimit of 40
			CDOTA_PlayerResource:SetIncome(event.PlayerID, CDOTA_PlayerResource:GetIncome(event.PlayerID) + GameRules.unitdata[event.name].income)
			CDOTA_PlayerResource:SetFood(event.PlayerID, myfood + GameRules.unitdata[event.name].food)
			if event.count == 0 and hero:GetRespawnsDisabled() == false then
				local team = hero:GetTeam()
				if CDOTA_PlayerResource:GetCreepDirectionBasic(event.PlayerID) == 1 then
					GameMode:spawnCreep(event.name, 1, Entities:FindByName( nil, "spawn_" .. team):GetAbsOrigin(), Entities:FindByName( nil, "point_" .. team), team, hero)
				else
					GameMode:spawnCreep(event.name, 1, Entities:FindByName( nil, "spawn_" .. team):GetAbsOrigin(), Entities:FindByName( nil, "point_reverse_" .. team), team, hero)
				end
			else
				CDOTA_PlayerResource:SetUnitCount(event.PlayerID, event.name, event.count)
			end
			local curunitlist = CDOTA_PlayerResource:GetUnitlist(hero:GetPlayerOwnerID())
			--DeepPrintTable(curunitlist)
			PlayerResource:SpendGold(event.PlayerID, GameRules.unitdata[event.name].cost, 1)
			GameMode:LoadPlayerUnits(event.PlayerID)		
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(event.PlayerID), "unitbuy_success", {income = CDOTA_PlayerResource:GetIncome(event.PlayerID), food = CDOTA_PlayerResource:GetFood(event.PlayerID)} )
		end
	end
end

function GameMode:OnBuyUpgrade(event)
	
	local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
	local curunitlist = CDOTA_PlayerResource:GetUpgradelist(event.PlayerID)
	
	if hero:GetGold() >= curunitlist[event.name].cost then
		curunitlist[event.name].level = curunitlist[event.name].level + 1
		local cost = curunitlist[event.name].cost + UPGRADE_COST_CONST*curunitlist[event.name].level
		PlayerResource:SpendGold(event.PlayerID, curunitlist[event.name].cost, 1)
		curunitlist[event.name].cost = cost;
		CDOTA_PlayerResource:SetUpgradelist(hero:GetPlayerOwnerID(), curunitlist)		
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(event.PlayerID), "upgradebuy_success", curunitlist )
	end
end

function GameMode:OnSellUnit(event)
	
	local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
	local unitcount = 0;
	local istrue = true
	local curunitlist = CDOTA_PlayerResource:GetUnitlist(event.PlayerID)
	if event.count ~= nil then
		for a, unit in pairs(curunitlist) do
			if unit.name == event.name then
				if unit.count == 0 then
					istrue = false
					break
				end
			end
			if unit.count > 0 then unitcount = unitcount + unit.count end
		end
		if istrue == true then
			if unitcount > 4 then
				CDOTA_PlayerResource:SetIncome(event.PlayerID, CDOTA_PlayerResource:GetIncome(event.PlayerID) - GameRules.unitdata[event.name].income)
				CDOTA_PlayerResource:SetFood(event.PlayerID, CDOTA_PlayerResource:GetFood(event.PlayerID) - GameRules.unitdata[event.name].food)
				PlayerResource:ModifyGold(hero:GetPlayerOwnerID(), GameRules.unitdata[event.name].cost, false, 1)
				CDOTA_PlayerResource:SetUnitCount(event.PlayerID, event.name, event.count*-1)
				GameMode:LoadPlayerUnits(event.PlayerID)
				CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(event.PlayerID), "unitbuy_success", {income = CDOTA_PlayerResource:GetIncome(event.PlayerID), food = CDOTA_PlayerResource:GetFood(event.PlayerID), maxfood = CDOTA_PlayerResource:GetMaxFood(event.PlayerID)} )
			end
		end
	end

end
function GameMode:OnHeroInGame(hero)
	if hero:IsRealHero() then
		print("hero spawned")
		local ownerid = hero:GetPlayerOwnerID()		
		Msg("load_allunits event started;")
		local keeper_s = FindUnitsInRadius(hero:GetTeam(), hero:GetAbsOrigin() ,nil, 25000.0,DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		local count = 0
		for _,keep in pairs(keeper_s) do
		   	local unitname = keep:GetUnitName()  
		   	if unitname:find("npc_dota_ve_keeper") ~= nil then
		      count = count + 1
			end
		end		
		if count == 0 then
			local pos_vector = Entities:FindByName( nil, "ve_keeper_"..hero:GetTeam() ):GetAbsOrigin()	
			local crunit = CreateUnitByName( "npc_dota_ve_keeper", pos_vector, true, hero, hero, hero:GetTeam())
			crunit:SetOwner(hero)
			crunit:SetControllableByPlayer(hero:GetPlayerOwnerID(), true)	
			crunit:SetHasInventory(false)	
		end
	end
end

function GameMode:OnGameInProgress()

	Timers:CreateTimer(0.1, function()
		local allHeroes = HeroList:GetAllHeroes()
		local processedOwnerIDs = {} -- this hotfixes meepo and other multieroed calls
		for _,hero in pairs(allHeroes) do
			local ownerid = hero:GetPlayerOwnerID()
			if not hero:IsIllusion() and not processedOwnerIDs[ownerid] then
				processedOwnerIDs[ownerid] = true
				
				--if ownerid and PlayerResource:GetPlayer(ownerid) and PlayerResource:IsValidPlayer(ownerid) and PlayerResource:HasSelectedHero( ownerid ) then
					local curunitlist = deepcopy(CDOTA_PlayerResource:GetUnitlist(ownerid))
					local team = hero:GetTeam()
					for key,unit in pairs(curunitlist) do
						local ucounter = 0
						Timers:CreateTimer(0.1, function()
							if unit.count > 0 then
								print(CDOTA_PlayerResource:GetCreepDirectionBasic(ownerid))
								if CDOTA_PlayerResource:GetCreepDirectionBasic(ownerid) == 1 then
									GameMode:spawnCreep(unit.name, 1, Entities:FindByName( nil, "spawn_" .. team):GetAbsOrigin(), Entities:FindByName( nil, "point_" .. team), team, hero)
								else
									GameMode:spawnCreep(unit.name, 1, Entities:FindByName( nil, "spawn_" .. team):GetAbsOrigin(), Entities:FindByName( nil, "point_reverse_" .. team), team, hero)
								end
								
								--Msg(hero:GetTeam() .. " - Spawned Creep - " .. unit.name .. " - Count: ".. unit.count .. "\n");				
							end	
							ucounter = ucounter + 1						
							if ucounter < unit.count then
								return CREEP_SPAWN_DELAY
							else return end
						end)

					end
				--end
			end
		end
		ROUND_TIME = ROUND_DELAY
		return ROUND_DELAY
	end)
	
	Timers:CreateTimer(0.1, function()
	
		local allHeroes = HeroList:GetAllHeroes()
		local processedOwnerIDs = {} -- this hotfixes meepo and other multieroed calls
		for _,hero in pairs(allHeroes) do
			local ownerid = hero:GetPlayerOwnerID()
			if not hero:IsIllusion() and not processedOwnerIDs[ownerid] then
				processedOwnerIDs[ownerid] = true
				
				if GameMode:game_IsValidPlayer(ownerid, false) then
					local team = hero:GetTeam()
					local myincome = CDOTA_PlayerResource:GetIncome(ownerid)
					PlayerResource:ModifyGold(ownerid, INCOME_COUNT*myincome, false, 1)
				end
			end
		end 		
		INCOME_TIME = INCOME_DELAY
		return INCOME_DELAY
	end)
end

-- An entity died
function GameMode:OnEntityKilled( keys )
	DebugPrint( '[BAREBONES] OnEntityKilled Called' )
	DebugPrintTable( keys )
  

  -- The Unit that was Killed
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	-- The Killing entity
	local killerEntity = nil
		
	if keys.entindex_attacker ~= nil then
		killerEntity = EntIndexToHScript( keys.entindex_attacker )
	end

	-- The ability/item used to kill, or nil if not killed by an item/ability
	local killerAbility = nil

	if keys.entindex_inflictor ~= nil then
		killerAbility = EntIndexToHScript( keys.entindex_inflictor )
	end
	local damagebits = keys.damagebits -- This might always be 0 and therefore useless
	local canrespawn = 0
	local allHeroes = HeroList:GetAllHeroes()
	local unitname = killedUnit:GetUnitName();	
	if unitname:find("npc_dota_ve_keeper") ~= nil then
		for _,hero in pairs(allHeroes) do

			if hero:GetTeam() == killerEntity:GetTeam() and not hero:IsIllusion() and PlayerResource:GetConnectionState(killedUnit:GetPlayerOwnerID()) == DOTA_CONNECTION_STATE_CONNECTED  then
				local value = 1000
				SendOverheadEventMessage( hero, OVERHEAD_ALERT_GOLD , hero, value, nil )
				PlayerResource:ModifyGold(hero:GetPlayerOwnerID(), value, false, 1)
				--GameRules:SendCustomMessage("Игрок <font color='#58ACFA'>".. PlayerResource:GetPlayerName(hero:GetPlayerOwnerID()) .."</font> получает <font color='gold'>".. value .."</font> золота за убийство хранителя", 0, 0)
				GameRules:SendCustomMessage("#Game_notification_kill_keeper", hero:GetPlayerOwnerID(), value)

			elseif hero:GetTeam() == killedUnit:GetTeam() then				
				--GameRules:SendCustomMessage("<font color='#58ACFA'>Паладин игрока " .. GetPlayerName(hero:GetPlayerID()) .. " был убит!</font>", 0, 0)
				hero:SetCanSellItems(false);
				hero:SetGold(0, false);
				hero:SetRespawnsDisabled(true)
				hero:SetUnitCanRespawn(false)
				hero:SetTimeUntilRespawn(-1)
				hero:SetBuyBackDisabledByReapersScythe(true)
				hero:Kill(killerAbility, killerEntity)		
        		AddFOWViewer(killedUnit:GetTeam(),killedUnit:GetAbsOrigin(), 99999999.0, 99999999.0, false)
				local ownerid = hero:GetPlayerOwnerID()
				if ownerid ~= nil and PlayerResource:IsValidPlayerID(ownerid) and PlayerResource:IsValidPlayer(ownerid) and not PlayerResource:IsFakeClient(ownerid)  then
					local curunitlist = CDOTA_PlayerResource:GetUnitlist(ownerid)
					for k in pairs (curunitlist) do
						curunitlist[k] = nil
					end					
					CDOTA_PlayerResource:SetUnitlist(hero:GetPlayerOwnerID(), curunitlist)
				end				
			end	
			if hero:GetRespawnsDisabled() == false and not hero:IsIllusion() then
					canrespawn = canrespawn + 1
			end
		end
		if canrespawn == 1 then
			GameRules:SetGameWinner(killerEntity:GetTeam())
			if not GameRules:IsCheatMode() then 
				SendToServer(killerEntity:GetTeam())
			else
				print('[SUPABASE] sending data to server can only occur without cheats')
			end
		end
	elseif killedUnit ~= killerEntity and killedUnit:IsHero() and not killedUnit:IsIllusion() and killedUnit:IsReincarnating() == false then
		if PlayerResource:GetConnectionState(killedUnit:GetPlayerOwnerID()) == DOTA_CONNECTION_STATE_CONNECTED then
			for _,hero in pairs(allHeroes) do
				if hero:GetTeam() == killerEntity:GetTeam() and not hero:IsIllusion() and PlayerResource:GetConnectionState(hero:GetPlayerOwnerID()) == DOTA_CONNECTION_STATE_CONNECTED then
					local value = 25*killedUnit:GetLevel()
					SendOverheadEventMessage( hero, OVERHEAD_ALERT_GOLD , hero, value, nil )
					PlayerResource:ModifyGold(hero:GetPlayerOwnerID(), value, false, 1)
					--GameRules:SendCustomMessage("Игрок <font color='#58ACFA'>".. PlayerResource:GetPlayerName(hero:GetPlayerOwnerID()) .."</font> получает <font color='gold'>".. value .."</font> золота за убийство героя противника", 0, 0)
					GameRules:SendCustomMessage("#Game_notification_kill_hero", hero:GetPlayerOwnerID(), value)					
				end
			end
		end
	end

end

function parseNewPos(killedTeam, parseTeam)
	local allHeroes = HeroList:GetAllHeroes()
	for _, targethero in pairs(allHeroes) do
		if targethero:GetTeam() == parseTeam then
			for _, targethero2 in pairs(allHeroes) do						
				if targethero2:GetTeam() ~= killedTeam and targethero2:GetTeam() ~= parseTeam and targethero2:GetRespawnsDisabled() == false then
					local pos = Entities:FindByName( nil, "target_point_team"..targethero2:GetTeam() ):GetAbsOrigin()	
					Entities:FindByName( nil, "target_point_"..parseTeam .."center2" ):SetAbsOrigin(pos)
				end
			end
		end
	end	
end