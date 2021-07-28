local RunService = game:GetService("RunService")

local Binder = {
    Binds = {}
}

local function Binding(prop, callback)
    return { prop, callback }
end

function Binder:Bind(sound, prop, callback)
    if not self.Binds[sound] then
        self.Binds[sound] = {}
    end

    local index = #self.Binds[sound]+1
    table.insert(self.Binds[sound], index, Binding(prop, callback))

    return index
end

function Binder:Unbind(sound, bindingIndex)
    if self.Binds[sound] then
        table.remove(self.Binds[sound], bindingIndex)
    end
end

function Binder:UnbindAll(sound)
    if self.Binds[sound] then
        for _,binding in pairs(self.Binds[sound]) do
            binding = nil
        end
        self.Binds[sound] = nil
    end
end

RunService.Heartbeat:Connect(function()
    for sound, bindings in pairs(Binder.Binds) do
        for _,binding in pairs(bindings) do
            local prop = binding[1]
            local callback = binding[2]
            sound:SetProperty(prop, callback(sound:GetProperty(prop)))
        end
    end
end)

return Binder