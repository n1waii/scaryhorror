local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataModules = ReplicatedStorage.DataModules
local ItemData = require(DataModules.Items)

local Knit = require(ReplicatedStorage.Knit)
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)

local TableUtil = require(ReplicatedStorage.Util.TableUtil)

local InventoryService = Knit.CreateService {
    Name = "InventoryService",
    Client = {
        InventoryChanged = RemoteSignal.new(),
        EquippedItemChanged = RemoteSignal.new(),
        EquipItem = RemoteSignal.new(),
        UnequipItems = RemoteSignal.new()
    }
}

function InventoryService:EquipItem(player, itemName)
    if not player.Character then return end
    local item = player.Backpack:FindFirstChild(itemName)
    if item then
        item = item:Clone()
        item.Parent = player.Character
        self.Client.EquippedItemChanged:Fire(player, itemName)
    end
end

function InventoryService:UnequipItems(player)
    if not player.Character then return end
    local item = player.Character:FindFirstChildOfClass("Tool")
    if item then
        item:Destroy()
        self.Client.EquippedItemChanged:Fire(player, nil)
    end
end

function InventoryService:RemoveItem(player, itemName)
    local item = player.Backpack:FindFirstChild(itemName)
    if item then
        item:Destroy()
        self.Client.InventoryChanged:Fire(player, TableUtil.cast(player.Backpack:GetChildren(), tostring))
    end
end

function InventoryService:AddItem(player, itemName)
    local thisItemData = ItemData[itemName]
    if thisItemData then
        thisItemData.Tool:Clone().Parent = player.Backpack
        self.Client.InventoryChanged:Fire(player, TableUtil.cast(player.Backpack:GetChildren(), tostring))
    else
        warn(("Tried giving invalid item of '%s' to %s"):format(itemName, player.Name))
    end
end

function InventoryService:GiveAllItem(itemName)
    local thisItemData = ItemData[itemName]
    if thisItemData then
        for _,player in pairs(Players:GetPlayers()) do
            self:AddItem(player, itemName)
        end
    end
end

function InventoryService:KnitStart()
    self.Client.EquipItem:Connect(function(player, itemName)
        self:EquipItem(player, itemName)
    end)

    self.Client.UnequipItems:Connect(function(player)
        self:UnequipItems(player)
    end)
end

return InventoryService