local Camera, Delay, Effect = require(script.Camera), require(script.Delay), require(script.Effect)

local Cutscene = {
	Camera = Camera,
	Delay = Delay,
	Effect = Effect
}
Cutscene.__index = Cutscene

function Cutscene.new(scenes)
	print("made cutscene")
	return setmetatable({
		Scenes = scenes,
		Playing = false
	}, Cutscene)
end

function Cutscene:Play()
	print("playing")
	if self.Playing then return end
	self.Playing = true
	for _,obj in ipairs(self.Scenes) do
		local _type = obj.__type
		if _type == "Camera" or _type == "Delay" or _type == "Effect" then
			obj:Start()
		else
			error("Unknown object type in scenes")
		end
	end
	Camera:Reset()
	self.Playing = false
end

return Cutscene