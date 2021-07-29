local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local CAR_TWEEN_INFO = TweenInfo.new(30, Enum.EasingStyle.Linear)
local CAR_STEERING_WHEEL_TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Linear)
local RADIO_SIGNAL_GONE_TIMING = 1.5
local MONSTER_SPAWN_TIMING = 3

local Player
local Mouse

local Knit = require(ReplicatedStorage.Knit)
local Soundly = require(ReplicatedStorage.Soundly)
local SoundProperties = require(ReplicatedStorage.SoundProperties)
local CEffect
local CameraShaker

local TriggerService
local CharacterController
local CameraController
local DialogueController
local UIController
local SoundController

if RunService:IsServer() then
    TriggerService = Knit.Services.TriggerService
else
    CharacterController = Knit.Controllers.CharacterController
    CameraController = Knit.Controllers.CameraController
    UIController = Knit.Controllers.UIController
    SoundController = Knit.Controllers.SoundController
    DialogueController = Knit.Controllers.DialogueController
    CEffect = require(ReplicatedStorage.Cutscene).Effect
    CameraShaker = require(ReplicatedStorage.CameraShaker)
    Player = Players.LocalPlayer
    Mouse = Player:GetMouse()
end

local CarSceneFolder = workspace.Building.CarScene
local HopsitalSceneFolder = workspace.Building.Hospital
local Camera = workspace.CurrentCamera

local CamShake

local currentCamCFrame
local CameraAngle = CFrame.Angles(0, 0, 0)

local StopCar = false

local function SetupCamera(part)
    local scale = 500

    RunService.RenderStepped:Connect(function()
        local Center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local Angle = CFrame.Angles(-((Mouse.Y-Center.Y)/scale), -((Mouse.X-Center.X)/scale), 0)
        CameraAngle = Angle
    end)
end

local function SetupSounds()
    return {
        RadioTalking = Soundly.CreateSound(workspace.GameSounds, SoundProperties.Intro.RadioTalking),
        RadioNoSignal = Soundly.CreateSound(workspace.GameSounds, SoundProperties.Intro.RadioNoSignal),
        StormAmbience = Soundly.CreateSound(workspace.GameSounds, SoundProperties.Intro.StormAmbience),
        CarEngine = Soundly.CreateSound(workspace.GameSounds, SoundProperties.Intro.CarEngine),
        CryingGirl = Soundly.CreateSound(workspace.GameSounds, SoundProperties.CryingGirl),
        SuddenImpact = Soundly.CreateSound(workspace.GameSounds, SoundProperties.SuddenImpact),
        CarCrash = Soundly.CreateSound(workspace.GameSounds, SoundProperties.Intro.CarCrash),
        PoliceSirens = Soundly.CreateSound(workspace.GameSounds, SoundProperties.Intro.PoliceSirens),
        HospitalShortBeep = Soundly.CreateSound(workspace.GameSounds, SoundProperties.Intro.HospitalShortBeep),
        HospitalFlatlineBeep = Soundly.CreateSound(workspace.GameSounds, SoundProperties.Intro.HospitalFlatlineBeep)
    }
end

local function RemoveSounds(sounds)
    for _,v in pairs(sounds) do
        v:Stop()
        v:Destroy()
        v = nil
    end
end

local function PoliceLights()
    coroutine.wrap(function()
        local toChange = CarSceneFolder.Car.PoliceLights.Red
        for i = 1, 200 do
            toChange.SurfaceLight.Enabled = false
            toChange = toChange == CarSceneFolder.Car.PoliceLights.Red and CarSceneFolder.Car.PoliceLights.Blue or CarSceneFolder.Car.PoliceLights.Red
            toChange.SurfaceLight.Enabled = true
            wait(0.1)
        end
        CarSceneFolder.Car.PoliceLights.Red.SurfaceLight.Enabled = false
        CarSceneFolder.Car.PoliceLights.Blue.SurfaceLight.Enabled = false
    end)()
end

local function MonsterAppearsInFrontOfCar()
    local car = CarSceneFolder.Car
    local monsterClone = workspace.Monsters.RegularMonster:Clone()
    monsterClone.PrimaryPart.Anchored = true
    monsterClone.Parent = workspace
    monsterClone:SetPrimaryPartCFrame(car.PrimaryPart.CFrame * CFrame.new(0, 1, -12) * CFrame.Angles(0, math.rad(180), 0))
    wait(1)
    monsterClone:Destroy()
end

local function MoveCar()
    local STUDS = 5000
    local carStart = CarSceneFolder.Car.Center.CFrame
    local camPartStart = CarSceneFolder.CameraPart.CFrame
    currentCamCFrame = camPartStart

    CamShake = CameraShaker.new(Enum.RenderPriority.Camera.Value-1, function(shakeCf)
        Camera.CFrame = currentCamCFrame * CameraAngle * shakeCf
    end) 
    CamShake:Start()
    -- local conn = RunService.Heartbeat:Connect(function()
    --     Camera.CFrame = currentCamCFrame * CameraAngle
    -- end)

    coroutine.wrap(function()
        for i = 1, STUDS do
            if StopCar then break end
            local carGoal = carStart * CFrame.new(0, 0, -STUDS)
            local camGoal = camPartStart * CFrame.new(0, 0, -STUDS)
            for a = 0, 1, 0.00000007 do
                if StopCar then break end
                CarSceneFolder.Car.Center.CFrame = CarSceneFolder.Car.Center.CFrame:Lerp(carGoal, a)
                currentCamCFrame = currentCamCFrame:Lerp(camGoal, a)
                RunService.RenderStepped:Wait()
            end
        end
    end)()
