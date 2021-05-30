local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit) 
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)

local DoorService = Knit.CreateService {
    Name = "DoorService",
    Client = {
        PromptTriggered = RemoteSignal.new(),
        OpenDoor = RemoteSignal.new(),
        CloseDoor = RemoteSignal.new()
    },
    OpenDoors = {} -- Map<doorModel, Map<String, CFrame>>
}

function DoorService:PromptCallback(player, proximityPart)
    if not player.Character then return end
    if not proximityPart:GetAttribute("Triggerable") then return end
    proximityPart:SetAttribute("Triggerable", false) 
    local doorModel = proximityPart.Parent
    
    if self.OpenDoors[doorModel] then
        -- close
        proximityPart:SetAttribute("ActionText", "open door")
        self.Client.CloseDoor:FireAll(doorModel, self.OpenDoors[doorModel].ClosedCFrame)
        self.OpenDoors[doorModel] = nil
    else
        -- open
        proximityPart:SetAttribute("ActionText", "close door")
        self.OpenDoors[doorModel] = {
            ClosedCFrame = doorModel.PrimaryPart.CFrame
        }
        local scalar = player.Character.HumanoidRootPart.CFrame.LookVector:Dot(doorModel.PrimaryPart.CFrame.LookVector)
        local angle;

        if scalar >= 0 and scalar <= 1 then
            angle = 100
        else
            angle = -100
        end
        
        local openAngle = CFrame.Angles(0, math.rad(angle), 0)
        self.Client.OpenDoor:FireAll(doorModel, openAngle)
    end

    wait(0.9)
    proximityPart:SetAttribute("Triggerable", true) 
end

function DoorService:KnitInit()
    self.Client.PromptTriggered:Connect(function(...)
        self:PromptCallback(...)
    end)
end

return DoorService