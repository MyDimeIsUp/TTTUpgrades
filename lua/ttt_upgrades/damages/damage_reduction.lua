local EVENT = {}

EVENT.Name = "Armor"
EVENT.Price = 1500
EVENT.Icon = "upgrade_icons/armor.png"
EVENT.Description = "Reduces taken damages by 10%."

EVENT.Hooks = { "EntityTakeDamage" }

function EVENT:EntityTakeDamage(ent, dmginfo)
	if GetRoundState() == ROUND_ACTIVE and ent:IsPlayer() and ent:IsActive() and dmginfo:GetAttacker() != ent and ent:UpgradeEnabled("damage_reduction") then
		dmginfo:ScaleDamage(0.9)
	end
end

TTT_AddUpgrade("damage_reduction", EVENT)