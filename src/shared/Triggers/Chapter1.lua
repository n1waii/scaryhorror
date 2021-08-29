local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Puzzles = ReplicatedStorage.Puzzles
local RuntimeInstances = ReplicatedStorage.RuntimeInstances
local ScareModels = ReplicatedStorage.ScareModels

local PositionParts = workspace.PositionParts
local CutsceneCameras = workspace.CutsceneCameras
local GameObjects = workspace.GameObjects
local DoorsFolder = workspace.Door
local TriggerParts = workspace.Triggers

local Chapter1Intro = require(script.Parent.Intro)
local BlockPuzzle = require(Puzzles.BlockPuzzle)

local Knit = require(ReplicatedStorage.Knit)
local TableUtil = require(Knit.Util.TableUtil)

local TriggerService
local ObjectivesService
local DialogueService
local DoorService
local CharacterService

local Cutscene, CEffect, CCamera, CDelay
local DialogueController
local InputController
local CharacterController
local SoundController
local CameraController
local LightController
local ObjectivesController
local TriggerController
local LightingController

local Player

local Soundly = require(ReplicatedStorage.Soundly)
local SoundProperties = require(ReplicatedStorage.SoundProperties)

if RunService:IsServer() then
    TriggerService = Knit.Services.TriggerService
    ObjectivesService = Knit.Services.ObjectivesService
    DialogueService = Knit.Services.DialogueService
    DoorService = Knit.Services.DoorService
    CharacterService = Knit.Services.CharacterService
else
    Player = Players.LocalPlayer
    Cutscene = require(ReplicatedStorage.Cutscene)
    CEffect = Cutscene.Effect
    CCamera = Cutscene.Camera
    CDelay = Cutscene.Delay
    TriggerController = Knit.Controllers.TriggerController
    DialogueController = Knit.Controllers.DialogueController
    InputController = Knit.Controllers.InputController
    CharacterController = Knit.Controllers.CharacterController
    SoundController = Knit.Controllers.SoundController
    CameraController = Knit.Controllers.CameraController
    LightController = Knit.Controllers.LightController
    ObjectivesController = Knit.Controllers.ObjectivesController
    LightingController = Knit.Controllers.LightingController
end

