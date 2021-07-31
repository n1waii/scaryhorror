local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = ReplicatedStorage.Util
local DataModules = ReplicatedStorage.DataModules

local Knit = require(ReplicatedStorage.Knit)
local Rodux = require(ReplicatedStorage.Rodux)

local TableUtil = require(Util.TableUtil)

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local StateController = Knit.CreateController {
    Name = "StateController"
}

local InitialState = {
    UIDisabled = false,
    Stamina = 100,
    StaminaBar = {
        Enabled = false,
    },
    Objectives = {
        Enabled = true,
        Tasks = {},
        TasksLength = 0,
        CompletedTasks = 0
    },
    Inventory = {
        Enabled = false,
        Equipped = nil,
        Items = {},
        ItemCount = 0
    },
    ProximityPrompt = {
        Enabled = false,
        Mount = nil,
    },
    Dialogue = {
        Enabled = false,
        Text = nil
    },
    Keypad = {
        Enabled = false,
    },
    Cursor = {
        Active = false
    },
}

local UIDisabledReducer = Rodux.createReducer(InitialState.UIDisabled, {
    SetUIDisabled = function(state, action)
        return action.Disabled
    end
})

local StaminaReducer = Rodux.createReducer(InitialState.Stamina, {
    SetStamina = function(state, action)
        return action.Stamina
    end
})

local StaminaBarReducer = Rodux.createReducer(InitialState.StaminaBar, {
    SetStaminaBar = function(state, action)
        local newState = TableUtil.shallowcopy(state)
        newState.Enabled = action.Enabled
        return newState
    end
})

local KeypadReducer = Rodux.createReducer(InitialState.Keypad, {
    SetKeypadEnabled = function(state, action)
        local newState = TableUtil.shallowcopy(state)
        newState.Enabled = action.Enabled
        return newState
    end
})

local ObjectivesReducer = Rodux.createReducer(InitialState.Objectives, {
    SetObjectivesEnabled = function(state, action)
        local newState = TableUtil.shallowcopy(state)
        newState.Enabled = action.Enabled
        return newState
    end,

    LoadObjectiveTasks = function(state, action)
        local newState = TableUtil.shallowcopy(state)
        for _,objective in pairs(action.Tasks) do
            table.insert(newState.Tasks, objective)
        end
        newState.TasksLength = #newState.Tasks
        return newState
    end,

    AddObjectiveTask = function(state, action)
        local newState = TableUtil.shallowcopy(state)
        table.insert(newState.Tasks, action.Task)
        newState.TasksLength = #newState.Tasks
        return newState
    end,

    RemoveObjectiveTask = function(state, action)
        local newState = TableUtil.shallowcopy(state)
        for i,objective in ipairs(newState.Tasks) do
            if objective.Id == action.Id then
                table.remove(newState.Tasks, i)
                break
            end
        end
        newState.TasksLength = #newState.Tasks
        return newState
    end,

    RemoveObjectiveTasks = function(state, action)
        local newState = TableUtil.shallowcopy(state)
        for i,objective in ipairs(newState.Tasks) do
            if action.Tasks[objective.Id] or table.find(action.Tasks, objective.Id) then
                table.remove(newState.Tasks, i)
            end
        end
        newState.TasksLength = #newState.Tasks
        return newState
    end,

    CompleteObjectiveTask = function(state, action)
        local newState = TableUtil.shallowcopy(state)
        for _, objective in ipairs(newState.Tasks) do
            if objective.Id == action.Id then
                objective.Completed = true
                break
            end
        end
        newState.CompletedTasks += 1
        return newState
    end
})

local InventoryReducer = Rodux.createReducer(InitialState.Inventory, {
    SetInventoryEnabled = function(state, action)
        local newState = TableUtil.shallowcopy(state)
        newState.Enabled = action.Enabled
        return newState
    end,

    SetInventoryItems = function(state, action)
        local newState = TableUtil.shallowcopy(state)
        newState.Items = action.Items
        newState.ItemCount = #newState.Items
        if not table.find(newState.Items, newState.Equipped) then
            newState.Equipped = nil
        end
        return newState
    end,

    EquipInventoryItem = function(state, action)
        local newState = TableUtil.shallowcopy(state)
        if action.ItemName ~= nil and not table.find(newState.Items, action.ItemName) then
            return newState
        end
        newState.Equipped = action.ItemName
        return newState
    end,

    UnequipInventoryItems = function(state, action)
        local newState = TableUtil.shallowcopy(state)
        newState.Equipped = nil
        return newState
    end
})

local ProximityPromptReducer = Rodux.createReducer(InitialState.ProximityPrompt, {
    SetProximityPrompt = function(state, action)
        local newState = TableUtil.shallowcopy(state)
        newState.Enabled = action.Enabled
        newState.Mount = action.Mount
        return newState
    end
})

local DialogueReducer = Rodux.createReducer(InitialState.Dialogue, {
    SetDialogue = function(state, action)
        local newState = TableUtil.shallowcopy(state)
        newState.Enabled = action.Enabled
        newState.Text = action.Text
        return newState
    end
})

local CursorReducer = Rodux.createReducer(InitialState.Cursor, {
    SetCursor = function(state, action)
        local newState = TableUtil.shallowcopy(state)
        newState.Active = action.Active and true or false
        return newState
    end
})

local MainReducer = Rodux.combineReducers({
    UIDisabled = UIDisabledReducer,
    Stamina = StaminaReducer,
    Objectives = ObjectivesReducer,
    StaminaBar = StaminaBarReducer,
    ProximityPrompt = ProximityPromptReducer,
    Inventory = InventoryReducer,
    Dialogue = DialogueReducer,
    Keypad = KeypadReducer,
    Cursor = CursorReducer
})

function StateController:KnitStart()
    self.Store = Rodux.Store.new(MainReducer)
end

return StateController