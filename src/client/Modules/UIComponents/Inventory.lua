local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local AMOUNT_OF_SLOTS = 32
local ACTIVE_SLOT_BORDER_COLOR = Color3.fromRGB(0, 150, 10)
local INACTIVE_SLOT_BORDER_COLOR = Color3.fromRGB(62, 62, 62)

local Knit  = require(ReplicatedStorage.Knit)

local Roact = require(script.Parent.Parent.Roact)
local RoactRodux = require(script.Parent.Parent.RoactRodux)
local Flipper = require(script.Parent.Parent.Flipper)
local Soundly = require(ReplicatedStorage.Soundly)
local SoundProperties = require(ReplicatedStorage.SoundProperties)
local ItemData = require(ReplicatedStorage.DataModules.Items)

local Player = Players.LocalPlayer

local Inventory = Roact.PureComponent:extend("Inventory")
local InventoryItem = Roact.PureComponent:extend("InventoryItem")
local e = Roact.createElement

local function lerp(a,b,t)
    return a * (1-t) + b * t
end

function InventoryItem:init()
    self.CameraRef = Roact.createRef()
    self.WorldModelRef = Roact.createRef()

    self.SlotMotor = Flipper.SingleMotor.new(0)
	local slotMotorBinding, setSlotMotorBinding = Roact.createBinding(self.SlotMotor:getValue())
	self.SlotMotorBinding = slotMotorBinding

	self.SlotMotor:onStep(setSlotMotorBinding)

    self:setState({
        ItemName = nil
    })
end

function InventoryItem:OnClicked()
    if self.props.ItemData then
        if self.props.EquippedItem == self.state.ItemName then
            Knit.Controllers.InventoryController:TryUnequippingItems()
        else
            Knit.Controllers.InventoryController:TryEquippingItem(self.state.ItemName)
        end
    end
end

function InventoryItem:render()
    local isActive = self.props.EquippedItem and self.state.ItemName == self.props.EquippedItem

    return e("Frame", {
        BackgroundColor3 = Color3.new(),
        BackgroundTransparency = self.SlotMotorBinding:map(function(value)
            return lerp(1, 0.6, value)
        end),
        BorderSizePixel = 0,
        LayoutOrder = self.props.LayoutOrder
    }, {
        UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
            AspectRatio = 1
        }),
        UICorner = e("UICorner", {
            CornerRadius = UDim.new(0.1, 0)
        }),
        UIStroke = e("UIStroke", {
            Color = isActive and ACTIVE_SLOT_BORDER_COLOR or INACTIVE_SLOT_BORDER_COLOR,
            Thickness = 1,
            Transparency = self.SlotMotorBinding:map(function(value)
                return lerp(1, 0, value)
            end)
        }),
        ViewportFrame = e("ViewportFrame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0),
            Size = UDim2.fromScale(1, 1),
            CurrentCamera = self.CameraRef,
            ImageTransparency = self.SlotMotorBinding:map(function(value)
                return lerp(1, 0, value)
            end)
        }, {
            WorldModel = e("WorldModel", {
                [Roact.Ref] = self.WorldModelRef
            }),
            Camera = e("Camera", {
                [Roact.Ref] = self.CameraRef,
            })
        }),
        ClickButton = e("TextButton", {
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.fromScale(1, 1),
            Modal = true,
            Text = "",
            [Roact.Event.MouseButton1Click] = function()
                self:OnClicked()
            end
        })
    })
end

function InventoryItem:didMount()
    local camera = self.CameraRef:getValue()
    local worldModel = self.WorldModelRef:getValue()
    local itemData = self.props.ItemData

    if itemData then
        local model = itemData and itemData.Model:Clone()
        model.Parent = worldModel
        camera.CFrame = itemData and (model.PrimaryPart.CFrame * itemData.CameraCFrame)
    end

    self.SlotMotor:setGoal(Flipper.Linear.new(1, {
        velocity = 3
    }))

    self:setState({ 
        ItemName = self.props.ItemData and self.props.ItemData.Name
    })
end

InventoryItem = RoactRodux.connect(
    function(state, props)
        return {
            EquippedItem = state.Inventory.Equipped,
        }
    end
)(InventoryItem)

function Inventory:ItemsFragment()
    local backpackItems = self.props.Items
    local fragment = {}

    for i = 1, AMOUNT_OF_SLOTS do
        local item = backpackItems[i]
        local _thisItemData

        if item then
            _thisItemData = ItemData[item]
        end

        fragment[i] = e(InventoryItem, {
            Active = self.ActiveItem,
            ItemData = _thisItemData,
            LayoutOrder = i
        })
    end

    return Roact.createFragment(fragment)
end

function Inventory:init()
    self.FadeMotor = Flipper.SingleMotor.new(0)
	local fadeMotorBinding, setFadeMotorBinding = Roact.createBinding(self.FadeMotor:getValue())
	self.FadeMotorBinding = fadeMotorBinding

	self.FadeMotor:onStep(setFadeMotorBinding)

    self:setState({
        Hide = true,
        Blur = nil
    })
end

function Inventory:render()
    if self.state.Hide then return end
    
    return e("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0.65, 0.853),
        Position = UDim2.fromScale(0.5, 0.5)
    }, {
        Title = e("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 0.03),
            Size = UDim2.fromScale(1, 0.117),
            Font = Enum.Font.PermanentMarker,
            Text = "Inventory",
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            TextTransparency = self.FadeMotorBinding:map(function(value)
                return lerp(1, 0, value)
            end)
        }),
        Items = e("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.028, 0.142),
            Size = UDim2.fromScale(0.944, 0.858)
        }, {
            UIGridLayout = e("UIGridLayout", { 
                CellPadding = UDim2.fromScale(0.01, 0.01),
                CellSize = UDim2.fromScale(0.105, 0.2),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center
            }),
            Roact.createElement(function()
                return self:ItemsFragment()
            end)
        })
    })
end

function Inventory:didUpdate(lastProps, lastState)
    print(self.props.EquippedItem)
    if self.state.Hide and self.props.isShowing then
        self:setState({
            Hide = false,
            Blur = Instance.new("BlurEffect")
        })
    elseif not self.state.Hide and lastState.Hide then
        -- fade in
        self.FadeMotor:setGoal(Flipper.Linear.new(1, {
            velocity = 3
        }))
        self.state.Blur.Size = 8
        self.state.Blur.Parent = Lighting
    elseif not self.props.isShowing and not self.state.Hide then
        self.state.Blur:Destroy()
        self:setState({
            Hide = true,
            Blur = nil
        })
    end
end

Inventory = RoactRodux.connect(
    function(state, props)
        return {
            isShowing = state.Inventory.Enabled,
            Items = state.Inventory.Items,
            ItemCount = state.Inventory.ItemCount
        }
    end
)(Inventory)

return Inventory