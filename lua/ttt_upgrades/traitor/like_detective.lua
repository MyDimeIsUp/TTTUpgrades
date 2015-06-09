
local EVENT = {}

EVENT.Name = "Like a Detective"
EVENT.Price = 2300
EVENT.Icon = "upgrade_icons/like_detective.png"
EVENT.Description = "Start the round with an Armor."

EVENT.Hooks = { "TTTBeginRound" }

function EVENT:TTTBeginRound()
	if SERVER then
		for k,v in pairs(player.GetHumans()) do
			if v:IsActiveTraitor() and v:UpgradeEnabled("like_detective") then
				v:GiveEquipmentItem(EQUIP_ARMOR)
			end
		end
	end
end

TTT_AddUpgrade("like_detective", EVENT)