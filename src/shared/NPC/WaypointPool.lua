local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local WaypointPool = {}
WaypointPool.__index = WaypointPool

function WaypointPool.new(poolCapacity)
    local self = setmetatable({
        Waypoints = {}, -- stack
        Observing = nil
    }, WaypointPool)
    self:_init()
end

function WaypointPool:Push(waypoint)
    table.insert(self.Waypoints, waypoint)
end

function WaypointPool:Pull()
    local i = #self.Waypoints
    local latestWaypoint = self.Waypoints[i]
    table.remove(self.Waypoints, i)
    return latestWaypoint
end

function WaypointPool:PopBottom(waypoint)
    table.remove(self.Waypoints, 1)
end

function WaypointPool:Eat() -- removes all waypoints
    self.Waypoints = {}
end

function WaypointPool:Observe(path, sourceInstance, targetInstance)
    self.Observing = {
        Path = path,
        Source = sourceInstance,
        Target = targetInstance
    }
end

function WaypointPool:Ignore()
    self.Observing = nil
end

function WaypointPool:_init()
    task.defer(function()
        while true do
            if self.Observing then
                local path = self.Observing.Path
                local waypoints = path:ComputeAsync(self.Source, self.Target)
                self:Eat()
                for _, wp in pairs(waypoints) do
                    self:Push(wp)
                end
            end
            task.wait(0.1)
        end
    end)
end

return WaypointPool