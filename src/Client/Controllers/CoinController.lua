-- Coin Controller
-- Username
-- October 19, 2024



local CoinController = {}

local Booths = workspace.Booths

--UI
local player = game.Players.LocalPlayer
local PlayerGui = player.PlayerGui
local UserInterface = PlayerGui:WaitForChild("UserInterface")

local Pages = UserInterface.Pages
local BuyScreen = Pages.BuyScreen
local CreateCoinScreen = Pages.CreateCoin
local CreateCoinScreenList = CreateCoinScreen.List
local CreateCoinButton = CreateCoinScreen.Create

local BuyScreen = Pages.BuyScreen
local BuySellSelectFrame = BuyScreen.BuySell

-- variables

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

function CoinController:updateTotal(mode)
    if not self.interactingBooth then return end
    local claimedCoin = LocalCache.cache.booths[self.interactingBooth].coin
    if not claimedCoin then return end
    local coinData = LocalCache.cache.coins[claimedCoin]

    local amount = tonumber(BuyScreen.BidAmount.TextBox.Text)
    if not amount then BuyScreen.BidAmount.TextBox.Text = "" return end
    if mode == "Buy" then
        local total = amount / coinData.buyAmount
        BuyScreen.Total.Text = formatNumber(total).. " ".. coinData.symbol
    else
        local total = amount / coinData.sellAmount
        BuyScreen.Total.Text = formatNumber(total).. " ".. ChainConfigs.chain_to_currency[coinData.chain]
    end
end

function CoinController:selectMode(mode)
    if not self.interactingBooth then return end
    local claimedCoin = LocalCache.cache.booths[self.interactingBooth].coin
    if not claimedCoin then return end
    local coinData = LocalCache.cache.coins[claimedCoin]

    if mode == "Buy" then
        BuyScreen.BidAmount.ChainIcon.Image = ChainConfigs.chain_icons[coinData.chain]
        BuyScreen.BidAmount.ChainIcon.ChainName.Text = ChainConfigs.chain_to_currency[coinData.chain]
        BuyScreen.Price.Text = "Price: ".. coinData.buyPrice.. " ".. ChainConfigs.chain_to_currency[coinData.chain]
        self:updateTotal(mode)
    elseif mode == "Sell" then
        BuyScreen.BidAmount.ChainIcon.Image = coinData.robloxlogo
        BuyScreen.BidAmount.ChainIcon.ChainName.Text = coinData.symbol
        BuyScreen.Price.Text = "Price: ".. coinData.sellPrice.. " ".. coinData.symbol
        self:updateTotal(mode)
    end
    
end

function CoinController:promptBuyScreen(Booth, mode)
    local mode = mode or "Buy"
    local claimedCoin = LocalCache.cache.booths[Booth].coin
    if claimedCoin then
        local coinData = LocalCache.cache.coins[claimedCoin]

        BuyScreen.CoinName.Text = coinData.name
        BuyScreen.Description.Text = coinData.description
        BuyScreen.tokenAddress.Text = "Coin Address: ".. claimedCoin
        BuyScreen.CoinIcon.Image = coinData.robloxlogo

        BuyScreen.Creator.Text = "Creator: ".. game.Players:GetPlayerByUserId(coinData.creatorRobloxUserId).Name

        local MarketCap = formatNumber(coinData.buyPrice * coinData.supply)
        BuyScreen.MarketCap.Text = "Market Cap: $".. MarketCap

        self.store.buysellSelect.states.selected = mode
    end
end

function CoinController:confirmTrade()
    if not self.interactingBooth then return end
    local claimedCoin = LocalCache.cache.booths[self.interactingBooth].coin
    if not claimedCoin then return end
    local coinData = LocalCache.cache.coins[claimedCoin]

    local amount = tonumber(BuyScreen.BidAmount.TextBox.Text)
    if not amount then BuyScreen.BidAmount.TextBox.Text = "" return end

    if self.store.buysellSelect.states.selected == "Buy" then
        
    else -- Sell

    end
end

function CoinController:SetupEmptyBooth(Booth)
    local ClaimPrompt = Booth.Base.ClaimPrompt
    ClaimPrompt.Triggered:Connect(function(player)
        self.pendingBooth = Booth
        CreateCoinScreen.Visible = true
    end)
    local InteractPrompt = Booth.Base.InteractPrompt
    InteractPrompt.Triggered:Connect(function(player)
        self:promptBuyScreen(Booth)
        BuyScreen.Visible = true
        self.interactingBooth = Booth
    end)
end


function CoinController:createCoin()
    
    local coinData = {}

    for i,frame in pairs(CreateCoinScreenList:GetChildren()) do
        if frame.Name == "Chain" then
            coinData["chain"] = self.store.selectChainInCreate.states.selected
        elseif frame:IsA("Frame") then
            coinData[frame.Name] = frame.TextBox.Text
        end
    end

    -- fire http
    local temptxt = CreateCoinButton.TextLabel.Text
    CreateCoinButton.TextLabel.Text = "Loading..."

    print(coinData)

    task.wait(1)

    -- if successfully created coin
    CoinService.setupBooth:Fire(player, self.pendingBooth, tokenAddress)

    -- after all processsing
    self.pendingBooth = nil
    CreateCoinScreen.Visible = false
    CreateCoinButton.TextLabel.Text = temptxt

end

function CoinController:Start()
    repeat task.wait() until LocalCache.loaded

    self.store = {
        selectChainInCreate = Robi.create(CreateCoinScreenList.Chain, RobiClasses.SelectFrame),
        buysellSelect = Robi.create(BuySellSelectFrame, {
            [RobiClasses.SelectFrame] = {"Buy"}
        })
    }
    Robi:run(self.store)

    for i,Booth in pairs(Booths:GetChildren()) do
        self:SetupEmptyBooth(Booth)
    end

    self.store.buysellSelect.states:GetPropertyChangedSignal("selected"):Connect(function(old, new)
        self:selectMode(new)
    end)

    CreateCoinButton.MouseButton1Down:Connect(function()
        self:createCoin()
    end)

    CreateCoinScreen.Close.MouseButton1Down:Connect(function()
        self.pendingBooth = nil
        CreateCoinScreen.Visible = false
    end)
    BuyScreen.Close.MouseButton1Down:Connect(function()
        self.interactingBooth = nil
        BuyScreen.Visible = false
    end)
    BuyScreen.BidAmount.TextBox.FocusLost:Connect(function()
        self:updateTotal(self.store.buysellSelect.states.selected)
    end)

    BuyScreen.Confirm.MouseButton1Down:Connect(function()
        self:confirmTrade()
    end)
end


function CoinController:Init()
    LocalCache = self.Controllers.LocalCache
	WalletController = self.Controllers.WalletController
    Robi = self.Modules.RobiFramework.Main
    RobiClasses = self.Modules.RobiFramework.Classes
    ChainConfigs = self.Shared.ChainConfigs

    CoinService = self.Services.CoinService

    self.pendingBooth = nil
    self.interactingBooth = nil
end


return CoinController