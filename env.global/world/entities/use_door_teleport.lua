

function SpawnDT(model,parent,pos,ang,sca)
	local e = ents.Create("use_door_teleport")
	--MsgN("lol"..model)
	e:SetModel(model) 
	if sca then e:SetModelScale(sca) end
	e:SetSizepower(1)
	e:SetParent(parent)
	e:SetPos(pos) 
	e:SetAng(ang) 
	e:Spawn()
	return e
end

ENT.usetype = "enter"

function ENT:Init()  
	local phys = self:AddComponent(CTYPE_PHYSOBJ)  
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model
	self.phys = phys
	self:SetSpaceEnabled(false)
	self:AddFlag(FLAG_PHYSSIMULATED)
	self:AddFlag(FLAG_USEABLE) 
	

	--phys:SetMass(10)  
	
end
function ENT:LoadModel() 
	local model_scale = self:GetParameter(VARTYPE_MODELSCALE) or 1
	
	local model = self.model
	local world = matrix.Scaling(model_scale)-- * matrix.Rotation(-90,0,0)
	 
	local phys =  self.phys
	local amul = 80
	
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel(self:GetParameter(VARTYPE_MODEL)) 
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,99999,0)  
	
	
	if(model:HasCollision()) then
		phys:SetShapeFromModel( matrix.Scaling(1) ) 
	else
		phys:SetShape(mdl, matrix.Scaling(1) ) 
	end
	--phys:SetShape(phymodel,world * matrix.Scaling(1/amul) )
	phys:SetMass(10) 
	
	model:SetMatrix( world* matrix.Translation(-phys:GetMassCenter()   ))
	
	--MsgN("model    "..tostring(phys:GetMassCenter()) )
end
function ENT:Load()
	self:LoadModel() 
	self:SetPos(self:GetPos())
end
function ENT:Spawn() 
	self:LoadModel() 
	self.phys:SoundCallbacks()
	self.phys:SetMaterial("wood")
end
function ENT:SetModel(mdl)
	self:SetParameter(VARTYPE_MODEL,mdl) 
end
function ENT:SetModelScale(scale) 
	self:SetParameter(VARTYPE_MODELSCALE,scale)
end
--function ENT:Think()
--	--MsgN(self.phys:OnGround())
--	--if input.KeyPressed(KEYS_K) then
--		--self.phys:SetStance(STANCE_STANDING)
--		--self.phys:SetMovementDirection(Vector(100,0,100))
--		--self.phys:SetStandingSpeed(1000) 
--		--self.phys:SetAirSpeed(1000) 
--	--else
--	--	self.phys:SetMovementDirection(Vector(0,0,0))
--	--end
--end
 
function ENT:Press(user) 
	local t = self.target
	if t then
		user:SetParent(t:GetParent())
		user:SetPos(t:GetPos())
	else
		MsgInfo("DED")
		user:Kill()
	end
end
ENT._typeevents = {
	[EVENT_USE] = {networked = true, f = ENT.Press},
}