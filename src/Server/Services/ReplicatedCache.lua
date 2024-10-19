-- Replicated Cache
-- Legenderox
-- December 14, 2020



local ReplicatedCache = {Client = {}}

local UPPDATE_LOCAL_CACHE_EVENT = "UppdateCache"
local UPPDATE_PLAYER_CACHE_EVENT = "UppdatePlayerCache"

ReplicatedCache.defaultCache = {
    score = {
        Team1 = 0,
        Team2 = 0,
    },
    capturePoints = {
        A = {},
        B = {},
        C = {},
    },
    Leaderboard = {}, --[UserId] = {player leaderboard}
}

ReplicatedCache.defaultPlayerCache = {
    ShipStats = nil,
    ShipVariables = nil,
    state = "loading", --[[
        loading
        deploy
        alive
        sinking
    ]]
    profile = nil, -- Data Store profileService profile
    lastDeath = 0, -- last death in 
    ship = nil,
    earnings = {
        db = {
        --  category* = amount*
            total = 0
        },
        xp = {
            total = 0
        },
    }
}

function ReplicatedCache.Client:getCache(player)
    return ReplicatedCache.cache:GetProperties()
end

function ReplicatedCache.Client:getPlayerCache(player)
    return ReplicatedCache.playerCaches[player.UserId]:GetProperties()
end

function ReplicatedCache:replicateCache(player)
    --[[
        input: player = optional* only if cache is only replicaed to a single player
        Fires Uppdate local cache event with cacheChanges in a table if there has been a change in the cache.

        NOTE: Nil values do not replicate, use "nil"(string) instead to nullify values
    ]]

    local properties = self.cache:GetProperties()
    local cacheChanges = TableUtil:returnDictionaryWithoutDuplicates(properties, self.replicatedCache)
    
    if cacheChanges ~= {} then
        if player then
            self:FireClient(UPPDATE_LOCAL_CACHE_EVENT, player, cacheChanges)
        else
            self:FireAllClients(UPPDATE_LOCAL_CACHE_EVENT, cacheChanges)
        end
        self.replicatedCache = properties
    end
end

function ReplicatedCache:replicatePlayerCache(player)
    --[[
        Input: player = which player's cache is uppdated
        Fires specified players client event with cacheChanges in a table if there has been a change in the cache.

        NOTE: Nil values do not replicate, use false instead to nullify values
    ]]

    local cache = self.playerCaches[player.UserId]
    local properties = cache:GetProperties()
    local cacheChanges = TableUtil:returnDictionaryWithoutDuplicates(properties, self.replicatedPlayerCaches[player.UserId])
    
    if cacheChanges ~= {} then
        self:FireClient(UPPDATE_PLAYER_CACHE_EVENT, player, cacheChanges)
        self.replicatedPlayerCaches[player.UserId] = properties
    end
end

function ReplicatedCache:Start()
    game:GetService("Players").PlayerAdded:Connect(function(player)
        self.playerCaches[player.UserId] = TableUtil.Copy(self.defaultPlayerCache)
        self.replicatedPlayerCaches[player.UserId] = {}

        self.playerCaches[player.UserId].mutated:Connect(function(oldTable, newTable)
            self:replicatePlayerCache(player)
        end)
    end)

    self.cache.mutated:Connect(function()
        self:replicateCache()
    end)
end

function ReplicatedCache:Init()
    EventModule = self.Shared.EventModule
    TableUtil = self.Shared.TableUtil
    
    self:RegisterClientEvent(UPPDATE_LOCAL_CACHE_EVENT)
    self:RegisterClientEvent(UPPDATE_PLAYER_CACHE_EVENT)

    self.cache = EventModule.new(self.defaultCache)
    self.replicatedCache = {}

    self.playerCaches = EventModule.new()
    self.replicatedPlayerCaches = {}
end

return ReplicatedCache