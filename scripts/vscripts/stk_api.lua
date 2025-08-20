

keyvalue = {}
GameRules.unitdata = {}

GameRules.upgradedata = {}
GameRules.upgradedata["melee_damage"] = {cost = 150, level = 0}
GameRules.upgradedata["melee_armor"] = {cost = 150, level = 0}
GameRules.upgradedata["melee_body"] = {cost = 50, level = 0}
GameRules.upgradedata["range_damage"] = {cost = 150, level = 0}
GameRules.upgradedata["range_armor"] = {cost = 50, level = 0}
GameRules.upgradedata["range_body"] = {cost = 150, level = 0}
--GameRules.GameRules.upgradedata["range_range"] = {cost = 1000, level = 0}
GameRules.upgradedata["healer_armor"] = {cost = 50, level = 0}
GameRules.upgradedata["healer_body"] = {cost = 50, level = 0}
--GameRules.GameRules.upgradedata["healer_heal"] = {cost = 1000, level = 0}
GameRules.upgradedata["special_armor"] = {cost = 50, level = 0}
GameRules.upgradedata["special_body"] = {cost = 50, level = 0}
--GameRules.GameRules.upgradedata["special_mana"] = {cost = 1000, level = 0}


GameMode.data_UnitList = {
	{name = "basic_unit_melee_1", count = 3},
	{name = "basic_unit_melee_2", count = 0},
	{name = "basic_unit_melee_3", count = 0},
	{name = "basic_unit_melee_4", count = 0},
	{name = "basic_unit_melee_5", count = 0},
	{name = "basic_unit_melee_6", count = 0},
	{name = "basic_unit_melee_7", count = 0},
	{name = "basic_unit_range_1", count = 1},
	{name = "basic_unit_range_2", count = 0},
	{name = "basic_unit_range_3", count = 0},
	{name = "basic_unit_range_4", count = 0},
	{name = "basic_unit_range_5", count = 0},
	{name = "basic_unit_range_6", count = 0},
	{name = "basic_unit_range_7", count = 0},
	{name = "basic_unit_luna_1", count = 0},
	{name = "basic_unit_luna_2", count = 0},
	{name = "basic_unit_luna_3", count = 0},
	{name = "basic_unit_luna_4", count = 0},
	{name = "basic_unit_luna_5", count = 0},
	{name = "basic_unit_luna_6", count = 0},
	{name = "basic_unit_luna_7", count = 0},
	{name = "basic_unit_buffer_1", count = 0},
	{name = "basic_unit_buffer_2", count = 0},
	{name = "basic_unit_buffer_3", count = 0},
	{name = "basic_unit_buffer_4", count = 0},
	{name = "basic_unit_buffer_5", count = 0},
	{name = "basic_unit_buffer_6", count = 0},
	{name = "basic_unit_buffer_7", count = 0},
	{name = "basic_unit_special_1", count = 0},
	{name = "basic_unit_special_2", count = 0},
	{name = "basic_unit_special_3", count = 0},
	{name = "basic_unit_special_4", count = 0},
	{name = "basic_unit_special_5", count = 0},
	{name = "basic_unit_special_6", count = 0},
	{name = "basic_unit_special_7", count = 0},
	{name = "boss_unit_doom", count = 0},
	{name = "boss_unit_legion_commander", count = 0},
	{name = "boss_unit_demonic_spirit", count = 0},
	{name = "boss_unit_ghost_keeper", count = 0},
}

GameMode.currentTowerDominationTeam = DOTA_TEAM_NEUTRALS


if not CDOTA_PlayerResource.PlayerData then 
	CDOTA_PlayerResource.PlayerData = {}
end

-- Ïðîâåðêà èãðîêà íà âàëèäíîñòü
function GameMode:game_IsValidPlayer(playerID, checkConnected)
	if playerID and PlayerResource:GetPlayer(playerID) and PlayerResource:IsValidPlayer(playerID) and PlayerResource:HasSelectedHero( playerID ) then
		if checkConnected == true then
			if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
				return true
			else
				return false
			end
		end
		return true
	else
		return false
	end
end

