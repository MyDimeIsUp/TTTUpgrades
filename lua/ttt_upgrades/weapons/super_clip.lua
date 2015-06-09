
local EVENT = {}

EVENT.Name = "Super clip"
EVENT.Price = 2300
EVENT.Icon = "upgrade_icons/ammo.png"
EVENT.Description = "Expands the magazine of all slot 2 and slot 3 weapons by 20%."

local function Enabled(ply)
	return (SERVER and ply:UpgradeEnabled("super_clip")) or (CLIENT and UpgradeEnabled("super_clip"))
end

EVENT.Hooks = { "Initialize" }

local function OverrideWep(wep)
	local owner = CLIENT and LocalPlayer() or wep:GetOwner()
	if not wep.Primary or not IsValid(owner) then return end
	if Enabled(owner) then
		if not wep.Primary.OriginalSize then
			wep.Primary.OriginalSize = wep.Primary.ClipSize
			wep.Primary.ClipSize = math.Round(wep.Primary.OriginalSize * 1.2)
			wep.Primary.DefaultClip = wep.Primary.ClipSize
		end
		if SERVER then
			if not wep.OldOwner then
				wep:SetClip1(wep.Primary.ClipSize)
				wep.OldOwner = true
			end
		end
	else
		if wep.Primary.OriginalSize then
			wep.Primary.ClipSize = wep.Primary.OriginalSize
			wep.Primary.DefaultClip = wep.Primary.ClipSize
			wep.Primary.OriginalSize = nil
		end
	end
end
net.Receive("OverrideWep", function()
	local wep = net.ReadEntity()
	OverrideWep(wep)
end)

if SERVER then
	util.AddNetworkString("OverrideWep")
end

function EVENT:Initialize()
	for k,v in pairs(weapons.GetList()) do
		if v.Base == "weapon_tttbase" and (v.Kind == WEAPON_HEAVY or v.Kind == WEAPON_PISTOL) then
			local old_Equip = v.Equip
			v.Equip = function(wep, owner)
				if old_Equip then 
					old_Equip(wep, owner) 
				else
					wep.BaseClass.Equip(wep, owner)
				end
				OverrideWep(wep)
				net.Start("OverrideWep")
				net.WriteEntity(wep)
				net.Send(wep.Owner)
			end
		end
	end
end


TTT_AddUpgrade("super_clip", EVENT)