function Commander_Call(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local target = keys.target
	local ability = keys.ability
	local activate_chance = ability:GetSpecialValueFor('activate_chance')
	local chance = math.random(0, 100)
	if ability:IsCooldownReady() and not target:IsAncient() and not target:IsHero() and chance <= activate_chance then
		target:SetOwner(caster)
		target:SetTeam(caster:GetTeam())
		target:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
		ability:StartCooldown(keys.ability:GetCooldown(1))
	end
end