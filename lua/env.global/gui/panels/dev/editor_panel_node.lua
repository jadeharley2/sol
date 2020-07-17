
local layout = {
	color = {0,0,0},
	size = {200,200},
	subs = {
		--{ name = "header",  class = "header_0",    
		--	dock = DOCK_TOP, 
		--	text = "World outliner", 
		--}, 
		{  
			size = {100,40},
            dock = DOCK_TOP,
            color = {0,0,0},
            subs = {
				 
				{ class = "bmenutoggle", texture = "textures/gui/panel_icons/move.png", contextinfo='Move mode', group = 'nod'},
				{ class = "bmenutoggle", texture = "textures/gui/panel_icons/rotate.png", contextinfo='Rotation mode', group = 'nod'},
				{ class = "bmenutoggle", texture = "textures/gui/panel_icons/scale.png", contextinfo='Scailing mode', group = 'nod'},
			}
		},
		{ name = "header", class = "header_1",   
			dock = DOCK_TOP, 
			text = "Hierarchy",  
			subs = {
				{type='button', name = "refcom",
					size = {20,20},
					dock = DOCK_RIGHT,
					ColorAuto = Vector(0,0.2,0.3),
					texture = "textures/gui/panel_icons/refresh.png",
				}
			}
		},
		{ type = "list",name = "hierarchy", class = "back",
			size = {200,200},
			dock = DOCK_TOP,
			itemheight = 16
		},
		{ name = "header", class = "header_1",  
			dock = DOCK_TOP, 
			text = "Nodes",  
		},
		{ name = "action_panel", class = "back",
			size = {200,200},
			dock = DOCK_BOTTOM,   
			subs = {
				{type='button', name = "bnodeadd",
					size = {20,20},
					dock = DOCK_TOP,
					ColorAuto = Vector(0,0.2,0.3)*2,
					text = "AddNode"
				}
			}
		},
		{ name = "header", class = "header_1", 
			dock = DOCK_BOTTOM, 
			text = "Actions",  
		},
		{ type = "tree2",name = "nodetree", class = "back",
			dock = DOCK_FILL,
			itemheight = 16
		},
	}
} 

function PANEL:Init() 
	gui.FromTable(layout,self,global_editor_style,self) 
	self.refcom.OnClick = function() self:UpdateCnodes() end  
	self:UpdateCnodes() 
	self:UpdateHierarchy() 
	self.noderef = {}
	
end 
function PANEL:SelectNode(node) 
	self:UpdateCnodes(node) 
	self:UpdateHierarchy(node) 
end

function PANEL:UpdateHierarchy(cnode)
	local cnode = cnode or GetCamera() --TEMP
	self.hierarchy:ClearItems()
	for k,v in pairs(cnode:GetHierarchy()) do
		self.hierarchy:AddItem(gui.FromTable({
			type = "button",
			size = {16,16},
			text = tostring(v),
			OnClick = function() 
				worldeditor:Select(v)
			end
		}))
	end
	self:UpdateLayout()
	self.hierarchy:ScrollToTop()
end
function PANEL:UpdateCnodes(root) 
	MsgN("CBN")
	local nodetree = self.nodetree
	local rtb = {"types"}
	root = root or GetCamera():GetParent()
	self.noderef = {}
	local roottreenode = self:NodeToTreeElement(root)
	--self:ConstructTreeSegment(root,roottreenode)
	nodetree:ClearNodes()
	nodetree:AddNode(roottreenode)
	nodetree:UpdateLayout()
	hook.Add("editor_select","nodetree_update",function(node)
		if node == nil then
			for k,v in pairs(self.noderef) do
				v.title:SetTextColor(Vector(0.6,0.8,1))
			end
		else
			local ss = self.noderef[node]
			if ss then
				ss.title:SetTextColor(Vector(0.8,2,1))
			end
		end
	end)
	hook.Add("editor_deselect","nodetree_update",function(node) 
		if IsValidEnt(node) then
			local ss = self.noderef[node]
			if ss then
				ss.title:SetTextColor(Vector(0.6,0.8,1)) 
			end
		end
	end)
end
function PANEL:GetEntIcon(ent)
	local class = ent:GetClass()
	if class=='' then
		if ent.AspectRatio then 
			class = 'camera'  
		end
	end
	local path = 'textures/gui/ents/'..class..'.png'
	if file.Exists(path) then return path else return 'textures/gui/ents/node.png' end
end
function PANEL:NodeToTreeElement(ent)
	local n = gui.FromTable({
		type = 'tree2node',
		text = tostring(ent), 
		textcolor = {0.6,0.8,1},
		Icon = self:GetEntIcon(ent),
		entity = ent,
		OnClick = function(s) 
			worldeditor:Select(s.entity)
		end
	})

	self.noderef[ent] = n
	self:ConstructTreeSegment(ent,n)
	return n
end
function PANEL:ConstructTreeSegment(ent,treenode)
	for k,v in pairs(ent:GetChildren()) do
		if not v.editor or not v.editor.hide then
			if not v:HasTag(TAG_CHUNKNODE) then
				treenode:AddNode(self:NodeToTreeElement(v))
			end
		end
	end
end
function PANEL:UpdateCnodes_old(root) 
	local nodetree = self.nodetree
	local rtb = {"types"}
	
	root = root or GetCamera():GetParent()
	local chp = root:GetChildren()
	  
	local tb2 = {"<<parent>>",OnClick=function(b) 
		local ct = CurTime()
		if b.lastclc and b.lastclc>(ct-0.5) then
			if root:GetParent() then
				self:UpdateCnodes(root:GetParent())
			end
		else
			b.lastclc = ct 
			worldeditor:Select(root)
		end
	end}  
	rtb[#rtb+1] = tb2
	local maxnodecount = 500
	for k,v in SortedPairs(chp) do 
		if v then
			maxnodecount = maxnodecount - 1
			if maxnodecount<=0 then
				local tb2 = {(#chp-100).." more"}  
				rtb[#rtb+1] = tb2
				break
			end
			local hide = (v.editor and v.editor.hide) or v:HasTag(320230)
			if not hide then
				local onclick = function(b) 
					local ct = CurTime()
					if b.lastclc and b.lastclc>(ct-0.5) then
						self:UpdateCnodes(v)
					else
						b.lastclc = ct 
						worldeditor:Select(v)
					end
				end 
				local cc = '['..#v:GetChildren()..'] '

				local tb2 = {cc..tostring(v),OnClick=onclick}  
				rtb[#rtb+1] = tb2
			end
		end
	end
	nodetree:SetTableType(2)
	
	nodetree:FromTable(rtb)
	nodetree:SetSize(430,400) 
	self:UpdateLayout()
	nodetree:ScrollToTop()
end
