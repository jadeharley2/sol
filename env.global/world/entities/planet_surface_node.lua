TSNODE = false

--function ENT:Init()  
--end
function ENT:Spawn() 
end
function ENT:Enter()
	--local debugwhite = "textures/debug/white.json"
	--for k=1,100 do
	--	local pos = Vector(math.random(-100000,100000)/100000,0,math.random(-100000,100000)/100000)
	--	SpawnSO("debris/rock01.smd",self,pos,0.75).model:SetMaterial(debugwhite) 
	--	
	--end
	--TSNODE = self
	render.SetGroupMode(RENDERGROUP_CURRENTPLANET,RENDERMODE_ENABLED) 
	 
	
	if CLIENT then   
		self.cubemap = SpawnCubemap(self,Vector(0,0.02,0),128)
		local sz = self:GetSizepower()
		self.cubemap:SetSizepower(sz)
		--self.cubemap:SetAng(Vector(0,0,90))
		self.cubemap:RequestDraw()
		self:Hook("pre_cubemap_render","move_cb",function()
			if self then
				local c = GetCamera()
				local cp = self:GetLocalCoordinates(c)
				local sc = self.cubemap
				if sc then
					sc:SetPos(cp+Vector(0,3/sz,0))
				end
			end
		end)
		
		if not SHADOW or not IsValidEnt(SHADOW) then 
			local star = self:GetParentWithFlag(FLAG_STAR)
			if star then
				local eshadow = ents.Create("test_shadowmap2")  
				eshadow.light = star
				eshadow:SetParent(GetCamera():GetParent()) 
				eshadow:Spawn() 
				---self.shadow = eshadow
				SHADOW = eshadow
			end
		end
		local p = SpawnParticles(self,"clouds",Vector(0,0,0),0,100,1) 
		--SHADOW = SHADOW or CreateTestShadowMapRenderer(GetCamera():GetParent(),Vector(0,0,0))
	end
end
function ENT:Leave() 
	if TSNODE == self then 
		TSNODE = false
	end
	if CLIENT then
		render.SetGroupMode(RENDERGROUP_CURRENTPLANET,RENDERMODE_BACKGROUND) 
		render.ClearShadowMaps()
		local cb = self.cubemap
		if cb then
			cb:Despawn() 
			self.cubemap = nil
		end 
	end 
end 

function ENT:GetElevation()
	 
end


function GETPOS()
	local c = GetCamera()
		MsgN("sadsad") 
	if TSNODE then
		local surf, part = c:GetParentWithComponent(CTYPE_PARTITION2D)
		MsgN("asd")
		if(surf and part) then
			local pos = surf:GetLocalCoordinates(c)
			local chunk = part:GetSurfacePos(TSNODE,pos)  
		end
	end   
end
   
if CBTASK then CBTASK:Stop() end 
CBTASK = debug.DelayedTimer(0,2600,-1,function()
	hook.Call("pre_cubemap_render")  
	hook.Call("cubemap_render") 
	--MsgInfo("asd")
end) 