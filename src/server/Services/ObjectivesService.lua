local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)

local ObjectivesService = Knit.CreateService {
    Name = "ObjectivesService",
    Client = {
        AddObjective = RemoteSignal.new(),
        CompleteObjective = RemoteSignal.new(),
        RemoveObjective = RemoteSignal.new(),
    }
}

function ObjectivesService:AddObjective(id)
    self.Client.AddObjective:FireAll(id)
end

function ObjectivesService:RemoveObjective(id)
    self.Client.RemoveObjective:FireAll(id)
end

function ObjectivesService:CompleteObjective(id)
    self.Client.RemoveObjective:FireAll(id)
end

return ObjectivesService