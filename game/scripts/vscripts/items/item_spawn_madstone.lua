if item_spawn_madstone == nil then
    item_spawn_madstone = class({})
end

-- On spell start (when item is used)
function item_spawn_madstone:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local position = caster:GetAbsOrigin() + RandomVector(100)

    -- Item to create (change to whatever you want)
    local item_name = "item_madstone_bundle"

    local newItem = CreateItem(item_name, nil, nil)
    local drop = CreateItemOnPositionSync(position, newItem)
	
	-- CDOTA_Item:LaunchLoot(bAutoUse, flLaunchHeight, flDuration, vEndPoint, hOwner)
	-- I have no idea about this hOwner. Dota API is hell
    newItem:LaunchLoot(false, 200, 0.5, position, nil)

    self:SpendCharge(1)
	local new_charges = self:GetCurrentCharges()
	if new_charges <= 0 then
		self.caster:RemoveItem(self)
	end
end
