
local EVENT = {}

EVENT.Name = "Drow Ranger"
EVENT.Price = 2500
EVENT.Icon = "upgrade_icons/drow_ranger.png"
EVENT.Description = "Guess what this does."

EVENT.Hooks = { "EntityTakeDamage" }

function EVENT:EntityTakeDamage(ent, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if GetRoundState() == ROUND_ACTIVE and ent:IsPlayer() and ent:IsActive() and dmginfo:IsDamageType(DMG_BULLET) and attacker:UpgradeEnabled("drow_ranger") then
		local timername = "timer_drow_"..ent:UniqueID()
		if timer.Exists(timername) then
			timer.Remove(timername)
		end
		ent.UDrow = true
		timer.Create(timername, 1.5, 1, function()
			ent.UDrow = false
		end)
	end
end

TTT_AddUpgrade("drow_ranger", EVENT)
