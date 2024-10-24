-- Coin Service
-- Username
-- October 19, 2024



local CoinService = {Client = {}}

local Booths = workspace.Booths
local HttpService = game:GetService("HttpService")

local boothDataTemplate = {
    claimed = false,
    coin = false,
}

local function formatNumber(num)
    local formatted = string.format("%.2f", num) -- Format to two decimal places

    -- Add commas to the integer part of the number
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end

    return formatted
end

function CoinService:setupBooth(player, BoothName, name)
    if ReplicatedCache.cache.booths[BoothName].claimed then warn(player.Name.. " cant claim booth: ".. BoothName.. " allready owned by: ".. ReplicatedCache.cache.booths[BoothName].claimed) return end

    -- wait untl the coin data is available in db
    local maxRepeats = 10
    local repeats = 0
    local tokenAddress
    local coinData
    while true do
        DataManager.dataUpdatedSignal:Wait()
        repeats = repeats + 1
        for i,v in pairs(DataManager.Data.coins) do
            if v.name == tostring(name) then
                tokenAddress = i
                coinData = v
                break
            end
        end
        if tokenAddress then break end
        if repeats >= maxRepeats then
            warn("Exeeded maxRepeats, new created coin did not arrive in database - ".. tokenAddress .. " booth: ".. BoothName.. " Player: ".. "player.Name")
            return
        end
    end 

    ReplicatedCache.cache.booths[BoothName].claimed = player.UserId
    ReplicatedCache.cache.booths[BoothName].coin = tokenAddress
    print("TOKE ADREESS", tokenAddress)

    local Booth = Booths[BoothName]
        
    Booth.Base.ClaimPrompt.Enabled = false
    Booth.Base.InteractPrompt.Enabled = true
    Booth.Base.Unclaimed.Enabled = false
    Booth.Base.ClaimedInfoDisplay.Enabled = true
    Booth.Base.ClaimedInfoDisplay.UserName.Text = player.Name.. "'s coin"

    Booth.ImageFrame.Picture.Decal.Texture = coinData.robloxlogo
    Booth.ImageFrame.Picture.Decal.Transparency = 0
    Booth.NamePart.SurfaceGui.Txt.Text = coinData.symbol
    Booth.PricePart.SurfaceGui.Enabled = true
    Booth.PricePart.SurfaceGui.ChainIcon.Image = ChainConfigs.chain_icons[coinData.chain]
end

function CoinService:updateActiveBooths()
    for BoothName, boothData in ReplicatedCache.cache.booths:pairs() do
        local Booth = Booths[BoothName]
        local claimedUserid = ReplicatedCache.cache.booths[BoothName].claimed
        if claimedUserid then
            local coinData = DataManager.Data.coins[boothData.coin]

            Booth.PricePart.SurfaceGui.Price.Text = "Price: ".. coinData.buyPrice.. " ".. ChainConfigs.chain_to_currency[coinData.chain]
            local MarketCap = formatNumber(coinData.buyPrice * coinData.supply)
            Booth.Base.ClaimedInfoDisplay.MarketCap.Text = "Market Cap: $".. MarketCap
        end
    end
end

function CoinService:resetBooth(Booth)
    local claimedCoin = ReplicatedCache.cache.booths[Booth.Name].coin
    if claimedCoin then
        Booth.Base.ClaimPrompt.Enabled = true
        Booth.Base.InteractPrompt.Enabled = false
        Booth.Base.Unclaimed.Enabled = true
        Booth.Base.ClaimedInfoDisplay.Enabled = false

        Booth.ImageFrame.Picture.Decal.Texture = ""
        Booth.NamePart.SurfaceGui.Txt.Text = ""
        Booth.PricePart.SurfaceGui.Enabled = false

        ReplicatedCache.cache.booths[Booth.Name].claimed = false
        ReplicatedCache.cache.booths[Booth.Name].coin = false
    end
end

function CoinService.Client:createCoin(player, coinData, BoothName)
    -- fire http
    local payload = HttpService:JSONEncode(coinData)

    local success, response = pcall(function()
        return HttpService:PostAsync("https://memecoin-backend-3w6fx.ondigitalocean.app/coins", payload)
    end)

    if success then
        print("successfully created the coin")
        local responseData = HttpService:JSONDecode(response)
        print(responseData, "response data")
        local name = responseData.name
        CoinService:setupBooth(player, BoothName, name)
    else
        warn("Failed to create a coin", response)
    end
end

function CoinService:Start()
	
    for i,Booth in pairs(Booths:GetChildren()) do
        ReplicatedCache.cache.booths[Booth.Name] = TableUtil.Copy(boothDataTemplate)
    end

    self:ConnectClientEvent("setupBooth", function(player, BoothName, tokenAddress)
        self:setupBooth(player, BoothName, tokenAddress)
    end)

    DataManager.dataUpdatedSignal:Connect(function()
        self:updateActiveBooths()
    end)

    --self:setupBooth(game.Players:WaitForChild("Legenderox"), "Booth2", "tokenAddress")
end


function CoinService:Init()
    ReplicatedCache = self.Services.ReplicatedCache
    DataManager = self.Services.DataManager
    TableUtil = self.Shared.TableUtil
    ChainConfigs = self.Shared.ChainConfigs

	self:RegisterClientEvent("setupBooth")
end

return CoinService