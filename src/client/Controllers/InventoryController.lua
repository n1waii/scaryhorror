local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local Soundly = require(ReplicatedStorage.Soundly)
local SoundProperties = require(ReplicatedStorage.SoundProperties)
local ItemData = require(ReplicatedStorage.DataModules.Items)

local InventoryController = Knit.CreateController {
    Name = "InventoryController"
}

function InventoryController:SetEquippedItem(itemName)
    print(itemName)
    Knit.Controllers.StateController.Store:dispatch({
        type = "EquipInventoryItem",
        ItemName = itemName
    })
end

function InventoryController:SetItems(items)
    Knit.Controllers.StateController.Store:dispatch({
        type = "SetInventoryItems",
        Items = items
    })
end

function InventoryController:OpenInventory()
    Knit.Controllers.StateController.Store:dispatch({
        type = "SetInventoryEnabled",
        Enabled = true
    })
end

function InventoryController:CloseInventory()
    Knit.Controllers.StateController.Store:dispatch({
        type = "SetInventoryEnabled",
        Enabled = false
    })
end

function InventoryController:TryEquippingItem(itemName)
    local InventoryService = Knit.GetService("InventoryService")
    InventoryService.EquipItem:Fire(itemName)
end

function InventoryController:TryUnequippingItems()
    local InventoryService = Knit.GetService("InventoryService")
    InventoryService.UnequipItems:Fire()
end

function InventoryController:KnitStart()
    local InventoryService = Knit.GetService("InventoryService")
    local InputController = Knit.Controllers.InputController
    local StateController = Knit.Controllers.StateController

    InputController:WhenKeyDown(Enum.KeyCode.Tab, function()
        local state = StateController.Store:getState()
        if state.Inventory.Enabled == false then
            self:OpenInventory()
        else
            self:CloseInventory()
        end
    end)

    InventoryService.InventoryChanged:Connect(function(items)
        self:SetItems(items)
    end)

    InventoryService.EquippedItemChanged:Connect(function(itemName)
        self:SetEquippedItem(itemName)
    end)
end

return InventoryController