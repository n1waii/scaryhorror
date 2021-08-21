local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local switch = require(ReplicatedStorage.Util.SwitchStatement)

local Soundly = require(ReplicatedStorage.Soundly)
local SoundProperties = require(ReplicatedStorage.SoundProperties)

local Player = Players.LocalPlayer

local GameObjects = workspace.GameObjects
local LightsFolder = workspace.Building.House.Lights

local Knit = require(ReplicatedStorage.Knit)
local LightController = Knit.CreateController {
    Name = "LightController",
    Lights = {},
    LightNumbers = {},
    DefaultLightColors = {}
}

function LightController:TurnOn(lights)
    lights = lights or self.LightNumbers
    for _,lightNumber in pairs(lights) do
        local surfaceLight = self.Lights[lightNumber]
        surfaceLight.Enabled = true
    end
end

function LightController:TurnOff(lights)
    lights = lights or self.LightNumbers
    for _,lightNumber in pairs(lights) do
        local surfaceLight = self.Lights[lightNumber]
        surfaceLight.Enabled = false
    end
end

function LightController:ChangeColor(lights, color, tweenInfo)
    lights = lights or self.LightNumbers
    for i,lightNumber in pairs(lights) do
        local surfaceLight = self.Lights[lightNumber]
        self.DefaultLightColors[lightNumber] = surfaceLight.Color
        if tweenInfo then
            local t = TweenService:Create(surfaceLight, tweenInfo, {
                Color = color
            })
            t:Play()
            if i == #lights then
                return i
            end
        else
            surfaceLight.Color = color
        end
    end
end

function LightController:ResetColor(lights)
    lights = lights or self.LightNumbers
    for _,lightNumber in pairs(lights) do
        local surfaceLight = self.Lights[lightNumber]
        surfaceLight.Color = self.DefaultLightColors[lightNumber] or Color3.fromRGB(255, 231, 181)
    end
end

function LightController:Flicker(speed, amount, lights)
    lights = lights or self.LightNumbers
    local lightEnabledState = {}
    local flickeringSound = Soundly.CreateSound(Player.Character.HumanoidRootPart, SoundProperties.LightFlickering)
    
    for _, lightNumber in pairs(lights) do
        local surfaceLight = self.Lights[lightNumber]
        lightEnabledState[surfaceLight] = surfaceLight.Enabled
    end

    flickeringSound:Play()
    for i = 1, amount do
        self:TurnOff(lights)
        task.wait(speed)
        self:TurnOn(lights)
        task.wait(speed)
    end
    flickeringSound:Destroy()

    for _, lightNumber in pairs(lights) do
        local surfaceLight = self.Lights[lightNumber]
        surfaceLight.Enabled = lightEnabledState[surfaceLight]
    end
end

function LightController:KnitStart()
    task.wait(10)
    for _,v in pairs(LightsFolder:GetChildren()) do
        local surfaceLight = v:FindFirstChildWhichIsA("SurfaceLight", true)
        if surfaceLight then
            self.Lights[tonumber(v.Name)] = surfaceLight
            table.insert(self.LightNumbers, tonumber(v.Name))
        end
    end
end

return LightController
