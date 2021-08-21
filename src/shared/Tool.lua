local Tool = {}
Tool.__index = Tool

function Tool:extend(toolInstance)
    assert(toolInstance:IsA("Tool"), "Argument 1 expected Tool")

    return setmetatable({
        _tool_instance = toolInstance
    }, Tool)
end

function Tool:didEquip(callback)
    self._tool_instance.Equipped:Connect(function(...)
        callback(...)
    end)
end

function Tool:didUnequip(callback)
    self._tool_instance.Unequipped:Connect(function(...)
        callback(...)
    end)
end

function Tool:didRelease(callback)
   self._tool_instance.Deactivated:Connect(function(...)
       callback(...)
   end)
end

function Tool:didPress(callback)
    self._tool_instance.Activated:Connect(function(...)
        callback(...)
    end)
end



    


return Tool