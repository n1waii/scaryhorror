local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interface = require(ReplicatedStorage.Interface)
local Objective = Interface : Create {
    Completed = Interface : Value ("boolean"),
    Text = Interface : Value ("string"),
    Id = Interface : Value ("string")
}

return Objective