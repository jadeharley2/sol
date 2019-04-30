if SERVER then return nil end

chareditor = chareditor or {}
--chareditor.world  = nil

function chareditor.CreateStaticLight( pos, color,power)

	local lighttest = ents.Create("omnilight") 
	local world = matrix.Scaling(2) 
	lighttest:SetParent(chareditor.space)
	lighttest:SetSizepower(0.1)
	lighttest.color = color or Vector(1,1,1)
	lighttest:SetSpaceEnabled(false)
	lighttest:Spawn() 
	if power then lighttest:SetBrightness(power) end
	lighttest:SetPos(pos)  
	return lighttest
end

function chareditor.SpawnWorld()
	local w = ents.Create("world_void")
	w:SetSeed(3245131)  
	w.subseed = 2482091
	w:Spawn()
	chareditor.world = w
	chareditor.space = w.space

	chareditor.CreateStaticLight(Vector(1,1,1), Vector(1,1,1),400000)

 
		
	local skybox = w:AddComponent(CTYPE_SKYBOX) 
	skybox:SetRenderGroup(RENDERGROUP_LOCAL) 
	skybox:SetTexture("textures/cubemap/bluespace.dds")
	chareditor.skybox = skybox

	local root_skyb =  ents.Create()
	root_skyb:SetSizepower(2000)
	root_skyb:SetParent(w.space)
	root_skyb:SetPos(Vector(0,100,0))
	root_skyb:Spawn()

	local cbm =  w.space:AddComponent(CTYPE_CUBEMAP)
	cbm:SetSize(512)
	cbm:SetTarget(nil,w.space) 
	cbm:RequestDraw()
	chareditor.cubemap = cbm 

	MsgInfo("new world")
end

function chareditor.CloseGui()
	if chareditor.panel then
		chareditor.panel:Close()
		chareditor.panel = nil
	end
end
local default_material = {
	shader="shader.model", 
	base_subsurface_val=0.5, 
	brightness=1,
	base_specular_intencity=0.1,
	mul_specular_intencity=1, 
	base_specular_power=0.2,
	mul_specular_power=1, 
	g_MeshTexture="textures/debug/white.png",  
	tint={1,1,1},
}
local global_color_options = { 
	keys = { "color_body_1","color_body_2","color_body_3","color_body_4" },
}
local test_options = {
	body = {
		body_ara={text="Ara",part="body_feline",materials={
			{   
				shader="shader.model",
				base_subsurface_val=0.5, 
				brightness=1,
				base_specular_intencity=0.1,
				mul_specular_intencity=1, 
				base_specular_power=0.2,
				mul_specular_power=1, 
				g_MeshTexture="models/species/anthro/materials/ara_body.png",  
				g_MeshTexture_e="models/species/anthro/materials/ara_body_e.png",  
			}
		},matdir="models/species/anthro/materials/"},
		body_vikna={text="Vikna",part="body_feline"},
		body_feline={text="Feline",part="body_feline",dynmaterial={
			matdir = "models/species/anthro/texparts/",
			basematerial = default_material,
			texparts = { 
				{file="textures/debug/white.png", color="color_body_1"},
				{file="models/species/anthro/texparts/body_feline_l1.png", color="color_body_2"},
				{file="models/species/anthro/texparts/body_feline_l2.png", color="color_body_3"} 
			}
		}},
	},
	head = {
		head_ara={text="Ara",part="head_ara"},
		head_vikna={text="Vikna",part="head_vikna"},
		head_feline={text="Feline",part="head_vikna",dynmaterial={
			matdir = "models/species/anthro/texparts/",
			basematerial = default_material,
			texparts = {
				{file="textures/debug/white.png", color="color_body_1"},
				{file="models/species/anthro/texparts/body_colors_l1.png", color="color_body_2"},
				{file="models/species/anthro/texparts/body_colors_l2.png", color="color_body_3"} ,
				{file="models/species/anthro/texparts/body_colors_l3.png", color="color_body_4"}
			}
		}},
	},
	tail = {
		tail_ara={text="Ara",part="tail_ara"},
		tail_vikna={text="Vikna",part="tail_vikna"},
		tail_feline={text="Feline",part="tail_vikna",dynmaterial={
			matdir = "models/species/anthro/texparts/",
			basematerial = default_material,
			texparts = {
				{file="textures/debug/white.png", color="color_body_1"},
				{file="models/species/anthro/texparts/body_colors_l1.png", color="color_body_2"},
				{file="models/species/anthro/texparts/body_colors_l2.png", color="color_body_3"} ,
				{file="models/species/anthro/texparts/body_colors_l3.png", color="color_body_4"}
			}
		}},
	},
	hair = {
		{text="Ara",part="hair_ara",colorable=true},
		{text="Vikna",part="hair_vikna",colorable=true},
	},
}
chareditor.colorray =chareditor.colorray or {}
function chareditor.SetPart(type,partinfo,key)
	local char = chareditor.character
	local partlist = char.spparts

	local oldpart= partlist[type]
	if oldpart then
		oldpart:Despawn()
		partlist[type] = nil
	end

	local partname = partinfo.part

	local bpath = char.species.model.basedir

	local bp = SpawnBP(bpath..partname..".stmd",char,0.03)
	bp:SetName(type)
	bp.partname = key
	partlist[type] = bp
	
	if bp and partinfo.materials then  
		for mid,mvl in pairs(partinfo.materials) do
			local mat = dynmateial.LoadDynMaterial(mvl,partinfo.matdir)
			bp.model:SetMaterial(mat,mid-1)
		end
	end
	if bp and partinfo.dynmaterial then 
		chareditor.UpdateDynamicTexture(type,partinfo,chareditor.colorray) 
	end
