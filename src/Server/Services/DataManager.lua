-- Data Manager
-- Legenderox
-- September 14, 2020

--[[
    DATASTORE 
        Name: "SavedData"
        Key: player.UserId.. DataManager.ProfileTemplate.Reset,
]]

local DataManager = {Client = {}}

DataManager.Data = {
    reset = 0,
    profiles = {
        --[[ userId:int = {
            "walletAddress" = str
            "tokens" = {
                int = {
                    "tokenAddress": "0x0000000000000000000000000000000000000000",
                    "symbol": "ETH",
                    "name": "Ether",
                    "decimals": 18,
                    "balance": "0",
                    "chain": "ethereum",
                    "logo": "https://assets.coingecko.com/coins/images/279/large/ethereum.png?1796501428",
                    "robloxlogo": "rbxassetid://106302508426873"
                    "balanceFormatted": "0",
                    "_id": "67145fac04e9876171971bfd"
                }
            }
        }]]
    },
    coins = {
        --[[{
            name: string;
            symbol: string;
            description: string;
            decimals: number;
            supply: string;
            chain: string;
            logo: string;
            robloxlogo: string;
            buyPrice: string;
            sellPrice: string;
            tokenAddress: string;
            creatorWalletAdress: string;
            creatorRobloxUserId: string;
        }]]
    }
}
DataManager.copiedProfiles = {}

-- 60 requests per minute roblxo rate limit
local user_data_update_frequency = 25 -- every 4 seconds get every user in this server's data from db
local coin_data_update_frequency = 25 -- every 2 seconds get data of all coins globally from db 
local user_update_delay = 60/user_data_update_frequency
local coin_update_delay = 60/user_data_update_frequency

----- Private Variables -----
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

----- Functions -----
function DataManager:getPlayerData(player)
    print("Getting all player data")

    local userIds = {}
    if player then
        userIds = {"robloxUserIds=" .. tostring(player.UserId)}
    else
        local players = Players:GetPlayers()
        for i,v in ipairs(players) do
            table.insert(userIds, "robloxUserIds=" .. tostring(v.UserId))
        end
    end
    userIds = table.concat(userIds, "&") -- turning into csv

    local success, response = pcall(function()
        return HttpService:GetAsync("https://memecoin-backend-3w6fx.ondigitalocean.app/wallets?" .. userIds)
    end)

    if success then
        -- Handle the response
        print("successfully retrieved all player data")
        local profiles = HttpService:JSONDecode(response)
        self.Data.profiles = {}
        for i,profile in pairs(profiles) do
            self.Data.profiles[tonumber(profile.robloxUserId)] = {
                walletAddress = profile.walletAddress,
                createdAt = profile.createdAt,
                updatedAt = profile.updatedAt,
                tokens = profile.tokens,
            }
        end
    else
        -- Handle any errors
        warn("failed to retrieve player data: " .. response)
    end
end

function DataManager:PlayerAdded(player)
    print("added")
    self.dataUpdatedSignal:Wait()
    if not self.Data.profiles[player.userId] then
        print("creating wallet")

        local payload = {
            robloxUserId = player.UserId,
        }
        local success, response = pcall(function()
            return HttpService:PostAsync("https://memecoin-backend-3w6fx.ondigitalocean.app/wallets", HttpService:JSONEncode(payload))
        end)

        if success then
            -- Handle the response
            print("successfully created wallet for player " .. tostring(player.UserId))
            local profile = HttpService:JSONDecode(response)
            self.Data.profiles[player.UserId] = {
                walletAddress = profile.walletAddress,
                createdAt = profile.createdAt,
                updatedAt = profile.updatedAt,
                tokens = profile.tokens,
            }
        else
            -- Handle any errors
            warn("failed to create player wallet: " .. tostring(player.UserId) .. response)
        end
    end
    print("data loaded")
end

function DataManager:PlayerRemoving(Player)
    
end

function DataManager:copyToReplicatedCache(player)
    local profiles;
    if player then
        profiles = {}
        profiles[player.userId] = self.Data.profiles[player.UserId] or {}
    else
        profiles = self.Data.profiles
    end

    for userid, profile in pairs(profiles) do
        self.copiedProfiles[userid] = self.copiedProfiles[userid] or {}
        if ReplicatedCache.playerCaches[userid] and not TableUtil.Equal(profile, self.copiedProfiles[userid]) then 
            local clone = TableUtil.Copy(profile)
            ReplicatedCache.playerCaches[userid].profile = clone
            self.copiedProfiles[userid] = clone
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

    while task.wait(user_update_delay) do
        self:getPlayerData()
        self:copyToReplicatedCache()
        self.dataUpdatedSignal:Fire()
    end
end


function DataManager:Init()
    ReplicatedCache = self.Services.ReplicatedCache
    TableUtil = self.Shared.TableUtil
    Signal = self.Shared.Signal

    self.dataUpdatedSignal = Signal.new()
end


return DataManager