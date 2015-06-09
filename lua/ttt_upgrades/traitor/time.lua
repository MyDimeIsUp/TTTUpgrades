
local EVENT = {}

EVENT.Name = "Time"
EVENT.Price = 1000
EVENT.Icon = "upgrade_icons/time.png"
EVENT.Description = "Gain 15 extra seconds when killing someone."

EVENT.Hooks = { "PlayerDeath" }

function EVENT:PlayerDeath(ply, inflictor, killer)
	if GetRoundState() == ROUND_ACTIVE and killer != ply and killer:IsPlayer() and killer:UpgradeEnabled("time") then
		IncRoundEnd(15)
	end
end

TTT_AddUpgrade("time", EVENT)