end
function chareditor.SetPartColor(type,color) 
	local char = chareditor.character
	local partlist = char.spparts

	local bp= partlist[type] 
	ModModelMaterials(bp.model,{tint = color},false)
end
function chareditor.GetPartColor(type) 
	local char = chareditor.character
	local partlist = char.spparts

	local bp= partlist[type] 
	local mat = bp.model:GetMaterial(0)
	return GetMaterialProperty(mat,"tint")
end
function chareditor.UpdateDynamicTextures() 
	local char = chareditor.character
	local partlist = char.spparts
	for k,v in pairs(test_options) do

		local bp= partlist[k] 
		local pn = bp.partname 
		if pn then
			local partinfo = v[pn] 
			if partinfo and partinfo.dynmaterial then 
				chareditor.UpdateDynamicTexture(k,partinfo,chareditor.colorray) 
			end
		end
	end
end
function chareditor.UpdateDynamicTexture(type,partinfo,colorray) 
	local char = chareditor.character
	local partlist = char.spparts

	local bp= partlist[type] 
	local DM = partinfo.dynmaterial
	if bp and DM then 
		local tab = {}
		for k,v in pairs(DM.texparts) do
			tab[#tab+1] = {
				texture = v.file,
				color = VectorJ( colorray[v.color] or Vector(1,1,1)),
				size = {512,512}
			}
		end
		local root = gui.FromTable({size ={512,512}, subs = tab})
		local mat = NewMaterial(DM.matdir, json.ToJson(DM.basematerial)) 
		--root:Show()
 
		--debug.Delayed(2000,function()  root:Close() end)
		RenderTexture(512,512,root,function(rtex)
			SetMaterialProperty(mat,"g_MeshTexture",rtex) 
			bp.model:SetMaterial(mat,DM.matid or 0)
		end)   
	end

