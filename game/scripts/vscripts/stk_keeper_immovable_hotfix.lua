-- god bless ChatGPT, I'm just so laaaazy...
--[[
PROMPT:
make a .lua code for dota2, check for every team whether the keeper is far enough from the spawn location 

(> 100 units away), if it is, move it to spawn

local unit = Entities:FindByName( nil, "player_spawn_" .. trigger.activator:GetTeam())
	local unitpoint = unit:GetAbsOrigin()

if unitname:find("npc_dota_ve_keeper") ~= nil then

		local keeper = Entities:FindByName( nil, "ve_keeper_".. trigger.activator:GetTeam())
		local keeper_pos = keeper:GetAbsOrigin()
		FindClearSpaceForUnit(trigger.activator, unitpoint, true)
]]




if keeper_hotfix == nil then
    keeper_hotfix = class({})
end

-- This function checks all teams and moves keepers too far from spawn
function CheckAndResetKeepers()
    local team = 0
    local max_team = 15  -- Dota supports up to 16 teams (0–15)
    local threshold = 100

    for team = 0, max_team do
        -- Find the spawn entity for this team
        local spawn = Entities:FindByName(nil, "ve_keeper_" .. team)
        if spawn then
            local spawn_pos = spawn:GetAbsOrigin()

            local keeper_s = FindUnitsInRadius(team, spawn_pos ,nil, 20000.0,DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

            for _,keep in pairs(keeper_s) do
                local unitname = keep:GetUnitName()  
                if unitname:find("npc_dota_ve_keeper") ~= nil then
                    
                    keep:SetAbsOrigin(spawn_pos)

                    break
                end
            end


        end
    end
end


-- Register to listen to NPC spawn events
function keeper_hotfix:Init()
    print('Inited stk_keeper_immovable_hotfix')
    Timers:CreateTimer(30, -- Start this timer 30 game-time seconds later
    function()
      --Msg("This function is called 30 seconds after the game begins, and every 30 seconds thereafter")
      
      CheckAndResetKeepers()
      return 10.0 -- Rerun this timer every 30 game-time seconds 
    end)
end

-- Initialize once when the script loads
if not keeper_hotfixINIT then
    keeper_hotfixINIT = true
    keeper_hotfix:Init()
end
