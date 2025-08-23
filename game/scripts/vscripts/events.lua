-- This file contains all barebones-registered events and has already set up the passed-in parameters for your use.

-- Cleanup a player when they leave
function GameMode:OnDisconnect(keys)
  DebugPrint('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
  DebugPrintTable(keys)

  local name = keys.name
  local networkid = keys.networkid
  local reason = keys.reason
  local userID = keys.userid
  local playerID = keys.PlayerID
  --local unit = PlayerResource:GetSelectedHeroEntity(playerID)
  --local team = unit:GetTeam()
--  local keeper_s = FindUnitsInRadius(team, unit:GetAbsOrigin() ,nil, 1200.0,DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

 -- for _,keep in pairs(keeper_s) do
 --   local unitname = keep:GetUnitName()  
 --   if unitname:find("npc_dota_ve_keeper") ~= nil then
  --      keep:AddNewModifier(keep, nil, 'modifier_smoke_of_deceit', nil)
  --    break
--    end
--  end
--  unit:AddNewModifier(unit, nil, 'modifier_smoke_of_deceit', nil)
  
--  keys.state = PlayerResource:GetConnectionState(playerID)
 -- DeepPrintTable(keys)
end
-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
  DebugPrint("[BAREBONES] GameRules State Changed")
  DebugPrintTable(keys)

  local newState = GameRules:State_Get()
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:OnNPCSpawned(keys)
  DebugPrint("[BAREBONES] NPC Spawned")
  DebugPrintTable(keys)

  local npc = EntIndexToHScript(keys.entindex)
  if npc:HasAbility("ve_courier_invulnerable") then npc:FindAbilityByName("ve_courier_invulnerable"):SetLevel(1) end
end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function GameMode:OnEntityHurt(keys)
  --DebugPrint("[BAREBONES] Entity Hurt")
  --DebugPrintTable(keys)

  local damagebits = keys.damagebits -- This might always be 0 and therefore useless
  if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil then
    local entCause = EntIndexToHScript(keys.entindex_attacker)
    local entVictim = EntIndexToHScript(keys.entindex_killed)

    -- The ability/item used to damage, or nil if not damaged by an item/ability
    local damagingAbility = nil

    if keys.entindex_inflictor ~= nil then
      damagingAbility = EntIndexToHScript( keys.entindex_inflictor )
    end
	
	if entVictim:IsAlive()then
		if entVictim:HasInventory() then
			for i = 0, 5, 1 do
				local current_item = entVictim:GetItemInSlot(i)
				if current_item ~= nil then
					if current_item:GetName() == "item_heart" then 
						current_item:StartCooldown(current_item:GetCooldown(1))
					end
				end
			end
		end
	end
	
  end
end

-- An item was picked up off the ground
function GameMode:OnItemPickedUp(keys)
  DebugPrint( '[BAREBONES] OnItemPickedUp' )
  DebugPrintTable(keys)

  local unitEntity = nil
  if keys.UnitEntitIndex then
    unitEntity = EntIndexToHScript(keys.UnitEntitIndex)
  elseif keys.HeroEntityIndex then
    unitEntity = EntIndexToHScript(keys.HeroEntityIndex)
  end

  local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local itemname = keys.itemname
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function GameMode:OnPlayerReconnect(keys)
  DebugPrint( '[BAREBONES] OnPlayerReconnect' )
  DeepPrintTable(keys)
	local newState = GameRules:State_Get()
	if newState >= DOTA_GAMERULES_STATE_STRATEGY_TIME then  
		--print(PlayerResource:GetSelectedHeroID(keys.PlayerID))
		if PlayerResource:GetSelectedHeroID(keys.PlayerID) == -1 then
			PlayerResource:GetPlayer(keys.PlayerID):MakeRandomHeroSelection()
		end
	end
end

   
-- An item was purchased by a player
function GameMode:OnItemPurchased( keys )
  DebugPrint( '[BAREBONES] OnItemPurchased' )
  DebugPrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost
  
end

-- An ability was used by a player
function GameMode:OnAbilityUsed(keys)
  DebugPrint('[BAREBONES] AbilityUsed')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityname = keys.abilityname
end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function GameMode:OnNonPlayerUsedAbility(keys)
  DebugPrint('[BAREBONES] OnNonPlayerUsedAbility')
  DebugPrintTable(keys)

  local abilityname=  keys.abilityname
end

-- A player changed their name
function GameMode:OnPlayerChangedName(keys)
  DebugPrint('[BAREBONES] OnPlayerChangedName')
  DebugPrintTable(keys)

  local newName = keys.newname
  local oldName = keys.oldName
end

-- A player leveled up an ability
function GameMode:OnPlayerLearnedAbility( keys)
  DebugPrint('[BAREBONES] OnPlayerLearnedAbility')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function GameMode:OnAbilityChannelFinished(keys)
  DebugPrint('[BAREBONES] OnAbilityChannelFinished')
  DebugPrintTable(keys)

  local abilityname = keys.abilityname
  local interrupted = keys.interrupted == 1
end

-- A player leveled up
function GameMode:OnPlayerLevelUp(keys)
  DebugPrint('[BAREBONES] OnPlayerLevelUp')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local level = keys.level
end

-- A player last hit a creep, a tower, or a hero
function GameMode:OnLastHit(keys)
  DebugPrint('[BAREBONES] OnLastHit')
  DebugPrintTable(keys)

  local isFirstBlood = keys.FirstBlood == 1
  local isHeroKill = keys.HeroKill == 1
  local isTowerKill = keys.TowerKill == 1
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local killedEnt = EntIndexToHScript(keys.EntKilled)
end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
  DebugPrint('[BAREBONES] OnTreeCut')
  DebugPrintTable(keys)

  local treeX = keys.tree_x
  local treeY = keys.tree_y
end

-- A rune was activated by a player
function GameMode:OnRuneActivated (keys)
  DebugPrint('[BAREBONES] OnRuneActivated')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local rune = keys.rune

  --[[ Rune Can be one of the following types
  DOTA_RUNE_DOUBLEDAMAGE
  DOTA_RUNE_HASTE
  DOTA_RUNE_HAUNTED
  DOTA_RUNE_ILLUSION
  DOTA_RUNE_INVISIBILITY
  DOTA_RUNE_BOUNTY
  DOTA_RUNE_MYSTERY
  DOTA_RUNE_RAPIER
  DOTA_RUNE_REGENERATION
  DOTA_RUNE_SPOOKY
  DOTA_RUNE_TURBO
  ]]
end

-- A player took damage from a tower
function GameMode:OnPlayerTakeTowerDamage(keys)
  DebugPrint('[BAREBONES] OnPlayerTakeTowerDamage')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local damage = keys.damage
end

-- A player picked a hero
function GameMode:OnPlayerPickHero(keys)
  DebugPrint('[BAREBONES] OnPlayerPickHero')
  DebugPrintTable(keys)

  local heroClass = keys.hero
  local heroEntity = EntIndexToHScript(keys.heroindex)
  local player = EntIndexToHScript(keys.player)
end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)
  DebugPrint('[BAREBONES] OnTeamKillCredit')
  DebugPrintTable(keys)

  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
  local numKills = keys.herokills
  local killerTeamNumber = keys.teamnumber
end

-- An entity died
--[[ function GameMode:OnEntityKilled( keys )
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
		--***
		--работаем с путями на paladins_arena
		--
		if GetMapName() == "paladins_arena" then
			for _, targetunit in pairs(allHeroes) do
				local targetunitlist = Entities:FindByNameNearest("target_point_".. targetunit:GetTeam() .. "center2", killedUnit:GetAbsOrigin(), 600.0)
				if targetunitlist ~= nil then
					local unitteam = string.sub(targetunitlist:GetName(), 14, 14) 
					parseNewPos(killedUnit:GetTeam(), tonumber(unitteam))
				end
			end
		elseif GetMapName() == "4x4_paladins" then 
			if killedUnit:GetTeam() == DOTA_TEAM_GOODGUYS then
				GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
			elseif killedUnit:GetTeam() == DOTA_TEAM_BADGUYS then
				GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)						
			end
			return
		end
		for _,hero in pairs(allHeroes) do
		--***********************
		-- Работаем с убийцей
		--***********************
			if hero:GetTeam() == killerEntity:GetTeam() and not hero:IsIllusion() and PlayerResource:GetConnectionState(killedUnit:GetPlayerOwnerID()) == DOTA_CONNECTION_STATE_CONNECTED  then
				local value = 1000
				SendOverheadEventMessage( hero, OVERHEAD_ALERT_GOLD , hero, value, nil )
				PlayerResource:ModifyGold(hero:GetPlayerOwnerID(), value, false, 1)
				--GameRules:SendCustomMessage("Игрок <font color='#58ACFA'>".. PlayerResource:GetPlayerName(hero:GetPlayerOwnerID()) .."</font> получает <font color='gold'>".. value .."</font> золота за убийство хранителя", 0, 0)
				GameRules:SendCustomMessage("#Game_notification_kill_keeper", hero:GetPlayerOwnerID(), value)

		--***********************
		-- Работаем с жертвой
		--***********************
			elseif hero:GetTeam() == killedUnit:GetTeam() then				
				--GameRules:SendCustomMessage("<font color='#58ACFA'>Паладин игрока " .. GetPlayerName(hero:GetPlayerID()) .. " был убит!</font>", 0, 0)
				hero:SetCanSellItems(false);
				hero:SetGold(0, false);
				hero:SetRespawnsDisabled(true)
				hero:SetUnitCanRespawn(false)
				hero:SetTimeUntilRespawn(-1)
				hero:SetBuyBackDisabledByReapersScythe(true)
				hero:Kill(killerAbility, killerEntity)		
        AddFOWViewer(killedUnit:GetTeam(),crunit:GetAbsOrigin(), 99999999.0, 99999999.0, false)
				local ownerid = hero:GetPlayerOwnerID()
				if ownerid ~= nil and PlayerResource:IsValidPlayerID(ownerid) and PlayerResource:IsValidPlayer(ownerid) and not PlayerResource:IsFakeClient(ownerid)  then
					local curunitlist = CDOTA_PlayerResource:GetUnitlist(ownerid)
					for k in pairs (curunitlist) do
						curunitlist[k] = nil
					end					
					CDOTA_PlayerResource:SetUnitlist(hero:GetPlayerOwnerID(), curunitlist)
				end
				if GetMapName() == "paladins_arena" then
					AddFOWViewer(hero:GetTeam(), Entities:FindByName( nil, "ve_keeper_2"):GetAbsOrigin(), 1300.0, 9999.0, false) 
					AddFOWViewer(hero:GetTeam(), Entities:FindByName( nil, "ve_keeper_3"):GetAbsOrigin(), 1300.0, 9999.0, false) 
					AddFOWViewer(hero:GetTeam(), Entities:FindByName( nil, "ve_keeper_6"):GetAbsOrigin(), 1300.0, 9999.0, false) 
					AddFOWViewer(hero:GetTeam(), Entities:FindByName( nil, "ve_keeper_7"):GetAbsOrigin(), 1300.0, 9999.0, false) 
				end
				
			end	
			if hero:GetRespawnsDisabled() == false and not hero:IsIllusion() then
					canrespawn = canrespawn + 1
			end
		end
		if canrespawn == 1 then
			GameRules:SetGameWinner(killerEntity:GetTeam())
		end
	elseif killedUnit ~= killerEntity and killedUnit:IsHero() and not killedUnit:IsIllusion() and killedUnit:IsReincarnating() == false then
		if PlayerResource:GetConnectionState(killedUnit:GetPlayerOwnerID()) == DOTA_CONNECTION_STATE_CONNECTED then
			if GetMapName() == "4x4_paladins" then
				if PlayerResource:GetConnectionState(killerEntity:GetPlayerOwnerID()) == DOTA_CONNECTION_STATE_CONNECTED then
					local value = 25*killedUnit:GetLevel()
          if not killerEntity:IsIllusion() then
  					SendOverheadEventMessage( killerEntity, OVERHEAD_ALERT_GOLD , killerEntity, value, nil )
  					PlayerResource:ModifyGold(killerEntity:GetPlayerOwnerID(), value, false, 1)
          end
					--GameRules:SendCustomMessage("Игрок <font color='#58ACFA'>".. PlayerResource:GetPlayerName(hero:GetPlayerOwnerID()) .."</font> получает <font color='gold'>".. value .."</font> золота за убийство героя противника", 0, 0)
					GameRules:SendCustomMessage("#Game_notification_kill_hero", killerEntity:GetPlayerOwnerID(), value)					
				end
			elseif GetMapName() ~= "paladins_domination" then
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

	--if unitname:GetTeam() == 
	--	GameRules:SendCustomMessage("<font color='#58ACFA'>Осталось убить" .. CURRENT_UNIT_COUNT .. " крипов!</font>", 0, 0)
	--end
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
end ]]

