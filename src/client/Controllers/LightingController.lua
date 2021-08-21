local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)

local LightingController = Knit.CreateController {
    Name = "LightingController",
    Defaults = {
        FogEnd = 50,
        FogStart = 0
    }
}

function LightingController:SetFog(fogEnd, fogStart)
    Lighting.FogEnd = fogEnd
    Lighting.FogStart = fogStart
end

function LightingController:ResetFog()
    Lighting.FogEnd = self.Defaults.FogEnd
    Lighting.FogStart = self.Defaults.FogStart
end

return LightingController