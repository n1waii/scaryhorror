local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local Cutscene = require(ReplicatedStorage.Cutscene)
local CCamera, CEffect, CDelay = Cutscene.Camera, Cutscene.Effect, Cutscene.Delay

local TriggersFolder = ReplicatedStorage.Triggers
local CutsceneCameras = workspace.CutsceneCameras

local Player = Players.LocalPlayer
local TriggerParts = workspace.Triggers

local TriggerController = Knit.CreateController {
    Name = "TriggerController"
}

function TriggerController:Trigger(player, event)
    local eventTriggers = require(TriggersFolder.Chapter1)[event]
    assert(eventTriggers ~= nil, "Event triggers don't exit for event '".. event .."'")
    eventTriggers.Client(player)
end

function TriggerController:TriggerOnServer(event)
    local TriggerService = Knit.GetService("TriggerService")
    TriggerService.TriggerOnServer:Fire(event)
end

function TriggerController:KnitStart()
    local TriggerService = Knit.GetService("TriggerService")

    TriggerService.TriggerClientCallback:Connect(function(...)
        self:Trigger(...)
    end)

    -- Trigger:Listen("test", function(player)
    --     print("triggered by " .. player.Name)
    --     Cutscene.new({
    --         CEffect.new("Fade", "In"),
    --         CCamera.new(CutsceneCameras.CamPart1.CFrame, function(cameraObj)
    --             print("Started cam 1")
    --         end),
    --         CEffect.new("Fade", "Out"),
    --         CDelay.new(1),
    --         CEffect.new("Fade", "I   n"),
    --         CCamera.new(CutsceneCameras.CamPart3.CFrame, function(cameraObj)
    --             print("Started cam 2")
    --             cameraObj:TweenTo(cameraObj.CFrame * CFrame.new(0, 0, 8), TweenInfo.new(10))
    --         end),
    --         CEffect.new("Fade", "Out")
    --     }):Play()
    -- end)
end

return TriggerController