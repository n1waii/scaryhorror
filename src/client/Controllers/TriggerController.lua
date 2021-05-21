local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local Trigger = require(ReplicatedStorage.Trigger)
local Cutscene = require(ReplicatedStorage.Cutscene)
local CCamera, CEffect, CDelay = Cutscene.Camera, Cutscene.Effect, Cutscene.Delay

local CutsceneCameras = workspace.CutsceneCameras

local Player = Players.LocalPlayer
local TriggerParts = workspace.Triggers

local TriggerController = Knit.CreateController {
    Name = "TriggerController"
}

function TriggerController:Setup()
    for _,part in pairs(TriggerParts:GetChildren()) do        
        local conn; conn = part.Touched:Connect(function(hit)
            if part:GetAttribute("OnCooldown") then return end
            if hit.Parent:FindFirstChild("Humanoid") then
                local player = Players:GetPlayerFromCharacter(hit.Parent)
                if player and player == Player then
                    part:SetAttribute("OnCooldown", true)
                    Trigger:Emit(part:GetAttribute("EventName"), player)
                    if part:GetAttribute("Once") then
                        conn:Disconnect()
                    else
                        wait(part:GetAttribute("CooldownTime"))
                        part:SetAttribute("OnCooldown", false)
                    end
                end
            end
        end)
    end
end

function TriggerController:KnitStart()
    Trigger:Listen("test", function(player)
        print("triggered by " .. player.Name)
        Cutscene.new({
            CEffect.new("Fade", "In"),
            CCamera.new(CutsceneCameras.CamPart1.CFrame, function(cameraObj)
                print("Started cam 1")
            end),
            CEffect.new("Fade", "Out"),
            CDelay.new(1),
            CEffect.new("Fade", "In"),
            CCamera.new(CutsceneCameras.CamPart3.CFrame, function(cameraObj)
                print("Started cam 2")
                cameraObj:TweenTo(cameraObj.CFrame * CFrame.new(0, 0, 8), TweenInfo.new(10))
            end),
            CEffect.new("Fade", "Out")
        }):Play()
    end)
    self:Setup()
end

return TriggerController