-- Çàãðóæàåò áàçîâûå äàííûå èãðîêà
function GameMode:LoadPlayerBasics (playerID)

	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "preload_configs", {}) 	-- Çàãðóçêà ïàðàìåòðîâ èãðû
		
	if GameMode:game_IsValidPlayer(playerID, false) then	
		util_OnPlayerLoaded(playerID)
	end
	if GameMode:game_IsValidPlayer(playerID, true) then		

		local user_steamids = {}
		for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if GameMode:game_IsValidPlayer(playerID, false) then
				if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
					user_steamids[playerID] = PlayerResource:GetSteamAccountID(playerID)
				end
			end
		end
		print("INCOME: " .. INCOME_COUNT);
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "load_configs", {income_count =  INCOME_COUNT, bonus_food = BONUS_FOOD, food = CDOTA_PlayerResource:GetFood(playerID), maxfood = CDOTA_PlayerResource:GetMaxFood(playerID)}) 	-- Çàãðóçêà ïàðàìåòðîâ èãðû
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "load_allunits", GameRules.unitdata )										-- Çàãðóçêà ïàðàìåòðîâ þíèòîâ
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "load_allupgrades", CDOTA_PlayerResource:GetUpgradelist(playerID) ) 	-- Çàãðóçêà ïàðàìåòðîâ óëó÷øåíèé
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "load_scoreboard", user_steamids ) 	-- Çàãðóçêà ïàðàìåòðîâ óëó÷øåíèé
		GameMode:LoadPlayerUnits(playerID)
		Msg("<<==>> [VE] Player BASICS was loaded <<==>>");
	end
end

-- PLAYER DATA: Âûçûâàåòñÿ, êîãäà èãðîê ïåðâûé ðàç çàãðóæåí
function util_OnPlayerLoaded( playerID )
  
    local status, err = pcall(function() 
		local ply = EntIndexToHScript(playerID+1)  
		--Timers:CreateTimer(0.03, function() -- To prevent it from being -1 when the player is created
			--if not ply then 
			--	SetValidStatus(playerID, false)
			--	return
			--end
			if not CDOTA_PlayerResource.PlayerData[playerID] then
				CDOTA_PlayerResource.PlayerData[playerID] = {}
				CDOTA_PlayerResource:SetUnitlist(playerID, GameMode.data_UnitList)
				CDOTA_PlayerResource:SetUpgradelist(playerID, GameRules.upgradedata)
				CDOTA_PlayerResource:SetIncome(playerID, 1)
				CDOTA_PlayerResource:SetFood(playerID, 9)
				CDOTA_PlayerResource:SetMaxFood(playerID, 25)
				CDOTA_PlayerResource:SetCreepDirectionBasic(playerID, 1)
				--SetValidStatus(playerID, true)
				--DeepPrintTable(PlayerData[playerID].unitlist)
			end
		--end)

	end)
	if not status then
		CustomGameEventManager:Send_ServerToAllClients( "error_debuger", {g_error = err, status = status} )
		print("\n *=* [VE ERROR] ********** " .. err)	
	end	
end

-- Çàãðóæàåò ñïèñîê êóïëåííûõ þíèòîâ èãðîêà
function GameMode:LoadPlayerUnits(playerID)
	if GameMode:game_IsValidPlayer(playerID, true) then	
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "load_playerunits", CDOTA_PlayerResource:GetUnitlist(playerID) )	-- Çàãðóçêà êóïëåííûõ þíèòîâ èãðîêà
	end
end

-- PLAYER DATA: Ïîëó÷èòü òåêóùåå êîëè÷åñòâî äîõîäà èãðîêà
function CDOTA_PlayerResource:GetIncome(playerID)
    return CDOTA_PlayerResource.PlayerData[playerID].income or 0 -- return income if set or default value (0)
end

-- PLAYER DATA: Óñòàíîâèòü òåêóùåå êîëè÷åñòâî äîõîäà èãðîêà
function CDOTA_PlayerResource:SetIncome(playerID, val)
	CDOTA_PlayerResource.PlayerData[playerID].income = val
    return CDOTA_PlayerResource.PlayerData[playerID].income
end

function CDOTA_PlayerResource:SetCreepDirectionBasic(playerID, val)
	CDOTA_PlayerResource.PlayerData[playerID].direction = val
    return CDOTA_PlayerResource.PlayerData[playerID].direction
end

function CDOTA_PlayerResource:GetCreepDirectionBasic(playerID)
	print(CDOTA_PlayerResource.PlayerData[playerID].direction .. " TEST")
    return CDOTA_PlayerResource.PlayerData[playerID].direction
end

-- PLAYER DATA: Óñòàíîâèòü òåêóùåå êîëè÷åñòâî åäû èãðîêà
function CDOTA_PlayerResource:SetFood(playerID, val)
	CDOTA_PlayerResource.PlayerData[playerID].food = val
    return CDOTA_PlayerResource.PlayerData[playerID].food
end

