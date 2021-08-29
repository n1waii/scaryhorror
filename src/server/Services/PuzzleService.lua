local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)

local PuzzleService = Knit.CreateService {
    Name = "PuzzleService",
    Client = {
        BlockPuzzle_RotateBlock = RemoteSignal.new()
    }
}

return PuzzleService