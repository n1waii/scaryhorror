local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local TRIGGER_KEYCODE = Enum.KeyCode.E
local PROMPT_RANGE = 10

local Knit = require(ReplicatedStorage.Knit)

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local ProximityPromptController = Knit.CreateController {
    Name = "ProximityPromptController",
    ActivePrompts = {},
    CurrentPrompt = nil,
    CanTrigger = true
}

function ProximityPromptController:AddPrompt(part)
    print("added new prompt: ", part.Name)
    self.ActivePrompts[part] = true
end

function ProximityPromptController:RemovePrompt(part)
    self.ActivePrompts[part] = nil
end

function ProximityPromptController:SetupPromptHovering()
    local StateController = Knit.Controllers.StateController

    RunService.RenderStepped:Connect(function()
        local target = Mouse.Target
        if target then
            if target:IsA("BasePart") then
                local model = target:FindFirstAncestorOfClass("Model")
                if model and model:FindFirstChild("AlphexusPrompt") then
                    local prompt = model.AlphexusPrompt
                    local dist = (Player.Character.HumanoidRootPart.Position-prompt.Position).Magnitude
                    if self.ActivePrompts[prompt] then
                        if dist <= PROMPT_RANGE then
                            if self.CurrentPrompt ~= prompt then
                                self.CurrentPrompt = prompt
                                StateController.Store:dispatch({
                                    type = "SetProximityPrompt",
                                    Enabled = true,
                                    Mount = prompt
                                })
                                StateController.Store:dispatch({
                                    type = "SetCursor",
                                    Active = true
                                })
                            end
                            return
                        end
                    end
                end
            end
        end

        -- no prompt hovering
        if self.CurrentPrompt ~= nil then
            self.CurrentPrompt = nil
            StateController.Store:dispatch({
                type = "SetProximityPrompt",
                Enabled = false,
                Mount = nil
            })
            StateController.Store:dispatch({
                type = "SetCursor",
                Active = false
            })
        end
    end)
end

function ProximityPromptController:AddPromptsDeep(start)
    for _,v in pairs(start:GetDescendants()) do
        if not v:IsA("BasePart") then continue end
        if v.Name == "AlphexusPrompt" then
            self:AddPrompt(v)
        end
    end
end

function ProximityPromptController:SetupPromptTriggering()
    local InputController = Knit.Controllers.InputController
    
    InputController:WhenKeyDown(TRIGGER_KEYCODE, function()
        if not self.CanTrigger or not self.CurrentPrompt then return print("no") end
        if not self.CurrentPrompt:GetAttribute("Triggerable") then return print'cant trigger' end
        local promptController = Knit.Controllers[self.CurrentPrompt:GetAttribute("Controller")]
        if promptController then
            self.CanTrigger = false
            promptController:PromptCallback(self.CurrentPrompt)
            wait(0.5)
            self.CanTrigger = true
        end
    end)
end

function ProximityPromptController:KnitStart()
    self:SetupPromptHovering()
    self:SetupPromptTriggering()
    wait(3)
    self:AddPromptsDeep(workspace)
end

return ProximityPromptController