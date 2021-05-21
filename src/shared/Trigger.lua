local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local Promise = require(Knit.Util.Promise)

local Trigger = {}
Trigger.Listening = {}

function Trigger:Listen(name, callback)
	if not Trigger.Listening[name] then
		Trigger.Listening[name] = {}
	end
	table.insert(Trigger.Listening[name], callback)
end

function Trigger:Emit(name, ...)
	if not Trigger.Listening[name] then return end
	local args = {...}
	return Promise.new(function(resolve, reject)
		for _,callback in pairs(Trigger.Listening[name]) do
			callback(unpack(args))
		end
		resolve()
	end)
end

return Trigger