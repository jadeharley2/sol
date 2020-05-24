PANEL.basetype = "graph_node"  
PANEL.datakeys = {
	pincount = "pincount"
}
function PANEL:Init() 
	PANEL.base.Init(self) 
	
	gui.FromTable({ 
		subs = { 
			{ name = "pin_del", type = "button",
				size = {20,20},
				dock = DOCK_RIGHT,
				texture =  "textures/gui/nodes/minus.png",
				ColorAuto = self:GetColor(),
				contextinfo = "remove pin",
				margin = {4,0,4,0},
				OnClick = function (x) self:ChangePins(-1) end
			},
			{ name = "pin_add", type = "button",
				size = {20,20},
				dock = DOCK_RIGHT,
				texture =  "textures/gui/nodes/plus.png",
				ColorAuto = self:GetColor(),
				contextinfo = "add pin",
				margin = {4,0,4,0},
				OnClick = function (x) self:ChangePins(1) end
			}  
		}
	},self.bcontext,{},self) 
	
end 
function PANEL:Load(pincount)    
	
	pincount = pincount or self.pincount or 5
	self.pincount = pincount

	self:SetTitle("Join")
	self:SetSize(256,pincount*16+40)
	
 
	
	for k=1,pincount do
		self:AddAnchor(-k,tostring(k)..">>","signal") 
	end 
	
	self:AddAnchor(1,">>","signal")
	
	self:Deselect()
	self:UpdateLayout()
	 
	
end
function PANEL:ChangePins(diff) 
	local pincount = self.pincount or 2
	pincount = math.Clamp(pincount+diff,2,32)
	self:Reload(pincount)
end
function PANEL:ToData()  
	local pos = self:GetPos() 
	local j = {id = self.id, type = "join",pos = {pos.x,pos.y}} 
	j.pincount = self.pincount or 5

	local out = self.outputs[1]
	local to = out.to:First()
	if to then
		j.next = {to.node.id,to.id,to.name}
	end
	
	return j
end 
function PANEL:FromData(data,mapping,posoffset) 
	PANEL.base.FromData(self,data,mapping,posoffset)  
	self.pincount = data.pincount or 5
end
 
function PANEL:Select(selector) 
	self:SetColor(Vector(83,255,164)/255)
	self.selector = selector
	
	---PrintTable(getmetatable(self))
end
function PANEL:Deselect()
	self:SetColor(Vector(255,255,255)/255) 
	self.selector = nil
end
 
 