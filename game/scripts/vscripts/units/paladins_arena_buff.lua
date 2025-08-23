
function ReduceDamage( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	if not attacker:IsHero() and not attacker:IsAncient() then
		local reduce_damage_pct = keys.ability:GetSpecialValueFor("damage_reduce") 
		local healthamount = keys.deal_damage * reduce_damage_pct/100
		GameRules:SendCustomMessage("hp: "..caster:GetHealth().." damage: "..keys.deal_damage.." reduced_damage: "..reduce_damage_pct.." health: "..healthamount, 0,0)
		local unithp = caster:GetHealth()+keys.deal_damage
		if keys.deal_damage - healthamoun > 0 
		caster:SetHealth(caster:GetHealth() + healthamount)
	end
end
