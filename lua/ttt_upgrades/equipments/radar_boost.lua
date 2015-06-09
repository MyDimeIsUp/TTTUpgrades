
local EVENT = {}

EVENT.Name = "Hunter"
EVENT.Price = 1700
EVENT.Icon = "upgrade_icons/radar.png"
EVENT.Description = "The radar only takes 15 seconds to reload."

if CLIENT then
	EVENT.Hooks = { "TTTBoughtItem" }
else
	EVENT.Hooks = { "Think" }
end

if SERVER then
	function EVENT:Think()
		if GetRoundState() == ROUND_ACTIVE then
			for k,v in pairs(player.GetHumans()) do
				if not v:IsActiveTraitor() and not v:HasEquipmentItem(EQUIP_RADAR) then continue end
				if v.radar_charge > CurTime() and not v.done_radar_charge then
					v.radar_charge = v.radar_charge - 15
					v.done_radar_charge = true
				end
				if v.radar_charge < CurTime() and v.done_radar_charge then
					v.done_radar_charge = false
				end
			end
		end
	end
else
	function EVENT:TTTBoughtItem(is_item, id)
		if is_item and id == EQUIP_RADAR then
			if UpgradeEnabled and UpgradeEnabled("radar_boost") then
				RADAR.duration = 16
			else
				RADAR.duration = 30
			end
		end
	end
end

TTT_AddUpgrade("radar_boost", EVENT)