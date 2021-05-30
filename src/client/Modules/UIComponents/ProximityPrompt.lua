local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local PROXIMITY_DISTANCE = 10

local Roact = require(script.Parent.Parent.Roact)
local RoactRodux = require(script.Parent.Parent.RoactRodux)

local Player = Players.LocalPlayer

local e = Roact.createElement
local ProximityPrompt = Roact.PureComponent:extend("ProximityPrompt")

local function map(value, minA, maxA, minB, maxB)
    return (maxB - minB) * (value - minA) / (maxA - minA) + minB
end

local function UICorner(props)
    return e("UICorner", {
        CornerRadius = props.CornerRadius or UDim.new(0.3, 0)
    })
end

function ProximityPrompt:init()
    self.PromptRef = Roact.createRef()
    self:setState({
        Hide = true,
        Mount = nil,
        ActionText = "_action_text"
    })
end

function ProximityPrompt:render()
    if self.state.Hide then return nil end
    return e("BillboardGui", {
        [Roact.Ref] = self.PromptRef,
        Adornee = self.state.Mount,
        AlwaysOnTop = true,
        LightInfluence = 0,
        MaxDistance = math.huge,
        ResetOnSpawn = false,
        Size = UDim2.fromScale(4, 1)
    }, {
        Main = e("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1, 1)
        }, {
            UIAspectRatioConstraint = e("UIAspectRatioConstraint", { AspectRatio = 3.768 }),
            ActionFrame = e("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.new(),
                BackgroundTransparency = 0.3,
                Position = UDim2.fromScale(0.65, 0.5),
                Size = UDim2.fromScale(0.6, 0.5)
            }, {
                UICorner = e(UICorner),
                ActionText = e("TextLabel", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromScale(0.8, 0.7),
                    Font = Enum.Font.SourceSans,
                    Text = self.state.Mount:GetAttribute("ActionText"),
                    TextColor3 = Color3.new(1, 1, 1),
                    TextScaled = true
                })
            }),
            E_Frame = e("Frame", {
                BackgroundColor3 = Color3.new(),
                BackgroundTransparency = 0.3,
                Position = UDim2.fromScale(0.05, 0),
                Size = UDim2.fromScale(0.25, 1)
            }, {
                UICorner = e(UICorner),
                TextButton = e("TextButton", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(0, 0),
                    Size = UDim2.fromScale(1, 1),
                    Font = Enum.Font.SourceSansSemibold,
                    Text = "E",
                    TextColor3 = Color3.new(1, 1, 1),
                    TextScaled = true
                })
            }),
        })
    })
end

function ProximityPrompt:didUpdate(lastProps, lastState)
    if self.state.Hide and self.props.isShowing then
        return self:setState({
            Hide = false,
            Mount = self.props.Mount,
            ActionText = self.props.ActionText
        })
    elseif not self.state.Hide and lastState.Hide then
        self.RunServiceConnection = RunService.RenderStepped:Connect(function()
            if not self.state.Mount then return end
            local character = Player.Character
            if character then
                local humRP = character:FindFirstChild("HumanoidRootPart")
                if not humRP then return end
                local distance = (humRP.Position-self.state.Mount.Position).Magnitude
                local proximityPrompt = self.PromptRef:getValue()
                if proximityPrompt then
                    local textTransparency = map(distance, 0, PROXIMITY_DISTANCE, 0, 0.9)
                    local bgTransparency = map(distance, 0, PROXIMITY_DISTANCE, 0, 0.8)
                    
                    proximityPrompt.Main.ActionFrame.ActionText.Text = self.state.Mount:GetAttribute("ActionText")
                    proximityPrompt.Main.ActionFrame.BackgroundTransparency = bgTransparency
                    proximityPrompt.Main.E_Frame.BackgroundTransparency = bgTransparency
                    proximityPrompt.Main.ActionFrame.ActionText.TextTransparency = textTransparency
                    proximityPrompt.Main.E_Frame.TextButton.TextTransparency = textTransparency
                end
            end
        end)
    elseif not self.state.Hide and not self.props.isShowing then
        self.RunServiceConnection:Disconnect()
        self.RunServiceConnection = nil
        return self:setState({
            Hide = true,
            Mount = nil
        })
    end
end

ProximityPrompt = RoactRodux.connect(
    function(state, props)
        return {
            Mount = state.ProximityPrompt.Mount,
            isShowing = state.ProximityPrompt.Enabled
        }
    end
)(ProximityPrompt)

return ProximityPrompt