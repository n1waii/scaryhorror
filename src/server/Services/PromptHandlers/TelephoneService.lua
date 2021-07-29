local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local switch = require(ReplicatedStorage.Util.SwitchStatement)

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
        StopRinging = RemoteSignal.new(),
        PromptActions = PromptActions
    }
}

function TelephoneService:PromptCallback(player, proximityPart)
    if not proximityPart:GetAttribute("Triggerable") then return end
    proximityPart:SetAttribute("Triggerable", false)
    
    switch (proximityPart:GetAttribute("ActionText")) {
        [PromptActions.StopRinging] = function()
            print("answer the phone lol")
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