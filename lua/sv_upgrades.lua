
AddCSLuaFile("sh_upgrades.lua")
AddCSLuaFile("cl_upgrades.lua")

AddCSLuaFile("vgui/upgrades_form.lua")

include("sh_upgrades.lua")
include("config/upgrades_mysql_config.lua")
include("sv_resources.lua")

util.AddNetworkString("UpdateUpgrades")
util.AddNetworkString("BuyUpgrade")
util.AddNetworkString("EnableUpgrade")
util.AddNetworkString("EnabledUpgrades")

local database
if Upgrades_Enable_MySQL then
	require("mysqloo")
	database = mysqloo.connect(Upgrades_MySQL.hostname, Upgrades_MySQL.user, Upgrades_MySQL.password, Upgrades_MySQL.database, Upgrades_MySQL.port)
	Upgrades_MySQL = nil
	database.onConnected = function(self)
		self.Connected = true
		local query = self:query("CREATE TABLE IF NOT EXISTS ttt_upgrades (id INT UNSIGNED NOT NULL AUTO_INCREMENT, uniqueid BIGINT UNSIGNED, upgrades longtext, PRIMARY KEY (id))")
		query:start()
	end
	database.onConnectionFailed = function(self, err)
		file.Write("upgrades_mysql_error.txt", os.date().." : "..err)
	end
	database:connect()
elseif not sql.TableExists("ttt_upgrades") then
	sql.Query("CREATE TABLE ttt_upgrades (uniqueid int, upgrades longtext)")
end

local function SendTable(ply)
	if ply.ttt_upgrades then
		net.Start("UpdateUpgrades")
		net.WriteTable(ply.ttt_upgrades)
		net.Send(ply)
	end
end

local function UpdateUpgrades(ply)
	if not ply.ttt_upgrades then return end
	SendTable(ply)
	local query_str = "UPDATE ttt_upgrades SET upgrades = "..sql.SQLStr(util.TableToJSON(ply.ttt_upgrades)).."WHERE uniqueid = "..ply:SteamID64()..""
	if Upgrades_Enable_MySQL then
		local query = database:query(query_str)
		query:start()
	else
		sql.Query(query_str)
	end
end

hook.Add("PlayerAuthed", "TTT_Upgrades", function(ply, steamid, uniqueid)
	local get = "SELECT upgrades FROM ttt_upgrades WHERE uniqueid = "..tostring(ply:SteamID64()).." LIMIT 1"
	local delete = "DELETE FROM upgrades WHERE uniqueid = "..tostring(ply:SteamID64())..""
	local json = util.TableToJSON({owned = {}, enabled = {}})
	local insert = "INSERT INTO ttt_upgrades(`uniqueid`, `upgrades`) VALUES ("..tostring(ply:SteamID64())..","..sql.SQLStr(json)..")"
	if Upgrades_Enable_MySQL and database.Connected then
		local function Insert()
			ply.ttt_upgrades = {
				owned = {},
				enabled = {}
			}
			local json = util.TableToJSON(ply.ttt_upgrades)
			local insert_query = database:query(insert)
			insert_query:start()
			SendTable(ply)
		end
		local query = database:query(get)
		query.onSuccess = function(self)
			if self:getData()[1] then
				local tbl = util.JSONToTable(self:getData()[1].upgrades)
				if tbl then
					ply.ttt_upgrades = tbl
					SendTable(ply)
				else
					local delete_query = database:query(delete)
					delete_query.onSuccess = function(self)
						Insert()
					end
					delete_query:start()
				end
			else
				Insert()
			end
		end
		query:start()
	elseif not Upgrades_Enable_MySQL then
		local upgrades = sql.QueryValue(get)
		local reload = false
		if upgrades then
			local tbl = util.JSONToTable(upgrades)
			if tbl then
				ply.ttt_upgrades = tbl
			else
				sql.Query(delete)
				reload = true
			end
		end
		if (not upgrades) or reload then
			ply.ttt_upgrades = {
				owned = {},
				enabled = {}
			}
			sql.Query(insert)
		end
		SendTable(ply)
	end
end)

local Player = FindMetaTable("Player")
function Player:HasUpgrade(id)
	return self.ttt_upgrades and self.ttt_upgrades.owned[id] or false
end
function Player:UpgradeEnabled(id)
	return self.RoundUpgrades and self.RoundUpgrades[id] or false
end

local function IsAllowed(ply)
	if UConfig.Whitelist then
		for k,v in pairs(UConfig.AllowedRanks) do
			if ply:IsUserGroup(v) then
				return true
			end
		end
		return false
	else
		return true
	end
end


net.Receive("BuyUpgrade", function(_, ply)
	local category = net.ReadString()
	local id = net.ReadString()
	if not ply.ttt_upgrades then return end
	if not IsAllowed(ply) then return end
	if not TTT_Upgrades[category] or not TTT_Upgrades[category][id] then return end
	if ply:HasUpgrade(id) then return end
	local price = TTT_Upgrades[category][id].Price
	if not ply:PS_HasPoints(price) then return end
	ply:PS_TakePoints(price)
	ply.ttt_upgrades.owned[id] = true
	UpdateUpgrades(ply)
end)

net.Receive("EnableUpgrade", function(_,ply)
	local enable = net.ReadUInt(1) == 1
	local id = net.ReadString()
	if not ply.ttt_upgrades then return end
	if not IsAllowed(ply) then return end
	if not id then return end
	if enable then
		if not ply:HasUpgrade(id) then return end
		if table.Count(ply.ttt_upgrades.enabled) >= GetUpgradesNumber(ply) then return end
		ply.ttt_upgrades.enabled[id] = true
	else
		ply.ttt_upgrades.enabled[id] = nil
	end
	UpdateUpgrades(ply)
end)

local function update()
	for _,ply in pairs(player.GetHumans()) do
		if not ply.ttt_upgrades or not ply.ttt_upgrades.enabled then continue end
		ply.RoundUpgrades = table.Copy(ply.ttt_upgrades.enabled)
		net.Start("EnabledUpgrades")
		net.WriteTable(ply.RoundUpgrades)
		net.Send(ply)
	end
end
hook.Add("TTTBeginRound", "TTT_Upgrades", update)
hook.Add("TTTPrepareRound", "TTT_Upgrades", update)