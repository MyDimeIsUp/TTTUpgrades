
TTT_Upgrades = {}

local Upgrades_hooks = {}

function TTT_AddUpgrade(id, tbl)
	if not TTT_Upgrades_Name then return end
	for k,v in pairs(tbl.Hooks or {}) do
		if not table.HasValue(Upgrades_hooks, v) then
			table.insert(Upgrades_hooks, v)
		end
	end
	if not TTT_Upgrades[TTT_Upgrades_Name] then
		TTT_Upgrades[TTT_Upgrades_Name] = {}
	end
	TTT_Upgrades[TTT_Upgrades_Name][id] = tbl
end

local _, folders = file.Find("ttt_upgrades/*", "LUA") 
if folders then
	for _,category in pairs(folders) do
		local namef = "ttt_upgrades/"..category.."/category_name.lua"
		if not file.Exists(namef, "LUA") then continue end
		if SERVER then
			AddCSLuaFile(namef)
		end
		include(namef)
		local upgrades = file.Find("ttt_upgrades/"..category.."/*.lua", "LUA")
		if upgrades then
			for k,v in pairs(upgrades) do
				local f = "ttt_upgrades/"..category.."/"..v
				if SERVER then
					AddCSLuaFile(f)
				end
				include(f)
			end
		end
	end
end

TTT_Upgrades_Name = nil

for _,name in pairs(Upgrades_hooks) do
	hook.Add(name, "TTT_Upgrade_"..name, function(...)
		for k,v in pairs(TTT_Upgrades) do
			for _,tbl in pairs(v) do
				if tbl[name] then
					tbl[name](tbl, ...)
				end
			end
		end
	end)
end

UConfig = { Upgrades = {} }
if SERVER then
	AddCSLuaFile("config/upgrades_config.lua")
end
include("config/upgrades_config.lua")

function GetUpgradesNumber(ply)
	for k,v in pairs(UConfig.Upgrades) do
		if ply:IsUserGroup(k) then
			return v
		end
	end
	return UConfig.DefaultUpgrades
end