-- Local Cache
-- Username
-- December 14, 2020



local LocalCache = {}

function LocalCache:mergeCacheAndDictionary(Dictionary, cache)
    --[[
		input: Dictionary = raw dicitonary that is merged into the cache (EventModule Object),
		NOTE: nil in Dictionary wont be merged into the cache, use "nil"(string) instead to nullify values
	]]
    if not Dictionary or typeof(Dictionary) ~= "table" then warn("Dictionary passed into mergeCacheAndDictionary is not a table", TableUtil.Print(Dictionary, "Dictionary", true)) return nil end
    if not cache or typeof(cache) ~= "table" then warn("cache passed into mergeCacheAndDictionary is not a table", TableUtil.Print(Dictionary, "Dictionary", true)) return nil end

	for i,v in pairs(Dictionary) do
        if typeof(v) == "table" then
            if not cache[i] or typeof(cache[i]) ~= "table" then
                cache[i] = {}
            end
			self:mergeCacheAndDictionary(v, cache[i])
		elseif cache[i] ~= v then         
            if v == "nil" then
                cache[i] = nil
            else
                cache[i] = v
            end     
		end
	end
end 

function LocalCache:Start()
    ReplicatedCache.UppdateCache:Connect(function(cacheChanges)
        self:mergeCacheAndDictionary(cacheChanges, self.cache)
    end)
    ReplicatedCache.UppdatePlayerCache:Connect(function(cacheChanges)
        self:mergeCacheAndDictionary(cacheChanges, self.playerCache)
    end)
end

function LocalCache:Init()
    EventModule = self.Shared.EventModule
    TableUtil = self.Shared.TableUtil
    ReplicatedCache = self.Services.ReplicatedCache

    self.cache = EventModule.new()
    self:mergeCacheAndDictionary(ReplicatedCache:getCache(), self.cache)
    self.playerCache = EventModule.new()
    self:mergeCacheAndDictionary(ReplicatedCache:getPlayerCache(), self.playerCache)
    self.loaded = true
end

return LocalCache