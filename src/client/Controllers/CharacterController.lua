local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Knit)

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

local CharacterController = Knit.CreateController {
    Name = "CharacterController",
    CanSprint = true
}

local R15_ARMS = {
    "RightHand",
    "RightUpperArm",
    "RightLowerArm",
    "LeftHand",
    "LeftUpperArm",
    "LeftLowerArm",
}

function CharacterController:SetTransparencyModifiers(character)
    Character = character
    for _,armPart in pairs(R15_ARMS) do
        local p = character:WaitForChild(armPart, 1)
        if p then
            p.LocalTransparencyModifier = 1
        end
    end
end

function CharacterController:SetCanSprint(bool)
    self.CanSprint = bool
end

function CharacterController:SetCharacterCFrame(cf)
    Character = Player.Character
    if Character then
        Character:SetPrimaryPartCFrame(cf * CFrame.new(0, Character.Humanoid.HipHeight, 0))
    end
end

function CharacterController:OnCharacterAdded(character)
    Character = character
    Character:GetAttributeChangedSignal("Stamina"):Connect(function()
        Knit.Controllers.StateController.Store:dispatch({
            type = "SetStamina",
            Stamina = Character:GetAttribute("Stamina")
        })
    end)
end

function CharacterController:DisableMovement()
    self:SetCanSprint(false)
    Character.Humanoid.WalkSpeed = 0
end

function CharacterController:EnableMovement()
    self:SetCanSprint(true)
    Character.Humanoid.WalkSpeed = 8
end

function CharacterController:KnitStart()
    local CharacterService = Knit.GetService("CharacterService")
    local StateController = Knit.Controllers.StateController
    local InputController = Knit.Controllers.InputController
    local UIController = Knit.Controllers.UIController
    
    -- sprinting
    CharacterController:OnCharacterAdded(Character)

    Player.CharacterAdded:Connect(function(character)
        self:OnCharacterAdded(character)
    end)

    CharacterService.SprintingStarted:Connect(function()
        StateController.Store:dispatch({
            type = "SetStaminaBar",
            Enabled = true
        })
    end)

    CharacterService.FullyRegened:Connect(function()
        StateController.Store:dispatch({
            type = "SetStaminaBar",
            Enabled = false
        })
    end)

    InputController:WhenKeyDown(Enum.KeyCode.LeftShift, function(gameProcessed)
        if gameProcessed then return end
        if not self.CanSprint then return end
        CharacterService.StartSprinting:Fire()
    end)

    InputController:WhenKeyUp(Enum.KeyCode.LeftShift, function()
        CharacterService.StopSprinting:Fire()
    end)

    -- Player.CharacterAdded:Connect(function(character)
    --     self:CharacterAdded(character)
    -- end)

    RunService.RenderStepped:Connect(function()
        if Player.Character then
            self:SetTransparencyModifiers(Player.Character)
        end
    end)

    Camera.FieldOfView = 60
end

return CharacterController