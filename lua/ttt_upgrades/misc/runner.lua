local EVENT = {}

EVENT.Name = "Runner"
EVENT.Price = 1800
EVENT.Icon = "upgrade_icons/runner.png"
EVENT.Description = "10% extra movement speed."

if SERVER then
	EVENT.Hooks = { "TTTPlayerSpeed" }
end

local function GetBonus(ply)
	local bonus = 1
	if GetRoundState() == ROUND_ACTIVE then
		if ply:UpgradeEnabled("runner") then
			bonus = bonus + 0.1
		end
		if ply:ReduceSpeedDrow() then
			bonus = bonus - 0.15
		end
	end
	return bonus
end

local Player = FindMetaTable("Player")
local old_SetWalkSpeed = Player.SetWalkSpeed
function Player:SetWalkSpeed(speed)
	local bonus = GetBonus(self)
	return old_SetWalkSpeed(self, speed*bonus)
end
local old_SetRunSpeed = Player.SetRunSpeed
function Player:SetRunSpeed(speed)
	local bonus = GetBonus(self)
	return old_SetRunSpeed(self, speed*bonus)
end
local old_SetMaxSpeed = Player.SetMaxSpeed
function Player:SetMaxSpeed(speed)
	local bonus = GetBonus(self)
	return old_SetMaxSpeed(self, speed*bonus)
end

function Player:ReduceSpeedDrow()
	return self.UDrow or false
end

TTT_AddUpgrade("runner", EVENT)