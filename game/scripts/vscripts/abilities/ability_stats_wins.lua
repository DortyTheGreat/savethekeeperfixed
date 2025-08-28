
LinkLuaModifier("modifier_stats_wins", "abilities/ability_stats_wins.lua", LUA_MODIFIER_MOTION_NONE)

ability_stats_wins = class({})

function ability_stats_wins:GetIntrinsicModifierName()
    return "modifier_stats_wins"
end


modifier_stats_wins = class({})

function modifier_stats_wins:IsHidden() return false end
function modifier_stats_wins:IsPurgable() return false end

function modifier_stats_wins:GetTexture()
    return "wins_counter" -- имя png файла иконки без расширения
end