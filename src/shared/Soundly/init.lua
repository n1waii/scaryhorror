local Sound = require(script.Sound)
local Binding = require(script.Binding)

local Soundly = {
    CreateSound = function(...)
        return Sound.new(...)
    end,
    CreateBinding = function(...)
        return Binding.new(...)
    end
}

return Soundly