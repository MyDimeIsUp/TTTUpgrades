
local EVENT = {}

EVENT.Name = "Money"
EVENT.Price = 2400
EVENT.Icon = "upgrade_icons/money.png"
EVENT.Description = "Start the round with an extra credit."

if SERVER then
	EVENT.Hooks = { "TTTBeginRound" }

	function EVENT:TTTBeginRound()
		for k,v in pairs(player.GetHumans()) do
			if v:IsActiveSpecial() and v:UpgradeEnabled("money") then
				v:AddCredits(1)
			end
		end
	end
end

TTT_AddUpgrade("money", EVENT)