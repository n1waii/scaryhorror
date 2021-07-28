local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local ItemPickupController = Knit.CreateController {
    Name = "ItemPickupController"
}

function ItemPickupController:PromptCallback(proximityPart)
    local ItemPickupService = Knit.GetService("ItemPickupService")
    ItemPickupService.PromptTriggered:Fire(proximityPart)
end

return ItemPickupController