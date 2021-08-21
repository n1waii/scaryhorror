local AbstractPuzzle = {}
AbstractPuzzle.__index = AbstractPuzzle

function AbstractPuzzle.new()
    return setmetatable({
        Completed = false
    }, AbstractPuzzle)
end

function AbstractPuzzle:isComplete()
    error(tostring(self) .. " did not override method 'isComplete'")
end

function AbstractPuzzle:Start()
    error(tostring(self) .. " did not override method 'Start'")
end

function AbstractPuzzle:onComplete()
    error(tostring(self) .. " did not override method 'Start'")
end

function AbstractPuzzle:__tostring()
    return "AbstractPuzzle"
end

return AbstractPuzzle