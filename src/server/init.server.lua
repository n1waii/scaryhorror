local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Knit)

Knit.AddServicesDeep(script.Services)
Knit.Start():Then(function()
    print("Services loaded")
    wait(3)
    for _,v in pairs(game.Players:GetPlayers()) do
        Knit.Services.InventoryService:AddItem(v, "Key")
    end
    print("Gave key")
end):Expect()