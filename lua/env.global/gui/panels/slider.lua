
function PANEL:Init() 
	self.pointer = panel.Create("panel",{
		texture = "textures/gui/pointer.png",
		size = {8,8},
		color = {1,1,1}
	},self) 
	self.pointer:SetCanRaiseMouseEvents(false)
	self:SetTexture("textures/gui/bar_v.png")
	self:SetTextColor(Vector(1,1,1))
	self:SetTextAlignment(ALIGN_CENTER)
	self.maxvalue = 100
end
function PANEL:MouseClick() 
	local cpos = self:GetLocalCursorPos()
	local csize = self:GetSize()-Point(20,0)
	cpos = Point(math.min(math.max(cpos.x,0),csize.x),csize.y/2-4)
	self.pointer:SetPos(cpos)
	local lpos = cpos/csize
	local vpx = (lpos.x)*(self.maxvalue or 1) 
	self.value = vpx
	local OnSlide = self.OnSlide
	self:SetText(tostring(math.round(vpx*10)/10))
	if OnSlide then
		OnSlide(self,vpx)
	end 
end
function PANEL:MouseDown()
	if not MouseLocked() then
		LockMouse() 
		hook.Add(EVENT_GLOBAL_PREDRAW,"slider",function(s)
			self:MouseClick()
		end)
		hook.Add("input.mouseup","slider",function(s) 
			hook.Remove(EVENT_GLOBAL_PREDRAW,"slider")
			hook.Remove("input.mouseup","slider")
			UnlockMouse()
		end)
	end
end 
function PANEL:SetValue(x)
	x = math.Clamp(x,0,self.maxvalue)
	local sz = self:GetSize()-Point(20,0)
	local cvx = x/self.maxvalue
	self.pointer:SetPos((cvx*2-1)*sz.x,sz.y/2-4) 
	self.value = x
	self:SetText(tostring(math.round(x*10)/10))
	local OnSlide = self.OnSlide 
	if OnSlide then
		OnSlide(self,x)
	end 
end
function PANEL:GetValue()
	return self.value or 0
end
function PANEL:SetMaximum(val)
	self.maxvalue = val or 1
end
function PANEL:OnMouseWheel(delta)
	self:SetValue(self:GetValue()+delta/self.maxvalue)
end
function PANEL:Resize()
	local x = self.value or 0
	local sz = self:GetSize()-Point(20,0)
	local cvx = x/self.maxvalue
	self.pointer:SetPos(cvx*sz.x ,sz.y/2-4)
end