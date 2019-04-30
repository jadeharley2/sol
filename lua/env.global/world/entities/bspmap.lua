module.Require('bsp')

function ENT:Init()  
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model 
	local coll = self:AddComponent(CTYPE_STATICCOLLISION)  
	self.coll = coll 
end
function ENT:Spawn()
	self:LoadBSP() 
	self:LoadModel()
	self:LoadEnts()   
end

function ENT:LoadBSP()
	local path = "maps/"..self[VARTYPE_FORM]..".bsp"
	self.bsp = bsp.Load(path,"textures/debug/") 
end

function ENT:LoadModel() 
	if not self.bsp then return end
	self.bsp:GenerateModel("tempbspmap.stmd",false)

	local scale = 0.01905 -- 0.75 * (metres per inch)
	
	local model = self.model
	local world = matrix.Scaling(scale*0.001) * matrix.Rotation(-90,0,0) 
	
	self:SetParameter(VARTYPE_MODEL,mdl)
	self:SetParameter(VARTYPE_MODELSCALE,scale)
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel("tempbspmap.stmd")   
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,9e20,0)  
	model:SetMatrix(world) 
	local coll =  self.coll 
	if(model:HasCollision()) then
		coll:SetShapeFromModel(matrix.Scaling(scale)* matrix.Rotation(-90,0,0)) 
	end 
	self.modelcom = true
	self.incol = SpawnSO("tempbspmap.stmd",self,Vector(0,0,0),0.01905)
end 


function ENT:LoadEnts()
	if not self.bsp then return end
	local entlist = json.FromJson(self.bsp:GetEntList())
	for k,v in pairs(entlist) do
		--Msg(v.classname)
		if v.classname == "info_player_start" then
			local pos = self:GetEntOrigin(v.origin)
			local e = ents.Create("spawnpoint")
			e:SetPos(pos)-- SpawnSO("primitives/sphere.stmd",self,pos,0.75)
			e:AddFlag(77723)
			e:SetParent(self)
			e:Spawn()
			e:SetPlayerSpawn()
		elseif v.classname == "light" then
			local pos = self:GetEntOrigin(v.origin)
			local clrb = self:GetNumberTable(v._light)
			local e = self:CreateStaticLight(pos,Vector(clrb[1]/255,clrb[2]/255,clrb[3]/255), clrb[4]/100)
			e:AddFlag(77723)
			--SpawnSO("primitives/sphere.stmd",self,pos,0.75) 
		end
	end
	
end
function ENT:ClearEnts() 
	for k,v in pairs(self:GetChildren()) do
		if v:HasFlag(77723) then
			v:Despawn()
		end
	end
end
  

function ENT:GetEntOrigin(str)
	local coeff = 0.01905*0.001
	local p = string.split(str,' ')
	return Vector(tonumber(p[1])*coeff,tonumber(p[3])*coeff,tonumber(p[2])*-coeff)
end
function ENT:GetNumberTable(str) --"_light" "255 255 255 400"
	local p = string.split(str,' ')
	local t = {}
	for k,v in pairs(p) do t[k] = tonumber(v) end
	return t
end

function ENT:CreateStaticLight( pos, color,power)

	local lighttest = ents.Create("omnilight") 
	local world = matrix.Scaling(2) 
	lighttest:SetParent(self)
	lighttest:SetSizepower(0.1)
	lighttest.color = color or Vector(1,1,1)
	lighttest:SetSpaceEnabled(false)
	lighttest:Spawn() 
	if power then lighttest:SetBrightness(power) end
	lighttest:SetPos(pos)  
	return lighttest
end