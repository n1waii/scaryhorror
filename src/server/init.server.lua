local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Knit)

Knit.AddServicesDeep(script.Services)
Knit.Start():Then(function()
    print("Services loaded")
end):Expect()