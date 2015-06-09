local EVENT = {}

EVENT.Name = "Pyro"
EVENT.Price = 1600
EVENT.Icon = "upgrade_icons/pyro.png"
EVENT.Description = "Incendiary grenades stay 10 seconds longer."

if SERVER then
	EVENT.Hooks = { "Initialize" }
end

function EVENT:Initialize()
	local old_StartFires = StartFires
	function StartFires(pos, tr, num, lifetime, explode, dmgowner)
		if not explode and IsValid(dmgowner) and dmgowner:IsPlayer() and dmgowner:UpgradeEnabled("pyro") then
			lifetime = lifetime + 10
		end
		return old_StartFires(pos, tr, num, lifetime, explode, dmgowner)
	end
end		

TTT_AddUpgrade("pyro", EVENT)