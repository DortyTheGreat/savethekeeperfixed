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
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_IGNORING_MOVE_ORDERS] = true,
        -- MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES
        -- MODIFIER_STATE_CAN_USE_BACKPACK_ITEMS ???
    }
    return state
end

