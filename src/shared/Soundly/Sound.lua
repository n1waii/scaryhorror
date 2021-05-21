local RunService = game:GetService("RunService")

local Sound = {}
Sound.__index = Sound

function Sound.new(mount, props, effects)
    assert(mount ~= nil and props ~= nil, "nil argument passed to Sound.new")
    local soundInstance = Instance.new("Sound")
    
    for prop, value in pairs(props) do
        soundInstance[prop] = value
    end

    if effects then
        for effectName, effectProps in pairs(effects) do
            local effectInstance = Instance.new(effectName)
            for effectProp, effectValue in pairs(effectProps) do
                effectInstance[effectProp] = effectValue
            end
        end
    end

    soundInstance.Parent = mount
    
    return setmetatable({
        Instance = soundInstance,
        BindedProperties = {
            Sound = {},
            Effects = {}
        }, 
        BinderConnection = nil
    }, Sound)
end

function Sound:CreateBindingConnection()
    if self.BinderConnection then return end
    local soundInstance = self:GetSoundInstance()
    self.BinderConnection = RunService.RenderStepped:Connect(function()
        for prop, callback in pairs(self.BindedProperties.Sound) do
            soundInstance[prop] = callback()
        end

        for effect, bindedProps in pairs(self.BindedProperties.Effects) do
            for prop, callback in pairs(bindedProps) do
                soundInstance[effect][prop] = callback()
            end
        end
    end)
end

function Sound:BindProperty(prop, callback)
    if self.BindedProperties.Sound[prop] then return end
    local soundInstance = self:GetSoundInstance()
    assert(pcall(function()
        return soundInstance[prop] 
    end, ("Property '%s' does not exist for Sound Instance"):format(prop)))
    
    self.BindedProperties.Sound[prop] = callback
    self:CreateBindingConnection()
end

function Sound:BindEffectProperty(effect, prop, callback)
    if self.BindedProperties.Sound[prop] then return end
    local soundInstance = self:GetSoundInstance()

    assert(pcall(function()
        return soundInstance[effect]
    end, ("Effect Instance '%s' is not a child of Sound Instance"):format(effect)))
    
    assert(pcall(function()
        return soundInstance[effect][prop] 
    end, ("Property '%s' does not exist for Sound Instance"):format(prop)))
    
    self.BindedProperties.Sound[prop] = callback
    self:CreateBindingConnection()
end

function Sound:Play()
    return self:GetSoundInstance():Play()
end

function Sound:GetSoundInstance()
    return self.Instance
end

return Sound