
local EVENT = {}

EVENT.Name = "One hit kill knife"
EVENT.Price = 2500
EVENT.Icon = "upgrade_icons/knife.png"
EVENT.Description = "Allows you to instantly kill a target using the knife without having to throw it."

EVENT.Hooks = { "Initialize" }
function EVENT:Initialize()
	local knife
	for k,v in pairs(weapons.GetList()) do
		if v.ClassName == "weapon_ttt_knife" then
			knife = v
			break
		end
	end
	if SERVER then
		if knife then
			local old_PrimaryAttack = knife.PrimaryAttack
			local original_damages = knife.Primary.Damage
			knife.PrimaryAttack = function(self)
				local owner = self:GetOwner()
				if IsValid(owner) and owner:IsPlayer() and owner:UpgradeEnabled("one_hit_kill_knife") then
					self.Primary.Damage = 100
				else
					self.Primary.Damage = original_damages
				end
				return old_PrimaryAttack(self)
			end
		end
	else
		if knife then
			local old_DrawHUD = knife.DrawHUD
			knife.DrawHUD = function(self)
				if self.Primary.Damage != 100 and UpgradeEnabled("one_hit_kill_knife") then
					self.Primary.Damage = 100
				end
				old_DrawHUD(self)
			end
		end
	end
end

TTT_AddUpgrade("one_hit_kill_knife", EVENT)