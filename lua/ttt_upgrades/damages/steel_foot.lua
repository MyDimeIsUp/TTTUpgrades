local EVENT = {}

EVENT.Name = "Steel foot"
EVENT.Price = 1200
EVENT.Icon = "upgrade_icons/steel_foot.png"
EVENT.Description = "Reduces fall damages by 30%."

EVENT.Hooks = { "EntityTakeDamage" }

function EVENT:EntityTakeDamage(ent, dmginfo)
	if GetRoundState() == ROUND_ACTIVE and ent:IsPlayer() and ent:IsActive() and dmginfo:IsFallDamage() and ent:UpgradeEnabled("steel_foot") then
		dmginfo:ScaleDamage(0.7)
	end
end

TTT_AddUpgrade("steel_foot", EVENT)