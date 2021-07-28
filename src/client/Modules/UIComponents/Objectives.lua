local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local TASK_ABSOLUTE_Y_SIZE = 31
local TASK_Y_OFFSET = 7
local ICON_X_OFFSET = -3

local ARROW_ICON = "rbxassetid://4370337241"
local CHECKMARK_ICON = "rbxassetid://3944680095"
local TASK_COMPLETION_COLOR = Color3.fromRGB(74, 214, 14)

local TASK_COMPLETED_TWEEN_INFO = TweenInfo.new(1, Enum.EasingStyle.Linear)
local NEW_TASK_TWEEN_INFO = TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local REMOVE_TASK_TWEEN_INFO = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TASK_ALIGNMENT_TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Quint)

local Knit = require(ReplicatedStorage.Knit)
local Roact = require(script.Parent.Parent.Roact)
local RoactRodux = require(script.Parent.Parent.RoactRodux)
local Promise = require(Knit.Util.Promise)

local Player = Players.LocalPlayer

local e = Roact.createElement
local Objectives = Roact.PureComponent:extend("Objectives")
local ObjectivesTaskComponent = Roact.PureComponent:extend("ObjectivesTaskComponent")

function ObjectivesTaskComponent:init()
    self.TaskFrame = Roact.createRef()
end

function ObjectivesTaskComponent:render()
    return e("Frame", {
        [Roact.Ref] = self.TaskFrame,
        BackgroundTransparency = 1,
        Position = self.props.Position,
        Size = UDim2.fromScale(0.955, 0.144),
    }, {
        TaskLabel = e("TextLabel", {
            AnchorPoint = Vector2.new(1, 1),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(1, 1),
            Size = UDim2.fromScale(0, 1),
            Font = Enum.Font.SourceSansSemibold,
            Text = self.props.Text,
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 25,
            TextXAlignment = Enum.TextXAlignment.Right
        }),
        Icon = e("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.55),
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0.117, 1),
            Rotation = 90,
            Image = ARROW_ICON
        })
    })
end

function ObjectivesTaskComponent:didMount()
    local frame = self.TaskFrame:getValue()
    frame.Position = UDim2.new(
        1,
        0,
        frame.Position.Y.Scale,
        frame.Position.Y.Offset
    )
    frame.Icon.Position = UDim2.new(0.95, (-frame.TaskLabel.AbsoluteSize.X)+ICON_X_OFFSET, 0.5, 0)
    TweenService:Create(frame, NEW_TASK_TWEEN_INFO, {
        Position = UDim2.new(
            0,
            0,
            frame.Position.Y.Scale,
            frame.Position.Y.Offset
        )
    }):Play()
end

local function TaskFragment(props)
    local taskComponents = {}
    
    for i, objective in ipairs(props.Tasks) do
        taskComponents[objective.Id] = e(ObjectivesTaskComponent, {
            Text = objective.Text,
            Position = UDim2.new(0, 0, 0.168, i == 1 and 0 or (i-1)*(TASK_ABSOLUTE_Y_SIZE+TASK_Y_OFFSET))
        })
    end

    -- for i, objective in ipairs(newTasks) do
    --     local order = #props.Tasks+i
    --     taskComponents[tostring(objective.Id)] = e(ObjectivesTaskComponent, {
    --         Text = objective.Text,
    --         Position = UDim2.new(1, 0, 0.168, order*(TASK_ABSOLUTE_Y_SIZE+TASK_Y_OFFSET))
    --     })
    -- end

    return Roact.createFragment(taskComponents)
end

function Objectives:init()
    self.MainFrameRef = Roact.createRef()
    return self:setState({
        Hide = false,
        Tasks = {}
    })
end

function Objectives:GetNewTasks()
    print("objectives:getnewTasks:", self.props.Tasks)
    if self.props.Tasks and #self.props.Tasks > #self.state.Tasks then
        local newObjectives = {}
        for i, objective in ipairs(self.props.Tasks) do
            if (not self.state.Tasks[i]) then
                table.insert(newObjectives, objective)
            end
        end
        return newObjectives
    else
        return {}
    end
