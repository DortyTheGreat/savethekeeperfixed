isTouched = false

function OnStartTouch(trigger)

	local unitTeam = GameMode.currentTowerDominationTeam
	print(unitTeam)
	local activatorTeam = trigger.activator:GetTeam()	
	if unitTeam ~= DOTA_TEAM_NEUTRALS and activatorTeam ~= DOTA_TEAM_NEUTRALS and not trigger.activator:HasAbility("ve_unit_was_spawned") and not trigger.activator:IsSummoned() then
		print("ANCIENT touched")
		local activatorName = trigger.activator:GetUnitName()
		local hero = nil

		for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do		
			if GameMode:game_IsValidPlayer(playerID, false) then
				if unitTeam == PlayerResource:GetTeam(playerID) then
					hero = PlayerResource:GetSelectedHeroEntity(playerID)
					break
				end
			end
		end

		if activatorTeam == unitTeam then
			trigger.activator:ForceKill(false)
			local prevUnit = nil

			while prevUnit ~= nil and prevUnit:GetTeam() == unitTeam do -- цикл от 10 до 1
			   prevUnit = Entities:FindByName( prevUnit, "npc_dota_ve_keeper")
			end

			for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
				if GameMode:game_IsValidPlayer(playerID, false) then
					local playerTeam = PlayerResource:GetTeam(playerID)
					if playerTeam ~= activatorTeam then
						local s_unit = GameMode:spawnCreep(activatorName, 1, Entities:FindByName( nil, "spawn_r_" .. playerTeam):GetAbsOrigin(), Entities:FindByName( nil, "point_r_" .. playerTeam), unitTeam, hero)
						s_unit:AddAbility("ve_unit_was_spawned")
					end
				end
			end
		end
	end
end

function Dominate(keys)
	if keys.caster:GetHealth() < 1 then
		keys.caster:SetHealth(keys.caster:GetMaxHealth())
		keys.caster:SetTeam(keys.attacker:GetTeam())
		local ownerId = keys.attacker:GetPlayerOwnerID()
		keys.caster:SetOwner(PlayerResource:GetSelectedHeroEntity(ownerId))
		keys.caster:SetControllableByPlayer(ownerId, true)	
		GameMode.currentTowerDominationTeam = keys.attacker:GetTeam()

		local hero = PlayerResource:GetSelectedHeroEntity(ownerId)

		local tarunits = FindUnitsInRadius(keys.attacker:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.caster:GetAcquisitionRange(), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for kev, funit in pairs(tarunits) do
			local unitname = funit:GetUnitName()  
			if funit:IsAlive() and not funit:IsHero() and unitname:find("npc_dota_tower_domination") == nil then

				--if hero:GetTeam() == funit:GetTeam() and not funit:HasAbility("ve_unit_was_spawned") and not funit:IsSummoned() then
				--	local unitName = funit:GetUnitName()
				--	funit:ForceKill(false)
				--	for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
				--		if GameMode:game_IsValidPlayer(playerID, false) then
				--			local playerTeam = PlayerResource:GetTeam(playerID)
				--			local s_unit = GameMode:spawnCreep(unitName, 1, Entities:FindByName( nil, "spawn_r_" .. playerTeam):GetAbsOrigin(), Entities:FindByName( nil, "point_r_" .. playerTeam), hero:GetTeam(), hero)
				--			s_unit:AddAbility("ve_unit_was_spawned")
				--		end
				--	end
				--end
				ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_kill_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, funit)
				funit:ForceKill(false)
			end
		end
		ParticleManager:CreateParticle("particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_reincarn_bone_explosion_style2.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	end
end
