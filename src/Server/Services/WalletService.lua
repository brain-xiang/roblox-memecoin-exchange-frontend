-- Wallet Service
-- Username
-- October 19, 2024



local WalletService = {Client = {}}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

function WalletService:CloneOverheadUI(player)
    local OverheadUI = ReplicatedStorage:FindFirstChild("OverheadUI"):Clone()

    OverheadUI.PlayerName.Text = player.Name
    OverheadUI.WalletID.Text = "Wallet ID:<br /> " .. tostring(ReplicatedCache.playerCaches[player.UserId].profile.walletAddress)

    OverheadUI.Parent = player.Character.HumanoidRootPart
end

function WalletService:Start()
	game.Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            repeat task.wait() until ReplicatedCache.playerCaches[player.UserId].profile
            self:CloneOverheadUI(player)
        end)
    end)
end


function WalletService:Init()
	ReplicatedCache = self.Services.ReplicatedCache
end


return WalletService