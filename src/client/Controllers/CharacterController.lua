local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Knit)

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

local CharacterController = Knit.CreateController {
    Name = "CharacterController",
    CanSprint = true,
    Connections = {}
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
    if Character then
        local CameraController = Knit.Controllers.CameraController
        local camPosition = Camera.CFrame.Position
        CameraController:Scriptable()
        Character:PivotTo(cf * CFrame.new(0, Character.Humanoid.HipHeight, 0))
        Camera.CFrame = CFrame.new(camPosition.X, camPosition.Y, camPosition.Z) * (cf-cf.Position)
        CameraController:Reset()
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

function CharacterController:IsCharacterFacing(model)
    if not Player.Character then return end
    local a = Player.Character.HumanoidRootPart.CFrame.LookVector
    local b = model.PrimaryPart.CFrame.LookVector
    local scalar = a:Dot(b)
    local theta = math.deg(math.acos(scalar))
    if theta >= 140 then
        return true
    end

    return false
end


function CharacterController:WhenCharacterNears(model, distance, callback)

end


function CharacterController:WhenPredicatesAreTrue(predicates, callback)
    local function evaluate()
        for _, f in ipairs(predicates) do
            if not f() then
                return false
            end
        end

        return true
    end

    local connection; connection = RunService.Heartbeat:Connect(function()
        if evaluate() then
            connection:Disconnect()
            callback()
        end
    end)

    return connection
end

-- CharacterController:WhenPredicatesAreTrue({
--     function() return CharacterController:IsCharacterNear(model, 10) end,
--     function() return CharacterController:IsCharacterFacing(model) end
-- }, function()
--     print("Character is facing and within 10 studs of model")
-- end)

function CharacterController:WhenCharacterFaces(model, callback)
    local connection; connection = RunService.Heartbeat:Connect(function()
        if CharacterController:IsCharacterFacing(model) then
            connection:Disconnect()
            callback()
        end
    end)

    return connection
end

function CharacterController:CacheConnection(name, connectionObject)
    self.Connections[name] = connectionObject
end

function CharacterController:DisconnectConnection(name)
    if self.Connections[name] then
        self.Connections[name]:Disconnect()
        self.Connections[name] = nil
    end
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