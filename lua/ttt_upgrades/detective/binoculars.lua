
local EVENT = {}

EVENT.Name = "Binoculars"
EVENT.Price = 1000
EVENT.Icon = "upgrade_icons/binoculars.png"
EVENT.Description = "Makes identifying corpses using the binoculars instant."

local function Enabled(ply)
	return (SERVER and ply:UpgradeEnabled("binoculars")) or (CLIENT and UpgradeEnabled("binoculars"))
end

EVENT.Hooks = { "Initialize" }

function EVENT:Initialize()
	for k,v in pairs(weapons.GetList()) do
		if v.ClassName == "weapon_ttt_binoculars" then
			local old_PrimaryAttack = v.PrimaryAttack
			local original_time = v.ProcessingDelay
			v.PrimaryAttack = function(self)
				local owner = self:GetOwner()
				if IsValid(owner) and owner:IsPlayer() and Enabled(owner) then
					self.ProcessingDelay = 0
				else
					self.Primary.Damage = original_time
				end
				return old_PrimaryAttack(self)
			end
			break
		end
	end
end

TTT_AddUpgrade("binoculars", EVENT)