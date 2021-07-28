local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local PositionParts = workspace.PositionParts
local CutsceneCameras = workspace.CutsceneCameras

local Chapter1Intro = require(script.Parent.Intro)

local Knit = require(ReplicatedStorage.Knit)
local TriggerService
local ObjectivesService

local Cutscene, CEffect, CCamera, CDelay
local DialogueController
local InputController
local CharacterController

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
end

return {
    Chapter1Intro = {
        Server = Chapter1Intro.Server,
        Client = Chapter1Intro.Client
    },

    SpawnScene = {
        Server = function(player, event)
            TriggerService.Client.TriggerClientCallback:Fire(player, player, event)
        end,

        Client = function(player)
            local thisSceneCameras = CutsceneCameras.Chapter1SpawnScene
            local thisScenePositionParts = PositionParts.Chapter1SpawnScene

            CharacterController:SetCharacterCFrame(thisScenePositionParts.Spawn.CFrame)
        end
    },

    FindMainDoorKey = {
        Server = function(player, event)
            print("giving objective 1")
            ObjectivesService:AddObjective("1")
        end
    }
}