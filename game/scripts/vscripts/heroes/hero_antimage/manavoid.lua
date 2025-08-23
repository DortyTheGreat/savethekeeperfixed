function ManaVoid( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() -1
	
	-- Parameters
	local damage_per_mana = ability:GetLevelSpecialValueFor('mana_void_damage_per_mana', ability_level)
	local radius = ability:GetLevelSpecialValueFor('mana_void_aoe_radius', ability_level)
	local mana_burn_pct = ability:GetLevelSpecialValueFor('mana_void_mana_burn_pct', ability_level)
	local damage = 0

	
	-- Burn main target's mana
	local target_mana_burn = caster:GetMaxMana() * mana_burn_pct / 100
	caster:ReduceMana(target_mana_burn)
	local this_enemy_damage = (caster:GetMaxMana() - caster:GetMana()) * damage_per_mana
	-- Find all enemies in the area of effect
	local nearby_enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,enemy in pairs(nearby_enemies) do
		ApplyDamage({attacker = caster, victim = enemy, ability = ability, damage = this_enemy_damage, damage_type = DAMAGE_TYPE_PURE})
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, enemy, damage, nil)
	end

	-- Shake screen due to excessive PURITY OF WILL
	ScreenShake(caster:GetOrigin(), 10, 0.1, 1, 500, 0, true)
end