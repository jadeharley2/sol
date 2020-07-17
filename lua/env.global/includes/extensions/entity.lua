--auto reload

local registry = debug.getregistry()
local ENTITY = registry.Entity
 

-- do for all items in table or for one
function tableq(t)
	if istable(t) then return pairs(t) 
	else
		return function(t,c)  
			if c==0 then 
				return 1, t
			else
				return nil
			end
		end, t, 0
	end
end
 
hook.Add("script.reload","entity", function(filename)
	if string.starts(filename,"env.global/world/entities/") then 
		ents.LoadType(filename)
		return true
	end
end)
Entity = ents.GetById


function ENTITY:Delayed(name,delay,action)
	if not isstring(name) then error("ENT:Delayed(name,delay,action) name is "..type(name).." must be string") end
	--MsgN("DDDelayed",self,name)
	local ddtasks = self._ddtasks or {}
	
	local oldtask = ddtasks[name]
	if oldtask then
		oldtask:Stop()
	end
	
	local task = debug.Delayed(delay,action)
	ddtasks[name] = task
	self._ddtasks = ddtasks
	return task
end

function ENTITY:Timer(name,delay,interval,count,action)
	--MsgN("DDTimer",self,name)
	local ddtasks = self._ddtasks or {}
	
	local oldtask = ddtasks[name]
	if oldtask then
		oldtask:Stop()
	end
	
	local task = debug.DelayedTimer(delay,interval,count,action)
	ddtasks[name] = task
	self._ddtasks = ddtasks
	return task
end

function ENTITY:Hook(hookname,name,action)
	--MsgN("DDHook",self,hookname,name)
	local ddhooks = self._ddhooks or {}
	
	local seed = tostring(self:GetSeed())
	local keyname = name..".ent"..seed 
	 
	local oldhook = ddhooks[hookname]
	if oldhook then
		hook.Remove(hookname,oldhook)
	end
	
	ddhooks[hookname] = keyname 
	hook.Add(hookname,keyname,action) 
	self._ddhooks = ddhooks
end
function ENTITY:UnHook(hookname,name)
	--MsgN("DDUnHook",self,hookname,name)
	local ddhooks = self._ddhooks or {}
	
	local seed = tostring(self:GetSeed())
	local keyname = name..".ent"..seed 
	
	local oldhook = ddhooks[hookname]
	if oldhook then
		hook.Remove(hookname,oldhook)
	end
	self._ddhooks = ddhooks
end

function ENTITY:DDFreeAll()
	--MsgN("DDFreeAll",self)
	--MsgN("  tasks")
	for k,v in pairs(self._ddtasks or {}) do
		--MsgN("    ",k," - ",v)
		v:Stop()
	end
	--MsgN("  hooks")
	for k,v in pairs(self._ddhooks or {}) do
		--MsgN("    ",k," - ",v)
		hook.Remove(k,v)
	end
	self._ddtasks = nil
	self._ddhooks = nil
end

function ENTITY:PrintEventHandlers()
	local eventinfo = debug.GetAPIInfo("EVENT_")
	local eventdict = {}
	for k,v in pairs(eventinfo) do if not string.starts(k,'_') then eventdict[tonumber(v)] = k end end 

	if self._events then 
		for k,v in SortedPairs(self._events) do
			MsgN("S",k,eventdict[k],v.networked)
		end
	end
	if self._comevents then 
		local cominfo = debug.GetAPIInfo("CTYPE_")
		local comdict = {}
		for k,v in pairs(cominfo) do if not string.starts(k,'_') then comdict[tonumber(v)] = k end end 

		for k,v in SortedPairs(self._comevents) do
			if v._typeevents then 
				for k2,v2 in SortedPairs(v._typeevents) do
					MsgN("C",'['..k..']'..comdict[k],'['..k2..']'..eventdict[k2],v2.networked)
				end
			end
		end
	end
	if self._typeevents then 
		for k,v in SortedPairs(self._typeevents) do
			MsgN("T",'['..k..']'..eventdict[k],v.networked)
		end
	end
	if self._metaevents then 
		for k,v in SortedPairs(self._metaevents) do
			MsgN("M",'['..k..']'..eventdict[k],v.networked)
		end
	end
end


function ENTITY:RegisterComponent(com)
	self._comevents = self._comevents or {}
	self._comevents[com.uid] = com

	local comef = com._entfunctions
	if comef then  
		local cf = self._comfunctions or {}
		self._comfunctions = cf
		for k,v in pairs(comef) do
			cf[k] = comef
		end
	end
end
function ENTITY:UnregisterComponent(com)
	self._comevents = self._comevents or {}
	self._comevents[com.uid] = nil

	local comef = com._entfunctions
	if comef then
		local cf = self._comfunctions or {}
		self._comfunctions = cf
		for k,v in pairs(comef) do
			cf[k] = nil
		end
	end
end

function ENTITY:RotateToAdd(axis,angle,time,fps)
	time = time or 1
	fps = fps or 30
	local times = time*fps
	local dt = angle/times
	return self:Timer('dynrotate',0,1000/fps,times,function (s)
		self:TRotateAroundAxis(axis,dt)
	end)
end


function ENTITY:SetupModel(modelname, modelscale, norotation)
	local model = self:GetComponent(CTYPE_MODEL)
	
	modelname = modelname or self[VARTYPE_MODEL]
	modelscale = modelscale or self[VARTYPE_MODELSCALE] or 1
	if modelname then
		self[VARTYPE_MODEL] = modelname
		self[VARTYPE_MODELSCALE] = modelscale

		local world = matrix.Scaling(modelscale)
		if not norotation then
			world = world * matrix.Rotation(-90,0,0)
		end
		model:SetRenderGroup(RENDERGROUP_LOCAL)
		model:SetModel(modelname) 
		model:SetBlendMode(BLEND_OPAQUE) 
		model:SetRasterizerMode(RASTER_DETPHSOLID) 
		model:SetDepthStencillMode(DEPTH_ENABLED)  
		model:SetBrightness(1)
		model:SetFadeBounds(0,99999,0)  
		model:SetMatrix(world)
	end
end
function ENTITY:SetupPhysicsObject(modelscale,norotation)
	local model = self:GetComponent(CTYPE_MODEL)
	local phys = self:GetComponent(CTYPE_PHYSOBJ)
	if model and phys then
		if(model:HasCollision()) then
			modelscale = modelscale or self[VARTYPE_MODELSCALE] or 1
			
			local world = matrix.Scaling(modelscale)
			if not norotation then
				world = world * matrix.Rotation(-90,0,0)
			end

			phys:SetShapeFromModel( world )  
		end
	end
end
function ENTITY:SetupStaticCollision(modelscale,norotation)
	local model = self:GetComponent(CTYPE_MODEL)
	local coll = self:GetComponent(CTYPE_STATICCOLLISION)
	if model and coll then
		if(model:HasCollision()) then
			modelscale = modelscale or self[VARTYPE_MODELSCALE] or 1
			
			local world = matrix.Scaling(modelscale)
			if not norotation then
				world = world * matrix.Rotation(-90,0,0)
			end

			coll:SetShapeFromModel( world )  
		end
	end
end