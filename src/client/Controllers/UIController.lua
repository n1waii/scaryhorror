local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local ClientModules = script.Parent.Parent.Modules
local UIComponentFolder = ClientModules.UIComponents

local UIComponents = {
    StaminaBar = require(UIComponentFolder.StaminaBar),
    Cursor = require(UIComponentFolder.Cursor),
    ProximityPrompt = require(UIComponentFolder.ProximityPrompt),
    Dialogue = require(UIComponentFolder.Dialogue),
    Objectives = require(UIComponentFolder.Objectives),
    Keypad = require(UIComponentFolder.Keypad),
    Inventory = require(UIComponentFolder.Inventory)
}

local Knit = require(ReplicatedStorage.Knit)
local Roact = require(ClientModules.Roact)
local RoactRodux = require(ClientModules.RoactRodux)

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Mouse = Player:GetMouse()

local UIController = Knit.CreateController {
    Name = "UIController",
    Mounted = {}
}

function UIController:EnableCoreUI()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
end

function UIController:DisableCoreUI()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end

function UIController:EnableUI()
    Knit.Controllers.StateController.Store:dispatch({
        type = "SetUIDisabled",
        Disabled = false
    })
    self:EnableCoreUI()
end

function UIController:DisableUI()
    Knit.Controllers.StateController.Store:dispatch({
        type = "SetUIDisabled",
        Disabled = true
    })
    self:DisableCoreUI()
end

function UIController:Mount(componentName)
    assert(UIComponents[componentName] ~= nil, "Trying to mount invalid component.")
    self.Mounted[componentName] = Roact.mount(
        Roact.createElement(UIComponents[componentName]),
        PlayerGui,
        componentName
    )
end

function UIController:Unmount(componentName)
    if self.Mounted[componentName] then
        Roact.unmount(self.Mounted[componentName])
        self.Mounted[componentName] = nil
    end
end

function UIController:KnitStart()
    local function mainUI(props)
        return Roact.createElement("ScreenGui", {
            ResetOnSpawn = false,
            Enabled = props.Enabled,
            IgnoreGuiInset = true
        }, {
            StaminaBar = Roact.createElement(UIComponents.StaminaBar),
            Cursor = Roact.createElement(UIComponents.Cursor),
            ProximityPrompt = Roact.createElement(UIComponents.ProximityPrompt),
            Dialogue = Roact.createElement(UIComponents.Dialogue),
            Objectives = Roact.createElement(UIComponents.Objectives),
            Keypad = Roact.createElement(UIComponents.Keypad),
            Inventory = Roact.createElement(UIComponents.Inventory)
        })
    end

    mainUI = RoactRodux.connect(
        function(state, props)
            return {
                Enabled = not state.UIDisabled
            }
        end
    )(mainUI)

    local function mainApp()
        return Roact.createElement(RoactRodux.StoreProvider, {
            store = Knit.Controllers.StateController.Store
        }, {
            MainUI = Roact.createElement(mainUI)
        })
    end
    
    wait(2)
    Roact.mount(Roact.createElement(mainApp), PlayerGui)
    Mouse.Icon = "rbxassetid://5604850266" -- fully transparent mouse icon

    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

end

return UIController