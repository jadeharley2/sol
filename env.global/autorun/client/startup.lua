if SERVER then return nil end

SAVEDGAME = false

	-- lua_run  TACTOR:GetParentWith(NTYPE_STARSYSTEM):ReloadSkybox()
function LoadMenu() 
	gui.SetStyle("default")
	
	--
	local vsize = GetViewportSize()
	chat = panel.Create("window_chat") 
	chat:SetSize(500,200)
	
	chat:SetPos(-vsize.x,-vsize.y) --+csize.x +csize.y
	chat:SetTitle("Chat")
	chat:Show()
	hook.Add("input.keydown","chat",function(key)  
		if not input.GetKeyboardBusy() then
			if key == KEYS_T then
				_CCC = chat
				debug.Delayed(1,function()
					_CCC:Select()
					_CCC = nil
				end)
			end
		end
	end)
	chat:SetVisibility(false)
	 
	--O_O = panel.Create("graph_editor") 
	--O_O:Show()
	
	--rdb = panel.Create("window_renderdebug") 
	--rdb:SetPos(0,vsize.y*0.8) 
	--rdb:SetTitle("Render")
	--rdb:Show()
	
	healthbar = panel.Create("healthbar")  
	--healthbar:SetPos(-1610,-980) --+csize.x +csize.y 
	healthbar:Show()
	healthbar:UpdateHealth()
	
	infobar = panel.Create("infobar")  
	infobar:SetPos(0,-80) --+csize.x +csize.y 
	infobar:Show()
	
	quickmenu = panel.Create("quickmenu")  
	quickmenu:SetPos(0,-200) --+csize.x +csize.y 
	quickmenu:Show()
	
	local wn = panel.Create("menu_main") 
	wn:SetPos(0,0)  
	wn:Show()
	
	
end

-- main menu shortcuts
function ConnectTo(ip)
	hook.Call("network.connect")
	return network.Connect(ip)
end
function LoadWorld(id)
	if not id and not SAVEDGAME then return error("world id unspecified") end
	
	cam:SetUpdateSpace(true)
	UNIid = id
	
	
	
	if SAVEDGAME then 
		local result, roottable = engine.LoadState(SAVEDGAME) 
		if result then
			U = roottable
		else
			
		end
	else 
		U = ents.Create("world_"..id)  
		U:Create() 
		SPAWNORIGIN,SPAWNPOS = U:GetSpawn()
		cam:SetParent(SPAWNORIGIN)
		cam:SetPos(SPAWNPOS)
	end
	
	--[[
	if id==0 then
		U = ents.Create()
		U:SetSizepower(math.pow(2,88))
		U:SetSeed(1000001)
		U:SetGlobalName("u1")
		U:Spawn() 

		space = ents.Create("spaceCluster") 
		space:SetSeed(1000002)
		space:SetParent(U) 
		space:SetSizepower(math.pow(2,86))
		space:SetGlobalName("u1.mc")
		space:Spawn() 
		
		--AddOrigin(cam)
		
		if ISSAVEDGAME then 
			LoadSave() 
		else
			SendTo(cam,"@u1.mc;-0.002718567,0.0005680526,0.004285494;0.3089897,0.02846826,0.06682603;s1065632697;s2008649333;s2397131")--ship
		--SendTo(cam,"@u1.mc;-0.002718567,0.0005680526,0.004285494;0.3089897,0.02846826,0.06682603;s1065632697;s2008649333;s2008650333;0.803679,0.07456001,-0.4183209")--planet surface
		end
	elseif id==1 then
		U = ents.Create()
		U:SetSizepower(10000)
		U:SetSeed(9900001)
		U:SetGlobalName("u1_room")
		U:Spawn() 

		space = ents.Create()
		space:SetSeed(9900002)
		space:SetParent(U) 
		space:SetSizepower(1000)
		space:SetGlobalName("u1_room.space")
		space:Spawn()  
		local sspace = space:AddComponent(CTYPE_PHYSSPACE)  
		sspace:SetGravity(Vector(0,-9.5,0))
		space.space = sspace
		
		SpawnSO("map/01/01.json",space,Vector(0,0,0),0.75) 
		local light = CreateStaticLight(space,Vector(-1.3,1.2,-2.5)/2*10,Vector(1,1,1),190000000)
		--light.light:SetShadow(true)
		--AddOrigin(cam)
		
		if ISSAVEDGAME then 
			LoadSave() 
		else
			cam:SetParent(space)
		end
	end
	]]
	--local targetpos = Vector(0.003537618,0.01925059,0.2446546)
	--cam:SetPos(targetpos)
	cam:SetGlobalName("player_cam")
	hook.Call("engine.location.loaded", cam,"local")