-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function GameMode:PlayerConnect(keys)
  DebugPrint('[BAREBONES] PlayerConnect')
  DebugPrintTable(keys)
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
  DebugPrint('[BAREBONES] OnConnectFull')
  DebugPrintTable(keys)
  
  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)
  
  -- The Player ID of the joining player
  if ply ~= nil then
    local playerID = ply:GetPlayerID()
  end
end

-- This function is called whenever illusions are created and tells you which was/is the original entity
function GameMode:OnIllusionsCreated(keys)
  DebugPrint('[BAREBONES] OnIllusionsCreated')
  DebugPrintTable(keys)

  local originalEntity = EntIndexToHScript(keys.original_entindex)
end

-- This function is called whenever an item is combined to create a new item
function GameMode:OnItemCombined(keys)
  DebugPrint('[BAREBONES] OnItemCombined')
  DebugPrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end
  local player = PlayerResource:GetPlayer(plyID)

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost
end

-- This function is called whenever an ability begins its PhaseStart phase (but before it is actually cast)
function GameMode:OnAbilityCastBegins(keys)
  DebugPrint('[BAREBONES] OnAbilityCastBegins')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityName = keys.abilityname
end

-- This function is called whenever a tower is killed
function GameMode:OnTowerKill(keys)
  DebugPrint('[BAREBONES] OnTowerKill')
  DebugPrintTable(keys)

  local gold = keys.gold
  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local team = keys.teamnumber
end

-- This function is called whenever a player changes there custom team selection during Game Setup 
function GameMode:OnPlayerSelectedCustomTeam(keys)
  DebugPrint('[BAREBONES] OnPlayerSelectedCustomTeam')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.player_id)
  local success = (keys.success == 1)
  local team = keys.team_id
end

-- This function is called whenever an NPC reaches its goal position/target
function GameMode:OnNPCGoalReached(keys)
  DebugPrint('[BAREBONES] OnNPCGoalReached')
  DebugPrintTable(keys)

  local goalEntity = EntIndexToHScript(keys.goal_entindex)
  local nextGoalEntity = EntIndexToHScript(keys.next_goal_entindex)
  local npc = EntIndexToHScript(keys.npc_entindex)
end

-- This function is called whenever any player sends a chat message to team or All
function GameMode:OnPlayerChat(keys)
  --local teamonly = keys.teamonly
  --local userID = keys.userid
  --local playerID = self.vUserIds[userID]:GetPlayerID()

  --local text = keys.text
end