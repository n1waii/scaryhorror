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
    },
    PlayerObjectives = {}
}

local function AddPlayerObjective(id)
    for _,player in pairs(Players:GetPlayers()) do
        if not ObjectivesService.PlayerObjectives[player] then
            ObjectivesService.PlayerObjectives[player] = {}
        end
        ObjectivesService.PlayerObjectives[player][id] = true
    end
end

local function RemovePlayerObjective(id)
    for _,player in pairs(Players:GetPlayers()) do
        ObjectivesService.PlayerObjectives[player][id] = nil
    end
end

function ObjectivesService:AddObjective(id)
    self.Client.AddObjective:FireAll(id)
    AddPlayerObjective(id)
end

function ObjectivesService:RemoveObjective(id)
    self.Client.RemoveObjective:FireAll(id)
end

function ObjectivesService:CompleteObjective(id)
    self.Client.RemoveObjective:FireAll(id)
end

function ObjectivesService:HasObjective(player, id)
    return self.PlayerObjectives[player][id]
end

return ObjectivesService