modifier_aether_staff_lua = class ({})
 
function modifier_aether_staff_lua:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_EXTRA_MANA_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS,
    }
 
    return funcs
end

function modifier_aether_staff_lua:GetModifierPreAttack_BonusDamage( params )
    local value = self:GetAbility():GetSpecialValueFor("mdamage")	
    return value
end

function modifier_aether_staff_lua:GetModifierBonusStats_Intellect( params )
    local value = self:GetAbility():GetSpecialValueFor("attribute")	
    return value
end

function modifier_aether_staff_lua:GetModifierPercentageManaRegen( params )
    local value = self:GetAbility():GetSpecialValueFor("manaregen")	
    return value
end

function modifier_aether_staff_lua:GetModifierAttackSpeedBonus_Constant( params )
    local value = self:GetAbility():GetSpecialValueFor("attackspeed")	
    return value
end

function modifier_aether_staff_lua:GetModifierSpellAmplify_Percentage( params )
    local value = self:GetAbility():GetSpecialValueFor("spell_amp")	
    return value
end
 
function modifier_aether_staff_lua:GetModifierCastRangeBonus( params )
    local value = self:GetAbility():GetSpecialValueFor("cast_range_bonus")	
    return value
end
 
function modifier_aether_staff_lua:IsDebuff()
    return false
end