return {
    Chapter1Intro = {
        Server = Chapter1Intro.Server,
        Client = Chapter1Intro.Client
    },

    SpawnScene = {
        Server = function(player, event, triggerPart)
            if TriggerService:IsTriggered(event) then return end
            TriggerService:AddTriggered(event)

            local telephoneModel = GameObjects.Telephone
            telephoneModel.AlphexusPrompt:SetAttribute("Enabled", true)
            TriggerService.Client.TriggerClientCallback:FireAll(player, event)
            task.wait(3)
            ObjectivesService:AddObjective("1")
        end,

        Client = function(player)
            local thisScenePositionParts = PositionParts.Chapter1SpawnScene
            local TelephoneController = Knit.Controllers.TelephoneController

            CEffect.new("Fade", "In"):Start() -- might cause bug when integrating with intro
            CharacterController:SetCharacterCFrame(thisScenePositionParts.Spawn.CFrame)
            TelephoneController:StartRinging()
            task.wait(2)
            CEffect.new("Fade", "Out"):Start()
        end
    },

    CheckMainDoor = {
        Server = function(player, event, triggerPart)
            if TriggerService:IsTriggered(event) then return end
            if not ObjectivesService:HasObjective(player, "2") then return end
            TriggerService:AddTriggered(event)
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
            CameraController:Reset()
            CharacterController:EnableMovement()
            ObjectivesController:AddObjective("3")
        end
    },

    TelephoneBackToCall = {
        Server = function(player, event, triggerPart)
            if TriggerService:IsTriggered(event) then return end
            TriggerService:AddTriggered(event)
            TriggerService.Client.TriggerClientCallback:FireAll(player, event)
            task.wait(4)
            workspace.Triggers.BedroomBed:SetAttribute("Triggerable", true)
        end,

        Client = function(player)
            local telephoneModel = GameObjects.Telephone
            ObjectivesController:CompleteObjective("3")
            DialogueController:PlayLine("37892", telephoneModel.PrimaryPart)
            task.wait(0.3)
            coroutine.wrap(function()
                task.wait(0.1)
                LightController:Flicker(0.1, 15)
            end)()
            DialogueController:PlayLine("38210")
            task.wait(1)
            DialogueController:PlayLine("37291", telephoneModel.PrimaryPart)
            TriggerController:TriggerOnServer("GiveObjective_GoToBed")
        end
    },

    GiveObjective_GoToBed = {
        Server = function(player)
            if not ObjectivesService:HasObjective(player, "5") then
                ObjectivesService:AddObjective("5")
            end
        end
    },

    Testing = {
        Server = function(player)
            --player.Character:MoveTo(workspace.testPos2.Position)
            TriggerService:Trigger(player, "BabyCribTryingToExit", TriggerParts.BabyCribExit)
        end
    },

    BedroomBed = {
        Server = function(player, event, triggerPart)
            if TriggerService:IsTriggered(event) then return end
            if ObjectivesService:HasObjective(player, "5") then -- sleepy time
                TriggerService:AddTriggered(event)
                triggerPart:SetAttribute("Triggerable", false)
                TriggerService.Client.TriggerClientCallback:FireAll(player, event)
                ObjectivesService:CompleteObjective("5")
            end
        end,

        Client = function(player, event)
            local thisSceneCameras = CutsceneCameras.BedroomBed
            local thisScenePositionParts = PositionParts.BedroomBed
            local alarmClock = GameObjects.DigitalAlarmClock

            local screechingSound = Soundly.CreateSound(workspace.GameSounds, SoundProperties.Screeching)
            local longViolinScare3 = Soundly.CreateSound(workspace.GameSounds, SoundProperties.LongViolinScare3)
            local alarmBeeping = Soundly.CreateSound(alarmClock.Base.PrimaryPart, SoundProperties.AlarmClockBeeping)

            CharacterController:DisableMovement()
            CameraController:Scriptable()
            CameraController:TweenCamera(thisSceneCameras.SleepPOV1.CFrame, 3).Completed:Wait()
            CameraController:TweenCamera(thisSceneCameras.SleepPOV2.CFrame, 2).Completed:Wait()

            local underBedCutscene = Cutscene.new({
                CEffect.new("Fade", "In"),
                CDelay.new(2),
                CCamera.new(thisSceneCameras.SleepPOV2.CFrame, function(cameraObj)
                    LightingController:SetFog(20, 0)
                    screechingSound:Play()
                    CameraController:TweenBlur(15, 0.5)
                    task.wait(1)
                    CEffect.new("Fade", "Out"):Start()
                    CameraController:TweenBlur(5, 0.5)
                    DialogueController:PlayLine("372138")
                    cameraObj:TweenTo(thisSceneCameras.LyingUpCam.CFrame, TweenInfo.new(2, Enum.EasingStyle.Quint)).Completed:Wait()
                    cameraObj:TweenTo(thisSceneCameras.LyingUpCamLeft.CFrame, TweenInfo.new(1, Enum.EasingStyle.Linear)).Completed:Wait()
                    task.wait(1)
                    cameraObj:TweenTo(thisSceneCameras.LyingUpCamRight.CFrame, TweenInfo.new(2, Enum.EasingStyle.Linear)).Completed:Wait()
                end),
                CDelay.new(1),
                CEffect.new("Fade", "In"),
                CDelay.new(1),
                CCamera.new(thisSceneCameras.UnderBedCam1.CFrame),
                CEffect.new("Fade", "Out"),
                CCamera.new(thisSceneCameras.UnderBedCam1.CFrame, function(cameraObj)
                    cameraObj:TweenTo(thisSceneCameras.UnderBedCam2.CFrame, TweenInfo.new(2, Enum.EasingStyle.Linear)).Completed:Wait()
                    task.wait(1)
                    screechingSound:PlayOnce()
                    cameraObj:TweenTo(thisSceneCameras.MonsterLookAtCam.CFrame, TweenInfo.new(3, Enum.EasingStyle.Linear))
                    local scareModel = ScareModels.ScareModel1:Clone()
                    scareModel:SetPrimaryPartCFrame(thisScenePositionParts.ScareModelPosition.CFrame)
                    scareModel.Parent = workspace.GameObjects
                    longViolinScare3:PlayOnce()
                    task.wait(3)
                    for _,v in pairs(scareModel:GetChildren()) do
                        if v:IsA("BasePart") then
                            TweenService:Create(v, TweenInfo.new(2), {Transparency = 1}):Play()
                        end
                    end
                    CameraController:TweenBlur(15, 3)
                end),
                CDelay.new(3),
                CEffect.new("Fade", "In"),
                CDelay.new(2),
            })
            underBedCutscene:Play():await()
            underBedCutscene:Destroy()
            LightingController:ResetFog()
            CameraController:TweenBlur(0, 1)
            CharacterController:EnableMovement()
            CharacterController:SetCharacterCFrame(thisScenePositionParts.WakeUpFromBedPosition.CFrame)
            alarmClock.Base.PrimaryPart.Clock:Stop()
            alarmBeeping:Play()
            alarmClock.Display.SurfaceGui.TextLabel.Text = "3:00 AM"
            coroutine.wrap(function() -- alarm flickering and stopping
                for _ = 1, 25 do
                    alarmClock.Display.SurfaceGui.Enabled = not alarmClock.Display.SurfaceGui.Enabled
                    task.wait(0.3)
                end
                alarmClock.Display.SurfaceGui.Enabled = true
                alarmClock.Display.SurfaceGui.TextLabel.Text = "3:01 AM"
                alarmBeeping:Destroy()
            end)()
            CEffect.new("Fade", "Out"):Start()
            task.wait(1.5)
            DialogueController:PlayLine("389213")
            task.wait(4)
            TriggerController:TriggerOnServer("BabyLaughingInCrib")
        end
    },

    BabyLaughingInCrib = {
        Server = function(player, event)
            if TriggerService:IsTriggered(event) then return end
            TriggerService:AddTriggered(event)
            TriggerService.Client.TriggerClientCallback:FireAll(player, event)
            TriggerParts.BabyCrib:SetAttribute("Triggerable", true)
        end,

        Client = function(player)
            local crib = GameObjects:WaitForChild("Crib")
            local babyLullaby = Soundly.CreateSound(crib.PrimaryPart, SoundProperties.BabyLullaby)
            local babySoundEffect = Soundly.CreateSound(crib.PrimaryPart, SoundProperties.BabySoundEffect)
            babyLullaby:Play()
            babySoundEffect:Play()
            SoundController:CacheSound("BabyLullaby", babyLullaby)
            SoundController:CacheSound("BabySoundEffect", babySoundEffect)
        end
    },

    BabyLaughingInCribStop = {
        Server = function(player, event)
            if TriggerService:IsTriggered(event) then return end
            TriggerService:AddTriggered(event)
            TriggerService.Client.TriggerClientCallback:FireAll(player, event)
            task.wait(2)
            local childRoomDoor = DoorsFolder.Door16
            if DoorService:IsOpen(childRoomDoor) then
                DoorService:CloseDoor(childRoomDoor)
            else
                DoorService:OpenDoor(childRoomDoor)
                task.wait(1)
                DoorService:CloseDoor(childRoomDoor)
            end
            DoorService:LockDoor(childRoomDoor, "ChildRoomEscapeKey")
            -- NOTE: TELEPORT ALL PLAYERS THAT ARE OUTSIDE THE CRIB, INSIDE THE CRIB ROOM
            TriggerParts.BabyCribExit:SetAttribute("Triggerable", true)
        end,

        Client = function(player, event)
            local babyLullaby = SoundController:GetSound("BabyLullaby")
            local babySoundEffect = SoundController:GetSound("BabySoundEffect")
            babyLullaby:FadeOut()
            babySoundEffect:FadeOut():andThen(function()
                DialogueController:PlayLine("381238")
                SoundController:RemoveSound("BabyLullaby")
                SoundController:RemoveSound("BabySoundEffect")
                task.wait(0.5)
                Soundly.CreateSound(workspace.GameSounds, SoundProperties.SuddenBeat):PlayOnce()
            end)
        end
    },

    BabyCribTryingToExit = {
        Server = function(player, event, triggerPart)
            if TriggerService:IsTriggered(event) then return end
            TriggerService:AddTriggered(event)
            triggerPart:SetAttribute("Triggerable", false)
            TriggerService.Client.TriggerClientCallback:FireAll(player, event)
        end,

        Client = function(player, event)
            local thisPositionParts = PositionParts.CribRoom
            local cribRoomDoor = DoorsFolder.Door16

            local lightFlickering do
                local lightFlickeringProperties = TableUtil.CopyShallow(SoundProperties.LightFlickering)
                lightFlickeringProperties.Looped = false
                lightFlickering = Soundly.CreateSound(workspace.GameSounds, lightFlickeringProperties)
            end

            DialogueController:PlayLine("312793")
            task.wait(2)
            lightFlickering:PlayOnce()
            LightController:TurnOff()
            task.wait(1)

            InputController:DisablePlayerControls()
            CharacterController:SetCharacterCFrame(thisPositionParts.PlayerPosition.CFrame)
            CameraController:Scriptable()
            cribRoomDoor.AlphexusPrompt:SetAttribute("Enabled", false)

            local scareModel = ScareModels.ScareModel2:Clone()
            scareModel:SetPrimaryPartCFrame(thisPositionParts.ScareModelPosition.CFrame)
            scareModel.Parent = GameObjects

            task.wait(2)
            LightController:TurnOn()
            CameraController:Reset()
            InputController:EnablePlayerControls()
            cribRoomDoor.AlphexusPrompt:SetAttribute("Enabled", true)
            CharacterController:CacheConnection("ScaryModelFacingCheck", CharacterController:WhenCharacterFaces(scareModel, function()
                TriggerController:TriggerOnServer("BabyCribFacedScaryModel")
            end))
        end
    },

    BabyCribFacedScaryModel = {
        Server = function(player, event)
            if TriggerService:IsTriggered(event) then return end
            TriggerService:AddTriggered(event)
            TriggerService.Client.TriggerClientCallback:FireAll(player, event)
        end,

        Client = function(player)
            local scareModel = GameObjects.ScareModel2
            local breatheGhostEerieSound = Soundly.CreateSound(workspace.GameSounds, SoundProperties.BreatheGhostEerie)
            local swooshSound = Soundly.CreateSound(workspace.GameSounds, SoundProperties.GhostSwoosh)

            CharacterController:DisconnectConnection("ScaryModelFacingCheck"  )

            breatheGhostEerieSound:Play()
            if not CharacterController:IsCharacterFacing(scareModel) then
                InputController:DisablePlayerControls()
                CameraController:Scriptable()
                local lookAtTween = CameraController:TweenCamera(CFrame.lookAt(CameraController.Camera.CFrame.Position, scareModel.PrimaryPart.Position), 2)
                lookAtTween.Completed:Connect(function()
                    lookAtTween:Destroy()
                    CameraController:Reset()
                    InputController:EnablePlayerControls()
                end)
            end

            local tiltModelTween = TweenService:Create(scareModel.PrimaryPart, TweenInfo.new(2, Enum.EasingStyle.Linear), {
                CFrame = scareModel.PrimaryPart.CFrame * CFrame.Angles(math.rad(-45), 0, 0)
            })
            local forwardTween = TweenService:Create(scareModel.PrimaryPart, TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                CFrame = (scareModel.PrimaryPart.CFrame * CFrame.Angles(math.rad(-45), 0, 0)) + Vector3.new(15, 0, 0)
            })

            tiltModelTween:Play()
            tiltModelTween.Completed:Wait()
            forwardTween:Play()
            swooshSound:PlayOnce()
            forwardTween.Completed:Wait()
            scareModel:Destroy()
            TriggerController:TriggerOnServer("BabyCribStartPuzzle")
        end
    },

    BabyCribStartPuzzle = {
        Server = function(player, event)
            if TriggerService:IsTriggered(event) then return end
            TriggerService:AddTriggered(event)
            TriggerService.Client.TriggerClientCallback:FireAll(player, event)
            task.wait(2)
            RuntimeInstances.CribRoom.Parent = GameObjects
            BlockPuzzle:Start()
            task.wait(1)
            DialogueService:PlayLineAll("3812790")
            ObjectivesService:AddObjective("6")
        end,

        Client = function(player)
            LightController:ChangeColor({20, 21, 23, 25, 8, 9}, Color3.fromRGB(255, 0, 0), TweenInfo.new(2))
        end
    }
}