local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LinesFolder = ReplicatedStorage.Lines
local Util = ReplicatedStorage.Util

local Knit = require(ReplicatedStorage.Knit)
local Soundly = require(ReplicatedStorage.Soundly)
local SoundProperties = require(ReplicatedStorage.SoundProperties)

local TableUtil = require(Util.TableUtil)

local Chapter1Lines = require(LinesFolder.Chapter1)

local DialogueController = Knit.CreateController {
    Name = "DialogueController",
    CharacterSounds = {}
}

function DialogueController:GetWaitLength(text)
    local wordNumber = #text:split(" ")
    local avgReadingWPM = 125
    local minutes = wordNumber / avgReadingWPM
    local seconds = minutes * 60
     
    return seconds
end

function DialogueController:PlayMultipleText(texts, soundIds, soundMount)
    local StateController = Knit.Controllers.StateController
    local thisSoundProperties = TableUtil.shallowcopy(SoundProperties.Dialogue)
    local sound = Soundly.CreateSound(soundMount or workspace.GameSounds, thisSoundProperties)
    Knit.Controllers.SoundController:CacheSound("DialogueSound", sound)

    for i = 1, #texts do
        StateController.Store:dispatch({
            type = "SetDialogue",
            Enabled = true,
            Text = texts[i]
        })
        if soundIds and soundIds[i] then
            thisSoundProperties.SoundId = soundIds[i]
            if not sound.IsLoaded then
                sound.Loaded:Wait()
            end
            sound:Play()
            sound.Ended:Wait()
        else
            wait(self:GetWaitLength(texts[i]))
        end
    end

    sound:Destroy()
    self:StopText()
end

function DialogueController:PlayLine(id, soundMount, callback)
    local line = Chapter1Lines.Story[id] or Chapter1Lines.Misc[id]
    assert(line ~= nil, ("Line '%s' not found"):format(id))
    
    if callback then
        coroutine.wrap(callback)()
    end

    if typeof(line.Text) == "table" and not line.RandomChoice then
        self:PlayMultipleText(line.Text, line.Audio, soundMount)
    elseif typeof(line.Text) == "table" and line.RandomChoice then
        local random = math.random(#line.Text)
        self:PlayText(line.Text[random], line.Audio[random], soundMount)
    else
        self:PlayText(line.Text, soundMount)
    end
    
    return DialogueController
end

function DialogueController:PlayText(text, soundId, soundMount)
    local StateController = Knit.Controllers.StateController
    StateController.Store:dispatch({
        type = "SetDialogue",
        Enabled = true,
        Text = text
    })

    if soundId then
        local thisSoundProperties = TableUtil.shallowcopy(SoundProperties.Dialogue)
        thisSoundProperties.SoundId = soundId
        local sound = Soundly.CreateSound(soundMount or workspace.GameSounds, thisSoundProperties)
        Knit.Controllers.SoundController:CacheSound("DialogueSound", sound)
        sound:PlayOnce()
        sound.Ended:Wait()
    else
        wait(self:GetWaitLength(text))
    end
    self:StopText()
    
    return DialogueController
end

function DialogueController:StopText()
    local StateController = Knit.Controllers.StateController
    StateController.Store:dispatch({
        type = "SetDialogue",
        Enabled = false,
        Text = nil
    })
    Knit.Controllers.SoundController:RemoveSound("DialogueSound")
    --wait(1)
end

function DialogueController:KnitInit()
    local DialogueService = Knit.GetService("DialogueService")
    
    DialogueService.PlayText:Connect(function(...)
        self:PlayText(...)
    end)

    DialogueService.PlayMultipleText:Connect(function(...)
        self:PlayMultipleText(...)
    end)

    DialogueService.PlayLine:Connect(function(...)
        self:PlayLine(...)
    end)
end

return DialogueController