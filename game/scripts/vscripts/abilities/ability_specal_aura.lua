LinkLuaModifier("modifier_special_aura", "abilities/ability_specal_aura.lua", LUA_MODIFIER_MOTION_NONE)

ability_specal_aura = class({})

function ability_specal_aura:GetIntrinsicModifierName()
    return "modifier_special_aura"
end

modifier_special_aura = class({})

function modifier_special_aura:IsHidden() return false end
function modifier_special_aura:IsPurgable() return false end

function modifier_special_aura:OnCreated(kv)
    if not IsServer() then return end

    -- проверка, что владелец - герой
    if self:GetParent() and self:GetParent():IsHero() then
        -- создаём партикл
        local particle = "particles/omniknight_repel_buff_ti8_glyph_custom.vpcf"--"particles/econ/items/warlock/warlock_hellsworn_construct/golem_hellsworn_ambient.vpcf"
        self.effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        
        -- уменьшаем размер ауры
        ParticleManager:SetParticleControl(self.effect, 1, Vector(100,100,100)) -- размер 50 вместо дефолтного
        self:AddParticle(self.effect, false, false, -1, false, false)
    end
end

--function modifier_special_aura:GetEffectName()
    --return "particles/econ/events/ti9/hero_levelup_effect.vpcf"
        --return "particles/frostivus_gameplay/frostivus_throne_wraith_king_ambient.vpcf"
    --return "particles/units/heroes/hero_invoker/invoker_ambient_light.vpcf"
--end

function modifier_special_aura:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end