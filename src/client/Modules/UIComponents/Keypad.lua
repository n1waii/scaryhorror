local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local KEYPAD_MAX_PINCODE_LENGTH = 5

local Knit  = require(ReplicatedStorage.Knit)

local Roact = require(script.Parent.Parent.Roact)
local RoactRodux = require(script.Parent.Parent.RoactRodux)
local Flipper = require(script.Parent.Parent.Flipper)
local Soundly = require(ReplicatedStorage.Soundly)
local SoundProperties = require(ReplicatedStorage.SoundProperties)

local Keypad = Roact.PureComponent:extend("Keypad")
local e = Roact.createElement

local function KeyComponent(props)
    return e("TextButton", {
        BackgroundColor3 = Color3.fromRGB(177, 177, 177),
        Font = Enum.Font.SourceSans,
        Text = props.Text,
        TextColor3 = Color3.fromRGB(52, 52, 52) or props.TextColor3,
        TextSize = 14,
        TextScaled = true,
        LayoutOrder = props.LayoutOrder,
        Modal = true,
        [Roact.Event.MouseButton1Click] = props.MouseButton1Click
    }, {
        UICorner = e("UICorner", {
            CornerRadius = UDim.new(0.2, 0)
        })
    })
end

function Keypad:init()
    self.MainFrameMotor = Flipper.SingleMotor.new(0)
	local mainFrameMotorBinding, setMainFrameMotor = Roact.createBinding(self.MainFrameMotor:getValue())
	self.MainFrameMotorBinding = mainFrameMotorBinding
    self.OutputLabelText, self.UpdateOutputLabelText = Roact.createBinding("")

	self.MainFrameMotor:onStep(setMainFrameMotor)

    self.KeypadButtonSound = Soundly.CreateSound(workspace.GameSounds, SoundProperties.Doors.KeypadButtonPress)

    self:setState({
        Hide = true
    })
end

function Keypad:KeyFragment()
    local keys = {}

    for i = 1, 12 do
        if i ~= 10 or i ~= 12 then
            keys[i] = e(KeyComponent, {
                LayoutOrder = i,
                Text = tostring(i%11),
                MouseButton1Click = function()
                    self.KeypadButtonSound:Play()
                    if #self.OutputLabelText:getValue() < KEYPAD_MAX_PINCODE_LENGTH then
                        self.UpdateOutputLabelText(self.OutputLabelText:getValue() .. tostring(i))
                    end
                end
            })
        end
    end

    keys[10] = e(KeyComponent, {
        LayoutOrder = 10,
        Text = "E",
        TextColor3 = Color3.fromRGB(71, 139, 39),
        MouseButton1Click = function()
            self.KeypadButtonSound:Play()
            Knit.Controllers.DoorController:TryKeypadDoor(self.OutputLabelText:getValue())
        end
    })

    keys[12] = e(KeyComponent, {
        LayoutOrder = 12,
        Text = "C",
        MouseButton1Click = function()
            local labelText = self.OutputLabelText:getValue()
            self.KeypadButtonSound:Play()
            self.UpdateOutputLabelText(labelText:sub(1, #labelText-1))
        end
    })

    return Roact.createFragment(keys)
end

function Keypad:render()
    if self.state.Hide then return end

    return e("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(52, 52, 52),
        BorderSizePixel = 0,
        Position = self.MainFrameMotorBinding:map(function(value)
            return UDim2.fromScale(0.5, -1):Lerp(UDim2.fromScale(0.5, 0.5), value)
        end),
        Size = UDim2.fromScale(0.191, 0.62)
    }, {
        Title = e("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.069, 0.031),
            Size = UDim2.fromScale(0.866, 0.101),
            Font = Enum.Font.SourceSansBold,
            Text = "Keypad",
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        Output = e("TextLabel", {
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.069, 0.175),
            Size = UDim2.fromScale(0.837, 0.093),
            Font = Enum.Font.SourceSans,
            Text = self.OutputLabelText,
            TextColor3 = Color3.fromRGB(52, 52, 52),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left
        }, {
            UICorner = e("UICorner", {
                CornerRadius = UDim.new(0.3, 0)
            })
        }),
        Keys = e("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.069, 0.298),
            Size = UDim2.fromScale(0.866, 0.677)
        }, {
            UIGridLayout = e("UIGridLayout", {
                CellPadding = UDim2.fromScale(0.06, 0.04),
                CellSize = UDim2.fromScale(0.27, 0.22),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            e(function()
                return self:KeyFragment()
            end)
        }),
        UICorner = e("UICorner", {
            CornerRadius = UDim.new(0.02, 0)
        }),
        UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
            AspectRatio = 0.67
        })
    })
end

function Keypad:didUpdate(lastProps, lastState)
    if self.state.Hide and self.props.isShowing then
        self:setState({
            Hide = false
        })
    elseif not self.state.Hide and lastState.Hide then
        -- animate main frame in
        self.UpdateOutputLabelText("")
        self.MainFrameMotor:setGoal(Flipper.Linear.new(1, {
            velocity = 3
        }))
    elseif not self.props.isShowing and not self.state.Hide then
        -- animate main frame out
        local conn; conn = self.MainFrameMotor:onComplete(function()
            conn:disconnect()
            self:setState({
                Hide = true
            })
        end)

        self.MainFrameMotor:setGoal(Flipper.Linear.new(0, {
            velocity = 3
        }))
    end
end

Keypad = RoactRodux.connect(
    function(state, props)
        return {
            isShowing = state.Keypad.Enabled
        }
    end
)(Keypad)

return Keypad