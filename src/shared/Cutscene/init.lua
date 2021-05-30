local Camera, Delay, Effect = require(script.Camera), require(script.Delay), require(script.Effect)

local Cutscene = {
	Camera = Camera,
	Delay = Delay,
	Effect = Effect
}
Cutscene.__index = Cutscene

function Cutscene.new(scenes)
	return setmetatable({
		Scenes = scenes,
		Playing = false
	}, Cutscene)
end

function Cutscene:Play()
	if self.Playing then return end
	self.Playing = true
	for _,obj in ipairs(self.Scenes) do
		if not self.Playing then return end
		local _type = obj.__type
		if _type == "Camera" or _type == "Delay" or _type == "Effect" then
			obj:Start()
		else
			error("Unknown object type in scenes")
		end
	end
	
end

function Cutscene:Stop()
	self.Playing = false
	Camera:Reset()
end

return Cutscene