end 
function UnloadWorld()
	if network.IsConnected() then
		network.Disconnect()
	end
	SetController()  
	cam:SetParent(LOBBY)
	
	if U then
		if istable(U) then
			for k,v in pairs(U) do v:Despawn() end
		else
			U:Despawn()
		end
		U = nil 
	end
	engine.ClearState()
end
function CreateTestShadowMapRenderer(ent, pos)
	local e = ents.Create("test_shadowmap")  
	--e.target = ent.rt1
	e:SetParent(ent)
	if pos then e:SetPos(pos) end
	e:Spawn()
	return e
end
function SpawnPlayerChar(posoverride)  
	local ship = SPAWNORIGIN or cam:GetParent()
	local targetpos = posoverride or SPAWNPOS -- Vector(0.003537618,0.01925059,0.2446546)
	local targetpos2 = Vector(0.003008218, -0.07939442, -0.02011958)
	local targetpos3 = Vector(0.4954455, -0.002244724, 0.02894697)
	
	local playeractor = false
	
	if not SAVEDGAME then
		--local actorC = ents.Create("base_actor")
		--actorC:SetSizepower(1000)
		--actorC:SetParent(ship)
		--actorC:SetSeed(120002)
		--actorC:SetCharacter("enchantress")
		--actorC:Create() 
		--actorC:SetPos(targetpos+Vector(0.001,0,0.001)) 
		--
		local actorD = ents.Create("base_actor")
		actorD:SetSizepower(1000)
		actorD:SetParent(ship)
		actorD:SetSeed(120003)
		actorD:SetCharacter("kindred")
		actorD:Create() 
		actorD:SetPos(targetpos+Vector(0,0,0.001)) 
		
		--local actorF = ents.Create("base_actor")
		--actorF:SetSizepower(1000)
		--actorF:SetParent(ship)
		--actorF:SetSeed(120003)
		--actorF:SetCharacter("ying")
		--actorF:Create() 
		--actorF:SetPos(targetpos+Vector(0,0,-0.001))
		--
		--local actorE = ents.Create("base_actor")
		--actorE:SetSizepower(1000)
		--actorE:SetParent(ship)
		--actorE:SetSeed(120003)
		--actorE:SetCharacter("tali")
		--actorE:Create() 
		--actorE:SetPos(targetpos+Vector(0,0,-0.002))
		
		----local actor = ents.Create("base_actor")
		----actor:SetSizepower(1000)
		----actor:SetParent(ship)
		----actor:SetSeed(120000)
		----actor:SetCharacter("nightwing")
		----actor:Create()  
		----actor:SetPos(targetpos+Vector(0.001,0,0))  
		
		local actor2 = ents.Create("base_actor")
		actor2:SetSizepower(1000)
		actor2:SetParent(ship)
		actor2:SetSeed(120001)
		actor2:SetCharacter(settings.GetString("player.model"))
		--actor2:SetModel(debug.LoadString("player.model"))-- "kindred/kindred.json")
		actor2:Create()
		--actor2.phys:SetGravity(Vector(0,-4,0)) 
		actor2:SetPos(targetpos)--targetpos3)--+Vector(0.001,0,0)) 
		actor2:SetSkin(settings.GetString("player.skinid"))
		--actorC:SetPos(targetpos+Vector(0.001,0,0.001)) 
		--actor:SetPos(targetpos+Vector(0.001,0,0)) 
		--actor2:SetPos(targetpos)
		TM2 = actorD
		TM2:AddFlag(FLAG_NPC)
		
		--actor2:Give("tool_magic")

		playeractor = actor2 
		playeractor:SetGlobalName('player') 
		local name = settings.GetString("player.name")
		playeractor:SetName(name)
		playeractor:AddFlag(FLAG_PLAYER)
	
		-- local pp = SpawnWeapon("testgun",ship,targetpos+Vector(-0.001,0.001,0))--0.006
		-- local pp2 = SpawnWeapon("lightgun",ship,targetpos+Vector(-0.002,0.001,0))--0.006
	
		--pp:SetParent(actor2)
		--actor2.model:Attach(pp,"weapon1")
	
	else
		playeractor = ents.GetByName('player') 
	end
	if playeractor then
		SetLocalPlayer(playeractor)
		SetController('actorcontroller')  
		
		local system = playeractor:GetParentWith(NTYPE_STARSYSTEM)
		if system then 
			system:ReloadSkybox()
		end 
		
		--if UNIid == 0 then
			ship = playeractor:GetParent()
			SHADOW = CreateTestShadowMapRenderer(ship,Vector(0.002456535,0.02487438,0.3199512))
		--end
	else
		MsgN("ERROR: PLAYER ACTOR NOT FOUND!")
	end