-- PLAYER DATA: Ïîëó÷èòü òåêóùåå êîëè÷åñòâî åäû èãðîêà
function CDOTA_PlayerResource:GetFood(playerID)
    return CDOTA_PlayerResource.PlayerData[playerID].food or 0
end

-- PLAYER DATA: Óñòàíîâèòü ìàêñèìàëüíîå êîëè÷åñòâî åäû èãðîêà
function CDOTA_PlayerResource:SetMaxFood(playerID, val)
	CDOTA_PlayerResource.PlayerData[playerID].maxfood = val
    return CDOTA_PlayerResource.PlayerData[playerID].maxfood
end

-- PLAYER DATA: Ïîëó÷èòü ìàêñèìàëüíîå êîëè÷åñòâî åäû èãðîêà
function CDOTA_PlayerResource:GetMaxFood(playerID)
    return CDOTA_PlayerResource.PlayerData[playerID].maxfood or 0
end

-- PLAYER DATA: Ïîëó÷èòü ïàðàìåòðû þíèòîâ èãðîêà (êîëè÷åñòâî è ò.ï.)
function CDOTA_PlayerResource:GetUnitlist(playerID)
	--DeepPrintTable(PlayerData[playerID].unitlist)
    return CDOTA_PlayerResource.PlayerData[playerID].unitlist or 0
end

-- PLAYER DATA: Óñòàíîâèòü ïàðàêåòðû þíèîâ èãðîêà (êîëè÷åñòâî è ò.ï.)
function CDOTA_PlayerResource:SetUnitlist(playerID, curlist)
	CDOTA_PlayerResource.PlayerData[playerID].unitlist = deepcopy(curlist)
    return CDOTA_PlayerResource.PlayerData[playerID].unitlist
end

-- PLAYER DATA: Ïîëó÷èòü ïàìåòðû óëó÷øåíèé èãðîêà (óðîâåíü, ñòîèìîñòü è ò.ï.)
function CDOTA_PlayerResource:GetUpgradelist(playerID)
	--DeepPrintTable(PlayerData[playerID].unitlist)
    return CDOTA_PlayerResource.PlayerData[playerID].upgradelist or 0
end

-- PLAYER DATA: Óñòàíîâèòü ïàðàìåòðû óëó÷øåíèé èãðîêà (óðîâåíü, ñòîèìîñòü è ò.ï.)
function CDOTA_PlayerResource:SetUpgradelist(playerID, curlist)
	CDOTA_PlayerResource.PlayerData[playerID].upgradelist = deepcopy(curlist)
    return CDOTA_PlayerResource.PlayerData[playerID].upgradelist
end

-- PLAYER DATA: Óñòàíîâèòü êîëè÷åñòâî þíèòîâ èãðîêà
function CDOTA_PlayerResource:SetUnitCount(playerID, name, count)
	for _,unit in pairs(CDOTA_PlayerResource.PlayerData[playerID].unitlist) do
		if unit.name == name then
			unit.count = unit.count + count
			break
		end
	end
end

-- PLAYER DATA: Ïîëó÷èòü êîëè÷åñòâî þíèòîâ èãðîêà
function CDOTA_PlayerResource:GetUnitCount(playerID, name)
	for _,unit in pairs(CDOTA_PlayerResource.PlayerData[playerID].unitlist) do
		if unit.name == name then
			return unit.count
		end
	end
end

