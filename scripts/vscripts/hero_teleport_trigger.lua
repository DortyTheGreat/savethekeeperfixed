--[[

Teleporting requires some changes. Not exactly sure what will fix it. Here is a bit of Reborn code.

FindClearSpaceForUnit(unit, PlayerResource:GetRespawnPosition(unit:GetTeamNumber()), true)
		unit:InterruptMotionControllers(true)
		


function IsLegalPosition(unit)
	return not unit:IsOnNotOwnBase()
end

function OnStartTouch(event)
	local unit = event.activator
	local trigger = event.caller
	if unit.bFirstSpawn == nil or (not unit:IsHero() and not unit:IsConsideredHero() and not unit:IsTechiesMine()) or unit:IsKeeper() or unit:IsPortal() or unit:HasModifier("modifier_spectre_haunt") then return end
	if not IsLegalPosition(unit) then
		FindClearSpaceForUnit(unit, PlayerResource:GetRespawnPosition(unit:GetTeamNumber()), true)
		unit:InterruptMotionControllers(true)
	end
	Timers:CreateTimer({endTime=1, callback=function()
		if not IsValidEntity(unit) then return end
		if not IsLegalPosition(unit) then
			FindClearSpaceForUnit(unit, PlayerResource:GetRespawnPosition(unit:GetTeamNumber()), true)
			unit:InterruptMotionControllers(true)
		end
	end}, nil, self)
end

function OnEndTouch(event)
end


function CDOTA_BaseNPC:IsOnNotOwnBase()
	for _, team in pairs(TEAMS) do
		if team ~= self:GetTeamNumber() then
			local base = Entities:FindByName(nil, tostring("trigger_base_"..team))
			if base ~= nil and base:IsTouching(self) then
				return true
			end
		end
	end
	return false
end
]]

isTouched = false

function OnEndTouch(trigger)
	
	--DeepPrintTable(trigger)
	
	
	local unit = Entities:FindByName( nil, "player_spawn_" .. trigger.activator:GetTeam())
	local unitpoint = unit:GetAbsOrigin()
	
	local unitname = trigger.activator:GetUnitName()  

	if unitname:find("npc_dota_ve_keeper") ~= nil then

		local keeper = Entities:FindByName( nil, "ve_keeper_".. trigger.activator:GetTeam())
		local keeper_pos = keeper:GetAbsOrigin()

		Timers:CreateTimer(0.001, function()
			if isTouched == false then
				trigger.activator:SetAbsOrigin(keeper_pos)
				--FindClearSpaceForUnit(trigger.activator, PlayerResource:GetRespawnPosition(trigger.activator:GetTeamNumber()), true)
				--trigger.activator:InterruptMotionControllers(true)
				print("Teleport Debug has called!")
			end
			return nil
		end)
	elseif trigger.activator:IsHero() and trigger.activator:IsRealHero() and not trigger.activator:IsAncient() then
		Timers:CreateTimer(0.001, function()
			if isTouched == false then
				--trigger.activator:SetAbsOrigin(unitpoint)
				FindClearSpaceForUnit(trigger.activator, unitpoint, true)
				trigger.activator:InterruptMotionControllers(true)
				print("Teleport Debug has called!")
			end
			return nil
		end)
	end
	isTouched = false;
end

function OnStart(trigger)
	isTouched = true
end