 
function PANEL:Init()
	
	self:SetClipEnabled(true)
	self.inner = self
end

function PANEL:SetFloater(floater)
	self.floater = floater 
	self.inner:Add(floater)
	local bar = self.vbar
	local bar2 = self.hbar
	if bar then bar:SetScroll(-1) end
	if bar2 then bar2:SetScroll(-1) end
end
-- 0 = NONE, 1 = VERTICAL, 2 = HORISONTAL, 3 = BOTH
function PANEL:SetScrollbars(type)
		
	if type == 1 or type == 3 then
		local bar =  panel.Create("scrollbar")
		bar:SetType(1)
		bar:Dock(DOCK_RIGHT)
		self:Add(bar)
		self.vbar = bar
	end
	if type == 2 or type == 3 then
		local bar =  panel.Create("scrollbar")
		bar:SetType(2)
		bar:Dock(DOCK_BOTTOM)
		self:Add(bar)
		self.hbar = bar
	end
	self:SetClipEnabled(false)
	local inner = panel.Create()
	inner:SetClipEnabled(true)
	inner:Dock(DOCK_FILL)
	self:Add(inner)
	
	self.inner = inner
	
	self:UpdateLayout()
end
function PANEL:GetFloater()
	return self.floater
end
function PANEL:SetScroll(pos)
	self.floater:SetPos(pos)
end

function PANEL:MouseEnter() 
	local bar = self.vbar
	local bar2 = self.hbar
	if bar or bar2 then 
		local sWVal = input.MouseWheel() 
		hook.Add("input.mousewheel", "float.scroll",function() 
			local mWVal = input.MouseWheel() 
			local delta = mWVal - sWVal
			sWVal = mWVal
			if input.KeyPressed(KEYS_SHIFTKEY) then
				if bar2 then bar2:Scroll(-delta) end
			else
				if bar then bar:Scroll(-delta) end
			end
		end)
	end
end
function PANEL:MouseLeave()
	local bar = self.vbar
	local bar2 = self.hbar
	if bar or bar2 then 
		hook.Remove("input.mousewheel", "float.scroll")
	end
end