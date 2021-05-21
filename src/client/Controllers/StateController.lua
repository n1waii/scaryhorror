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
    UIShowing = {
        StaminaBar = false
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

local UIShowingReducer = Rodux.createReducer(InitialState.UIShowing, {
    ShowUI = function(state, action)
        state = shallowcopy(state)
        state[action.UI] = true
        return state
    end,

    HideUI = function(state, action)
        state = shallowcopy(state)
        state[action.UI] = false
        return state
    end
})

local MainReducer = Rodux.combineReducers({
    Stamina = StaminaReducer,
    UIShowing = UIShowingReducer
})

function StateController:KnitStart()
    self.Store = Rodux.Store.new(MainReducer)
end

return StateController