local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local CabinetOpenTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear)
local CabinetCloseTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local Knit = require(ReplicatedStorage.Knit) 
local CabinetController = Knit.CreateController {
    Name = "CabinetController"
}

function CabinetController:CloseCabinet(cabinetModel, closedCFrame)
    local tween = TweenService:Create(cabinetModel.PrimaryPart, CabinetOpenTweenInfo, {
        CFrame = closedCFrame
    })
    tween:Play()
end

function CabinetController:OpenCabinet(cabinetModel, openAngle)
    local tween = TweenService:Create(cabinetModel.PrimaryPart, CabinetCloseTweenInfo, {
        CFrame = cabinetModel.PrimaryPart.CFrame * openAngle
    })
    tween:Play()
end

function CabinetController:PromptCallback(proximityPart)
    local CabinetService = Knit.GetService("CabinetService")
    CabinetService.PromptTriggered:Fire(proximityPart)
end

function CabinetController:KnitStart()
    local CabinetService = Knit.GetService("CabinetService")

    CabinetService.CloseCabinet:Connect(function(...)
        self:CloseCabinet(...)
    end)

    CabinetService.OpenCabinet:Connect(function(...)
        self:OpenCabinet(...)
    end)
end

return CabinetController
