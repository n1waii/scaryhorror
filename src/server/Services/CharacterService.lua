local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WALKING_SPEED = 8
local SPRINTING_SPEED = 16
local JUMP_POWER = 0
local MAX_STAMINA = 100
local STAMINA_REDUCTION_DELAY = 0.3
local STAMINA_REGEN_DELAY = 0.1

local Knit = require(ReplicatedStorage.Knit)
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)

local CharacterService = Knit.CreateService {
    Name = "CharacterService",
    Client = {
        StartSprinting = RemoteSignal.new(),
        StopSprinting = RemoteSignal.new(),
        SprintingStarted = RemoteSignal.new(),
        FullyRegened = RemoteSignal.new()
    },
    Sprinting = {},
    Frozen = {}
}

function CharacterService:CharacterAdded(character)
    character.Humanoid.WalkSpeed = WALKING_SPEED
    character.Humanoid.JumpPower = JUMP_POWER
    character:SetAttribute("Stamina", MAX_STAMINA)
end

function CharacterService:Freeze(character)
    if self.Frozen[character] then return end
    self.Frozen[character] = {
        LastWalkspeed = character.Humanoid.WalkSpeed,
        LastJumpPower = character.Humanoid.JumpPower
    }
    character.Humanoid.WalkSpeed = 0
    character.Humanoid.JumpPower = 0
end

function CharacterService:Thaw(character)
    local lastHumanoidState = self.Frozen[character]
    if lastHumanoidState then
        character.Humanoid.WalkSpeed = lastHumanoidState.LastWalkspeed
        character.Humanoid.JumpPower = lastHumanoidState.LastJumpPower
    end
end

function CharacterService:RegenStamina(player)
    wait(1)
    
    while not self.Sprinting[player] and (player.Character and player.Character:GetAttribute("Stamina") ~= MAX_STAMINA) do
        if not player.Character then return end
        player.Character:SetAttribute("Stamina", math.clamp(
            player.Character:GetAttribute("Stamina")+1,
            0,
            MAX_STAMINA
        ))
        wait(STAMINA_REGEN_DELAY)
    end

    if player.Character and player.Character:GetAttribute("Stamina") == MAX_STAMINA then -- fully regened
        self.Client.FullyRegened:Fire(player)
    end
end

function CharacterService:StopSprinting(player)
    if self.Sprinting[player] then
        player.Character.Humanoid.WalkSpeed = WALKING_SPEED
        self.Sprinting[player] = nil
        coroutine.wrap(function()
            self:RegenStamina(player)
        end)()
    end
end

function CharacterService:StartSprinting(player)
    if not player.Character or player.Character.Humanoid.Health <= 0 then return end
    if self.Frozen[player.Character] or self.Sprinting[player] then return end

    self.Sprinting[player] = true
    player.Character.Humanoid.WalkSpeed = SPRINTING_SPEED
    self.Client.SprintingStarted:Fire(player)
    
    while self.Sprinting[player] do
        local character = player.Character

        if not character
        or not character:FindFirstChild("Humanoid")
        or character.Humanoid.Health <= 0  then
            break
        end

        character:SetAttribute("Stamina", math.clamp(
            character:GetAttribute("Stamina")-1,
            0,
            MAX_STAMINA   
        ))

        if character:GetAttribute("Stamina") == 0 or character.Humanoid.MoveDirection.Magnitude == 0 then
            self:StopSprinting(player)
            break
        end

        wait(STAMINA_REDUCTION_DELAY)
    end
end

function CharacterService:KnitInit()
    self.Client.StartSprinting:Connect(function(player)
        self:StartSprinting(player)
    end)

    self.Client.StopSprinting:Connect(function(player)
        self:StopSprinting(player)
    end)
end

return CharacterService