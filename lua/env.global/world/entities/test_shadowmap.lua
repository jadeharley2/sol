
--CLIENT ONLY

function ENT:Init()  
	self:SetSpaceEnabled(false) 
	self:SetDonotsave(true) 
	self:SetSizepower(1000)
end

function ENT:Spawn()   
	local seed = self:GetSeed()
	hook.Add("settings.changed","shadowmapupdate",function()
		self:UpdateShadowMap()
	end)
	self:UpdateShadowMap()
end
function ENT:Despawn() 
	hook.Remove(EVENT_GLOBAL_PREDRAW, "shadowmapupdate")
	hook.Remove("settings.changed","shadowmapupdate")
end
function ENT:UpdateShadowMap()

	local shadows_enabled = settings.GetBool("engine.shadowsenabled",true)  
	if shadows_enabled then
		local shadow_size = settings.GetNumber("engine.shadowssize",1024) 
		
		local cc = self.cc or ents.CreateCamera()
		cc:SetParent(self) 
		cc:Spawn()
		self.cc = cc  
		
		local seed = self:GetSeed()
		--self.target or 
		local target = CreateRenderTarget(shadow_size,shadow_size,"@shadow"..tostring(seed)..":Texture2D",1)
		self.target = target
		 
		local camera = self.camera or self:AddComponent(CTYPE_CAMERA) 
		camera:SetCamera(cc)
		camera:SetRenderTarget(0,target)
		camera:SetTargetTech("shadow")
		camera:RequestDraw()
		self.camera = camera 
		
		
		--self:SetUpdating(true)
		hook.Add(EVENT_GLOBAL_PREDRAW, "shadowmapupdate", function() self:UpdatePos() end)
	else
		local cc = self.cc 
		local target = self.target
		local camera = self.camera
		
		if cc then cc:Despawn() self.cc = nil end
		if target then target:Unload() self.target = nil end
		if camera then camera:UnsetShadowMap() self:RemoveComponent(camera) self.camera = nil end
		
		--self:SetUpdating(false)
		hook.Remove(EVENT_GLOBAL_PREDRAW, "shadowmapupdate")
	end 
end
function ENT:UpdatePos() 
	local c = GetCamera()
	if not self or not IsValidEnt(self) then
		hook.Remove(EVENT_GLOBAL_PREDRAW, "shadowmapupdate")
		return
	end
	local p = self:GetParent()
	local cp = c:GetParent()
	if cp and IsValidEnt(cp) then
		while cp:HasFlag(FLAG_ACTOR) do
			cp = cp:GetParent()
		end
		if(cp~=p)then
			self:SetParent(cp)
			p = cp
			MsgN("cp ",self, " to ",cp)
		end
		local starsys = self:GetParentWith(NTYPE_STARSYSTEM)
		if starsys then
			local dir = p:GetLocalCoordinates(starsys):Normalized()
			local cpos = p:GetLocalCoordinates(c)--p:GetLocalCoordinates(c) 
			self:SetPos(cpos +dir/p:GetSizepower()*1000)--*10
			self:LookAt(-dir)
			local sc = self.camera
			if sc then
				sc:RequestDraw()
			end
		end
	else 
		hook.Remove(EVENT_GLOBAL_PREDRAW, "shadowmapupdate")
	end
end