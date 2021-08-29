local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NPCModules = ReplicatedStorage.NPC

local Knit = require(ReplicatedStorage.Knit)
local Promise = require(Knit.Util.Promise)

local WaypointPool = require(NPCModules.WaypointPool)

local DEFAULT_PATH_PARAMS = {
    AgentCanJump = false
}

local NPC = {}
NPC.__index = NPC

function NPC.new(npcModel, pathParams)
    local self = setmetatable({
        Model = npcModel,
        Path = PathfindingService:CreatePath(pathParams or DEFAULT_PATH_PARAMS),
        WaypointPool = WaypointPool.new()
    }, NPC)
    self:_init()

    return self
end

function NPC:SetPathParams(newParams)
    self.Path = PathfindingService:CreatePath(newParams)
end

function NPC:WalkTo(vectorPos, shouldPathfind)
    local npcModel = self.Model

    local function pathfind()
        local path = self.Path
        path:ComputeAsync(npcModel.HumanoidRootPart.Position, vectorPos)

        if not path.Status == Enum.PathStatus.Success then
            return
        end

        local waypoints = path:GetWaypoints()
        for _, waypoint in pairs(waypoints) do
            self.WaypointPool:Push(waypoint)
        end
    end

    local function move()
        self.WaypointPool:Push(vectorPos)
    end

    return shouldPathfind and pathfind() or move()
end

function NPC:Follow(part)
    self.WaypointPool:Observe(self.Model.HumanoidRootPart, part)
end

function NPC:Unfollow()
    self.WaypointPool:Ignore()
    self.WaypointPool:Eat()
end

function NPC:_init()
    self.Path.Blocked:Connect(function()
        print("blocked")
    end)

    task.defer(function()
        while true do
            local waypoint = self.WaypointPool:Pull()
            if waypoint then
                self.Model.Humanoid:MoveTo(waypoint.Position)
                self.Model.Humanoid.MoveToFinished:Wait()
            end
            task.wait(0.1)
        end
    end)
end

return NPC
