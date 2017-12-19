PANEL.basetype = "menu_dialog"
 
PANEL.LoadSingleplayer = function(id)
	SAVEDGAME = false
	engine.PausePhysics() 
	hook.Call("menu","loadscreen")
	debug.Delayed(1,function() 
		LoadWorld(id)  
		if id == 1 then
			SpawnPlayerChar(Vector(0,0.0001,0)) 
		else
			SpawnPlayerChar() 
		end
		--SetController('freecameracontroller')   
		debug.Delayed(1,function() 
			MAIN_MENU:SetWorldLoaded(true) 
			hook.Call("menu") 
			debug.Delayed(1,function() 
				engine.ResumePhysics()
			end)
		end)
	end)
end
function PANEL:Init()  

	
	self.base.Init(self,"Singleplayer",200,500)
	
	 
	local bcol = Vector(83,164,255)/255
	
	local ff_grid_floater = panel.Create()  
	ff_grid_floater:SetSize(400,1000)
	
	 
	local flist = file.GetFiles("lua/env.global/world/entities/","lua") 
	local totals = 0
	for k,v in pairs(flist) do 
		local cname = string.lower( file.GetFileNameWE(v)) 
		if string.starts(cname,"world_") then 
			local meta = ents.GetType(cname)
			cname = string.sub( cname,7)
			local sp_new = panel.Create("button")
			sp_new:SetText(meta.name or cname) 
			sp_new:Dock(DOCK_TOP)
			sp_new:SetTextColorAuto(bcol) 
			sp_new:SetTextAlignment(ALIGN_CENTER)
			sp_new:SetSize(150,20)
			sp_new.OnClick = function() ISSAVEDGAME = false self.LoadSingleplayer(cname) end
			ff_grid_floater:Add(sp_new)
			self:SetupStyle(sp_new)
			totals = totals + 20
		end 
	end
	ff_grid_floater:SetSize(400,totals)
	ff_grid_floater:SetColor(bcol)
	--[[
	local sp_new = panel.Create("button")
	sp_new:SetText("New solverse") 
	sp_new:Dock(DOCK_TOP)
	sp_new.OnClick = function() ISSAVEDGAME = false self.LoadSingleplayer("solverse") end
	self:SetupStyle(sp_new)
	
	local sp_new2 = panel.Create("button")
	sp_new2:SetText("New testmap") 
	sp_new2:Dock(DOCK_TOP)
	sp_new2.OnClick = function() ISSAVEDGAME = false self.LoadSingleplayer("testmap") end
	self:SetupStyle(sp_new2)
	
	local sp_new3 = panel.Create("button")
	sp_new3:SetText("New testcity") 
	sp_new3:Dock(DOCK_TOP)
	sp_new3.OnClick = function() ISSAVEDGAME = false self.LoadSingleplayer("testcity") end
	self:SetupStyle(sp_new3)
	
	local sp_new4 = panel.Create("button")
	sp_new4:SetText("New gm_construct") 
	sp_new4:Dock(DOCK_TOP)
	sp_new4.OnClick = function() ISSAVEDGAME = false self.LoadSingleplayer("testmap2") end
	self:SetupStyle(sp_new4)
	]]--
	
	
	
	
	
	
	local ff_grid = panel.Create("floatcontainer") 
	ff_grid:SetSize(400,120)  
	if totals > 120 then
		ff_grid:SetScrollbars(1)
	end
	ff_grid:SetFloater(ff_grid_floater) 
	ff_grid:SetColor(bcol)
	
	
	
	
	local sp_load = panel.Create("button")
	sp_load:SetText("Load") 
	sp_load:SetPos(-100,-150) 
	sp_load.OnClick = function() hook.Call("menu","load") end
	self:SetupStyle(sp_load)
	
	local sp_back = panel.Create("button")
	sp_back:SetText("Back") 
	sp_back:SetPos(100,-150)
	sp_back.OnClick = function() hook.Call("menu","main") end
	self:SetupStyle(sp_back)
	
	for k,v in pairs({sp_load,sp_back}) do  --sp_new,sp_new2,sp_new3,sp_new4,
		v:SetTextColorAuto(bcol)
		--v:SetTextOnly(true)
		v:SetTextAlignment(ALIGN_CENTER)
		v:SetSize(150,20)
	end
	
		sp_load:SetSize(50,20)
		sp_back:SetSize(50,20)
	
	--ff_grid_floater:Add(sp_new)
	--ff_grid_floater:Add(sp_new2)
	--ff_grid_floater:Add(sp_new3)
	--ff_grid_floater:Add(sp_new4)
	self:Add(ff_grid)
	self:Add(sp_load)
	self:Add(sp_back)    
end