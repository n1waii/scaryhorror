local ReplicatedStorage = game:GetService("ReplicatedStorage")

local switch = require(ReplicatedStorage.Util.SwitchStatement)

local Soundly = require(ReplicatedStorage.Soundly)
local SoundProperties = require(ReplicatedStorage.SoundProperties)

local GameObjects = workspace.GameObjects
local TelephoneModel = GameObjects.Telephone

local Knit = require(ReplicatedStorage.Knit)
local TelephoneController = Knit.CreateController {
    Name = "TelephoneController"
}

function TelephoneController:StartRinging()
    local sound = Soundly.CreateSound(TelephoneModel.PrimaryPart, SoundProperties.TelephoneRinging)
    sound:Play()
    Knit.Controllers.SoundController:CacheSound("TelephoneRinging", sound)
end

function TelephoneController:StopRinging()
    Knit.Controllers.SoundController:RemoveSound("TelephoneRinging")
end

function TelephoneController:PromptCallback(proximityPart)
    local TelephoneService = Knit.GetService("TelephoneService")
    local SoundController = Knit.Controllers.SoundController

    TelephoneService.PromptTriggered:Fire(proximityPart)

    switch (proximityPart:GetAttribute("ActionText")) {
        [TelephoneService.PromptActions.AnswerPhone] = function()
            self:StopRinging()
        end
    }
end

function TelephoneController:KnitStart()
    local TelephoneService = Knit.GetService("TelephoneService")

    TelephoneService.StartRinging:Connect(function()
        self:StartRinging()
    end)

    TelephoneService.StopRinging:Connect(function()
        self:StopRinging()
    end)
end

return TelephoneController
