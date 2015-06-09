local EVENT = {}

EVENT.Name = "10% Lifesteal"
EVENT.Price = 2000
EVENT.Icon = "upgrade_icons/lifesteal.png"
EVENT.Description = "Gain health when damaging someone."

EVENT.Hooks = { "EntityTakeDamage" }

function EVENT:EntityTakeDamage(ent, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if GetRoundState() == ROUND_ACTIVE and ent:IsPlayer() and ent:IsActive() and IsValid(attacker) and attacker:IsPlayer() and attacker:IsActive() and attacker:UpgradeEnabled("lifesteal") then
		local damages = dmginfo:GetDamage()
		attacker:SetHealth(math.Clamp(attacker:Health() + math.floor(damages/10), 0, 100))
	end
end

TTT_AddUpgrade("lifesteal", EVENT)