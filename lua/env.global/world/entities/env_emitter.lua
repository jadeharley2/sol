

function EmitParticles(ent,type,time,size,speed)
	time = time or 1 
	size = size or 1
	
	local particlesys2 = --ent:GetComponent(CTYPE_PARTICLESYSTEM2) or
	 ent:AddComponent(CTYPE_PARTICLESYSTEM2) 
	particlesys2:SetSpeed(speed or 1)

	particlesys2:SetRenderGroup(RENDERGROUP_LOCAL)
	particlesys2:SetBlendMode(BLEND_ADD) 
	particlesys2:SetRasterizerMode(RASTER_DETPHSOLID) 

	particlesys2:SetDepthStencillMode(DEPTH_READ)  
 
	particlesys2:Set("particles/"..type..".particle")
   
	if time>0 then
		debug.Delayed(time*1000, function()
			ent:RemoveComponent(particlesys2)
		end)
	end
	return particlesys2
end  
 
function GLFootstep(ent, parent,type,pos,time,size,speed)
	local e = SpawnParticles(parent,type,pos,time,size,speed)
	if e then
		local m = e:RequireComponent(CTYPE_MODEL) 
		m:SetRenderGroup(RENDERGROUP_LOCAL)
		m:SetBlendMode(BLEND_OPAQUE) 
		m:SetRasterizerMode(RASTER_DETPHSOLID) 
		m:SetDepthStencillMode(DEPTH_ENABLED)  
		m:SetBrightness(1)
		m:SetFadeBounds(0,9e20,0)  
		m:SetModel('models/primitives/plane.stmd')   
		m:SetMaxRenderDistance(1000)   
		m:SetMatrix(
			matrix.Scaling(ent.footstepsize or 3.5)
			*matrix.Rotation(Vector(-90,-90,0))
			*ent:GetWorld()
			*matrix.Translation(Vector(0,0.3,0))
		) 
		m:SetMaterial(ent.footsteptex or 'textures/surface/footprint/default.json')
	end

end
function SpawnParticles(parent,type,pos,time,size,speed)
	time = time or 1
	local e = ents.Create("env_emitter")
	e.speed = speed or 1
	e:SetParent(parent)
	e:SetParameter(VARTYPE_CHARACTER,type or "explosion")
	e:SetSizepower(size or 1)
	if pos then e:SetPos(pos) end
	e:Spawn()


	if time>0 then
		debug.Delayed(time*1000, function()
			if IsValidEnt(e) then e:Despawn() end
		end)
	end
	return e
end   
function SpawnParticlesCustom(parent,type,pos,time,size,speed)
	time = time or 1 
	local e = ents.Create("env_emitter")
	e.speed = speed or 1
	e:SetParent(parent)
	e.customtype = type 
	e:SetSizepower(size or 1)
	if pos then e:SetPos(pos) end
	e:Spawn()
	if time>0 then
		debug.Delayed(time*1000, function()
			if IsValidEnt(e) then e:Despawn() end
		end)
	end
	return e
end
--lua_run SpawnParticlesStarsystem(Entity(1065632697),"explosion_void",Vector(0,0,0),100,1000000000)
function SpawnParticlesStarsystem(parent,type,pos,time,size,speed)
	time = time or 1 
	local e = ents.Create("env_emitter")
	e.speed = speed or 1
	e.rgroup = RENDERGROUP_STARSYSTEM
	e:SetParent(parent)
	e:SetParameter(VARTYPE_CHARACTER,type or "explosion")
	e:SetSizepower(size or 1)
	if pos then e:SetPos(pos) end
	e:Spawn()
	if time>0 then
		debug.Delayed(time*1000, function()
			e:Despawn()
		end)
	end
	return e
end
function SpawnParticlesSpace(parent,type,pos,time,size,speed)
	time = time or 1 
	local e = ents.Create("env_emitter")
	e.speed = speed or 1
	e.rgroup = RENDERGROUP_DEEPSPACE
	e.dmode = DEPTH_NONE
	e:SetParent(parent)
	e:SetParameter(VARTYPE_CHARACTER,type or "explosion")
	e:SetSizepower(size or 1)
	if pos then e:SetPos(pos) end
	e:Spawn()
	if time>0 then
		debug.Delayed(time*1000, function()
			e:Despawn()
		end)
	end
	return e
end

function ENT:Init()  
	self:SetSpaceEnabled(false) 
end
function ENT:SetCustom(effect)
	self.customtype = effect
end


function ENT:Spawn(c)  
	
	local customtype = self.customtype
	
	local particlesys2 = self:AddComponent(CTYPE_PARTICLESYSTEM2) 
	particlesys2:SetSpeed(self.speed or 1)
	particlesys2:SetRenderGroup(self.rgroup or RENDERGROUP_LOCAL)
	particlesys2:SetBlendMode(BLEND_ADD) 
	particlesys2:SetRasterizerMode(RASTER_DETPHSOLID) 
	if self.dmode ~=nil then
		particlesys2:SetDepthStencillMode(self.dmode)  
	else
		particlesys2:SetDepthStencillMode(DEPTH_READ)  
	end
	if customtype then
		particlesys2:Set(customtype)
	else
		local ptype = self:GetParameter(VARTYPE_CHARACTER,"magic_explosion") --or "magic_explosion" 
		if ptype then
			particlesys2:Set("particles/"..ptype..".particle")
		end
	end
	self.particlesys2 = particlesys2 
	
end 
console.AddCmd("spawnparticles",function(type,size,time)
	SpawnParticles(LocalPlayer(),type,Vector(0,1/LocalPlayer():GetSizepower(),0),tonumber(time or 1),tonumber(size or 1),1) 
end)
console.AddCmd("emit",function(type,name,size,time)
	local ent = LocalPlayer()
	if name then ent = LocalPlayer():GetByName(name) or ent end
	if not type or type == "stop" then
		local particlesys2 = ent:GetComponent(CTYPE_PARTICLESYSTEM2)
		if particlesys2 then
			particlesys2:Set(nil)
		end
	else
		EmitParticles(ent,type,tonumber(time or 1),tonumber(size or 1),1) 
	end
end)


function testglow(ent) 
	local mod = { 
		g_MeshTexture =  "textures/debug/black.png", 
		g_MeshTexture_e = "textures/debug/white.png", 
		emissionTint= Vector(0.05,0.07,0.10),  
		rimfadeEmission=Point(-1,0.2),
		mul_emissive_intencity=15
	}
	return ModNodeMaterials(ent,mod,false,true) 
end