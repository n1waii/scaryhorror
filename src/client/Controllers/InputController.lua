local ControllerService = game:GetService("ControllerService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Knit)
local InputController = Knit.CreateController {
    Name = "InputController",
    KeysDown = {},
    KeyDownListeners = {},
    KeyUpListeners = {},
    MappedKeys = {},
    ControllerCache = {}
}

function InputController:Map(keyCode, callback)
    self.MappedKeys[keyCode] = callback
end

function InputController:Unmap(keyCode)
    self.MappedKeys[keyCode] = nil
end

function InputController:InvokeMapped(keyCode)
    if self.MappedKeys[keyCode] then
        self.MappedKeys[keyCode]()
    end
end

function InputController:UnbindKeyDown(keyCode, index)
    if self.KeyDownListeners[keyCode] and self.KeyDownListeners[keyCode][index]  then
        table.remove(self.KeyDownListeners[keyCode], index)
    end
end

function InputController:UnbindKeyUp(keyCode, index)
    if self.KeyUpListeners[keyCode] and self.KeyUpListeners[keyCode][index]  then
        table.remove(self.KeyUpListeners[keyCode], index)
    end
end

function InputController:WhenKeyDown(keyCode, callback)
    if not self.KeyDownListeners[keyCode] then
        self.KeyDownListeners[keyCode] = {}
    end
    
    local pushIndex = #self.KeyDownListeners[keyCode]+1
    table.insert(self.KeyDownListeners[keyCode], pushIndex, callback)

    return pushIndex
end

function InputController:WhenKeyUp(keyCode, callback)
    if not self.KeyUpListeners[keyCode] then
        self.KeyUpListeners[keyCode] = {}
    end
    
    local pushIndex = #self.KeyUpListeners[keyCode]+1
    table.insert(self.KeyUpListeners[keyCode], pushIndex, callback)

    return pushIndex
end

function InputController:EmitKeyUp(keyCode, ...)
    self.KeysDown[keyCode] = nil
    if not self.KeyUpListeners[keyCode] then return end
    for _,callback in pairs(self.KeyUpListeners[keyCode]) do
        coroutine.wrap(callback)(...)
    end
end

function InputController:EmitKeyDown(keyCode, ...)
    if self.KeysDown[keyCode] or not self.KeyDownListeners[keyCode] then return end
    self.KeysDown[keyCode] = true
    for _,callback in pairs(self.KeyDownListeners[keyCode]) do
        coroutine.wrap(callback)(...)
    end
end

function InputController:DisablePlayerControls()
    for _,controller in pairs(ControllerService:GetChildren()) do
        controller.Parent = nil
        table.insert(self.ControllerCache, controller)
    end
end

function InputController:EnablePlayerControls()
    for _,controller in pairs(self.ControllerCache) do
        controller.Parent = nil
    end
    self.ControllerCache = {}
end

function InputController:GetContextActionService()
    return ContextActionService
end

function InputController:KnitStart()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            self:EmitKeyDown(input.KeyCode, gameProcessed)
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            self:EmitKeyUp(input.KeyCode, gameProcessed)
        end
    end)

    UserInputService.MouseIconEnabled = false
end

return InputController