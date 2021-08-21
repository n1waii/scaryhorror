local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)

local AbstractPuzzle = require(script.Parent.AbstractPuzzle)
local Janitor = require(Knit.Util.Janitor)

local BlockPuzzle = {}
BlockPuzzle.__index = BlockPuzzle
setmetatable(BlockPuzzle, AbstractPuzzle)

function BlockPuzzle.new(blocks, correctPattern)
    local puzzle = AbstractPuzzle.new()
    puzzle.Blocks = blocks
    puzzle.BlockFaces = {}
    puzzle.CorrectPattern = correctPattern
    puzzle.Janitor = Janitor.new()
    puzzle.OriginalBlockCFrames = {}

    for i, block in pairs(blocks) do
        puzzle.BlockFaces[tostring(i)] = block.Letters.Value
    end

    return setmetatable(puzzle, BlockPuzzle)
end

function BlockPuzzle:isComplete()
    for i, letter in pairs(self.BlockFaces) do
        if letter ~= self.CorrectPattern[i] then
            return false
        end
    end
    return true
end

function BlockPuzzle:Start()
    local PuzzleService = Knit.Services.PuzzleService

    for _,block in pairs(self.Blocks) do
        self.OriginalBlockCFrames[block.Name] = block.PrimaryPart.CFrame
    end

    self.Janitor:Add(PuzzleService.BlockPuzzle_RotateBlock:Connect(function(player, block)
        if self.Completed then return end
        block.AlphexusPrompt:SetAttribute("Triggerable", false)
        block.LetterNumber.Value += (1%4)
        self.BlockFaces[tonumber(block.Name)] = block.Letters:sub(block.LetterNumber.Value, block.LetterNumber.Value)
        block:SetPrimaryPartCFrame(self.OriginalBlockCFrames[block.Name] * CFrame.Angles(0, (block.LetterNumber.Value * 90), 0))
        if self:isComplete() then
            return self:onComplete()
        end
        wait(0.5)
        block.AlphexusPrompt:SetAttribute("Triggerable", true)
    end))
end

function BlockPuzzle:onComplete()
    self.Completed = true
    Janitor:Cleanup()
    for _,blocks in pairs(self.Blocks) do
        blocks.AlphexusPrompt:SetAttribute("Triggerable", false)
    end
end

function BlockPuzzle:__tostring()
    return "BlockPuzzle"
end

return BlockPuzzle
