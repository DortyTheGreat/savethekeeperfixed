custom_heal_ability = class({})

function custom_heal_ability:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local heal_amount = self:GetSpecialValueFor("heal_amount")

    if target ~= nil and target:IsAlive() then
        -- Heal the target
        target:Heal(heal_amount, caster)

        -- Show overhead heal numbers
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, heal_amount, nil)

        -- Particle + Sound
        local particle = ParticleManager:CreateParticle("particles/items3_fx/warmage_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:ReleaseParticleIndex(particle)

        target:EmitSound("n_creep_ForestTrollHighPriest.Heal")
    end
end