end



-- test functions
function SPA() 
	local cc = GetCamera()
	local fpos = cc:GetPos()
	local actor2 = ents.Create("base_actor")
	actor2:SetSizepower(1000)
	actor2:SetParent(cc:GetParent())
	actor2:SetSeed(120000)
	actor2:SetPos(fpos) 
	actor2:SetModel(settings.GetString("player.model"))
	actor2:Spawn()
	actor2.phys:SetGravity(Vector(0,-4,0))
	
	TACTOR = actor2
	TACTOR:SetGlobalName('player') 
	SetController('actorcontroller')  
end
function SPT(scale)
	local cc = GetCamera()
	local fpos = cc:GetPos()
	--SpawnSO("engine/unit_box.SMD",cc:GetParent(),fpos,scale or 0.01).model:SetMaterial("textures/debug/white.json") 
	SpawnSO("test/tree2/dtree.json",cc:GetParent(),fpos,scale or 0.01)
end

 
function fff_GoToPos(npc,pos)
	local sz = npc:GetParent():GetSizepower()
	local a1pos = npc:GetPos()*sz
	local a2pos = pos*sz
	local dir = (a2pos-a1pos):Normalized()
	local dist = a1pos:Distance(a2pos)
	npc.phys:SetStandingSpeed(1)
	if npc.targetpos then
		npc:LookAt((a2pos-a1pos):Rotate(Vector(0,90,0)))
		npc.phys:SetViewDirection(dir)
	end
	if(dist>4)then
		npc.targetpos = Vector(0,0,1)
	end
	if(dist<2)then
		npc.targetpos  = nil 
	end
end


-- startup function 
function OnStartup()

	if not cam then
		cam = ents.CreateCamera()
		cam:SetParent(LOBBY)
		cam:Spawn()

		AddOrigin(cam)
		SetCamera(cam) 
		
		
		render.SetGroupMode(RENDERGROUP_DEEPSPACE,RENDERMODE_BACKGROUND) 
		render.SetGroupMode(RENDERGROUP_STARSYSTEM,RENDERMODE_BACKGROUND)  
		render.SetGroupMode(RENDERGROUP_PLANET,RENDERMODE_BACKGROUND) 
		render.SetGroupMode(RENDERGROUP_CURRENTPLANET,RENDERMODE_BACKGROUND) 
		render.SetGroupMode(RENDERGROUP_LOCAL,RENDERMODE_ENABLED) 
		
		cam:SetFOV(settings.GetNumber("engine.fov"))
		
		hook.Add("settings.changed","camera.fov_update",function() 
			cam:SetFOV(settings.GetNumber("engine.fov"))
		end) 
		
		LoadMenu()
	end
end
function OnLocationLoad(origin,gametype) 
	MsgN("Location loaded")
	if gametype ~= "local" then
		local system = origin:GetParentWith(NTYPE_STARSYSTEM)
		if system then 
			system:ReloadSkybox()
		end 
	end
end
hook.Add("main.startup","main",OnStartup)
hook.Add("engine.location.loaded","main",OnLocationLoad)