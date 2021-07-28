local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = ReplicatedStorage.Util
local DataModules = ReplicatedStorage.DataModules

local Objectives = require(DataModules.Objectives)
local TableUtil = require(Util.TableUtil)

local Knit = require(ReplicatedStorage.Knit)
local ObjectivesController = Knit.CreateController {
    Name = "ObjectivesController"
}

function ObjectivesController:AddObjective(id)
    if Objectives[id] then
        Knit.Controllers.StateController.Store:dispatch({
            type = "AddObjectiveTask",
            Task = TableUtil.shallowcopy(Objectives[id])
        })
    end
end

function ObjectivesController:CompleteObjective(id)
    if Objectives[id] then
        Knit.Controllers.StateController.Store:dispatch({
            type = "CompleteObjectiveTask",
            Id = id
        })
    end
end

function ObjectivesController:RemoveObjective(id)
    if Objectives[id] then
        Knit.Controllers.StateController.Store:dispatch({
            type = "RemoveObjectiveTask",
            Id = id
        })
    end
end

function ObjectivesController:RemoveObjectives(tasks)
    Knit.Controllers.StateController.Store:dispatch({
        type = "RemoveObjectiveTasks",
        Tasks = tasks
    })
end

function ObjectivesController:LoadObjectives(objectiveIds)
    local newObjectives = {}

    for _,id in pairs(objectiveIds) do
        if Objectives[id] then
            table.insert(newObjectives, TableUtil.shallowcopy(Objectives[id]))
        end
    end

    self.Controllers.StateController.Store:dispatch({
        type = "LoadObjectiveTasks",
        Tasks = newObjectives
    })
end

function ObjectivesController:KnitStart()
    local ObjectivesService = Knit.GetService("ObjectivesService")

    ObjectivesService.AddObjective:Connect(function(id)
        self:AddObjective(id)
    end)

    ObjectivesService.RemoveObjective:Connect(function(id)
        self:RemoveObjective(id)
    end)

    ObjectivesService.CompleteObjective:Connect(function(id)
        self:CompleteObjective(id)
    end)
end

return ObjectivesController