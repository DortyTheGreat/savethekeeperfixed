function UpgradeKeeper(keys)
	local caster = keys.caster
	local team = caster:GetTeam()
	local keeper_s = FindUnitsInRadius(team, caster:GetAbsOrigin() ,nil, 20000.0,DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	for _,keep in pairs(keeper_s) do
		local unitname = keep:GetUnitName()  
		if unitname:find("npc_dota_ve_keeper") ~= nil then
			--keep:SetHasInventory(true)
			ParticleManager:CreateParticle("particles/econ/items/skywrath_mage/manticore/wings_of_the_manticore_ambientfx.vpcf", PATTACH_ABSORIGIN_FOLLOW, keep)
			ParticleManager:CreateParticle("particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_ti6_immortal.vpcf", PATTACH_ABSORIGIN_FOLLOW, keep)
			keep:SetMaxHealth(16000)
			keep:SetHealth(16000)
			keep:SetBaseDamageMin(220)
			keep:SetBaseDamageMax(229)	
			keep:SetHasInventory(true)

			local ability = keep:AddAbility("ve_keeper_unit_buff")
			ability:SetLevel(1)
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(caster:GetPlayerID()), "reverse_available", {})
			break
		end
	end

end

