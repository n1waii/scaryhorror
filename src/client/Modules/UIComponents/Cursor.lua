local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Roact = require(script.Parent.Parent.Roact)
local RoactRodux = require(script.Parent.Parent.RoactRodux)

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local e = Roact.createElement
local Cursor = Roact.PureComponent:extend("Cursor")

function Cursor:init()
    self.CursorFrameRef = Roact.createRef()
end

function Cursor:render()
    return e("Frame", {
        [Roact.Ref] = self.CursorFrameRef,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = self.props.Active and 0 or 1,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.007, 0.02)
    }, {
        UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
            AspectRatio = 1,
            AspectType = Enum.AspectType.FitWithinMaxSize,
            DominantAxis = Enum.DominantAxis.Width
        }),
        UICorner = e("UICorner", {
           CornerRadius = UDim.new(1, 0)
        }),
        UIStroke = e("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.new(1, 1, 1),
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1
        }),
        UIScale = e("UIScale")
    })
end

function Cursor:didMount()
    local cursorFrame = self.CursorFrameRef:getValue()
    RunService.RenderStepped:Connect(function()
        cursorFrame.Position = UDim2.fromOffset(Mouse.X, Mouse.Y)
    end)
end

Cursor = RoactRodux.connect(
    function(state, props)
        return {
            Active = state.Cursor.Active
        }
    end
)(Cursor)

return Cursor