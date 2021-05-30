local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local DoorOpenTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
local DoorCloseTweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local Knit = require(ReplicatedStorage.Knit) 
local DoorController = Knit.CreateController {
    Name = "DoorController"
}

function DoorController:CloseDoor(doorModel, closedCFrame)
    local tween = TweenService:Create(doorModel.PrimaryPart, DoorCloseTweenInfo, {
        CFrame = closedCFrame
    })
    tween:Play()
    tween.Completed:Wait()
    tween:Destroy()
end

function DoorController:OpenDoor(doorModel, openAngle)
    local tween = TweenService:Create(doorModel.PrimaryPart, DoorOpenTweenInfo, {
        CFrame = doorModel.PrimaryPart.CFrame * openAngle
    })
    tween:Play()
    tween.Completed:Wait()
    tween:Destroy()
end

function DoorController:PromptCallback(proximityPart)
    local DoorService = Knit.GetService("DoorService")
    DoorService.PromptTriggered:Fire(proximityPart)
end

function DoorController:KnitStart()
    local DoorService = Knit.GetService("DoorService")
    
    DoorService.CloseDoor:Connect(function(...)
        self:CloseDoor(...)
    end)

    DoorService.OpenDoor:Connect(function(...)
        self:OpenDoor(...)
    end)
end

return DoorController
