local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Knit)

Knit.AddControllersDeep(script.Controllers)
Knit.Start():Then(function()
    print("Controllers loaded")
end):Catch(error)