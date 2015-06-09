
local PANEL = {}

surface.CreateFont("TTT_UpgradesTitle", {
	font = "Arial",
	size = 22
})

function PANEL:Init()
	self.Header:SetFont("TTT_UpgradesTitle")
	self.Header:SetTextColor(Color(30, 30, 70))
	self.Header:SetSize(self.Header:GetWide(), 25)
end

function PANEL:Paint()
end

function PANEL:SetNameEx(name)
	self.Down = false
	self.NameStr = name
	self:SetName("▼ "..name)
end

function PANEL:SetExpanded(expanded)
	self.m_bSizeExpanded = expanded
	if not self.Down then
		self.Header:SetText("➤ "..self.NameStr)
		self.Down = true
	else
		self.Header:SetText("▼ "..self.NameStr)
		self.Down = false
	end
end

function PANEL:AddItem(item)
	self:InvalidateLayout()
	local Panel = vgui.Create( "DSizeToContents", self )
	Panel:SetSizeX( false )
	Panel:Dock( TOP )
	Panel:DockPadding(0, 0, 0, 0)
	Panel:InvalidateLayout()
		
	item:SetParent( Panel )
	item:Dock( TOP )
	
	table.insert( self.Items, Panel )
end

derma.DefineControl("DUpgradesForm", "WHAT???", PANEL, "DForm")