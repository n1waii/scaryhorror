local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)

local TriggersFolder = ReplicatedStorage.Triggers

local TriggerParts = workspace.Triggers

local TriggerService = Knit.CreateService {
    Name = "TriggerService",
    Client = {
        TriggerClientCallback = RemoteSignal.new(),
        TriggerOnServer = RemoteSignal.new()
    },
    Triggered = {},
    TriggeredByPlayer = {},
    TriggerQueue = {}
}

function TriggerService:Trigger(player, event, triggerPart)
    local eventTriggers = require(TriggersFolder.Chapter1)[event]
    assert(eventTriggers ~= nil, "Event triggers don't exit for event '".. event .."'")
    table.insert(self.TriggerQueue, { player, event, triggerPart })
end

function TriggerService:AddTriggeredForPlayer(player, event)
    if not self.TriggeredByPlayer[player] then
        self.TriggeredByPlayer[player] = {}
    end
    self.TriggeredByPlayer[player][event] = true
end

function TriggerService:AddTriggered(event)
    self.Triggered[event] = true
end

function TriggerService:IsTriggeredByPlayer(player, event)
    if self.TriggeredByPlayer[player] then
        return self.TriggeredByPlayer[player][event] and true or false
    end
end

function TriggerService:IsTriggered(event)
   return self.Triggered[event]
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

function TriggerService:_handleQueue()
    coroutine.wrap(function()
        while true do
            for i, triggerArgs in ipairs(self.TriggerQueue) do
                local eventTriggers = require(TriggersFolder.Chapter1)[triggerArgs[2]]
                eventTriggers.Server(unpack(triggerArgs))
                table.remove(self.TriggerQueue, i)
                task.wait(0.5)
            end
            task.wait()
        end
    end)()
end

function TriggerService:KnitStart()
    self:SetupTriggerParts()

    TriggerService.Client.TriggerOnServer:Connect(function(player, event)
        self:Trigger(player, event)
    end)
 
    self:_handleQueue()
end

return TriggerService
