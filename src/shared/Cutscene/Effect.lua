assert(game:GetService("RunService"):IsClient(), "Cutscene EffectInfo must be required on the client")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Effect = {}
Effect.__index = Effect
Effect.__type = "Effect"
Effect.Effects = {
	Fade = {
		Start = function(effect)
			local UI = PlayerGui:FindFirstChild("CutsceneFadeUI")
			if UI then return UI end
			
			UI = Instance.new("ScreenGui")
			UI.Name = "CutsceneFadeUI"
			UI.IgnoreGuiInset = true
			
			local mainFrame = Instance.new('Frame')
			mainFrame.Size = UDim2.fromScale(1, 1)
			mainFrame.Position = UDim2.fromScale(0, 0)
			mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
			mainFrame.BackgroundTransparency = 1
			mainFrame.Parent = UI
			
			UI.Parent = PlayerGui

			return UI
		end,
		In = function(effect, ui)
			local tween = TweenService:Create(ui.Frame, TweenInfo.new(effect.Time, Enum.EasingStyle.Linear), {
				BackgroundTransparency = 0
			})
			tween:Play()
			return tween
		end,
		Out = function(effect, ui)
			local tween = TweenService:Create(ui.Frame, TweenInfo.new(effect.Time, Enum.EasingStyle.Linear), {
				BackgroundTransparency = 1
			})
			tween:Play()
			return tween
		end
	}
}

function Effect.new(effectName, effectDirection, effectTime, repeatCount, reverse)
	assert(Effect.Effects[effectName] ~= nil, ("Effect '%s' does not exist"):format(effectName))

	local completedEvent = Instance.new("BindableEvent")
	local repeatedEvent = Instance.new("BindableEvent")

	return setmetatable({
		Name = effectName,
		EasingDirection = effectDirection or "In",
		RepeatCount = repeatCount or 1,
		Time = effectTime or 1,
		Reverse = reverse or false,
		_Completed = completedEvent,
		_Repeated = repeatedEvent,
		Completed = completedEvent.Event,
		Repeated = repeatedEvent.Event
	}, Effect)
end

function Effect:Start()
	local effect = self.Effects[self.Name]
	local currentDirection = self.EasingDirection
	local returns = { effect.Start(self) }

	for i = 1, self.RepeatCount do
		local tween = effect[currentDirection](self, unpack(returns))
		if tween then
			tween.Completed:Wait()
		end
		self._Repeated:Fire()
	end

	self._Completed:Fire()
end

return Effect