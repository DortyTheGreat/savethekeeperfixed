-- make a script so that whenever arc's ult clone spawns it apperars at specific locaion instead

-- file: arc_custom.lua
-- This script listens for the Tempest Double spawn and moves it

if ArcCustom == nil then
    ArcCustom = class({})
end

-- Register to listen to NPC spawn events
function ArcCustom:Init()
    ListenToGameEvent("npc_spawned", Dynamic_Wrap(ArcCustom, "OnNPCSpawned"), self)
end

function ArcCustom:OnNPCSpawned(keys)
    local spawnedUnit = EntIndexToHScript(keys.entindex)

    if spawnedUnit and spawnedUnit:GetUnitName() == "npc_dota_hero_arc_warden" then
        -- Tempest Double clones are controllable illusions with IsTempestDouble true
        if spawnedUnit:IsTempestDouble() then
			
			local unit = Entities:FindByName( nil, "player_spawn_" .. spawnedUnit:GetTeam())
			local unitpoint = unit:GetAbsOrigin()
			print("arc_warden_hotfix")
			
			Timers:CreateTimer(0.1,function()
				FindClearSpaceForUnit(spawnedUnit, unitpoint, true)
				spawnedUnit:InterruptMotionControllers(true)
				spawnedUnit:Stop() -- prevent immediate auto-move
			end)
			
            
        end
    end
end

-- Initialize once when the script loads
if not ArcCustomInit then
    ArcCustomInit = true
    ArcCustom:Init()
end
