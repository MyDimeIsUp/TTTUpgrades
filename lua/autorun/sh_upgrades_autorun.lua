
if LOADED_UPGRADES then return end
LOADED_UPGRADES = true

if SERVER then

	AddCSLuaFile()
	
	include("sv_upgrades.lua")
	
else

	include("cl_upgrades.lua")
	
end