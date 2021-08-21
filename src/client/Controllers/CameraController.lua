local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Knit)

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Camera = workspace.CurrentCamera

local CameraController = Knit.CreateController {
    Name = "CameraController",
    Connections = {},
    Camera = Camera
}

function CameraController:CameraRotationEffect(scale)
    local DefaultCFrame = Camera.CFrame
    scale = scale or 200

    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        local Center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local MoveVector = Vector3.new((Mouse.X-Center.X)/scale, (Mouse.Y-Center.Y)/scale, 0)
        Camera.CFrame = DefaultCFrame * CFrame.new(DefaultCFrame.Position + MoveVector)
    end))
end

function CameraController:Scriptable(cf)
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CFrame = cf or Camera.CFrame
end

function CameraController:Track(part)
    Camera.CameraType = Enum.CameraType.Track
    Camera.CameraSubject = part
end

function CameraController:Reset()
    Camera.CameraType = Enum.CameraType.Custom
    Camera.CameraSubject = Player.Character.Humanoid
    
    for _,v in pairs(self.Connections) do
        v:Disconnect()
        v = nil
    end
end

function CameraController:TweenCamera(cf, t)
    local tween = TweenService:Create(Camera, TweenInfo.new(t), {
        CFrame = cf
    })
    tween:Play()

    return tween
end

function CameraController:TweenBlur(size, t)
    local tween = TweenService:Create(self.Blur, TweenInfo.new(t), {
        Size = size
    })
    tween:Play()

    return tween
end

function CameraController:KnitStart()
   self.Blur = Instance.new("BlurEffect")
   self.Blur.Size = 0
   self.Blur.Parent = Lighting
end

return CameraController