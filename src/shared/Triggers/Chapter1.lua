local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local PositionParts = workspace.PositionParts
local CutsceneCameras = workspace.CutsceneCameras
local GameObjects = workspace.GameObjects

local Chapter1Intro = require(script.Parent.Intro)

local Knit = require(ReplicatedStorage.Knit)
local TriggerService
local ObjectivesService

local Cutscene, CEffect, CCamera, CDelay
local DialogueController
local InputController
local CharacterController
local SoundController

local Soundly = require(ReplicatedStorage.Soundly)
local SoundProperties = require(ReplicatedStorage.SoundProperties)

if RunService:IsServer() then
    TriggerService = Knit.Services.TriggerService
    ObjectivesService = Knit.Services.ObjectivesService
else
    Cutscene = require(ReplicatedStorage.Cutscene)
    CEffect = Cutscene.Effect
    CCamera = Cutscene.Camera
    CDelay = Cutscene.Delay
    DialogueController = Knit.Controllers.DialogueController
    InputController = Knit.Controllers.InputController
    CharacterController = Knit.Controllers.CharacterController
    SoundController = Knit.Controllers.SoundController
end

return {
    Chapter1Intro = {
        Server = Chapter1Intro.Server,
        Client = Chapter1Intro.Client
    },

    SpawnScene = {
        Server = function(player, event, triggerPart)
            TriggerService.Client.TriggerClientCallback:Fire(player, player, event)
            ObjectivesService:AddObjective("1")
        end,

        Client = function(player)
            local thisScenePositionParts = PositionParts.Chapter1SpawnScene
            local TelephoneController = Knit.Controllers.TelephoneController

            CEffect.new("Fade", "In"):Start() -- might cause bug when integrating with intro
            CharacterController:SetCharacterCFrame(thisScenePositionParts.Spawn.CFrame)
            TelephoneController:StartRinging()
            wait(2)
            CEffect.new("Fade", "Out"):Start()
        end
    },

    CheckMainDoor = {
        Server = function(player, event, triggerPart)
            if not ObjectivesService:HasObjective(player, "2") then return end
            ObjectivesService:CompleteObjective(player, "2")
            triggerPart:SetAttribute("Triggerable", false)
            TriggerService.Client.TriggerClientCallback:Fire(player, player, event)
            workspace.Triggers.Telephone:SetAttribute("Triggerable", true)
        end,

        Client = function(player)
            local thisSceneCameras = CutsceneCameras.MainDoorWindowPanorama
            CharacterController:DisableMovement()
            local cutscene = Cutscene.new({
                CCamera.new(thisSceneCameras.Cam1.CFrame, function(cameraObj)
                    cameraObj:TweenTo(thisSceneCameras.Cam2.CFrame, TweenInfo.new(2, Enum.EasingStyle.Linear)).Completed:Wait()
                end),
                CDelay.new(1)
            })
            cutscene:Play()
            cutscene:Stop()
            CharacterController:EnableMovement()
        end
    }
}