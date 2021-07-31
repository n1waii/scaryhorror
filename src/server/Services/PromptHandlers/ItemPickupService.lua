local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Knit = require(ReplicatedStorage.Knit) 
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)

local ItemPickupService = Knit.CreateService {
    Name = "ItemPickupService",
    Client = {
        PromptTriggered = RemoteSignal.new()
    }
}

function ItemPickupService:PromptCallback(player, proximityPart)
    if not player.Character then return end
    if not proximityPart:GetAttribute("Triggerable") then return end
    
    Knit.Services.QueryService:HandleRequest("ItemRequest", proximityPart.ItemRequest, player)
    
    proximityPart:Destroy()
    wait(0.9)
    proximityPart:SetAttribute("Triggerable", true)
end

function ItemPickupService:KnitInit()
    self.Client.PromptTriggered:Connect(function(...)
        self:PromptCallback(...)
    end)
end

return ItemPickupService