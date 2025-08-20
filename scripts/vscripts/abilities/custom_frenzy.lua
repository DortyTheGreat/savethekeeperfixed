LinkLuaModifier("modifier_custom_frenzy", "abilities/custom_frenzy.lua", LUA_MODIFIER_MOTION_NONE)

custom_frenzy = class({})

function custom_frenzy:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("AbilityDuration")

    caster:AddNewModifier(caster, self, "modifier_custom_frenzy", {duration = duration})

    caster:EmitSound("Hero_Chen.HandOfGodHealCreep") -- you can replace with any sound
end



modifier_custom_frenzy = class({})

function modifier_custom_frenzy:IsHidden() return false end
function modifier_custom_frenzy:IsDebuff() return false end
function modifier_custom_frenzy:IsPurgable() return true end

function modifier_custom_frenzy:OnCreated(kv)
    self.ability = self:GetAbility()
    if not self.ability then return end

    self.bonus_as = self.ability:GetSpecialValueFor("bonus_attack_speed")
    self.bonus_dmg = self.ability:GetSpecialValueFor("bonus_damage")
end

function modifier_custom_frenzy:OnRefresh(kv)
    self:OnCreated(kv)
end

function modifier_custom_frenzy:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_custom_frenzy:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_as or 0
end

function modifier_custom_frenzy:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg or 0
end

function modifier_custom_frenzy:GetEffectName()
    return "particles/units/heroes/hero_ursa/ursa_overpower_buff.vpcf"
end

function modifier_custom_frenzy:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end