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
				print("Teleport Debug has called!")
			end
			return nil
		end)
	elseif trigger.activator:IsHero() and trigger.activator:IsRealHero() and not trigger.activator:IsAncient() then
		Timers:CreateTimer(0.001, function()
			if isTouched == false then
				trigger.activator:SetAbsOrigin(unitpoint)
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