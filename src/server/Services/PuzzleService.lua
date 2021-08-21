local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
-- local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)

local PuzzleService = Knit.CreateService {
    Name = "PuzzleService",
    Client = {
        --BlockPuzzle_RotateBlock = RemoteSignal.new()
    },
    GamePuzzles = {}
}

function PuzzleService:StartPuzzle(puzzleName)
    local puzzleObject = self.GamePuzzles[puzzleName]
    if puzzleObject then
        puzzleObject:Start()
    else
        error("Tried to start unknown puzzle '" .. puzzleName .. "'")
    end
end

function PuzzleService:_addPuzzle(puzzleObject)
    self.GamePuzzles[tostring(puzzleObject)] = puzzleObject
end

function PuzzleService:KnitStart()
    --self:_addPuzzle(BlockPuzzle.new())
end

return PuzzleService