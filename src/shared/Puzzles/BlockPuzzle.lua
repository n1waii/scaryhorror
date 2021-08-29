local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SOLVE_PUZZLE_OBJECTIVE_ID = "7"
local CORRECT_PATTERN = "HELP"

local GameObjects = workspace.GameObjects
local RuntimeInstances = ReplicatedStorage.RuntimeInstances

local Knit = require(ReplicatedStorage.Knit)
local Janitor = require(Knit.Util.Janitor).new()

local BlockPuzzle = {
    Blocks = RuntimeInstances.CribRoom.Blocks:GetChildren(),
    BlockFaces = {},
    OriginalBlockCFrames = {},
    CorrectPattern = "HELP",
    Completed = false,
    MovedBlockOnce = false
}

for _,block in pairs(BlockPuzzle.Blocks) do
    BlockPuzzle.BlockFaces[block.Name] = block.Letters.Value:sub(block.LetterNumber.Value, block.LetterNumber.Value)
    BlockPuzzle.OriginalBlockCFrames[block.Name] = block.PrimaryPart.CFrame
end

function BlockPuzzle:isComplete()
    for i = 1, #self.CorrectPattern do
        if self.BlockFaces[tostring(i)] ~= self.CorrectPattern:sub(i,i) then
            print(i)
            return false
        end
    end
    return true
end

function BlockPuzzle:Start()
    if self.Completed then return end
    local PuzzleService = Knit.Services.PuzzleService
    local ObjectivesService = Knit.Services.ObjectivesService
    local DialogueService = Knit.Services.DialogueService

    local function wrap_int(x, min, max)
        return (x > max and min) or (x < min and max) or x
    end

    Janitor:Add(PuzzleService.Client.BlockPuzzle_RotateBlock:Connect(function(player, proximityPart)
        if self.Completed then return end
        local block = proximityPart.Parent
        if not block or not block:FindFirstChild("LetterNumber") then return end
        block.AlphexusPrompt:SetAttribute("Triggerable", false)
        block.LetterNumber.Value = wrap_int(block.LetterNumber.Value+1, 1, 4)
        self.BlockFaces[block.Name] = block.Letters.Value:sub(block.LetterNumber.Value, block.LetterNumber.Value)
        print(self.BlockFaces[block.Name])
        PuzzleService.Client.BlockPuzzle_RotateBlock:FireAll(block,
            self.OriginalBlockCFrames[block.Name] * CFrame.Angles(math.rad((block.LetterNumber.Value-1) * -90), 0, 0)
        )
        if not self.MovedBlockOnce then
            self.MovedBlockOnce = true
            DialogueService:PlayLineAll("3812308")
            task.defer(function()
                task.wait(2)
                ObjectivesService:AddObjective(SOLVE_PUZZLE_OBJECTIVE_ID)
            end)
        end
        if self:isComplete() then
            return self:End()
        end
        wait(0.5)
        block.AlphexusPrompt:SetAttribute("Triggerable", true)
    end))
end

function BlockPuzzle:StartJackInTheBox()
    if not self.Completed then return end
end

function BlockPuzzle:End()
    self.Completed = true
    Janitor:Cleanup()
    for _,blocks in pairs(self.Blocks) do
        blocks.AlphexusPrompt:SetAttribute("Enabled", false)
    end
    Knit.Services.ObjectivesService:CompleteObjective(SOLVE_PUZZLE_OBJECTIVE_ID)
    GameObjects.CribRoom.JackInTheBox.Handle.AlphexusPrompt:SetAttribute("Enabled", true)
    print("Completed puzzle")
end

return BlockPuzzle