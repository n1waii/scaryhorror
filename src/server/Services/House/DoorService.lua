local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit) 
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)

local Soundly = require(ReplicatedStorage.Soundly)
local SoundProperties = require(ReplicatedStorage.SoundProperties)

local DoorService = Knit.CreateService {
    Name = "DoorService",
    Client = {
        PromptTriggered = RemoteSignal.new(),
        OpenDoor = RemoteSignal.new(),
        CloseDoor = RemoteSignal.new(),
        OpenKeypadDoor = RemoteSignal.new(),
        PromptKeypad = RemoteSignal.new(),
        LockedDoorCallback = RemoteSignal.new()
    },
    OpenDoors = {}, -- Map<doorModel, Map<String, CFrame>>
    KeypadDoors = {} -- Map<keycode, doorModel>,
}

function DoorService:IsLocked(doorModel)
    return doorModel:GetAttribute("Locked")
end

function DoorService:IsOpen(doorModel)
    return self.OpenDoors[doorModel]
end

function DoorService:LockDoor(doorModel, keyId)
    doorModel:SetAttribute("Locked", true)
    doorModel:SetAttribute("KeyId", keyId)
end

function DoorService:HasKey(doorModel, player)
    local character = player.Character
    if not character then return end
    
    local key = character:FindFirstChild("Key")
    if key and key:GetAttribute("KeyId") == doorModel:GetAttribute("KeyId") then
        return true, key
    end

    for _,tool in pairs(player.Backpack:GetChildren()) do
        if tool.Name == "Key" and tool:GetAttribute("KeyId") == doorModel:GetAttribute("KeyId") then
            return true, tool
        end
    end

    return false
end

function DoorService:OpenDoor(doorModel, charModel)
    self.OpenDoors[doorModel] = {
        CloseCFrame = doorModel.PrimaryPart.CFrame
    }

    local openAngle = CFrame.Angles(0, math.rad(100), 0)
    if charModel then
        local scalar = charModel.HumanoidRootPart.CFrame.LookVector:Dot(doorModel.PrimaryPart.CFrame.LookVector)
        local angle;

        if scalar >= 0 then
            openAngle = CFrame.Angles(0, math.rad(100), 0)
        else
            openAngle = CFrame.Angles(0, math.rad(-100), 0)
        end
    end

    Soundly.CreateSound(doorModel.PrimaryPart, SoundProperties.Doors.DoorOpen):PlayOnce()
    self.Client.OpenDoor:FireAll(doorModel, openAngle)
    doorModel.AlphexusPrompt:SetAttribute("ActionText", "Close door")
end

function DoorService:CloseDoor(doorModel)
    Soundly.CreateSound(doorModel.PrimaryPart, SoundProperties.Doors.DoorClose):PlayOnce()
    self.Client.CloseDoor:FireAll(doorModel, self.OpenDoors[doorModel].CloseCFrame)
    self.OpenDoors[doorModel] = nil
    doorModel.AlphexusPrompt:SetAttribute("ActionText", "Open door")
end

function DoorService:PromptCallback(player, proximityPart)
    if not player.Character then return end
    if not proximityPart:GetAttribute("Triggerable") then return end
    proximityPart:SetAttribute("Triggerable", false)
    local doorModel = proximityPart.Parent
    
    if self.OpenDoors[doorModel] then
        self:CloseDoor(doorModel)
    else
        if self:IsLocked(doorModel) then
            if self:HasKey(doorModel, player) then
                self:OpenDoor(doorModel, player.Character)
            else
                Soundly.CreateSound(doorModel.PrimaryPart, SoundProperties.Doors.DoorLocked):PlayOnce()
                self.Client.LockedDoorCallback:Fire(player)
                
                local trigger = doorModel:GetAttribute("Trigger")
                if trigger then
                    if doorModel:GetAttribute("CanTrigger") then
                        doorModel:SetAttribute("CanTrigger", false)
                        Knit.Services.TriggerService:Trigger(player, trigger)
                    end
                end
            end
        else
            if doorModel:GetAttribute("Keycode") then
                self.Client.PromptKeypad:Fire(player)
            else
                self:OpenDoor(doorModel, player.Character)
            end
        end
    end

    wait(0.9)
    proximityPart:SetAttribute("Triggerable", true)
end

function DoorService:OpenKeypadDoor(keycode, charModel)
    local doorModel = self.KeypadDoors[keycode]
    if doorModel then
        self:OpenDoor(doorModel, charModel)
    end
end

function DoorService:KnitStart()
    for _,doorModel in pairs(workspace.Door:GetChildren()) do
        local keyCode = doorModel:GetAttribute("Keycode")
        if keyCode then
            self.KeypadDoors[keyCode] = doorModel
        end
    end
end

function DoorService:KnitInit()
    self.Client.OpenKeypadDoor:Connect(function(player, keycode)
        if not player.Character then return end
        self:OpenKeypadDoor(keycode, player.Character)
    end)

    self.Client.PromptTriggered:Connect(function(...)
        self:PromptCallback(...)
    end)
end

return DoorService