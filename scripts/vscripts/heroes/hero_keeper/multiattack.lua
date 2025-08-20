function MultiAttack(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local target = keys.target
	local ability = keys.ability
	local max_targets = ability:GetSpecialValueFor('targets')
	local radius = ability:GetSpecialValueFor('radius')
	if attacker == caster and ability:IsCooldownReady() and not ability.IsAttacking then
		local all_targets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		ability.IsAttacking = true
		for _,unit in pairs(all_targets) do
			if unit ~= target then
				caster:PerformAttack(unit, false, true, true, false, true, false, false)
				max_targets = max_targets - 1
				EmitSoundOn(keys.SoundName, unit)
				--ParticleManager:CreateParticle(keys.EffectName, PATTACH_POINT, unit)
			end
			if max_targets == 0 then break end
		end
		ability.IsAttacking = false
	end
end