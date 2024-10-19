-- Audio Controller
-- Username
-- April 4, 2021



local AudioController = {}

function AudioController:getProperty(instance, propertyName)
    local property;
    
    pcall(function()
        if typeof(instance[propertyName]) ~= "Instance" then 
            property = instance[propertyName]
        end
    end)

    return property
end

function AudioController:playFromPart(sound, parent, deleteOnClomplete, properties)
    --[[
        input: 
            sound = Instance, 
            parent = Instance, parent which sound is played on, 
            deleteOnClomplete = bool, if clone is deleted when complete
            properties = tbl, table of properties thats diffrent in clone than original
        clones then plays sound on part
        returns: cloned sound Instnace
    ]]
    

    local clone = sound:Clone()
    for property, value in pairs(properties) do
        if self:getProperty(sound, property) then
            sound[property] = value
        end
    end

    

    clone.parent = parent
    clone:Play()

    if deleteOnClomplete then
        -- cant deleteOnComplete if looped
        if clone.Looped then 
            warn("Cannot delete ".. sound.Name.."[sound] On complete, since its looped") 
        else
            clone.Ended:Connect(function()
                clone:Destroy()
            end)
        end
    end
    return clone
end

function AudioController:playLocally(sound)
    --[[
        input: sound = instance
        plays sound locally
    ]]
    sound:Play()
end

function AudioController:Start()
	AudioService.playLocally:Connect(function(...)
        self:playLocally(...)
    end)
    AudioService.playLocallyFromPart:Connect(function(...)
        self:playFromPart(...)
    end)
end


function AudioController:Init()
	AudioService = self.Services.AudioService
end


return AudioController