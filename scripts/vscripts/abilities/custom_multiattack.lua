LinkLuaModifier("modifier_custom_multiattack", "abilities/custom_multiattack.lua", LUA_MODIFIER_MOTION_NONE)

custom_multiattack = class({})

function custom_multiattack:GetIntrinsicModifierName()
    return "modifier_custom_multiattack"
end




modifier_custom_multiattack = class({})

function modifier_custom_multiattack:IsHidden() return true end
function modifier_custom_multiattack:IsPurgable() return false end
function modifier_custom_multiattack:RemoveOnDeath() return false end

function modifier_custom_multiattack:OnCreated()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    self.in_bonus_attack = false
    self.last_proc_time = -9999

    if not self.ability then return end
    self:OnRefresh()
end

function modifier_custom_multiattack:OnRefresh()
    if not self.ability then return end
    self.extra_attacks   = self.ability:GetSpecialValueFor("extra_attacks") or 0
    self.search_radius   = self.ability:GetSpecialValueFor("search_radius") or 600
    self.damage_pct      = self.ability:GetSpecialValueFor("damage_pct") or 60
    self.icd             = self.ability:GetSpecialValueFor("internal_cooldown") or 0.0
end

function modifier_custom_multiattack:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK,                             -- to spawn extra attacks
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,          -- to scale bonus-attack damage
    }
end

-- Apply damage scaling ONLY during our scripted extra attacks
function modifier_custom_multiattack:GetModifierDamageOutgoing_Percentage(params)
    if self.in_bonus_attack then
        -- e.g., damage_pct = 60 -> return -40 (% change relative to 100)
        return self.damage_pct - 100
    end
    return 0
end

function modifier_custom_multiattack:OnAttack(keys)
    if not IsServer() then return end
    if keys.attacker ~= self.parent then return end
    if not self.ability or self.ability:IsNull() then return end
    if self.parent:IsIllusion() then return end
    if self.parent:IsSilenced() then return end
    if self.parent:PassivesDisabled() then return end

    -- prevent recursion: ignore attacks we ourselves created
    if self.in_bonus_attack then return end

    -- internal cooldown (optional)
    local time_now = GameRules:GetGameTime()
    if time_now - (self.last_proc_time or -9999) < (self.icd or 0) then
        return
    end

    local original_target = keys.target
    if not original_target or original_target:IsNull() or not original_target:IsAlive() then return end

    -- Collect nearby enemy units (heroes + basic)
    local team = self.parent:GetTeamNumber()
    local enemies = FindUnitsInRadius(
        team,
        original_target:GetAbsOrigin(),
        nil,
        self.search_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
        FIND_CLOSEST,
        false
    )

    -- Filter out the original target, pick up to extra_attacks
    local to_attack = {}
    for _,unit in ipairs(enemies) do
        if unit ~= original_target and unit:IsAlive() then
            table.insert(to_attack, unit)
            if #to_attack >= self.extra_attacks then break end
        end
    end

    if #to_attack == 0 then return end

    -- Fire the extra attacks. We disable procs/orbs and don't count these as attack records for lifesteal/etc.
    -- PerformAttack flags meaning (in order):
    -- target,
    -- bUseCastAttackOrb, bProcessProcs, bSkipCooldown, bIgnoreInvis,
    -- bUseProjectile, bFakeAttack, bNeverMiss, bIsAttack
    self.in_bonus_attack = true
    for _,t in ipairs(to_attack) do
        if t and not t:IsNull() and t:IsAlive() then
            self.parent:PerformAttack(
                t,
                false,       -- no orbs
                false,       -- no procs
                true,        -- skip attack cooldown
                true,        -- ignore invis if revealed
                true,        -- use projectile if ranged
                false,       -- not fake
                false        -- can miss as normal
            )
        end
    end
    self.in_bonus_attack = false

    self.last_proc_time = time_now
end
