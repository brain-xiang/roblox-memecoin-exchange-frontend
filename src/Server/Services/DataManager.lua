-- Data Manager
-- Legenderox
-- September 14, 2020

--[[
    DATASTORE 
        Name: "SavedData"
        Key: player.UserId.. DataManager.ProfileTemplate.Reset,
]]

local DataManager = {Client = {}}

DataManager.ProfileTemplate = {
    Reset = 0; -- mainplace reset or test place reset
	Profile = {
		
	}
}

DataManager.TestingProfileTemplate = { -- template used when not in GameConfig.LIVE_GAME_ID, REset > 100
    Reset = 100; 
	Profile = {
		
	}
}


----- Private Variables -----
local Players = game:GetService("Players")

----- Functions -----
function DataManager:PlayerAdded(player)
    print("added")
    local template = self.ProfileTemplate
    local profile = GameProfileStore:LoadProfileAsync(
        player.UserId.. "_".. template.Reset,
        "ForceLoad"
    )
    if profile ~= nil then
        profile:ListenToRelease(function()
            DataManager.Profiles[player] = nil
            -- The profile could've been loaded on another Roblox server:
            player:Kick("The profile could've been loaded on another Roblox server")
        end)
        if player:IsDescendantOf(Players) == true then
            DataManager.Profiles[player] = profile
            self.copiedProfiles[player] = {}
            self:copyToReplicatedCache(player)
            print("A profile has been successfully loaded: ".. player.Name)
        else
            print("Player left before the profile loaded: ".. player.Name)
            profile:Release()
        end
    else
        print("The profile couldn't be loaded possibly due to other Roblox servers trying to load this profile at the same time: ".. player.Name)
        player:Kick("The profile couldn't be loaded possibly due to other Roblox servers trying to load this profile at the same time") 
    end
end

function DataManager:PlayerRemoving(Player)
    local Profile = DataManager.Profiles[Player]
    if Profile then
        Profile:Release()
    end
end

function DataManager:copyToReplicatedCache(player)
    local profiles;
    if player then
        profiles = {}
        profiles[player] = self.Profiles[player]
    else
        profiles = self.Profiles
    end

    for player, profile in pairs(profiles) do
        if not TableUtil.Equal(profile.Data, self.copiedProfiles[player]) then 
            local clone = TableUtil.Copy(profile.Data)
            ReplicatedCache.playerCaches[player.UserId].profile = clone
            self.copiedProfiles[player] = clone
        end
    end
end

----- Initialize -----
function DataManager:Start()
	-- In case Players have joined the server earlier than this script ran:
    for _, player in ipairs(Players:GetPlayers()) do
        Spawn(function()
            self:PlayerAdded(player)
        end)
    end

    Players.PlayerAdded:Connect(function(player)
        self:PlayerAdded(player)
    end)
    Players.PlayerRemoving:Connect(function( ... )
        self:PlayerRemoving(...)
    end)

    

    while true do
        self:copyToReplicatedCache()
        wait(2)
    end
end


function DataManager:Init()
    ReplicatedCache = self.Services.ReplicatedCache
    TableUtil = self.Shared.TableUtil

    --Setting up Profile service
    local ProfileService = self.Modules.ProfileService
    local template = self.ProfileTemplate
    GameProfileStore = ProfileService.GetProfileStore(
        "SavedData",
        template.Profile
    )
    self.Profiles = {} -- [player] = profile
    self.copiedProfiles = {}
end


return DataManager