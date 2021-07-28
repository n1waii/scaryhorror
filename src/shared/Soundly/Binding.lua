local Binder = require(script.Parent.Binder)

local Binding = {}
Binding.__index = Binding
Binding.__type = "Binding"

function Binding.new(callback)
    assert(typeof(callback) == "function", 
        ("Argument 1 expected type 'function' got '%s'"):format(typeof(callback))
    )
    return setmetatable({
        Callback = callback
    }, Binding)
end

function Binding:_startBinding(sound, prop)
    return Binder:Bind(sound, prop, self.Callback)
end

return Binding