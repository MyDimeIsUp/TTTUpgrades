local EVENT = {}

EVENT.Name = "40% Faster reloading"
EVENT.Price = 2000
EVENT.Icon = "upgrade_icons/fast_reload.png"
EVENT.Description = "Does not work on shotguns."

EVENT.Hooks = { "Initialize" }
function EVENT:Initialize()
	for k,v in pairs(weapons.GetList()) do
		if v.Base == "weapon_tttbase" and not (v.Reload and not v.SetZoom) then
			function v:Reload()
				local upgrade = (SERVER and self.Owner.UpgradeEnabled and self.Owner:UpgradeEnabled("reload_time")) or (CLIENT and UpgradeEnabled and UpgradeEnabled("reload_time"))
				if upgrade then
					if not self.Owner.GetAmmoCount then return end
					if self.Reloading or self:Clip1() == self.Primary.ClipSize or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then return end
					self.Reloading = true
					self:SendWeaponAnim(ACT_VM_RELOAD)
					local reloadtime = self.Owner:GetViewModel():SequenceDuration() / 1.4
					self.Owner:GetViewModel():SetPlaybackRate(1.4)
					timer.Simple(reloadtime, function()
						if self then
							self.Reloading = false
							if self.Primary.ClipSize < self.Owner:GetAmmoCount(self.Primary.Ammo) then
								local old_clip = self:Clip1()
								self:SetClip1(self.Primary.ClipSize)
								self.Owner:SetAmmo(self.Owner:GetAmmoCount(self.Primary.Ammo) - self.Primary.ClipSize + old_clip, self.Primary.Ammo)
							else
								self:SetClip1(self.Owner:GetAmmoCount(self.Primary.Ammo))
								self.Owner:SetAmmo(0, self.Primary.Ammo)
							end
						end
					end)
					self:SetIronsights(false)
				else
					self:DefaultReload(ACT_VM_RELOAD)
				end
				self:SetIronsights(false)
				if self.SetZoom then
					self:SetZoom(false)
				end
			end
		end
	end	
end

TTT_AddUpgrade("reload_time", EVENT)