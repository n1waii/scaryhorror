local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local Promise = require(Knit.Util.Promise)

local Binder = require(script.Parent.Binder)

local Sound = {}
Sound.__index = Sound

function Sound.new(mount, props)
    assert(mount ~= nil, "Argument 1 missing or nil")
    local soundInstance = Instance.new("Sound")
    
    local events = {
        _TimePositionReached = Instance.new("BindableEvent"),
        _Played = Instance.new("BindableEvent")
    }

    local self = setmetatable({
        Instance = soundInstance,
        Ended = soundInstance.Ended,
        EventBindables = events,
        Played = events._Played.Event
    }, Sound)

    if props then
        for prop, value in pairs(props) do
            if typeof(value) == "table" and value.__type == "Binding" then
                props[prop] = value:_startBinding(self, prop)
            else
                soundInstance[prop] = value
            end
        end
    end

    soundInstance.Parent = mount
    
    return self
end

function Sound:GetTimePositionReachedSignal(t, callback)
    -- TO DO
    -- local instance = self:GetSoundInstance()
    -- assert(t <= instance.TimeLength and t >= 0, "TimePosition argument must be >= 0 and <= Sound.TimeLength")

end

function Sound:FadeOut()
    local sound = self:GetSoundInstance()
    for i = sound.Volume, 0, 0.01 do
        sound.Volume = i
        wait(0.01)
    end
end

function Sound:FadeIn(volume)
    local sound = self:GetSoundInstance()
    for i = 0, volume, 0.005 do
        sound.Volume = i
        RunService.Heartbeat:Wait()
    end
end

function Sound:Stop()
    self:GetSoundInstance():Stop()
end

function Sound:Play()
    self:GetSoundInstance():Play()
    self.EventBindables._Played:Fire()
end

function Sound:PlayOnce()
    return Promise.new(function(res, rej)
        self:Play()
        self:GetSoundInstance().Ended:Wait()
        self:Destroy()
        res()
    end)
end

function Sound:SetProperty(prop, value)
    self:GetSoundInstance()[prop] = value
end

function Sound:GetProperty(prop)
    return self:GetSoundInstance()[prop]
end

function Sound:GetSoundInstance()
    return self.Instance
end

function Sound:Destroy()
    Binder:UnbindAll(self)
    self:GetSoundInstance():Stop()
    self:GetSoundInstance():Destroy()
    self = nil
end

return Sound