
local EVENT = {}

EVENT.Name = "DNA"
EVENT.Price = 1400
EVENT.Icon = "upgrade_icons/dna.png"
EVENT.Description = "Makes the DNA Scanner 20% faster."

local function Enabled(ply)
	return (SERVER and ply:UpgradeEnabled("dna")) or (CLIENT and UpgradeEnabled("dna"))
end

EVENT.Hooks = { "Initialize" }

function EVENT:Initialize()
	for k,v in pairs(weapons.GetList()) do
		if v.ClassName == "weapon_ttt_wtester" then
			local old_SetupDataTables = v.SetupDataTables
			v.SetupDataTables = function(dna)
				local s = old_SetupDataTables(dna)
				local old_SetCharge = dna.SetCharge
				dna.SetCharge = function(_dna, charge)
					if charge == (_dna:GetCharge() + 3) and IsValid(_dna.Owner) and Enabled(_dna.Owner) then
						charge = charge + 3 * 1.2
					end
					return old_SetCharge(_dna, charge)
				end
				return s
			end
		end
	end
end

TTT_AddUpgrade("dna", EVENT)