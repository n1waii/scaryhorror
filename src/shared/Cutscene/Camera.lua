assert(game:GetService("RunService"):IsClient(), "Cutscene Camera must be required on the client")

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local Camera = {}
Camera.__type = "Camera"
Camera.__index = Camera

local CurrentCamera = workspace.CurrentCamera

function Camera.new(cframe, callback)
	return setmetatable({
		CFrame = cframe,
		Callback = callback
	}, Camera)
end

function Camera:Reset()
	if Player.Character and Player.Character:FindFirstChild("Humanoid") then
		CurrentCamera.CameraType = Enum.CameraType.Custom
		CurrentCamera.CameraSubject = Player.Character.Humanoid
	end
end

function Camera:Start()
	CurrentCamera.CameraType = Enum.CameraType.Scriptable
	CurrentCamera.CFrame = self.CFrame
	if self.Callback then self.Callback(self) end
end

function Camera:TweenTo(cframe, tweenInfo)
	local t = TweenService:Create(CurrentCamera, tweenInfo, {
		CFrame = cframe
	})
	t:Play()
	return t
end

return Camera