-- Çàñïàâíèòü êðèïîâ â óêàçàííîé òî÷êå
-- * unit - èìÿ þíèòà
-- * count - êîëè÷åñòâî þíèòîâ
-- * start_point - êîîðäèíàòû òî÷êè ïîÿâëåíèÿ
-- * target_point - òî÷êà, ê êîòîðîé þíèò áóäåò îòïðàâëåí ïîñëå ïîÿâëåíèÿ
-- * team - êîìàíäà þíèòà
-- * hero - âëàäåëåö þíèòà (ãåðîé)
function GameMode:spawnCreep(unit, count, start_point, target_point, team, hero)				
	local upgradelist = CDOTA_PlayerResource:GetUpgradelist(hero:GetPlayerOwnerID())
		


	--Timers:CreateTimer(0.1, function()
		local r_unit = CreateUnitByName( unit, start_point + RandomVector( RandomFloat( 0, 200 ) ), true, hero, hero, team )
		r_unit:SetInitialGoalEntity( target_point )
		if CREEP_ARENA_BUFF == true then
			local ability = r_unit:AddAbility("ve_paladins_arena_unit_buff")
			ability:SetLevel(1)
		end
		r_unit:SetMinimumGoldBounty(r_unit:GetMinimumGoldBounty()*CREEP_GOLD_REWARD_CONST)
		r_unit:SetMaximumGoldBounty(r_unit:GetMaximumGoldBounty()*CREEP_GOLD_REWARD_CONST)
		--r_unit:SetOwner(hero)
		--r_unit:SetControllableByPlayer(hero:GetPlayerOwnerID(), false)	
		ParticleManager:CreateParticle("particles/ui/ui_game_start_hero_spawn_streaks.vpcf", PATTACH_ABSORIGIN_FOLLOW, r_unit)
		EmitSoundOn('Hero_Leshrac.Attack', r_unit)
		local unitname = r_unit:GetUnitName()
		if GameRules.unitdata[unitname].AItype == "healer" then 
			r_unit.ThinkerType = "healer"
			r_unit.CastAbilityIndex = r_unit:GetAbilityByIndex(0):entindex()
			r_unit.NextOrderTime = GameRules:GetGameTime() + 1
			table.insert(GameMode.UnitThinkerList, r_unit)
		elseif GameRules.unitdata[unitname].AItype == "target_caster" then 
			r_unit.ThinkerType = "target_caster"
			r_unit.CastAbilityIndex = r_unit:GetAbilityByIndex(0):entindex()
			r_unit.NextOrderTime = GameRules:GetGameTime() + 1
			table.insert(GameMode.UnitThinkerList, r_unit)
		elseif GameRules.unitdata[unitname].AItype == "target_point" then 
			r_unit.ThinkerType = "target_point"
			r_unit.CastAbilityIndex = r_unit:GetAbilityByIndex(0):entindex()
			r_unit.NextOrderTime = GameRules:GetGameTime() + 1
			table.insert(GameMode.UnitThinkerList, r_unit)
		elseif GameRules.unitdata[unitname].AItype == "point_target_caster" then 
			r_unit.ThinkerType = "point_target_caster"
			r_unit.CastAbilityIndex = r_unit:GetAbilityByIndex(0):entindex()
			r_unit.NextOrderTime = GameRules:GetGameTime() + 1
			table.insert(GameMode.UnitThinkerList, r_unit)
		end
					
		if GameRules.unitdata[unitname].UnitType == "melee" then
			r_unit:SetBaseDamageMin(r_unit:GetBaseDamageMin() + upgradelist["melee_damage"].level*10)
			r_unit:SetBaseDamageMax(r_unit:GetBaseDamageMax() + upgradelist["melee_damage"].level*10)				
			r_unit:SetPhysicalArmorBaseValue(r_unit:GetPhysicalArmorBaseValue() + upgradelist["melee_armor"].level*1)
			r_unit:SetBaseMaxHealth(r_unit:GetBaseMaxHealth() + upgradelist["melee_body"].level*50)
		elseif GameRules.unitdata[unitname].UnitType == "range" then
			r_unit:SetBaseDamageMin(r_unit:GetBaseDamageMin() + upgradelist["range_damage"].level*10)
			r_unit:SetBaseDamageMax(r_unit:GetBaseDamageMax() + upgradelist["range_damage"].level*10)				
			r_unit:SetPhysicalArmorBaseValue(r_unit:GetPhysicalArmorBaseValue() + upgradelist["range_armor"].level*1)
			r_unit:SetBaseMaxHealth(r_unit:GetBaseMaxHealth() + upgradelist["range_body"].level*50)			
		elseif GameRules.unitdata[unitname].UnitType == "healer" then			
			r_unit:SetPhysicalArmorBaseValue(r_unit:GetPhysicalArmorBaseValue() + upgradelist["healer_armor"].level*1)
			r_unit:SetBaseMaxHealth(r_unit:GetBaseMaxHealth() + upgradelist["healer_body"].level*50)				
		elseif GameRules.unitdata[unitname].UnitType == "special" then
			r_unit:SetPhysicalArmorBaseValue(r_unit:GetPhysicalArmorBaseValue() + upgradelist["special_armor"].level*1)
			r_unit:SetBaseMaxHealth(r_unit:GetBaseMaxHealth() + upgradelist["special_body"].level*50)			
			--r_unit:SetMana(r_unit:GetMana() + upgradelist["special_mana"].level*50)			
		end
		return r_unit
	--end)


	--for i=1, count do
	--end
end

function deepcopy(object)
	local lookup_table = {}
	local function _copy(object)	
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		
		local new_table = {}	
		lookup_table[object] = new_table
		
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		
		return setmetatable(new_table, _copy(getmetatable(object)))
	end
	return _copy(object)
end