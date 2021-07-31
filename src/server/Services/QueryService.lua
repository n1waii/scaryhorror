-- Query String Params --

--[[
    ItemRequest: {
        "item": string,
        "dialogue_request": DialogueRequest?,
        "recipient": RecipientType
    }

    ObjectiveRequest: {
        "objective_id": string,
        "completion": boolean?,
        "dialogue_request": DialogueRequest?
    }

    DialogueRequest: {
        "dialogue_id": string,
        "recipient": RecipientType
    }
--]]

--[[
    RecipientTypes: {
        all -- all players
        requester -- only the requester of the query
    }
--]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = ReplicatedStorage.Util
local switch = require(Util.SwitchStatement)

local Knit = require(ReplicatedStorage.Knit)
local QueryService = Knit.CreateService {
    Name = "QueryService"
}
local EnumList = require(Knit.Util.EnumList)

local RecipientTypes = {
    all = "all",
    requester = "requester"
}

local QueryHandlers = {}

QueryHandlers.ItemRequest = function(queryObject, requester)
    local item = queryObject.item
    local recipient = queryObject.recipient
    local dialogue_request = queryObject.dialogue_request

    local InventoryService = Knit.Services.InventoryService

    switch (recipient) {
        [RecipientTypes.requester] = function()
            if not requester then return end
            InventoryService:AddItem(requester, item)
        end,

        [RecipientTypes.all] = function()
            InventoryService:GiveAllItem(requester, item)
        end
    }

    if dialogue_request then
        QueryHandlers.DialogueRequest(HttpService:JSONDecode(dialogue_request), requester)
    end
end

QueryHandlers.ObjectiveRequest = function(queryObject)
    local objective_id = queryObject.objective_id
    local completion = queryObject.completion
    local dialogue_request = queryObject.dialogue_request

    local ObjectiveService = Knit.Services.ObjectiveService

    if completion then
        ObjectiveService:CompleteObjective(objective_id)
    else
        ObjectiveService:AddObjective(objective_id)
    end
    
    if dialogue_request then
        QueryHandlers.DialogueRequest(HttpService:JSONDecode(dialogue_request))
    end
end

QueryHandlers.DialogueRequest = function(queryObject, requester)
    local dialogue_id = queryObject.dialogue_id
    local recipient = queryObject.recipient

    local DialogueService = Knit.Services.DialogueService

    switch (recipient) {
        [RecipientTypes.requester] = function()
            if not requester then return end
            DialogueService:PlayLine(requester, dialogue_id)
        end,

        [RecipientTypes.all] = function()
            DialogueService:PlayLineAll(dialogue_id)
        end
    }
end

function QueryService:HandleRequest(queryType, queryObject, requester)
    if typeof(queryObject) == "string" then
        queryObject = HttpService:JSONDecode(queryObject)
    end

    if QueryHandlers[queryType] then
        QueryHandlers[queryType](queryObject, requester)
    end
end


return QueryService