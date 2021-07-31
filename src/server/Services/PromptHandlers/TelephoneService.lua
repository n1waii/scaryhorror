local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local switch = require(ReplicatedStorage.Util.SwitchStatement)
local Soundly = require(ReplicatedStorage.Soundly)
local SoundProperties = require(ReplicatedStorage.SoundProperties)

local Knit = require(ReplicatedStorage.Knit) 
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)

local PromptActions = {
    AnswerPhone = "Answer phone"
}

local TelephoneService = Knit.CreateService {
    Name = "TelephoneService",
    Client = {
        PromptTriggered = RemoteSignal.new(),
        StartRinging = RemoteSignal.new(),
        StopRinging = RemoteSignal.new()
    }
}

local TelephoneModel = workspace.GameObjects.Telephone

local AnswerPhoneActions = {}

AnswerPhoneActions.CallFromStart = function(proximityPart)
    local ObjectivesService = Knit.Services.ObjectivesService
    local DialogueService = Knit.Services.DialogueService

    ObjectivesService:CompleteObjective("1")
    DialogueService:PlayLineAll("73921", TelephoneModel.PrimaryPart)
    wait(16)
    Soundly.CreateSound(workspace.Door.MainDoor.PrimaryPart, SoundProperties.DoorKnocking):PlayOnce()
    wait(1)
    DialogueService:PlayLineAll("93120", TelephoneModel.PrimaryPart)
    ObjectivesService:AddObjective("2")
end

function TelephoneService:PromptCallback(player, proximityPart)
    if not proximityPart:GetAttribute("Triggerable") then return end
    proximityPart:SetAttribute("Triggerable", false)
    
    switch (proximityPart:GetAttribute("ActionText")) {
        [PromptActions.AnswerPhone] = function()
            if Knit.Services.ObjectivesService:HasObjective(player, "1") then
                AnswerPhoneActions.CallFromStart(proximityPart)
            end
        end
    }
end

function TelephoneService:StartRinging()
    self.Client.StartRinging:FireAll()
end

function TelephoneService:StopRinging()
    self.Client.StopRinging:FireAll()
end

function TelephoneService:KnitInit()
    self.Client.PromptTriggered:Connect(function(...)
        self:PromptCallback(...)
    end)
end

return TelephoneService