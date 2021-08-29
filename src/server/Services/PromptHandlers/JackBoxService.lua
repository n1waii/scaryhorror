local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local GameObjects = workspace.GameObjects

local BlockPuzzle = require(ReplicatedStorage.Puzzles.BlockPuzzle)

local Knit = require(ReplicatedStorage.Knit) 
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)

local JackBoxService = Knit.CreateService {
    Name = "JackBoxService",
    Client = {
        SetItemRetrievable = RemoteSignal.new()
    }
}

function JackBoxService.Client:IsBoxOpenable(player, proximityPart)
    if BlockPuzzle.Completed then
        proximityPart:SetAttribute("Enabled", false)
        return true
    end

    return false
end

function JackBoxService:KnitInit()
    self.Client.SetItemRetrievable:Connect(function(player)
        GameObjects.CribRoom.JackInTheBox.Top.AlphexusPrompt:SetAttribute("Enabled", true)
    end)
end

return JackBoxService