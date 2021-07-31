local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)

local TriggersFolder = ReplicatedStorage.Triggers

local TriggerParts = workspace.Triggers

local TriggerService = Knit.CreateService {
    Name = "TriggerService",
    Client = {
        TriggerClientCallback = RemoteSignal.new()
    },
    Triggered = {}
}

function TriggerService:Trigger(player, event, triggerPart)
    local eventTriggers = require(TriggersFolder.Chapter1)[event]
    assert(eventTriggers ~= nil, "Event triggers don't exit for event '".. event .."'")
    eventTriggers.Server(player, event, triggerPart)
end

function TriggerService:AddTriggered(player, event)
    if not self.Triggered[player] then
        self.Triggered[player] = {}
    end
    self.Triggered[player][event] = true
end

function TriggerService:IsTriggered(player, event)
    if self.Triggered[player] then
        return self.Triggered[player][event] and true or false
    end
end

function TriggerService:SetupTriggerParts()
    for _,part in pairs(TriggerParts:GetChildren()) do        
        local conn; conn = part.Touched:Connect(function(hit)
            if not part:GetAttribute("Triggerable") then return end
            if hit.Parent:FindFirstChild("Humanoid") then
                local player = Players:GetPlayerFromCharacter(hit.Parent)
                if player then
                    if part:GetAttribute("Once") then
                        conn:Disconnect()
                    end
                    self:Trigger(player, part:GetAttribute("EventName"), part)
                end
            end
        end)
    end
end

function TriggerService:KnitStart()
    self:SetupTriggerParts()
end

return TriggerService