end

function Objectives:GetCompletedTasks()
    local completedTasks = {}
    for i, objective in ipairs(self.props.Tasks) do
        if objective.Completed == true then
            table.insert(completedTasks, objective)
        end
    end
    return completedTasks
end

function Objectives:render()
    if self.state.Hide then return end

    return e("Frame", {
        [Roact.Ref] = self.MainFrameRef,
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.75, 0),
        Size = UDim2.fromScale(0.245, 0.544)
    }, {
        Title = e("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.067, 0),
            Size = UDim2.fromScale(0.888, 0.158),
            Font = Enum.Font.PermanentMarker,
            Text = "Objectives",
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Right
        }),
        Roact.createElement(TaskFragment, {
            Tasks = self.props.Tasks
        })
    })
end

function Objectives:TweenCompletedTasks(completedTasks)
    local mainFrame = self.MainFrameRef:getValue()
    completedTasks = completedTasks or self:GetCompletedTasks()
    
    for i, objective in pairs(completedTasks) do
        local objectiveFrame = mainFrame:FindFirstChild(tostring(objective.Id))
        if objectiveFrame then
            local t = TweenService:Create(objectiveFrame.TaskLabel, TASK_COMPLETED_TWEEN_INFO, {
                TextColor3 = TASK_COMPLETION_COLOR
            })
            local t2 = TweenService:Create(objectiveFrame.Icon, TASK_COMPLETED_TWEEN_INFO, {
                ImageColor3 = TASK_COMPLETION_COLOR
            })
            t.Completed:Connect(function()
                t:Destroy()
                wait(1)
                TweenService:Create(objectiveFrame, REMOVE_TASK_TWEEN_INFO, {
                    Position = UDim2.new(
                        1,
                        0,
                        objectiveFrame.Position.Y.Scale,
                        objectiveFrame.Position.Y.Offset
                    )
                }):Play()
            end)
            objectiveFrame.Icon.Rotation = 0
            objectiveFrame.Icon.Image = CHECKMARK_ICON
            t:Play()
            t2:Play()
        end
    end

    return Promise.new(function(res, rej)
        wait(3)
        res()
    end)
end

function Objectives:Align()
    print("aligning tasks")
    local mainFrame = self.MainFrameRef:getValue()
    for i, objective in pairs(self.props.Tasks) do
        local objectiveFrame = mainFrame:FindFirstChild(tostring(objective.Id))
        if objectiveFrame then
            TweenService:Create(objectiveFrame, TASK_ALIGNMENT_TWEEN_INFO, {
                Position = UDim2.new(
                    0,
                    0,
                    objectiveFrame.Position.Y.Scale,
                    i == 1 and 0 or (i-1)*(TASK_ABSOLUTE_Y_SIZE+TASK_Y_OFFSET)
                )
            }):Play()
        end
    end
end

function Objectives:didUpdate(lastProps, lastState)
    print("updated")
    local completedTasks = self:GetCompletedTasks()
    print('Prop tasks: ', self.props.Tasks)

    if self.state.Hide and self.props.isShowing then
        self:setState({
            Hide = false,
        })
    elseif #completedTasks > 0 then
        print("starting to tween completed tasks")
        self:TweenCompletedTasks(completedTasks):andThen(function()
            local completedTaskIds = {}
            for _,task in pairs(completedTasks) do
                completedTaskIds[task.Id] = true
                table.remove(self.props.Tasks, table.find(self.props.Tasks, task))
            end
            self:Align()
            wait(4)
            Knit.Controllers.ObjectivesController:RemoveObjectives(completedTaskIds)
        end)
    elseif not self.state.Hide and not self.props.isShowing then
        self:setState({
            Hide = true,
        })
    end
end

Objectives = RoactRodux.connect(
    function(state, props)
        return {
            Tasks = state.Objectives.Tasks,
            isShowing = state.Objectives.Enabled,
            TasksLength = state.Objectives.TasksLength,
            CompletedTasks = state.Objectives.CompletedTasks
        }
    end
)(Objectives)


return Objectives