local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TAG = "Cabinet"

local Knit = require(ReplicatedStorage.Knit) 
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)

local Soundly = require(ReplicatedStorage.Soundly)
local SoundProperties = require(ReplicatedStorage.SoundProperties)

local CabinetService = Knit.CreateService {
    Name = "CabinetService",
    Client = {
        PromptTriggered = RemoteSignal.new(),
        OpenCabinet = RemoteSignal.new(),
        CloseCabinet = RemoteSignal.new(),
    },
    Cabinets = {},
    OpenCabinets = {}, -- Map<cabinetModel, Map<String, CFrame>>
}

function CabinetService:OpenCabinet(cabinetModel)
    self.OpenCabinets[cabinetModel] = {
        CloseCFrame = cabinetModel.PrimaryPart.CFrame
    }

    local openAngle = CFrame.Angles(
        0,
        math.rad(cabinetModel:GetAttribute("CabinetDirection") == "Right" and 80 or -80),
        0
    )

    Soundly.CreateSound(cabinetModel.PrimaryPart, SoundProperties.Cabinets.CabinetOpen):PlayOnce()
    self.Client.OpenCabinet:FireAll(cabinetModel, openAngle)
    cabinetModel.AlphexusPrompt:SetAttribute("ActionText", "Close cabinet")
end

function CabinetService:CloseCabinet(cabinetModel)
    self.Client.CloseCabinet:FireAll(cabinetModel, self.OpenCabinets[cabinetModel].CloseCFrame)
    self.OpenCabinets[cabinetModel] = nil
    cabinetModel.AlphexusPrompt:SetAttribute("ActionText", "Open cabinet")
    wait(0.2)
    Soundly.CreateSound(cabinetModel.PrimaryPart, SoundProperties.Cabinets.CabinetClose):PlayOnce()
end

function CabinetService:PromptCallback(player, proximityPart)
    if not player.Character then return end
    if not proximityPart:GetAttribute("Triggerable") then return end
    proximityPart:SetAttribute("Triggerable", false)
    local cabinetModel = proximityPart.Parent
    
    if self.Cabinets[cabinetModel] then
        if self.OpenCabinets[cabinetModel] then
            self:CloseCabinet(cabinetModel)
        else
            self:OpenCabinet(cabinetModel)
        end
    end

    wait(0.9)
    proximityPart:SetAttribute("Triggerable", true)
end

function CabinetService:KnitStart()
    for _,cabinetModel in pairs(CollectionService:GetTagged(TAG)) do
        self.Cabinets[cabinetModel] = true
    end
end

function CabinetService:KnitInit()
    self.Client.PromptTriggered:Connect(function(...)
        self:PromptCallback(...)
    end)
end

return CabinetService