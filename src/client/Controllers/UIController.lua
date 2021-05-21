local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientModules = script.Parent.Parent.Modules
local UIComponentFolder = ClientModules.UIComponents

local UIComponents = {
    StaminaBar = require(UIComponentFolder.StaminaBar),
    Cursor = require(UIComponentFolder.Cursor)
}

local Knit = require(ReplicatedStorage.Knit)
local Roact = require(ClientModules.Roact)
local RoactRodux = require(ClientModules.RoactRodux)

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Mouse = Player:GetMouse()

local UIController = Knit.CreateController {
    Name = "UIController",
    Mounted = {},
    
}

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
    local function mainUI()
        return Roact.createElement("ScreenGui", {
            ResetOnSpawn = false
        }, {
            StaminaBar = Roact.createElement(UIComponents.StaminaBar),
            Cursor = Roact.createElement(UIComponents.Cursor)
        })
    end
    
    local function mainApp()
        return Roact.createElement(RoactRodux.StoreProvider, {
            store = Knit.Controllers.StateController.Store
        }, {
            MainUI = Roact.createElement(mainUI)
        })
    end
    
    Roact.mount(Roact.createElement(mainApp), PlayerGui)
    Mouse.Icon = "rbxassetid://5604850266" -- fully transparent mouse icon
end

return UIController