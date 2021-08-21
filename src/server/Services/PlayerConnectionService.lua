local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local PLAYERS_COLLISION_GROUP = "Players"
local SCARE_MODELS_COLLISION_GROUP = "Scare Models"

local PreviousCollisionGroups = {}

local Knit = require(ReplicatedStorage.Knit)
local PlayerConnectionService = Knit.CreateService {
    Name = "PlayerConnectionService"
}

function PlayerConnectionService:PlayerAdded(player)
    if player.Character then
        self:CharacterAdded(player.Character)
    end

    player.CharacterAdded:Connect(function(character)
        self:CharacterAdded(character)
    end)

    player:LoadCharacter()
    wait(6)
    Knit.Services.TriggerService:Trigger(player, "Testing")
end

function PlayerConnectionService:PlayerRemoving(player)
    
end

function PlayerConnectionService:CharacterAdded(character)
    local function setCollisionGroup(object)
        if object:IsA("BasePart") then
            PreviousCollisionGroups[object] = object.CollisionGroupId
            PhysicsService:SetPartCollisionGroup(object, PLAYERS_COLLISION_GROUP)
        end
    end

    local function setCollisionGroupRecursive(object)
        setCollisionGroup(object)
        for _, child in ipairs(object:GetChildren()) do
            setCollisionGroupRecursive(child)
        end
    end

    local function resetCollisionGroup(object)
        local previousCollisionGroupId = PreviousCollisionGroups[object]
        if not previousCollisionGroupId then return end
        
        local previousCollisionGroupName = PhysicsService:GetCollisionGroupName(previousCollisionGroupId)
        if not previousCollisionGroupName then return end
        
        PhysicsService:SetPartCollisionGroup(object, previousCollisionGroupName)
        PreviousCollisionGroups[object] = nil
    end

    setCollisionGroupRecursive(character)
    character.DescendantAdded:Connect(setCollisionGroup)
    character.DescendantRemoving:Connect(resetCollisionGroup)
 
    Knit.Services.CharacterService:CharacterAdded(character)
end

function PlayerConnectionService:KnitStart()
    PhysicsService:CreateCollisionGroup(PLAYERS_COLLISION_GROUP)
    PhysicsService:CollisionGroupSetCollidable(PLAYERS_COLLISION_GROUP, PLAYERS_COLLISION_GROUP, false)
    PhysicsService:CollisionGroupSetCollidable(SCARE_MODELS_COLLISION_GROUP, PLAYERS_COLLISION_GROUP, false)

    for _,player in pairs(Players:GetPlayers()) do
        coroutine.wrap(function()
            self:PlayerAdded(player)
        end)()
    end
    
    Players.PlayerAdded:Connect(function(player)
        self:PlayerAdded(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:PlayerRemoving(player)
    end)
end

return PlayerConnectionService