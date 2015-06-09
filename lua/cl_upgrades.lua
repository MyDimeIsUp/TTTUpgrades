
include("sh_upgrades.lua")

include("vgui/upgrades_form.lua")

local upgrades = {
	owned = {},
	enabled = {}
}
local update_list = false

surface.CreateFont("TTT_UpgradesTitle", {
	font = "Arial",
	size = 22
})

surface.CreateFont("TTT_UpgradesOwns", {
	font = "Arial",
	size = 21
})

surface.CreateFont("TTT_UpgradesItem", {
	font = "Arial",
	size = 20,
	weight = 700
})

surface.CreateFont("TTT_UpgradesDescription", {
	font = "Arial",
	size = 20
})

local function IsAllowed()
	if UConfig.Whitelist then
		for k,v in pairs(UConfig.AllowedRanks) do
			if LocalPlayer():IsUserGroup(v) then
				return true
			end
		end
		return false
	else
		return true
	end
end

local function HasUpgrade(id)
	return upgrades.owned[id]
end

net.Receive("EnabledUpgrades", function()
	EnabledUpgrades = net.ReadTable()
end)

function UpgradeEnabled(id)
	return EnabledUpgrades and EnabledUpgrades[id] or false
end

local function AddCategories(PanelList)

	for Name,Category in pairs(TTT_Upgrades) do
		
		local form = vgui.Create("DUpgradesForm")
		form:SetSpacing(0)
		form:SetNameEx(Name)
	
		for id,tbl in pairs(Category) do
		
			local Panel = vgui.Create("DPanel")
			Panel.Icon = Material(tbl.Icon)
	
			Panel.Title = vgui.Create("DLabel", Panel)
			Panel.Title:SetText(tbl.Name)
			Panel.Title:SetFont("TTT_UpgradesItem")
			Panel.Title:SetTextColor(color_black)
			
			Panel.Description = vgui.Create("DLabel", Panel)
			
			Panel.Description:SetFont("TTT_UpgradesDescription")
			Panel.Description:SetTextColor(color_black)
			
			if not HasUpgrade(id) then
				Panel.Buy = vgui.Create("DButton", Panel)
				Panel.Buy:SetText("Purchase")			
				Panel.Buy.Think = function(self)
					if HasUpgrade(id) then
						self:Remove()
						return
					end
					if LocalPlayer():PS_HasPoints(tbl.Price) and self.Disabled then
						self:SetDisabled(false)
						self.Disabled = false
					elseif not LocalPlayer():PS_HasPoints(tbl.Price) and not self.Disabled then
						self:SetDisabled(true)
						self.Disabled = true
					end
				end
				Panel.Buy.DoClick = function(self)
					if not IsAllowed() then 
						Derma_Message(UConfig.Whitelist_ErrorMessage, "Error", "OK")
					else
						local function buy()
							net.Start("BuyUpgrade")
							net.WriteString(Name)
							net.WriteString(id)
							net.SendToServer()
						end
						Derma_Query("Buy "..tbl.Name.. " for "..tbl.Price.. " points ?", "Confirmation", "Yes", buy, "No", function() end)
					end
				end
			end
			
			Panel.PerformLayout = function(self)
				local wide = self:GetWide()
				self.Title:SetPos(self:GetTall(), 13)
				self.Title:SizeToContents()
				local description, _max = nil, wide - self:GetTall() - 100
				local desc_w = surface.GetTextSize(tbl.Description)
				if desc_w > _max then
					surface.SetFont("TTT_UpgradesDescription")
					local caracters = math.floor(string.len(tbl.Description) * _max / desc_w)
					local i = nil
					local cut
					while true do
						local last_i = i
						i = string.find(tbl.Description, " ", last_i and last_i + 1 or 1)
						if i and i > caracters and last_i then
							cut = last_i
							break
						elseif not i then
							if last_i and last_i < caracters then
								cut = last_i
							else
								cut = caracters
							end
							break
						end
					end
					description = string.Left(tbl.Description, cut).."\n"..string.Right(tbl.Description, string.len(tbl.Description) - cut)
				else
					description = tbl.Description
				end
				self.Description:SetText(description)
				self.Description:SetPos(self:GetTall(), 20 + self.Title:GetTall())
				self.Description:SizeToContents()
				if IsValid(self.Buy) then
					self.Buy:SetSize(90, 25)
					self.Buy:SetPos(self:GetWide() - self.Buy:GetWide() - 10, self:GetTall() - 10- self.Buy:GetTall())
				end
			end
			
			Panel.Paint = function(self, w, h)
				surface.SetDrawColor(color_black)
				surface.DrawRect(0,0, w, h)
				surface.SetDrawColor(Color(210, 210, 210))
				surface.DrawRect(1, 1, w-2, h-2)
				surface.SetDrawColor(color_white)
				surface.SetMaterial(self.Icon)
				surface.DrawTexturedRect(10, 10, h - 20, h - 20)
				local text_color
				if LocalPlayer():PS_GetPoints() >= tbl.Price or HasUpgrade(id) then
					text_color = Color(0,128,0)
				else
					text_color = Color(147,0,0)
				end
				draw.SimpleText(HasUpgrade(id) and "Purchased!" or tbl.Price.." Points", "TTT_UpgradesItem", w-10, 13, text_color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
			end
			Panel:SetSize(Panel:GetWide(), 85)
			
			form:AddItem(Panel)
		end
		PanelList:AddItem(form)
		form:Toggle()
		
	end
	
end

local function GetUpgradesPanel()

	update_list = true

	local PanelList = vgui.Create("DPanelList")
	PanelList:SetPadding(10)
	PanelList:EnableVerticalScrollbar(true)
	PanelList.Paint = function(self, w, h)
		surface.SetDrawColor(Color(220, 220, 220))
		surface.DrawRect(0,0,w,h)
	end
		
	local Panel = vgui.Create("DPanel")
	Panel.Paint = PanelList.Paint
	
	Panel.Owned = vgui.Create("DPanel", Panel)
	Panel.NotOwned = vgui.Create("DPanel", Panel)
	local Owns_Paint = function(self, w, h)
		surface.SetDrawColor(color_black)
		surface.DrawRect(0,0, w, h)
		surface.SetDrawColor(Color(210, 210, 210))
		surface.DrawRect(1, 1, w-2, h-2)
		surface.SetDrawColor(color_black)
		surface.DrawLine(0, 25, w, 25)
	end
	Panel.Owned.Paint = Owns_Paint
	Panel.NotOwned.Paint = Owns_Paint
	
	Panel.OwnedList = vgui.Create("EquipSelect", Panel.Owned)
	Panel.OwnedList:EnableVerticalScrollbar(true)
	Panel.OwnedList:EnableHorizontal(true)	
	if #Panel.OwnedList:GetItems() > 0 then
		Panel.OwnedList:SelectPanel(Panel.OwnedList:GetItems()[1])
	end
	
	Panel.NotOwnedList = vgui.Create("EquipSelect", Panel.NotOwned)
	Panel.NotOwnedList:EnableVerticalScrollbar(true)
	Panel.NotOwnedList:EnableHorizontal(true)	
	if #Panel.NotOwnedList:GetItems() > 0 then
		Panel.NotOwnedList:SelectPanel(Panel.NotOwnedList:GetItems()[1])
	end
	
	hook.Add("Think", "Upgrades", function()
		if not IsValid(Panel) then 
			hook.Remove("Think", "Upgrades")
			return
		end
		if update_list then
			update_list = false
			Panel.OwnedList:Clear()
			Panel.NotOwnedList:Clear()
			for k,v in pairs(upgrades.owned) do
				if upgrades.enabled[k] then continue end
				local info = false
				for _,category in pairs(TTT_Upgrades) do
					if not info and category[k] then 
						info = category[k]
					end
				end
				if not info then continue end
				local icon = vgui.Create("SimpleIcon", Panel.OwnedList)
				icon:SetIconSize(64)
				icon:SetIcon(info.Icon)
				icon.id = k
				icon:SetTooltip(info.Name)
				Panel.OwnedList:AddPanel(icon)
			end
			for k,v in pairs(upgrades.enabled) do
				local info = false
				for _,category in pairs(TTT_Upgrades) do
					if not info and category[k] then 
						info = category[k]
					end
				end
				if not info then continue end
				local icon = vgui.Create("SimpleIcon", Panel.NotOwnedList)
				icon:SetIconSize(64)
				icon:SetIcon(info.Icon)
				icon.id = k
				icon:SetTooltip(info.Name)
				Panel.NotOwnedList:AddPanel(icon)
			end
		end
	end)
	
	Panel.NotOwnedList = vgui.Create("EquipSelect", Panel.NotOwned)
	Panel.NotOwnedList:EnableVerticalScrollbar(true)
	Panel.NotOwnedList:EnableHorizontal(true)	
	
	Panel.EnableButton = vgui.Create("DButton", Panel.Owned)
	Panel.EnableButton:SetText("Enable the selected item")
	Panel.EnableButton:SetDisabled(true)
	Panel.EnableButton.Disabled = true
	Panel.EnableButton.Think = function(self)
		if not IsAllowed() then return end
		local selected = #Panel.OwnedList:GetItems() > 0
		if selected and table.Count(upgrades.enabled) < GetUpgradesNumber(LocalPlayer()) and self.Disabled then
			self:SetDisabled(false)
			self.Disabled = false
		elseif (not selected or table.Count(upgrades.enabled) >= GetUpgradesNumber(LocalPlayer())) and not self.Disabled then
			self:SetDisabled(true)
			self.Disabled = true
		end
	end
	Panel.EnableButton.DoClick = function(self)
		local selected = #Panel.OwnedList:GetItems() > 0
		if Panel.OwnedList.SelectedPanel and selected and table.Count(upgrades.enabled) < GetUpgradesNumber(LocalPlayer()) then
			net.Start("EnableUpgrade")
			net.WriteUInt(1,1)
			net.WriteString(Panel.OwnedList.SelectedPanel.id)
			net.SendToServer()
		end
	end
	
	Panel.DisableButton = vgui.Create("DButton", Panel.NotOwned)
	Panel.DisableButton:SetText("Disable the selected item")
	Panel.DisableButton:SetDisabled(true)
	Panel.DisableButton.Disabled = true
	Panel.DisableButton.Think = function(self)
		local selected = #Panel.NotOwnedList:GetItems() > 0
		if selected and self.Disabled then
			self.Disabled = false
			self:SetDisabled(false)
		elseif not self.Disabled and not selected then
			self.Disabled = true
			self:SetDisabled(true)
		end
	end
	Panel.DisableButton.DoClick = function(self)
		local selected = #Panel.NotOwnedList:GetItems() > 0
		if Panel.NotOwnedList.SelectedPanel and selected then
			net.Start("EnableUpgrade")
			net.WriteUInt(0,1)
			net.WriteString(Panel.NotOwnedList.SelectedPanel.id)
			net.SendToServer()
		end
	end
	
	Panel.Disabled = vgui.Create("DLabel", Panel.Owned)
	Panel.Disabled:SetFont("TTT_UpgradesOwns")
	Panel.Disabled:SetText("Disabled upgrades")
	Panel.Disabled:SizeToContents()
	Panel.Disabled:SetTextColor(Color(190, 50, 50))
	
	Panel.Enabled = vgui.Create("DLabel", Panel.NotOwned)
	Panel.Enabled:SetFont("TTT_UpgradesOwns")
	Panel.Enabled:SetText("Enabled upgrades")
	Panel.Enabled:SizeToContents()
	Panel.Enabled:SetTextColor(Color(70, 170, 70))
	
	Panel.Message = vgui.Create("DLabel", Panel)
	Panel.Message:SetFont("TTT_UpgradesDescription")
	Panel.Message:SetText("You can only enable "..GetUpgradesNumber(LocalPlayer()).." upgrades at once.\nChanges will only apply when the next round begins.")
	Panel.Message:SizeToContents()
	Panel.Message:SetTextColor(color_black)
	
	function Panel:PerformLayout()
		local margin = 10
		local wide = self:GetWide() + 30
		
		Panel.Message:SetPos(0, 0)
		
		local OwnsH, OwnsW = 300, wide/2 - margin - 5
		self.Owned:SetPos(0,40)
		self.Owned:SetSize(OwnsW, OwnsH)
		self.NotOwned:SetPos(self.Owned:GetWide()-1,40) 
		self.NotOwned:SetSize(OwnsW, OwnsH)
		
		surface.SetFont("TTT_UpgradesOwns")
		self.Disabled.X, self.Disabled.Y = surface.GetTextSize(self.Disabled:GetText())
		self.Disabled:SetPos(self.Owned:GetWide()/2 - self.Disabled.X/2, 3)
		self.Enabled.X, self.Enabled.Y = surface.GetTextSize(self.Enabled:GetText())
		self.Enabled:SetPos(self.NotOwned:GetWide()/2 - self.Enabled.X/2, 3)
		
		self.OwnedList:SetPos(5, 30)
		self.OwnedList:SetSize(self.Owned:GetWide() - margin, 235)
		self.OwnedList.Paint = function(self, w, h)
			surface.SetDrawColor(Color(255, 255, 255, 130))
			surface.DrawRect(0, 0, w, h)
		end
		self.NotOwnedList:SetPos(5, 30)
		self.NotOwnedList:SetSize(self.Owned:GetWide() - margin, 235)
		self.NotOwnedList.Paint = self.OwnedList.Paint
		
		self.EnableButton:SetPos(5, 270)
		self.EnableButton:SetSize(self.Owned:GetWide()-margin, 25)
		self.DisableButton:SetPos(5, 270)
		self.DisableButton:SetSize(self.Owned:GetWide()-margin, 25)
	end
	
	local Form1 = vgui.Create("DUpgradesForm")
	Form1:SetNameEx("Manage purchased upgrades")
	Panel:SetSize(Panel:GetWide(), 360)
	Form1:AddItem(Panel)
	PanelList:AddItem(Form1)
	
	AddCategories(PanelList)
	
	return PanelList
	
end

net.Receive("UpdateUpgrades", function()
	local tbl = net.ReadTable()
	upgrades = tbl
	update_list = true
end)

local Menu = nil

concommand.Add("upgrades_menu", function()

	Menu = vgui.Create("DFrame")
	local w,h = 600, math.Clamp( 658, 0, ScrH())
	Menu:SetSize(w, h)
	Menu.Points = LocalPlayer():PS_GetPoints()
	Menu:SetTitle("Upgrades (You have "..Menu.Points.." points)")
	Menu.Think = function(self)
		if LocalPlayer():PS_GetPoints() != self.Points then
			self.Points = LocalPlayer():PS_GetPoints()
			self:SetTitle("Upgrades (You have "..self.Points.." points)")
		end
	end
	Menu:Center()
	
	local Panel = GetUpgradesPanel()
	Panel:SetParent(Menu)
	Panel:SetPos(5,30)
	Panel:SetSize(w-10, h-35)
	
	Menu:MakePopup()

end)

if UConfig.StandaloneMenu then
	local bind = false
	hook.Add("Think", "TTT_Uprades_Key", function()
		if input.IsKeyDown(UConfig.StandaloneMenuKey) then
			if not bind then
				bind = true
				if ValidPanel(Menu) and Menu:IsVisible() then
					Menu:Close()
					return false
				else
					RunConsoleCommand("upgrades_menu")
				end
			end
		else
			bind = false
		end
	end)	
else
	local old_vgui = vgui.Create
	vgui.Create = function(name, parent, targetname)
		local panel = old_vgui(name, parent, targetname)
		if name == "DPropertySheet" then
			local level = 1
			while true do
				local info = debug.getinfo(level, "Sln") -- hate to do that
				if not info then break end
				if string.find(string.lower(info.short_src), "dpointshopmenu.lua") then
					local add = false
					local added = false
					local old_AddSheet = panel.AddSheet
					panel.AddSheet = function(self, name, pnl, icon, b1, b2)
						if not add then
							add = true
						elseif not added then
							added = true
							self:AddSheet("Upgrades", GetUpgradesPanel(), "icon16/gun.png")
						end
						return old_AddSheet(self, name, pnl, icon, b1, b2)
					end
				end
				level = level + 1
			end
		end
		return panel
	end
end