local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)

local DialogueService = Knit.CreateService {
    Name = "DialogueService",
    Client = {
        PlayText = RemoteSignal.new(),
        PlayMultipleText = RemoteSignal.new(),
        PlayLine = RemoteSignal.new()
    }
}

function DialogueService:PlayTextAll(text)
    self.Client.PlayText:FireAll(text)
end

function DialogueService:PlayMultipleTextAll(texts)
    self.Client.PlayMultipleText:FireAll(texts)
end

function DialogueService:PlayText(player, text)
    self.Client.PlayText:Fire(player, text)
end

function DialogueService:PlayMultipleText(player, texts)
    self.Client.PlayMultipleText:Fire(player, texts)
end

function DialogueService:PlayLine(player, id)
    self.Client.PlayLine:Fire(player, id)
end

function DialogueService:PlayLineAll(id)
    self.Client.PlayLine:FireAll(id)
end

return DialogueService