end

local function CrashCar()
    coroutine.wrap(function()
        local turnAngle = CFrame.Angles(0, math.rad(45), 0)
        local zGoal = CFrame.new(0, 0, -10)
        local carGoal = CarSceneFolder.Car.PrimaryPart.CFrame * turnAngle * zGoal
        local camGoal = currentCamCFrame * turnAngle * zGoal
        
        for a = 0, 1, 0.001 do
            if StopCar then break end
            CarSceneFolder.Car.Center.CFrame = CarSceneFolder.Car.Center.CFrame:Lerp(carGoal, a)
            currentCamCFrame = currentCamCFrame:Lerp(camGoal, a)
            RunService.RenderStepped:Wait()
        end

        for _, v in pairs(CarSceneFolder.Car.FirePart:GetChildren()) do
            if v:IsA("ParticleEmitter") then
                v.Enabled = true
            end
        end
    end)()
end

return {
    Server = function(player, event, triggerPart)
        TriggerService.Client.TriggerClientCallback:Fire(player, player, event)
    end,

    Client = function(player)
        --player:RequestStreamAroundAsync(Vector3.new(-103.591, 8.947, -773.256))
        UIController:DisableCoreUI()
        SoundController:SilenceCharacter()
        CameraController:Scriptable(CarSceneFolder:WaitForChild("CameraPart").CFrame)
        local cameraRotConnection = SetupCamera(CarSceneFolder.CameraPart)
        local sounds = SetupSounds()
        sounds.RadioTalking:Play()
        sounds.StormAmbience:Play()
        sounds.CarEngine:Play()
        local cameraConnection = MoveCar()
        wait(5)
        DialogueController:PlayLine("302916")
        DialogueController:PlayLine("849122")
        DialogueController:PlayLine("578913")
        DialogueController:PlayLine("409821", function() 
            wait(RADIO_SIGNAL_GONE_TIMING)
            sounds.RadioTalking:Stop()
            sounds.RadioNoSignal:Play()
        end)
        DialogueController:PlayLine("380212")
        wait(2)
        sounds.CryingGirl:Play()
        wait(1)
        DialogueController:PlayLine("873012")
        DialogueController:PlayLine("7389021")
        DialogueController:PlayLine("348021")
        DialogueController:PlayLine("932112")
        DialogueController:PlayLine("893212")
        DialogueController:PlayLine("820132")
        wait(MONSTER_SPAWN_TIMING)
        -- monster appears in front of windshield --
        StopCar = true
        sounds.CryingGirl:Stop()
        sounds.SuddenImpact:Play()
        coroutine.wrap(MonsterAppearsInFrontOfCar)()
        wait(0.4)
        sounds.CarCrash:Play()
        StopCar = false
        CrashCar()
        wait(0.5)
        CamShake:Shake(CameraShaker.Presets.Explosion)
        DialogueController:PlayLine("834012")
        StopCar = true
        wait(0.3)
        CameraController:TweenBlur(12, 1)
        wait(2)
        CameraController:TweenBlur(4, 1)
        wait(1)
        CameraController:TweenBlur(13, 1)
        wait(1)
        CameraController:TweenBlur(6, 1)
        CEffect.new("Fade", "In"):Start()
        wait(1)
        sounds.PoliceSirens:Play()
        wait(3)
        PoliceLights()
        CEffect.new("Fade", "Out"):Start()
        CameraController:TweenBlur(7, 2)
        wait(2)
        CEffect.new("Fade", "In"):Start()
        wait(1)
        -- hospital scene --
        sounds.PoliceSirens:FadeOut()
        sounds.PoliceSirens:Stop()
        sounds.HospitalShortBeep:Play()
        currentCamCFrame = HopsitalSceneFolder.Cam1.CFrame
        wait(3)
        CEffect.new("Fade", "Out"):Start()
        CameraController:TweenBlur(0, 2)
        for i = 1, 2, 0.01 do -- make beeping faster
            sounds.HospitalShortBeep:SetProperty("PlaybackSpeed", i)
            wait(0.01)
        end
        CEffect.new("Fade", "In"):Start()
        wait(2)
        sounds.HospitalShortBeep:Stop()
        sounds.HospitalFlatlineBeep:Play()
        CamShake:Stop()
        CamShake = nil
        Camera.CFrame = HopsitalSceneFolder.Cam2.CFrame
        wait(2)
        CEffect.new("Fade", "Out"):Start()
        wait(1)
        CameraController:TweenCamera(HopsitalSceneFolder.Cam3.CFrame, 1)
        local crossTween = TweenService:Create(HopsitalSceneFolder.Cross, TweenInfo.new(1), {
            CFrame = HopsitalSceneFolder.Cross.CFrame * CFrame.Angles(math.rad(180), 0, 0)
        })
        wait(2)
        crossTween:Play()
        crossTween.Completed:Wait()
        crossTween:Destroy()
        wait(1)
        sounds.HospitalFlatlineBeep:Stop()
        sounds.HospitalShortBeep:SetProperty("PlaybackSpeed", 1)
        sounds.HospitalShortBeep:Play()
        wait(2)
        CEffect.new("Fade", "In"):Start()
        wait(1)
        RemoveSounds()
    end
}