--[[
For some reasons MODIFIER_STATE_IGNORING_MOVE_ORDERS(.lua) overrides DOTA_UNIT_CAP_MOVE_NONE(.kv)
that means that I have no idea how to make a unit unmovable & have no collision.
It might be possible that keeper should be a building, but even this mostl hotfixes ever issue (apart from earthshaker I guess).

Later on I might add some for loop that checks whether the position of keeper is unchanged, but this hotfix should work for now
]]
LinkLuaModifier("modifier_rooted_unmovable", "abilities/ability_unmovable.lua", LUA_MODIFIER_MOTION_NONE)

ability_unmovable = class({})

function ability_unmovable:GetIntrinsicModifierName()
    return "modifier_rooted_unmovable"
end

modifier_rooted_unmovable = class({})

function modifier_rooted_unmovable:IsHidden() return true end
function modifier_rooted_unmovable:IsPurgable() return false end

function modifier_rooted_unmovable:CheckState()
    local state = {
        --[MODIFIER_STATE_ROOTED] = true, -- сам ходить не может
        --[MODIFIER_STATE_NO_UNIT_COLLISION] = true,  -- коллизия включена
        [MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true, -- нельзя сдвинуть
        --[MODIFIER_STATE_FLYING	] = true,
        --[MODIFIER_STATE_IGNORING_MOVE_ORDERS] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true, -- нельзя сдвинуть
        -- 
        -- MODIFIER_STATE_CAN_USE_BACKPACK_ITEMS ???
    }
    return state
end
