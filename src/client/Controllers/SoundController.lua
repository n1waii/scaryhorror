local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local Soundly = require(ReplicatedStorage.Soundly)

local SoundController = Knit.CreateController {
    Name = "SoundController",
    CharacterSounds = {}
}

function SoundController:GetSound()
    
end

function SoundController:KnitStart()
    local StateController = Knit.Controllers.StateController
    self.CharacterSounds.Breathing = Soundly.Sound.new(workspace.GameSounds, {
        Name = "Breathing",
        Volume = 0.1,
        RollOffMinDistance = math.huge,
        RollOffMaxDistance = math.huge,
        PlaybackSpeed = 0.7,
        Looped = true,
        SoundId = "rbxassetid://3725917109"
    })

    self.CharacterSounds.Heartbeat = Soundly.Sound.new(workspace.GameSounds, {
        Name = "Breathing",
        Volume = 0.2,
        RollOffMinDistance = math.huge,
        RollOffMaxDistance = math.huge,
        PlaybackSpeed = 0.5,
        Looped = true,
        SoundId = "rbxassetid://6841299763"
    })

    -- breathing
    self.CharacterSounds.Breathing:BindProperty("Volume", function(oldValue)
        local stamina = StateController.Store:getState().Stamina
        return Soundly.Map(stamina, 100, 0, 0.1, 1.5)
    end)

    self.CharacterSounds.Breathing:BindProperty("PlaybackSpeed", function(oldValue)
        local stamina = StateController.Store:getState().Stamina
        return Soundly.Map(stamina, 100, 0, 0.7, 1.1)
    end)

    -- heartbeat
    self.CharacterSounds.Heartbeat:BindProperty("Volume", function(oldValue)
        local stamina = StateController.Store:getState().Stamina
        return Soundly.Map(stamina, 100, 0, 0.2, 1)
    end)

    self.CharacterSounds.Heartbeat:BindProperty("PlaybackSpeed", function(oldValue)
        local stamina = StateController.Store:getState().Stamina
        return Soundly.Map(stamina, 100, 0, 0.5, 1.1)
    end)

    self.CharacterSounds.Breathing:Play()
    self.CharacterSounds.Heartbeat:Play()
end

return SoundController