end
function chareditor.OpenGui()
	chareditor.CloseGui() 
	local layout = {type = "panel", 
		size = {200,600},
		dock = DOCK_TOP,  
		color = {0.2,0.2,0.2},  
		subs = {{type = "panel", 
				dock = DOCK_TOP,  
				text = "Character editor",
				size = {20,20},
				margin = {5,5,5,5}, 
				color = {1,1,1},  
			},
			{type = "panel", name ="cat_group",
				dock = DOCK_TOP,   
				size = {20,20}, 
				color = {1,1,1},  
				margin = {5,5,5,5}, 
				autosize={false,true}
			},
			{type = "panel", name ="partlist",
				dock = DOCK_TOP,   
				size = {20,20}, 
				color = {1,1,1},  
				margin = {5,5,5,5}, 
				autosize={false,true}
			},
			{type = "panel", name ="param_group",
				dock = DOCK_TOP,   
				size = {20,20}, 
				color = {0,0,0},  
				margin = {5,5,5,5}, 
				autosize={false,true}
			}, 
			{type = "panel", name ="global_param_group",
				dock = DOCK_TOP,   
				size = {20,20}, 
				color = {0,0,0},  
				margin = {5,5,5,5},       
				autosize={false,true}
			},
			--{type = "list",
			--	dock = DOCK_FILL,   
			--	size = {200,100}, 
			--	color = {0,0,0},  
			--	subs= { 
			--		{type="floatcontainer",  -- class = "submenu",
			--			visible = true, 
			--			size = {200,100}, 
			--			dock = DOCK_FILL,
			--			color = {0,0,0}, 
			--			textonly=true, 
			--			Floater = {type="panel", 
			--				scrollbars = 1,
			--				color = {0,0,0}, 
			--				size = {200,200},  
			--				autosize={false,true},
			--				subs={ 
			--				}
			--			},
			--		}, 
			--	}
			--},  
		}
	}
	local nt = {} 
	local p = gui.FromTable(layout,nil,{},nt) 
	chareditor.panel = p 
	local lstc = nt.partlist
	MsgN("aaaa",p,nt)
	PrintTable(nt)
	local SelectPartItem = function(type,item,key) 
		chareditor.SetPart(type,item,key)

		nt.param_group:Clear()
		if item.colorable then
			local oncolorchange = function(s,c)
				chareditor.SetPartColor(type,c)
			end
			local cp = gui.FromTable({
				type = "color_param",
				dock = DOCK_TOP,
				text = "Part color",
				OnPick = oncolorchange
			})
			local ptcolor = chareditor.GetPartColor(type)
			cp:SetValue(ptcolor or Vector(1,1,1))
			nt.param_group:Add(cp) 
		end 

		p:UpdateLayout()
	end
	local SelectPartType = function(type)
		lstc:Clear()
		nt.param_group:Clear()
		local typeinfo = test_options[type]
		for k,v in pairs(typeinfo) do
			lstc:Add(gui.FromTable({ type="button",  -- class = "submenu", 
				size = {20,20},
				states = {
					idle    = {color = {0,0,0}},
					hover   = {color = {0.3,0.3,0.3}},
					pressed = {color = {1,1,1}},
				}, 
				stat = "idle",
				color = {0,0,0}, 
				textcolor = {1,1,1},
				text = v.text,
				dock = DOCK_TOP,  
				tag = {type,v,k},
				OnClick = function(s) 
					SelectPartItem(s.tag[1],s.tag[2],s.tag[3])
				end
			}))  
		end  

		p:UpdateLayout()
	end

	local lst = nt.cat_group
	local selectOne = function(btn)
		for k,v in pairs(lst:GetChildren()) do if v~=btn then v:SetState("idle") end end 
	end
	for k,v in pairs(test_options) do
		lst:Add(gui.FromTable({ type="button",  -- class = "submenu", 
			size = {20,20},
			states = {
				idle    = {color = {0,0,0}},
				hover   = {color = {0.3,0.3,0.3}},
				pressed = {color = {0.3,0.5,0.3}}, 
			}, 
			stat = "idle",
			color = {0,0,0}, 
			textcolor = {1,1,1},
			text = k,
			dock = DOCK_TOP,   
			toggleable = true,
			
			tag = k,
			OnClick = function(s) 
				SelectPartType(s.tag)
				selectOne(s)
			end
		}))  
	end
 
	nt.global_param_group:Clear()  
	local oncolorchange = function(s,c)
		chareditor.colorray[s.key] = c
		chareditor.UpdateDynamicTextures()--type,item,colorpickray)
	end
	for k,v in pairs(global_color_options.keys) do
		local cp = gui.FromTable({
			type = "color_param",
			dock = DOCK_TOP,
			key = v,
			OnPick = oncolorchange
		})
		--local cp = gui.FromTable(button_c)
		cp:SetText(v)
		cp.key = v
		cp.OnPick = oncolorchange
		cp:SetValue(chareditor.colorray[v] or Vector(1,1,1))
		nt.global_param_group:Add(cp)  
	end  

	local vsize = GetViewportSize()  
	p:SetPos(vsize.x-300,0)
	p:Show()  
	p:UpdateLayout()
end

function chareditor.Enable()
	if not chareditor.world  then chareditor.SpawnWorld() end
	chareditor.enabled = true
	local char =  LocalPlayer()
	chareditor.character = char
	if char then
		SetController("orbitingcamera")
		global_controller.center = Vector(0,0.001,0)
		global_controller.zoom = 1
		global_controller.mode = "restricted"
		GetCamera():SetParent(char)

		chareditor.savednode = char:GetParent()
		chareditor.savedpos = char:GetPos()
		--chareditor.savedw = char:GetWorld()
		char:DisableGraphUpdate() 
		char:SetParent(chareditor.space)
		char:SetPos(Vector(0,0,0))
		char:SetAng(Vector(0,0,0))
		char:SetEyeAngles(0,0,true) 
		local cm = char.model
		if cm then
			cm:SetPoseParameter("head_yaw",0,true)
			cm:SetPoseParameter("head_pitch",0,true) 
			cm:SetPoseParameter("eyes_x",0,true)
			cm:SetPoseParameter("eyes_y",0,true) 
		end
		local cq = char.equipment
		if cq then
			for k,v in pairs(cq:GetParts()) do v:SetVisible(false) end
		end  
		for k,v in pairs(char.spparts) do v:SetVisible(true) end 
	end
	--local list_view = nodeeditor._lv or panel.Create("graph_editor")
	--nodeeditor._lv = list_view
	--list_view:Show()
	chareditor.OpenGui()
end
function chareditor.Disable()
	chareditor.enabled = false
	local char = chareditor.character
	if char then
		if chareditor.savednode then
			char:SetParent(chareditor.savednode)
			char:SetPos(chareditor.savedpos)
			--char:SetWorld(chareditor.savedw)
			char:EnableGraphUpdate() 
		end
		local cq = char.equipment
		if cq then
			for k,v in pairs(cq:GetParts()) do v:SetVisible(true) end
		end 
		for k,v in pairs(char.spparts) do v:UpdateVisibility() end 
		SetController("actor")
	end
	chareditor.CloseGui() 
end
function chareditor.Toggle()
	if chareditor.enabled then
		chareditor.Disable()
	else
		chareditor.Enable()
	end
end 

console.AddCmd("ed_char", chareditor.Toggle)
---test

--render.SetRenderBounds(100,100,1000,1000)