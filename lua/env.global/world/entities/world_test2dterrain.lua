ENT.name = "Test 2d terrain"

local rdtex = LoadTexture("space/star_sprites.png")
function ENT:CreateStaticLight( pos, color,power,glname,seed)

	local lighttest = ents.Create("omnilight") 
	local world = matrix.Scaling(2) 
	lighttest:SetParent(self)
	lighttest:SetSizepower(0.1)
	lighttest.color = color or Vector(1,1,1)
	lighttest:SetSpaceEnabled(false)
	lighttest:Spawn() 
	if power then lighttest:SetBrightness(power) end
	lighttest:SetPos(pos) 
	if glname then lighttest:SetGlobalName(glname) end
	if seed then lighttest:SetSeed(seed) end
	

	local particlesys = lighttest:AddComponent(CTYPE_PARTICLESYSTEM) 
	particlesys:SetRenderGroup(RENDERGROUP_LOCAL)
	particlesys:SetNodeMode(false)
	particlesys:AddNode(8)
	particlesys:SetNodeStates(8,BLEND_ADD,RASTER_DETPHSOLID,DEPTH_READ) 
	particlesys:SetTexture(8,rdtex)
	particlesys:AddParticle(8,Vector(0,0,0), Vector(1, 244 / 255, 232 / 255)*1,100000*8,0) 
	particlesys:SetMaxRenderDistance(10000000000)
	lighttest.psys = particlesys

	return lighttest
end

function ENT:Init()

	self:SetSizepower(10000)
	self:SetSeed(9900001)
	self:SetGlobalName("u_grid") 
	self:SetUpdating(true,16)
end
function ENT:LoadWorld(name)
	local data = json.Read('chunkdata/'..name..'/info.json')
	if(not data) then return end

	if IsValidEnt(self.skybox) then
		self.skybox:Despawn()
		self.skybox = nil
	end  
	if IsValidEnt(self.dynsky) then
		self.dynsky:Despawn()
		self.dynsky = nil
	end  
	if data.sky and data.sky.texture then
		self.skybox = SpawnSkybox(self.space,data.sky.texture or "textures/cubemap/bluespace.dds")
		if data.sky.rotation then self.skybox:SetWorld(matrix.Rotation(JVector(data.sky.rotation))) end--Vector(180,0,0)))
	end
	if data.atmosphere then
		self.dynsky = SpawnDynsky(self.space)
	end
	self.grid:SetWorldName(name)
	if CLIENT then 
		self:Delayed("cubemapdraw",1000,function()
			if IsValidEnt(self) then
				self.cubemap:RequestDraw()
			end
			
		end)
	end

end
function ENT:Spawn()

	-- all worlds must have minimum 1 subspace 
	-- 
	local space = ents.Create()
	space:SetLoadMode(1)
	space:SetSeed(9900002)
	space:SetParent(self) 
	space:SetSizepower(1000)
	space:SetGlobalName("u_grid.space")
	space:Spawn()  
	local sspace = space:AddComponent(CTYPE_PHYSSPACE)  
	sspace:SetGravity(Vector(0,-4,0))
	space.space = sspace

	
	--def:1900000000
	local light = self:CreateStaticLight(Vector(-85.6,106.2,124.6)/10/2*10,
		Vector(255,255,255)/255,50500000000*8,"dgl_star0",33244285)
	light.light:SetShadow(true)  
	SpawnPV('prop.furniture.space.spawn',space,Vector(0,-1,0)*0.001,Vector(0,0,0),0)
	self.space = space
	 
	local grid = space:AddComponent(CTYPE_CHUNKTERRAIN)
	self.grid = grid
	grid:SetRenderGroup(RENDERGROUP_LOCAL)

	local name = 'testworld01'--'unnamedworld_131'

	self:LoadWorld(name)

	if CLIENT then

		local eshadow = ents.Create("test_shadowmap2")  
		eshadow.light = light
		eshadow:SetParent(ent) 
		eshadow:Spawn() 
		self.shadow = eshadow

		
		 
		local root_skyb =  ents.Create()
		root_skyb:SetSizepower(2000)
		root_skyb:SetParent(space)
		root_skyb:SetPos(Vector(0,0.5,0))
		root_skyb:SetSpaceEnabled(false)
		root_skyb:Spawn()

		local cubemap = root_skyb:AddComponent(CTYPE_CUBEMAP)  
		self.cubemap = cubemap 
		cubemap:SetTarget(nil,self)  
		cubemap:RequestDraw()

		GlobalSetCubemap(cubemap)
		
	end 
	CreateSpawnpoint(space,Vector(0,0.0013627,0) )
end
function ENT:Think()
	local time = CurTime()
	self:SetTime(time)
	return true
end
function ENT:SetTime(time)
	local dt = time - (self.time or 0)
	self.time = time
	local dgl_star0 = ents.GetByName("dgl_star0")
	if dgl_star0 then
		local lpos = dgl_star0:GetPos()
		local dbase = Vector(0,70,0)
		-- 0 = -180
		-- 6 = -90
		-- 12= 0 
		-- 16= 90
		local angle = dt/100--(time/10/12-1)*180

		dgl_star0:SetPos(lpos:Rotate(Vector(angle,0,0)))
		local alpos =  dgl_star0:GetPos():Normalized().y
		local mulb = math.min(math.max(alpos*20,0),1)
		--MsgN(alpos,mulb)
		dgl_star0:SetBrightness(50500000000*8*mulb,1)--
	end
end
function ENT:GetSpawn() 
	if CLIENT then
		local c = SpawnPlayerChar( Vector(0,0.0013627,0),self.space) 
		return c, Vector(0,0,0)
	end
	return self.space, Vector(0,0.01,0)
end

console.AddCmd("changedim",function(dim)
	local pl = LocalPlayer()
	if pl then
		local top = pl:GetTop()
		if top and top.LoadWorld then
			top:LoadWorld(dim)
			--debug.Delayed(function()
			--	top.grid:GetHeight()
			--end)
		end
	end
end)
console.AddCmd("listdim",function ()
	local dims = file.GetDirectories("chunkdata")
	for k,v in pairs(dims) do
		MsgN(k, string.sub(v,11))
	end
end)

function terrain_NodeSetChunk(ent,set)
	local p = ent:GetParent()
	if p then
		local chtr = p:GetComponent(CTYPE_CHUNKTERRAIN)
		if chtr then
			if set then
				chtr:AddNode(ent)
			else
				chtr:DelNode(ent)
			end
			return true
		end
	end
end
hook.Add("node_properties","chunk_node_params",function(node,params)
	local p = node:GetParent()
	if p:GetComponent(CTYPE_CHUNKTERRAIN) then 
		params.chunknode_display = {text = "is chunk node",type="indicator",value = function(ent)  
			local p = ent:GetParent()
			if p then
				local chtr = p:GetComponent(CTYPE_CHUNKTERRAIN)
				if chtr then
					return chtr:IsChunkNode(ent)
				end
			end
			return false
		end}
		params.chunknode_set = {text = "set chunk node",type="action",action = function(ent)  
			local p = ent:GetParent()
			if p then
				local chtr = p:GetComponent(CTYPE_CHUNKTERRAIN)
				if chtr then
					chtr:AddNode(ent)
					return true
				end
			end
		end}
		params.chunknode_unset = {text = "unset chunk node",type="action",action = function(ent)  
			local p = ent:GetParent()
			if p then
				local chtr = p:GetComponent(CTYPE_CHUNKTERRAIN)
				if chtr then
					chtr:DelNode(ent)
					return true
				end
			end
		end}
	end
end)