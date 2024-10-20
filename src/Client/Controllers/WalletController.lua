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
local WalletPage = Pages.Wallet
local AddEth = Pages.AddEth

local BottomFrame = UserInterface.BottomFrame
local WalletButton = BottomFrame.WalletButton 

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
end


return WalletController