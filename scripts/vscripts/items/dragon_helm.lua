function CheckHP(keys)
	local caster = keys.caster
	if keys.ability:IsCooldownReady() and caster:GetHealth() <= caster:GetMaxHealth() * (keys.ability:GetSpecialValueFor( "buff_min_health")/100) then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "item_dragon_helm_buff", {})
		keys.ability:StartCooldown(keys.ability:GetCooldown(1))
	end
end