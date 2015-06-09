local EVENT = {}

EVENT.Name = "Extra damages"
EVENT.Price = 1500
EVENT.Icon = "upgrade_icons/extra_damages.png"
EVENT.Description = "10% extra damages."

EVENT.Hooks = { "EntityTakeDamage" }

function EVENT:EntityTakeDamage(ent, dmginfo)
	if GetRoundState() == ROUND_ACTIVE and ent:IsPlayer() and ent:IsActive() and dmginfo:GetAttacker() != ent and ent:UpgradeEnabled("extra_damages") then
		dmginfo:ScaleDamage(1.1)
	end
end

TTT_AddUpgrade("extra_damages", EVENT)