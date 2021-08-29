local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ROTATE_HANDLE_TWEEN_INFO = TweenInfo.new(6.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
local SPRING_OUT_TWEEN_INFO = TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
local GameObjects = workspace.GameObjects

local Soundly = require(ReplicatedStorage.Soundly)
local SoundProperties = require(ReplicatedStorage.SoundProperties)

local Spring = require(ReplicatedStorage.Physics.Spring)

local Knit = require(ReplicatedStorage.Knit)
local JackBoxController = Knit.CreateController {
    Name = "JackBoxController"
}

function JackBoxController:PromptCallback(proximityPart)
    local JackBoxService = Knit.GetService("JackBoxService")
    if JackBoxService:IsBoxOpenable(proximityPart) then
        self:OpenJackInTheBox()
    end
end

function JackBoxController:OpenJackInTheBox()
    local JackBoxService = Knit.GetService("JackBoxService")
    local boxModel = GameObjects.CribRoom.JackInTheBox
    local song = Soundly.CreateSound(boxModel, SoundProperties.JackInTheBox)
    local handleTween1 = TweenService:Create(boxModel.Handle.PrimaryPart, ROTATE_HANDLE_TWEEN_INFO, {
        CFrame = boxModel.Handle.PrimaryPart.CFrame * CFrame.Angles(math.pi, 0, 0)
    })
    local handleTween2 = TweenService:Create(boxModel.Handle.PrimaryPart, ROTATE_HANDLE_TWEEN_INFO, {
        CFrame = boxModel.Handle.PrimaryPart.CFrame * CFrame.Angles(math.pi*2, 0, 0)
    })
    local springOutTween = TweenService:Create(boxModel.Top.PrimaryPart, SPRING_OUT_TWEEN_INFO, {
        CFrame = boxModel.Top.PrimaryPart.CFrame + Vector3.new(0, 2.25, 0)
    })
    handleTween1:Play()
    handleTween1.Completed:Connect(function()
        handleTween1:Destroy()
        handleTween2:Play()
    end)

    song:PlayOnce():andThen(function()
        springOutTween:Play()
        springOutTween.Completed:Wait()
        JackBoxService.SetItemRetrievable:Fire()
    end)
end

return JackBoxController