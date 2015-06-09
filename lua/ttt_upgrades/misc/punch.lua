local EVENT = {}

EVENT.Name = "Punch"
EVENT.Price = 1500
EVENT.Icon = "upgrade_icons/punch.png"
EVENT.Description = "Replaces hosterled by fists dealing 15-20 damages."

if SERVER then

	EVENT.Hooks = { "PlayerLoadout" }
	
	function EVENT:PlayerLoadout(v)
			if v:Alive() and v:UpgradeEnabled("punch") then
				v:StripWeapon("weapon_ttt_unarmed")
				v:Give("weapon_ttt_fists")
			end
	end

end

TTT_AddUpgrade("punch", EVENT)