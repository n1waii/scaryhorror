local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local TEXT_TWEEN_INFO = TweenInfo.new(1, Enum.EasingStyle.Linear)
local TEXT_TRANSITION_TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Linear)

local Roact = require(script.Parent.Parent.Roact)
local RoactRodux = require(script.Parent.Parent.RoactRodux)

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local e = Roact.createElement
local Dialogue = Roact.PureComponent:extend("Dialogue")

function Dialogue:init()
    self.DialogueRef = Roact.createRef()
    self:setState({
        Hide = true,
        Text = "No text",
        NextText = nil
    })
end

function Dialogue:render()
    if self.state.Hide then return end
    return e("TextLabel", {
        [Roact.Ref] = self.DialogueRef,
        AnchorPoint = Vector2.new(0.5, 0.5),
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.9),
        Size = UDim2.fromScale(0.845, 0.15),
        Font = Enum.Font.SourceSansBold,
        Text = self.state.Text,
        TextColor3 = Color3.new(1, 1, 1),
        TextTransparency = 1,
        TextSize = 25,
        TextWrapped = true
    })
end

function Dialogue:TweenIn()
    local textLabel = self.DialogueRef:getValue()
    local tween = TweenService:Create(textLabel, TEXT_TWEEN_INFO, {
        TextTransparency = 0
    })
    tween.Completed:Connect(function()
        tween:Destroy()
    end)
    tween:Play()
end

function Dialogue:TweenOut()
    local textLabel = self.DialogueRef:getValue()
    local tween = TweenService:Create(textLabel, TEXT_TWEEN_INFO, {
        TextTransparency = 1
    })
    tween.Completed:Connect(function()
        tween:Destroy()
        self:setState({
            Hide = true,
            NextText = nil
        })
    end)
    tween:Play()
end

function Dialogue:TextTransitionOut(newText)
    local textLabel = self.DialogueRef:getValue()
    local tween = TweenService:Create(textLabel, TEXT_TRANSITION_TWEEN_INFO, {
        TextTransparency = 1
    })
    tween.Completed:Connect(function()
        self:setState({
            Text = newText,
            NextText = newText
        })
        tween:Destroy()
    end)
    tween:Play()
end

function Dialogue:TextTransitionIn(newText)
    local textLabel = self.DialogueRef:getValue()
    local tween = TweenService:Create(textLabel, TEXT_TRANSITION_TWEEN_INFO, {
        TextTransparency = 0
    })
    tween.Completed:Connect(function()
        tween:Destroy()
    end)
    tween:Play()
end

function Dialogue:didUpdate(lastProps, lastState)
    if self.state.Hide and self.props.isShowing then
        self:setState({
            Hide = false,
            Text = self.props.Text
        })
    elseif not self.state.Hide and lastState.Hide then
        -- there wasn't an old text so we can just tween in
        self:TweenIn()
    elseif not self.state.Hide and not self.props.isShowing then
        -- text is done showing so we can tween out
        self:TweenOut()
    elseif not self.state.Hide and self.state.Text ~= self.props.Text and self.props.Text ~= nil then
        -- text is being changed
        self:TextTransitionOut(self.props.Text)
    elseif not self.state.Hide and self.state.NextText == lastProps.Text then
        -- text has been changed and we can transition back in with the new text
        self:TextTransitionIn()
    end
end

Dialogue = RoactRodux.connect(
    function(state, props)
        return {
            Text = state.Dialogue.Text,
            isShowing = state.Dialogue.Enabled
        }
    end
)(Dialogue)

return Dialogue