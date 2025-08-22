--[[

Fot whatever the reason I can't send message to a specific player.
I decided to leave my attempts at making a private message so you could laugh at my skill issue
Changing the idea to: change item from item_wisdom_scroll_1_1 -> item_wisdom_scroll_1_2 -> item_wisdom_scroll_1_3 -> ...
each item has new localization

if item_wisdom_scroll_1 == nil then
    item_wisdom_scroll_1 = class({})
end

-- On spell start (when item is used)
function item_wisdom_scroll_1:OnSpellStart()
    if not IsServer() then return end
	
	local caster = self:GetCaster()
	
    --SendOverheadEventMessage
	--SendCustomMessageToTeam
	--Say(caster, "Hello, this is a private message!", false)
	
	local playerID = 2
	GameRules:SendCustomMessage("Custom message just for you!", 123, 1)
	GameRules:SendCustomMessageToTeam("This goes to Radiant only!", 1, 1, 1)
	GameRules:SendCustomMessageToTeam("Dire, get ready to fight!2", 2, 2, 2)
	GameRules:SendCustomMessageToTeam("Dire, get ready to fight!3", 3, 3, 3)
	GameRules:SendCustomMessageToTeam("Dire, get ready to fight!0", 0, 0, 0)
	--print("caster: " .. caster)
	CustomGameEventManager:Send_ServerToPlayer(
		caster, -- weird, but ok...
		"custom_private_message",
		{ text = "Only you can see this!" }
	)
	
	CustomGameEventManager:Send_ServerToPlayer(
		PlayerResource:GetPlayer(caster:GetPlayerOwnerID()), -- target player
		"custom_message_event",              -- event name (you define this)
		{ msg = "Hello, this is for you only!" } -- data table
	)
	UTIL_MessageText_WithContext( caster:GetPlayerOwnerID(), "ScoreboardRow", 255, 255, 255, 255, { team_name = "Team", value = 50 } )
	UTIL_MessageText( 1, "ScoreboardRow", 123, 123, 123, 123)
	UTIL_MessageText( 0, "ScoreboardRow", 123, 123, 123, 123)
	UTIL_MessageText( 2, "ScoreboardRow", 123, 123, 123, 123)
	UTIL_MessageText( 3, "ScoreboardRow", 123, 123, 123, 123)
	UTIL_MessageText( 4, "ScoreboardRow", 123, 123, 123, 123)
	UTIL_MessageText( 5, "ScoreboardRow", 123, 123, 123, 123)
    self:SpendCharge(1)
	--local new_charges = self:GetCurrentCharges()
	--if new_charges <= 0 then
	--	self.caster:RemoveItem(self)
	--end
end

]]

scroll_amount = 4

-- despite the fact that this definision chain looks dumb I don't think that there is a workaround
item_wisdom_scroll_1 = class({})
item_wisdom_scroll_2 = class({})
item_wisdom_scroll_3 = class({})
item_wisdom_scroll_4 = class({})

local wisdom_scrolls = {
    item_wisdom_scroll_1,
    item_wisdom_scroll_2,
    item_wisdom_scroll_3,
    item_wisdom_scroll_4
}

for i, scroll in ipairs(wisdom_scrolls) do
    print("Processing scroll #" .. i)
    -- On spell start (when item is used)
	function scroll:OnSpellStart()
		if not IsServer() then return end
		
		local caster = self:GetCaster()
		local itemSlot = self:GetItemSlot() -- save current slot
		
		local abilityName = self:GetAbilityName()
        local lastChar = string.sub(abilityName, -1)
        local number = tonumber(lastChar) + 1

        -- Loop back to 1 if over scroll_amount
        if number > scroll_amount then
            number = 1
        end
		
		-- remove current item
		caster:RemoveItem(self)

		-- add new item
		local newItem = caster:AddItemByName("item_wisdom_scroll_" .. number)

		-- force it into the same slot
		if newItem then
			caster:SwapItems(newItem:GetItemSlot(), itemSlot)
		end
	end
end



