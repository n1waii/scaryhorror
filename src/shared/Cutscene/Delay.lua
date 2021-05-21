local Delay = {}
Delay.__index = Delay
Delay.__type = "Delay"

function Delay.new(t, callback)
	return setmetatable({
		Time = t,
		Callback = callback or nil
	}, Delay)
end

function Delay:Start()
	if self.Callback then
		coroutine.wrap(self.Callback)()
	end
	wait(self.Time)
end

return Delay