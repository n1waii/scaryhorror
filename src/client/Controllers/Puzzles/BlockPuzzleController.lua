local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ROTATE_TWEEN_INFO = TweenInfo.new(1, Enum.EasingStyle.Quart)

local Soundly = require(ReplicatedStorage.Soundly)
local SoundProperties = require(ReplicatedStorage.SoundProperties)
local Spring = require(ReplicatedStorage.Physics.Spring)

local Knit = require(ReplicatedStorage.Knit)
local BlockPuzzleController = Knit.CreateController {
    Name = "BlockPuzzleController"
}

function BlockPuzzleController:PromptCallback(proximityPart)
    local PuzzleService = Knit.GetService("PuzzleService")
    PuzzleService.BlockPuzzle_RotateBlock:Fire(proximityPart)
end

function BlockPuzzleController:RotateBlock(block, cframeGoal)
    Soundly.CreateSound(block.PrimaryPart, SoundProperties.RotatingObjectSwoosh):PlayOnce()
    TweenService:Create(block.PrimaryPart, ROTATE_TWEEN_INFO, {
        CFrame = cframeGoal
    }):Play()
end

function BlockPuzzleController:KnitStart()
    local PuzzleService = Knit.GetService("PuzzleService")
    PuzzleService.BlockPuzzle_RotateBlock:Connect(function(...)
        self:RotateBlock(...)
    end)
end

return BlockPuzzleController