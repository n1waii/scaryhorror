local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local Rodux = require(ReplicatedStorage.Rodux)

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local StateController = Knit.CreateController {
    Name = "StateController"
}

local InitialState = {
    Stamina = 100,
    StaminaBar = {
        Enabled = false,
    },
    ProximityPrompt = {
        Enabled = false,
        Mount = nil,
    },
    Cursor = {
        Active = false
    }
}

local function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else 
        copy = orig
    end
    return copy
end

local StaminaReducer = Rodux.createReducer(InitialState.Stamina, {
    SetStamina = function(state, action)
        return action.Stamina
    end
})

local StaminaBarReducer = Rodux.createReducer(InitialState.StaminaBar, {
    SetStaminaBar = function(state, action)
        local newState = shallowcopy(state)
        newState.Enabled = action.Enabled
        return newState
    end
})

local ProximityPromptReducer = Rodux.createReducer(InitialState.ProximityPrompt, {
    SetProximityPrompt = function(state, action)
        local newState = shallowcopy(state)
        newState.Enabled = action.Enabled
        newState.Mount = action.Mount
        return newState
    end
})

local CursorReducer = Rodux.createReducer(InitialState.Cursor, {
    SetCursor = function(state, action)
        local newState = shallowcopy(state)
        newState.Active = action.Active and true or false
        return newState
    end
})

local MainReducer = Rodux.combineReducers({
    Stamina = StaminaReducer,
    StaminaBar = StaminaBarReducer,
    ProximityPrompt = ProximityPromptReducer,
    Cursor = CursorReducer
})

function StateController:KnitStart()
    self.Store = Rodux.Store.new(MainReducer)
end

return StateController