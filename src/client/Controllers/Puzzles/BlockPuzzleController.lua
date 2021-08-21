local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local BlockPuzzleController = Knit.CreateController {
    Name = "BlockPuzzleController"
}

function BlockPuzzleController:PromptCallback(proximityPart)
    local PuzzleService = Knit.GetService("PuzzleService")
    PuzzleService.BlockPuzzle_RotateBlock:Fire(proximityPart.Parent)
end

return BlockPuzzleController