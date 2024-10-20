-- Wallet Controller
-- Username
-- October 19, 2024



local WalletController = {}

--variables
local player = game.Players.LocalPlayer


-- UI elements
local PlayerGui = player.PlayerGui
local UserInterface = PlayerGui:WaitForChild("UserInterface")
local EtheriumButton = UserInterface.EtheriumButton
local BalanceLabel = EtheriumButton.BalanceLabel
local WalletId = UserInterface.WalletId

local Pages = UserInterface.Pages
local BuyScreen = Pages.BuyScreen
local AddEth = Pages.AddEth

local BottomFrame = UserInterface.BottomFrame
local WalletButton = BottomFrame.WalletButton 

local WalletPage = Pages.Wallet
local WalletList = WalletPage.List
local WalletTemplate = WalletList.Template

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

function WalletController:findToken(array, targetName)
    -- array has to be Event module
    for i,v in array:ipairs() do
        local name = v.name
        if name == targetName then
            return v
        end
    end
    return nil
end

function WalletController:updateEthCounter(amount)
    amount = amount or self:findToken(LocalCache.playerCache.profile.tokens, "Ether").balanceFormatted
    BalanceLabel.Text = tostring(amount)
    WalletId.Text = "Wallet ID: " .. LocalCache.playerCache.profile.walletAddress
end

function WalletController:loadWallet()
    local tokens = LocalCache.playerCache.profile.tokens
    local totalBalance = 0
    for i,tokenData in ipairs(tokens) do
        local walletEntry = WalletTemplate:Duplicate()
        walletEntry.Name = tokenData.name
        walletEntry.Parent = WalletList

        walletEntry.Name.Text = tokenData.Name
        walletEntry.Amount.Text = tokenData.balanceFormatted.. " ".. ChainConfigs.chain_to_currency[string.upper(tokenData.chain)]
        walletEntry.Icon.Image = tokenData.robloxlogo

        local coinData = LocalCache.cache.coins[tokenData.tokenAddress]
        local totalWorth = coinData.sellPrice * tokenData.balanceFormatted

        walletEntry.TotalWorth.Text = "$".. totalWorth

        totalBalance = totalBalance + totalWorth
    end

    WalletPage.TotalBalance = "$".. formatNumber(totalBalance)
end

function WalletController:Start()
    EtheriumButton.MouseButton1Down:Connect(function()
        AddEth.Visible = not AddEth.Visible
    end)
    AddEth.Close.MouseButton1Down:Connect(function()
        AddEth.Visible = false
    end)
    
    -- Wallet 
    WalletButton.MouseButton1Down:Connect(function()
        WalletPage.Visible = not WalletPage.Visible
        if WalletPage.Visible then
            self:loadWallet()
        end
    end)
    WalletPage.Close.MouseButton1Down:Connect(function()
        WalletPage.Visible = false
    end)

    repeat task.wait() until LocalCache.loaded and LocalCache.playerCache.profile
    
    self:updateEthCounter()
    LocalCache.playerCache.profile.mutated:Connect(function(old, new)
        self:updateEthCounter()
    end)

    
end


function WalletController:Init()
	LocalCache = self.Controllers.LocalCache
    ChainConfigs = self.Shared.ChainConfigs

end


return WalletController