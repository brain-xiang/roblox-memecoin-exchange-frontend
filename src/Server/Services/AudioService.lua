-- Sound Service
-- Username
-- April 4, 2021



local AudioService = {Client = {}}

local PLAY_SOUND_LOCALLY_EVENT = "playLocally"
local PLAY_SOUND_LOCALLY_FROM_PART_EVENT = "playLocallyFromPart"

function AudioService:getProperty(instance, propertyName)
    local property;
    
    pcall(function()
        if typeof(instance[propertyName]) ~= "Instance" then 
            property = instance[propertyName]
        end
    end)

    return property
end

function AudioService:playFromPart(sound, parent, deleteOnClomplete, properties)
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
    if properties then
        for property, value in pairs(properties) do
            if self:getProperty(sound, property) then
                sound[property] = value
            end
        end
    end

    

    clone.Parent = parent
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

function AudioService:playLocally(players, sound)
    --[[
        input: players = playerInstance or tbl of player instances, sound = Instance
        players the sound locally for players provided
    ]]
    players = typeof(players) == "Instance" and {players} or players
    for i,player in pairs(players) do
        self:FireClient(PLAY_SOUND_LOCALLY_EVENT, player, sound)
    end
end

function AudioService:playeLocallyFromPart(players, sound, parent, deleteOnClomplete, properties)
     --[[
        input: 
            players = playerInstance or tbl of player instances, sound = Instance
            sound = Instance, 
            parent = Instance, parent which sound is played on, 
            deleteOnClomplete = bool, if clone is deleted when complete
            properties = tbl, table of properties thats diffrent in clone than original
        plays the sound locally for "players" from part
    ]]
    players = typeof(players) == "Instance" and {players} or players
    for i,player in pairs(players) do
        self:FireClient(PLAY_SOUND_LOCALLY_FROM_PART_EVENT, player, sound, parent, deleteOnClomplete, properties)
    end
end

function AudioService:Start()
	
end


function AudioService:Init()
    self:RegisterClientEvent(PLAY_SOUND_LOCALLY_FROM_PART_EVENT)
	self:RegisterClientEvent(PLAY_SOUND_LOCALLY_EVENT)
end


return AudioService