local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
    wait(10)
    Knit.Services.TriggerService:Trigger(player, "SpawnScene")
end

function PlayerConnectionService:PlayerRemoving(player)
    
end

function PlayerConnectionService:CharacterAdded(character)
    Knit.Services.CharacterService:CharacterAdded(character)
end

function PlayerConnectionService:KnitStart()
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