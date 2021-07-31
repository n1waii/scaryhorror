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
local DialogueService

local Cutscene, CEffect, CCamera, CDelay
local DialogueController
local InputController
local CharacterController
local SoundController
local CameraController
local LightController
local ObjectivesController

local Soundly = require(ReplicatedStorage.Soundly)
local SoundProperties = require(ReplicatedStorage.SoundProperties)

if RunService:IsServer() then
    TriggerService = Knit.Services.TriggerService
    ObjectivesService = Knit.Services.ObjectivesService
    DialogueService = Knit.Services.DialogueService
else
    Cutscene = require(ReplicatedStorage.Cutscene)
    CEffect = Cutscene.Effect
    CCamera = Cutscene.Camera
    CDelay = Cutscene.Delay
    DialogueController = Knit.Controllers.DialogueController
    InputController = Knit.Controllers.InputController
    CharacterController = Knit.Controllers.CharacterController
    SoundController = Knit.Controllers.SoundController
    CameraController = Knit.Controllers.CameraController
    LightController = Knit.Controllers.LightController
    ObjectivesController = Knit.Controllers.ObjectivesController
end

return {
    Chapter1Intro = {
        Server = Chapter1Intro.Server,
        Client = Chapter1Intro.Client
    },

    SpawnScene = {
        Server = function(player, event, triggerPart)
            TriggerService.Client.TriggerClientCallback:Fire(player, player, event)
            wait(3)
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
            ObjectivesService:CompleteObjective("2")
            triggerPart:SetAttribute("Triggerable", false)
            TriggerService.Client.TriggerClientCallback:Fire(player, player, event)
            workspace.Triggers.Telephone:SetAttribute("Triggerable", true)
        end,

        Client = function(player)
            local thisSceneCameras = CutsceneCameras.MainDoorWindowPanorama
            local spookyAmbienceSound = Soundly.CreateSound(workspace.GameSounds, SoundProperties.SpookyAmbience1)

            CharacterController:DisableMovement()
            CameraController:Scriptable()
            CameraController:TweenCamera(thisSceneCameras.Cam1.CFrame, 1).Completed:Wait()

            local cutscene = Cutscene.new({
                CCamera.new(thisSceneCameras.Cam1.CFrame, function(cameraObj)
                    spookyAmbienceSound:PlayOnce()
                    cameraObj:TweenTo(thisSceneCameras.Cam2.CFrame, TweenInfo.new(2, Enum.EasingStyle.Linear)).Completed:Wait()
                end),
                CDelay.new(1)
            })

            cutscene:Play():await()
            DialogueController:PlayLine("381203")
            cutscene:Destroy()
            CharacterController:EnableMovement()
            ObjectivesController:AddObjective("3")
        end
    },

    TelephoneBackToCall = {
        Server = function(player, event, triggerPart)
            TriggerService.Client.TriggerClientCallback:Fire(player, player, event)
        end,

        Client = function(player)
            local telephoneModel = GameObjects.Telephone
            ObjectivesController:CompleteObjective("3")
            DialogueController:PlayLine("37892", telephoneModel.PrimaryPart)
            wait(0.3)
            coroutine.wrap(function()
                wait(0.1)
                LightController:Flicker(0.1, 15)
            end)()
            DialogueController:PlayLine("38210")
            wait(1)
            DialogueController:PlayLine("37291", telephoneModel.PrimaryPart)
        end
    }
}