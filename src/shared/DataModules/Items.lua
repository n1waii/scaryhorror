local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Items = ReplicatedStorage.Items
local Models = Items.Models
local Tools = Items.Tools

local DEFAULT_CAM_Z_OFFSET = 2

return {
    ["Key"] = {
        Name = "Key",
        Tool = Tools.Key,
        Model = Models.Key,
        CameraCFrame = CFrame.Angles(math.rad(90), 0, math.rad(35)) * CFrame.new(0, 0, DEFAULT_CAM_Z_OFFSET)
    }
}