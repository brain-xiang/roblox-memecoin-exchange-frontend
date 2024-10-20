-- Coin Service
-- Username
-- October 19, 2024



local CoinService = {Client = {}}

local Booths = workspace.Booths

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

function CoinService:setupBooth(player, Booth, tokenAddress)
    
    if ReplicatedCache.cache.booths[Booth].claimed then warn(player.Name.. " cant claim booth: ".. Booth.name.. " allready owned by: ".. ReplicatedCache.cache.booths[Booth].claimed) return end

    -- wait untl the coin data is available in db
    local maxRepeats = 10
    local repeats = 0
    repeat 
        DataManager.dataUpdatedSignal:Wait()
        repeats = repeats + 1
    until
        DataManager.Data.coins[tokenAddress] or repeats >= maxRepeats
    if repeats >= maxRepeats then warn("Exeeded maxRepeats, new created coin did not arrive in database - ".. tokenAddress .. " booth: ".. Booth.Name.. " Player: ".. "player.Name") return end

    local coinData = DataManager.Data.coins[tokenAddress]

    ReplicatedCache.cache.booths[Booth].claimed = player.UserId
    ReplicatedCache.cache.booths[Booth].coin = tokenAddress

    Booth.Base.ClaimPrompt.Enabled = false
    Booth.Base.InteractPrompt.Enabled = true
    Booth.Base.Unclaimed.Enabled = false
    Booth.Base.ClaimedInfoDisplay.Enabled = true
    Booth.Base.ClaimedInfoDisplay.UserName.Text = player.Name.. "'s coin"

    Booth.ImageFrame.Picture.Decal.Texture = coinData.robloxlogo
    Booth.NamePart.SurfaceGui.Txt.Text = coinData.name
    Booth.PricePart.SurfaceGui.Enabled = true
    Booth.PricePart.SurfaceGui.ChainIcon.Image = ChainConfigs.chain_icons[coinData.chain]
end

function CoinService:updateActiveBooths()
    for Booth, boothData in pairs(ReplicatedCache.cache.booths) do
        local claimedUserid = ReplicatedCache.cache.booths[Booth].claimed
        if claimedUserid then
            local coinData = DataManager.Data.coins[boothData.coin]

            Booth.PricePart.SurfaceGui.Price.Text = "Price: ".. coinData.buyPrice.. " ".. ChainConfigs.chain_to_currency[coinData.chain]
            local MarketCap = formatNumber(coinData.buyPrice * coinData.supply)
            Booth.Base.ClaimedInfoDisplay.MarketCap.Text = "Market Cap: $".. MarketCap
        end
    end
end

function CoinService:resetBooth(Booth)
    local claimedCoin = ReplicatedCache.cache.booths[Booth].coin
    if claimedCoin then
        Booth.Base.ClaimPrompt.Enabled = true
        Booth.Base.InteractPrompt.Enabled = false
        Booth.Base.Unclaimed.Enabled = true
        Booth.Base.ClaimedInfoDisplay.Enabled = false

        Booth.ImageFrame.Picture.Decal.Texture = ""
        Booth.NamePart.SurfaceGui.Txt.Text = ""
        Booth.PricePart.SurfaceGui.Enabled = false

        ReplicatedCache.cache.booths[Booth].claimed = false
        ReplicatedCache.cache.booths[Booth].coin = false
    end
end

function CoinService:Start()
	
    for i,Booth in pairs(Booths:GetChildren()) do
        ReplicatedCache.cache.booths[Booth] = TableUtil.Copy(self.boothDataTemplate)
    end

    self.ConnectClientEvent("setupBooth", function(...)
        self:setupBooth(...)
    end)

    DataManager.dataUpdatedSignal:Connect(function()
        self:updateActiveBooths()
    end)
end


function CoinService:Init()
    ReplicatedCache = self.Services.ReplicatedCache
    DataManager = self.Services.DataManager
    TableUtil = self.Shared.TableUtil
    ChainConfigs = self.shared.ChainConfigs

	self:RegisterClientEvent("setupBooth")
end

return CoinService