local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local DoorOpenTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
local DoorCloseTweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local Knit = require(ReplicatedStorage.Knit) 
local DoorController = Knit.CreateController {
    Name = "DoorController",
    LockCallbackCooldown = false
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

function DoorController:TryKeypadDoor(keycode)
    local DoorService = Knit.GetService("DoorService")
    DoorService.OpenKeypadDoor:Fire(keycode)
    Knit.Controllers.StateController.Store:dispatch({
        type = "SetKeypadEnabled",
        Enabled = false
    })
end

function DoorController:LockDoorCallback()
    if self.LockCallbackCooldown then return end
    self.LockCallbackCooldown = true
    Knit.Controllers.DialogueController:PlayLine("37219")
    wait(2)
    self.LockCallbackCooldown = false
end

function DoorController:KnitStart()
    local DoorService = Knit.GetService("DoorService")

    DoorService.CloseDoor:Connect(function(...)
        self:CloseDoor(...)
    end)

    DoorService.OpenDoor:Connect(function(...)
        self:OpenDoor(...)
    end)

    DoorService.LockedDoorCallback:Connect(function()
        self:LockDoorCallback()
    end)

    DoorService.PromptKeypad:Connect(function()
        Knit.Controllers.StateController.Store:dispatch({
            type = "SetKeypadEnabled",
            Enabled = true
        })
    end)
end

return DoorController
