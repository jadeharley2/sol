MOVETYPE_IDLE = 0
MOVETYPE_WALK = 1
MOVETYPE_RUN = 2
MOVETYPE_SWIM = 3
MOVETYPE_FLY = 4

EVENT_DAMAGE = 80001
EVENT_SET_VEHICLE = 80002

EVENT_HEALTH_CHANGED = 81003
EVENT_MAXHEALTH_CHANGED = 81004
EVENT_DEATH = 81005
EVENT_SPAWN = 81006
EVENT_ACTOR_JUMP = 81007
EVENT_CHANGE_CHARACTER = 81008
EVENT_TOOL_DROP = 81011

EVENT_RESPAWN_AT = 82033
EVENT_STATE_CHANGED = 82034
EVENT_GIVE_ITEM = 82066

function ENT:Init()  
	self:AddFlag(FLAG_ACTOR)
	local phys = self:AddComponent(CTYPE_PHYSACTOR)  
	local model = self:AddComponent(CTYPE_MODEL)  
	self.model = model
	self.phys = phys
	self:SetSpaceEnabled(false)
	
	self.speedmul = 1
	self.walkspeed = 3
	self.runspeed = 6
	self.movementtype = MOVETYPE_IDLE
	
	phys:SetMass(10) 
	
	
	
	self:SetParameter(VARTYPE_MAXHEALTH,100)
	self:SetParameter(VARTYPE_HEALTH,100)

	self:AddEventListener(EVENT_DAMAGE,"event",function(amount)
		
		if SERVER then 
			local hp = self:GetParameter(VARTYPE_HEALTH) 
			hp = hp - amount 
			self:SetParameter(VARTYPE_HEALTH,hp)
			self:SetHealth(hp)  
			return
		end
		
		local hp = self:GetParameter(VARTYPE_HEALTH) 
		hp = hp - amount 
		self:SetParameter(VARTYPE_HEALTH,hp)
		if hp <= 0 then 	self:SendEvent(EVENT_DEATH) end
		if CLIENT and LocalPlayer() == self then healthbar:UpdateHealth(hp) end
	end)
	
	self:AddEventListener(EVENT_HEALTH_CHANGED,"event",function(val) 
		self:SetParameter(VARTYPE_HEALTH,val)  
		if CLIENT and LocalPlayer() == self then healthbar:UpdateHealth(val) end
		self:SetVehicle(nil) 
	end)
	self:AddEventListener(EVENT_MAXHEALTH_CHANGED,"event",function(val) self:SetParameter(VARTYPE_MAXHEALTH,val) end)
	
	self:AddEventListener(EVENT_DEATH,"event",function() 
		self:SetParameter(VARTYPE_HEALTH,0)  
		if CLIENT and LocalPlayer() == self then healthbar:UpdateHealth(0) end
		self.graph:SetState("dead") 
	end)
	self:AddEventListener(EVENT_SPAWN,"event",function() 
		local hp = self:GetParameter(VARTYPE_MAXHEALTH)
		self:SetParameter(VARTYPE_HEALTH,hp)  
		if CLIENT and LocalPlayer() == self then healthbar:UpdateHealth(hp) end
		self.graph:SetState("spawn") 
	end)
	self:AddEventListener(EVENT_CHANGE_CHARACTER,"event",function(char) 
		self:SetCharacter(char) 
	end)
	
	self:AddEventListener(EVENT_TOOL_DROP,"event",function() self:DropActiveWeapon()  end)
	
	self:AddEventListener(EVENT_ACTOR_JUMP,"event",function() self:Jump()  end)
	
	self:AddEventListener(EVENT_SET_VEHICLE,"event",function(veh,mountpointid,assignnode)  
		self:SetVehicle(veh,mountpointid,assignnode) 
	end)
	
	self:AddEventListener(EVENT_RESPAWN_AT,"event",function(pos) 
		self:SetPos(pos)
		self.phys:SetVelocity(Vector(0,0,0))
	end)
	
	self:AddEventListener(EVENT_STATE_CHANGED,"event",function(newstate) 
		if SERVER or self ~= LocalPlayer() then self.graph:SetState(newstate) end end)
	
	
	self:AddEventListener(EVENT_RESPAWN_AT,"event",function(pos) 
		self:SetPos(pos)
		self.phys:SetVelocity(Vector(0,0,0))
	end)
	
	self:AddEventListener(EVENT_GIVE_ITEM,"event",function(type) 
		self:Give(type)
	end)
	
	self:SetNetworkedEvent(EVENT_HEALTH_CHANGED)
	self:SetNetworkedEvent(EVENT_MAXHEALTH_CHANGED)
	self:SetNetworkedEvent(EVENT_ACTOR_HURT)
	self:SetNetworkedEvent(EVENT_DEATH)
	self:SetNetworkedEvent(EVENT_SPAWN)
	self:SetNetworkedEvent(EVENT_TOOL_DROP)
	self:SetNetworkedEvent(EVENT_ACTOR_JUMP)
	self:SetNetworkedEvent(EVENT_CHANGE_CHARACTER)
	self:SetNetworkedEvent(EVENT_SET_VEHICLE)
	self:SetNetworkedEvent(EVENT_RESPAWN_AT)
	self:SetNetworkedEvent(EVENT_STATE_CHANGED)
	self:SetNetworkedEvent(EVENT_GIVE_ITEM)
	
	self:AddFlag(FLAG_PHYSSIMULATED)
	
	phys:SetupCallbacks()
	self:AddNativeEventListener(EVENT_PHYSICS_COLLISION_STARTED,"event",
	function(selfobj,eid,collider,velonhit) 
		selfobj:VelocityCheck()--collider,velonhit)
	end)
	
	
end

function ENT:Spawn()

	local model = self.model
	local phys = self.phys  
	local modelfile = self:GetParameter(VARTYPE_MODEL)
	
	local char = self:GetParameter(VARTYPE_CHARACTER)
	if char then
		self:SetCharacter(char)
	end
end
function ENT:Load()
	self:SetPos(self:GetPos())
	self:CopyAng(self)
	local char = self:GetParameter(VARTYPE_CHARACTER)
	--MsgN("WTF?? ",char)
	self:SetCharacter(char)
end
function ENT:PlayAnimation(aname,exitnode,ns)
	exitnode = exitnode or "idle"

	local nodename = "_autoanim_"..aname
	local graph = self.graph
	graph:NewState(nodename,function(s,e) return e.model:ResetAnimation(aname,ns) end)
	graph:NewTransition(nodename,exitnode,CND_ONEND)
	graph:SetState(nodename)
end
function ENT:LoadGraph()

	local graph = BehaviorGraph(self) 
	
	graph:NewState("idle",function(s,e) 
		if e.model:HasAnimation("idle1") then
			local rm =math.random(1,100)
			if rm<90 then
				return e.model:SetAnimation("idle") 
			else
				local ar = math.random(1,4)
				local aname = "idle"..ar
				while (ar>0 ) do
					if e.model:HasAnimation(aname) then break end
					ar = ar - 1
					aname = "idle"..ar
				end
				return e.model:SetAnimation(aname) 
			end 
		else
			return e.model:SetAnimation("idle") 
		end
		--e.phys:SetMovementDirection(Vector(0,0,0)) 
	end) 
	graph:NewState("idle_loop",function(s,e)  return 0 end)
	
	graph:NewState("cidle",function(s,e) e.model:SetAnimation("cidle")  
		--e.phys:SetMovementDirection(Vector(0,0,0)) 
	end)
	
	graph:NewState("run",function(s,e) e.model:SetAnimation("run") end)
	graph:NewState("walk",function(s,e) e.model:SetAnimation("walk") end)
	graph:NewState("cwalk",function(s,e) e.model:SetAnimation("cwalk") end)
	
	graph:NewState("attack",function(s,e)  
		e.phys:SetMovementDirection(Vector(0,0,0)) 
		return e.model:SetAnimation("attack") 
	end)
	
	graph:NewState("ability",function(s,e)   
		local anim = e.abilityanim
		if anim then return e.model:SetAnimation(anim) end
	end)
	
	graph:NewState("soar_idle",function(s,e) e.model:SetAnimation("soar_idle")  end)
	graph:NewState("soar_in",function(s,e) return e.model:SetAnimation("soar_in")  end)
	graph:NewState("soar_out",function(s,e) return e.model:SetAnimation("soar_out")  end)
	
	graph:NewState("jump",function(s,e) return e.model:SetAnimation("jump") end)
	graph:NewState("jump_inair",function(s,e) return e.model:SetAnimation("jump_inair") end)
	graph:NewState("land",function(s,e)  MsgN("MVD: ", e.phys:GetMovementDirection()) return e.model:SetAnimation("land") end)
	
	graph:NewState("sit",function(s,e) e.model:SetAnimation("sit")  
		e.phys:SetMovementDirection(Vector(0,0,0)) 
	end)
	
	graph:NewState("sit.chair",function(s,e) e.model:SetAnimation("sit.chair")  
		e.phys:SetMovementDirection(Vector(0,0,0)) 
	end)
	graph:NewState("sit.capchair",function(s,e) e.model:SetAnimation("sit.capchair")  
		e.phys:SetMovementDirection(Vector(0,0,0)) 
	end)
	graph:NewState("sit.saddle",function(s,e) e.model:SetAnimation("sit.saddle")  
		e.phys:SetMovementDirection(Vector(0,0,0)) 
	end)
	
	graph:NewState("recall",function(s,e) return e.model:SetAnimation("recall") end)
	graph:NewState("recall_end",function(s,e) if e.Recall then return e:Recall(s) end return 0 end)
	
	graph:NewState("flight_start",function(s,e) end)
	graph:NewState("flight_end",function(s,e) end)
	
	graph:NewState("flight_idle",function(s,e) e.model:SetAnimation("fly_idle")   end)
	graph:NewState("flight_move",function(s,e) e.model:SetAnimation("fly_move")   end)
	
	
	graph:NewState("dead",function(s,e)
		local phys = e.phys
		phys:SetMovementDirection(Vector(0,0,0)) 
		phys:SetGravity() 
		phys:SetAirSpeed(0)
		e.isflying = false
		e.model:SetAnimation("death")   
		return 5
	end)
	
	graph:NewState("respawn",function(s,e) 
		self:Respawn()
	end)
	
	graph:NewState("spawn",function(s,e)
		if e.Recall then e:Recall(s) end
		return e.model:SetAnimation("spawn")  
	end)
	--graph:NewTransition("idle","run",function(s,e) return e.move or e.targetpos end)
	--graph:NewTransition("run_stop","run",function(s,e) return e.move or e.targetpos end)
	--graph:NewTransition("run","idle",function(s,e) 
	--	if e.move then e.phys:SetMovementDirection(e.move) end
	--	if e.targetpos then e.phys:SetMovementDirection(e.targetpos) end
	--if e.targetpos then
	--	local pos = e.targetpos
	--	local dir = pos - e:GetPos()
	--	local dist = dir:Length()
	--	MsgN(dist)
	--	if dist < 0.002 then
	--		e.targetpos = nil
	--	else
	--		dir = dir / dist
	--		e:SetAng(Vector(0,math.atan2(dir.z,dir.x)/3.1415926*-180,0)) 
	--		e.phys:SetMovementDirection(Vector(0,0,1))
	--	end
	--end
	---return not e.move and not e.targetpos 
	-----
	-----
	---end)
	--graph:NewTransition("run_stop","idle",function(s,e) return s.anim_end < CurTime() end)
	
	graph:NewGroup("g_movement",{"walk","run"})
	
	
	graph:NewTransition("attack","idle",CND_ONEND)
	graph:NewTransition("ability","idle",CND_ONEND)
	--
	--graph:NewTransition("soar_in","soar_idle",CND_ONEND)
	--graph:NewTransition("soar_idle","soar_out",function(s,e) return e.move end)
	--graph:NewTransition("soar_out","idle",CND_ONEND)
	local CND_ONGROUND = function(s,e) return e.phys:OnGround() end
	local CND_NOTONGROUND = function(s,e) return not e.phys:OnGround() end
	graph:NewTransition("jump","idle", CND_ONGROUND)
	graph:NewTransition("jump_inair","idle",CND_ONGROUND) 
	graph:NewTransition("jump","jump_inair",CND_ONEND)
	graph:NewTransition("land","idle",CND_ONEND)
	
	graph:NewTransition("idle","jump",CND_NOTONGROUND) 
	graph:NewTransition("g_movement","jump",CND_NOTONGROUND)
	
	graph:NewTransition("idle","walk",CND_ONREQ)
	graph:NewTransition("idle","run",CND_ONREQ)
	graph:NewTransition("g_movement","idle",CND_ONREQ)  
	graph:NewTwoWayTransition("walk","run",CND_ONREQ) 
	graph:NewTransition("idle","jump",CND_ONREQ)
	graph:NewTransition("g_movement","jump",CND_ONREQ)
	
	graph:NewTransition("idle","attack",CND_ONREQ)
	
	graph:NewTransition("idle","recall",CND_ONREQ)
	graph:NewTransition("recall","recall_end",CND_ONEND)
	graph:NewTransition("recall_end","idle",CND_ONEND)
	
	
	if self.model:HasAnimation("idle1") then 
		graph:NewTransition("idle","idle_loop",CND_ONEND)
		graph:NewTransition("idle_loop","idle",CND_ONEND) 
	
	end
	
	graph:NewTransition("idle","cidle",function(s,e) return self.duckmode end)
	graph:NewTransition("cidle","idle",function(s,e) return not self.duckmode end) 
	graph:NewTransition("walk","cwalk",function(s,e) return self.duckmode end)
	graph:NewTransition("cwalk","walk",function(s,e) return not self.duckmode end)
	graph:NewTransition("run","cwalk",function(s,e) return self.duckmode end) 
	graph:NewTransition("cidle","cwalk",CND_ONREQ)
	graph:NewTransition("cwalk","cidle",CND_ONREQ)
	
	graph:NewTransition("idle","flight_start",CND_ONREQ)
	graph:NewTransition("flight_idle","flight_end",CND_ONREQ)
	graph:NewTransition("flight_idle","flight_move",CND_ONREQ)
	graph:NewTransition("flight_move","flight_idle",CND_ONREQ)
	
	graph:NewTransition("flight_start","flight_idle",CND_ONEND)
	graph:NewTransition("flight_end","idle",CND_ONEND)
	
	graph:NewTransition("flight_move","idle",function(s,e) if e.phys:OnGround() then e:Land() return true end end)
	graph:NewTransition("flight_idle","idle",function(s,e) if e.phys:OnGround() then e:Land() return true end end)
	
	
	
	
	
	
	
	graph:NewState("unc_transition",function(s,e)
		e.phys:SetMovementDirection(Vector(0,0,0)) 
		return e.model:SetAnimation("tr_en_t_com")   
	end)
	graph:NewState("unc_stop",function(s,e)
		e.phys:SetMovementDirection(Vector(0,0,0)) 
		--TurnIntoStone(e)
		return e.model:SetAnimation("tr_com_t_ncom")   
	end) 
	graph:NewTransition("idle","unc_transition",CND_ONREQ)
	graph:NewTransition("unc_transition","unc_stop",CND_ONEND)
	
	
	graph:NewTransition("dead","respawn",CND_ONEND)
	graph:NewTransition("spawn","idle",CND_ONEND)
	
	
	graph:SetState("idle")
	 
	
	if CLIENT then
		graph.callback = function(g,e,n)
			if e == LocalPlayer() then 
				if network.IsConnected() then
					network.CallServer('_1',e,EVENT_STATE_CHANGED,n)
				end
			end
		end
	end
	
	return graph
end

function ENT:Think()
	self:VelocityCheck()
	local ai = self.controller 
	if ai and not ai.camZoom then
		if ai.Update then
			ai:Update()
		end
	end

	
	if CLIENT and (not network.IsConnected() or self == LocalPlayer()) then
		local graph = self.graph 
		if graph then
			graph:Run() 
		end
	end
	self:RunTaskStep() 
	
	local m = self.model
	local ct = CurTime()
	local srb = self.resetblink
	local snb = self.nextblink
	if srb then
		if ct>srb then
			m:StopLayeredSequence(10)
			self.nextblink = ct+1+math.random(1,8)
			self.resetblink = nil
		end
	elseif not srb  and (not snb or ( snb and ct>snb )) then
		m:PlayLayeredSequence(10,"_blink_auto")
		self.resetblink = ct+1
		
	end
	if self:GetParameter(VARTYPE_STATE) == "sit.capchair" then
		if self.acd then
			if ct>self.acd then
				self.model:SetAnimation("sit.capchair")
				self.acd = nil
			end
		elseif math.random(1,1000)>990 then
			--if math.random(1,1000)>500 then
				self.acd =ct+ self.model:SetAnimation("sit.capchair.s1") 
			--else
			--	self.acd =ct+ self.model:SetAnimation("sit.capchair.s2") 
			--end
		end		
	end
	--if string.find(tostring(self),"Nami") then
	--MsgN("nb ",snb," rb ",srb," ct ",ct)
	--end 
	
--	--MsgN(self.phys:OnGround())
--	--if input.KeyPressed(KEYS_K) then
--		--self.phys:SetStance(STANCE_STANDING)
--		--self.phys:SetMovementDirection(Vector(100,0,100))
--		--self.phys:SetStandingSpeed(1000) 
--		--self.phys:SetAirSpeed(1000) 
--	--else
--	--	self.phys:SetMovementDirection(Vector(0,0,0))
--	--end
end

function ENT:SetCharacter(id)
	id = id or "kindred"
	
	if id then 
		local data = json.Read("forms/characters/"..id..".json")
		if data then
			self:SetParameter(VARTYPE_CHARACTER,id)
			 
			local model_scale = self.model_scale or 1
			local world = matrix.Scaling(0.03) 
			local model = self.model
			local phys = self.phys
			
			if data.name and self:GetName() == "" then self:SetName(data.name) end
			
			if data.species then
				self:SetSpecies(data.species)
			end
			
			self:Config(data)
			
			model:SetModel(self:GetParameter(VARTYPE_MODEL))
			model:SetRenderGroup(RENDERGROUP_LOCAL) 
			model:SetBlendMode(BLEND_OPAQUE) 
			model:SetRasterizerMode(RASTER_DETPHSOLID) 
			model:SetDepthStencillMode(DEPTH_ENABLED)  
			model:SetBrightness(1)
			model:SetFadeBounds(0,99999,0)   
			model:SetMatrix(world*matrix.Translation(-phys:GetFootOffset()*0.75)*matrix.Scaling(0.001*model_scale))---*matrix.Scaling(0.0000001)
			
			model:SetDynamic()
			
			self.graph = self:LoadGraph() or self.graph
			
			
			
			if data.parts then
				local bpath = self.species.model.basedir
				local bpr = {}
				for k,v in pairs(data.parts) do
					bpr[k] = SpawnBP(bpath..v..".json",self,0.03)
				end
				self.spparts = bpr
				
				--TEST!
				local mat = NewMaterial("models/mlppony/tex/", json.ToJson({
					shader = "shader.model", 
					g_MeshTexture = "models/mlppony/tex/body_luna.jpg",
					g_MeshTexture_n = "models/mlppony/tex/base_normal.dds",
				}))
				local root = panel.Create()
				root:SetSize(512,512)
				root:SetTexture(LoadTexture("textures/ponygen/body.dds"))
				root:SetColor(Vector(56,73,125)/255) 
				local tex = RenderTexture(512,512,root) 
				SetMaterialProperty(mat,"g_MeshTexture",tex)
				self.spparts.body.model:SetMaterial(mat)
			--END
			end
			
			
			self:SetUpdating(true,100)
			--MsgN("faf ",self:GetPos())
			--self:SetPos(self:GetPos()) 
		end
	end
end
function ENT:SetSpecies(spstr) 
	if spstr then 
		local spd = spstr:split(':')
		local species = spd[1]
		local variation = spd[2]
		
		local data = json.Read("forms/species/"..species..".json")
		if data then 
			self:Config(data,species,variation)
			
			self.species = data
			self.variation = data.model.variations[variation]
			
		end
	end
end

function ENT:GetEquipment(slot)
	local e = self.equipment
	if e then
		return e[slot] 
	end
	return nil
end
function ENT:Equip(item) 
	MsgN(self, " equip ",item)
	local slot = item.slot
	MsgN(item, " slot ",slot)
	if slot then
		local s = self:GetEquipment(slot) 
		MsgN("s slot ",s)
		if s and item.GetSkelModel then
			local itemmodel = item:GetSkelModel(self,slot) 
			MsgN("itemmodel ",itemmodel)
			if itemmodel then
				if s.ent then
					s.ent:Despawn()
					s.ent = nil
					if s.item.OnUnequipped then s.item:OnUnequipped(self) end
				end
				local olditem = s.item
				
				local newE = SpawnBP(itemmodel,self,0.03)
				s.ent = newE
				s.item = item 
				if item.OnEquipped then item:OnEquipped(self) end
				return olditem
			end
		end
	end
	return nil
end
function ENT:Unequip(slot)
	local s = self:GetEquipment(slot)
	if s then
		if s.ent then
			s.ent:Despawn()
			s.ent = nil
			local item = s.item
			s.item = nil
			if item.OnUnequipped then item:OnUnequipped(self) end
			return item
		end
	end
	return nil
end

function ENT:Config(data,species,variation)

	local phys = self.phys
	if species then
		if data.bodyparts then
		
		
		end 
		if data.equipment then
			local equipment = {}
			for k,v in pairs(data.equipment.slots) do
				equipment[v] = {}
			end
			self.equipment = equipment
		
		end
	end
	if data.model then
		if isstring(data.model) then
			self:SetModel(data.model) 
		else
			local varbase = data.model.variations[variation]
			local skel = varbase.skeleton
			self:SetModel(data.model.basedir..skel..".json") 
		end
	end 
	if data.mass then phys:SetMass(data.mass) end
	if data.variables then
		for k, v in pairs(data.variables) do 
			self[k] = v
		end
	end
	if data.movement then
		if data.movement.walk then self.walkspeed = data.movement.walk.speed or self.walkspeed end
		if data.movement.run then self.runspeed = data.movement.run.speed or self.runspeed end 
		if data.movement.fly then self.flyspeed = data.movement.fly.speed or self.flyspeed end 
	end
	if data.attributes then
		self.attributes = data.attributes
		for k,v in pairs(data.attributes) do
			if v == "mount" then 
				self:AddEventListener(EVENT_USE,"use_event",function(user) 
					user:SendEvent(EVENT_SET_VEHICLE,self,1,self)
				end)
				self:AddFlag(FLAG_USEABLE) 
			end
		end
	end
	if data.abilities then
		self.abilities = {}
		for k,v in pairs(data.abilities) do
			self.abilities[k] = Ability(v)
		end
	end
end

function ENT:SetAi(id)
	if id then
		local ai = Ai(id,self)
		if ai then
			self.controller = ai
		end
	else
		self.controller = nil
	end
end
function ENT:Say(text) 
	if not network.IsConnected() then
		hook.Call("chat.msg.received", self, text)
	end
end

function ENT:SetModel(mdl)
	self:SetParameter(VARTYPE_MODEL,mdl)
	--self.modelfile = mdl
	--if SERVER then
	--	network.BroadcastLua("ents.GetById("..tostring(self:GetSeed())..").modelfile = '"..mdl.."'")
	--end
end
function ENT:SetVehicle(veh,mountpointid,assignnode,servercall) 
	if veh then
		mountpointid = mountpointid or 1
		assignnode = assignnode or veh
		servercall = servercall or false
		
		local mountpoint = veh.mountpoints[mountpointid]
		if not mountpoint then return false end
		if mountpoint.ent then return false end
		
		local phys = self.phys
		self.IsInVehicle = true
		self.vehicle = veh
		self.graph:SetState(mountpoint.state or "sit")
		self:SetParent(veh)
		phys:SetVelocity(Vector(0,0,0))
		--self.phys:SetMass(-1)
		self:SetPos(mountpoint.pos or Vector(0,0,0))--pos)
		self:SetAng(mountpoint.ang or Vector(0,0,0))
		if mountpoint.attachment then
			veh.model:Attach(self,mountpoint.attachment)
		end
		self.currentmountpoint = mountpoint
		local weld = self.weld
		if weld then
			weld:Break()
		end
		self.weld = constraint.Weld(phys,nil,Vector(0,0,0)) 
		self:SetUpdateSpace(false)
		
		mountpoint.ent = self
		--local ply = self.player
		--if assignnode and ply then 
		--	self.assignednode = assignnode
		--	ply:AssignNode(assignnode)
		--end
		if CLIENT and LocalPlayer()==self then
			network.RequestAssignNode(assignnode)
			self.assignednode = assignnode
		end
	else
		local v = self.vehicle
		if v then
			local weld = self.weld
			if weld then
				weld:Break()
				self.weld = nil
			end
			
			local cmp = self.currentmountpoint
			if cmp and cmp.attachment then
				v.model:Detach(self)
			end
			self.IsInVehicle = false
			local vparent = self.vehicle:GetParent()
			if SERVER or not network.IsConnected() then
				self:SetPos(Vector(0,0,0))
				self:Eject()
				self:SetParent(vparent)
				self:SendEvent(EVENT_RESPAWN_AT,self.vehicle:GetPos())
			end 
			self.vehicle = nil
			self.graph:SetState("idle")
			--self:SetParent(v:GetParent())
			--self:SetPos(v:GetPos())
			--self.phys:SetMass(10)
			self:SetUpdateSpace(true)
			
			--local ply = self.player
			--if self.assignednode and ply then 
			--	self.assignednode = nil
			--	ply:UnassignNode(self.assignednode)
			--end
			if self.assignednode and  LocalPlayer()==self then 
				self.assignednode = nil
				network.RequestUnassignNode(v)
			end
			cmp.ent = nil
		end
	end
	
	self:VelocityCheck(true)
	--if not servercall and CLIENT then
	--	network.CallServer("actor_set_vehicle",self,veh,mountpointid,assignnode) 
	--end
end 
function ENT:SetSize(val)
	local model = self.model
	local phys = self.phys
	if model and phys then
		self.scale = val
		model:SetMatrix(matrix.Scaling(0.03)*matrix.Translation(-phys:GetFootOffset()*0.75/val)*matrix.Scaling(0.001*val))
	end
end

--[[
if SERVER then
	
	hook.Add("umsg.actor_set_vehicle","0",function(actor,veh,mountpointid,assignnode) 
		network.BroadcastCall("actor_set_vehicle",actor,veh,mountpointid,assignnode) 
	end) 
else -- CLIENT

	-hook.Add("umsg.actor_set_vehicle","0",function(actor,veh,mountpointid,assignnode)  
	-	MsgN("set vehicle: ",actor,veh,mountpointid,assignnode)
	-	actor:SetVehicle(veh,mountpointid,assignnode,true)  
	-end)  
end
]]
function ENT:GetVehicle() 
	return self.vehicle
end

--MOVEMENT
function ENT:Turn(ang)
	if self.model:HasAnimation("turn_l") then 
		local Up = self:Up():Normalized()
		self:TRotateAroundAxis(Up, ang)   
		MsgN(ang)
		if(ang>0) then 
			self:PlayAnimation("turn_l","idle",true) 
		else 
			self:PlayAnimation("turn_r","idle",true) 
		end
		return true
	else 
		return false
	end
end
function ENT:Jump()
	local phys = self.phys
	local ong = phys:OnGround()
	if self:IsFlying() then
		if ong then
			phys:Jump()
		else
			phys:ApplyImpulse(self:Up())
		end
	else
		if ong then 
			if self.graph:TrySetState("jump") then
				phys:Jump()
			end 
		else
			self:StartFlight()
		end
	end
end
function ENT:Move(dir,run,updatespeed)
	local phys = self.phys
	local graph = self.graph
	local scale = self.scale or 1
	local spmul = self.speedmul or 1
	local spscale = scale*spmul
	
	self.lastdir = dir
	self.lastrun = run
	if dir then
		if self:IsFlying() then 
			if run then
				phys:SetAirSpeed(self.flyspeed*1000*spscale) 
			else
				phys:SetAirSpeed(self.flyspeed*10*spscale) 
			end 
			graph:TrySetState("flight_move")   
		else 
			if self:Crouching() then
				if graph:TrySetState("cwalk") or updatespeed  then 
					phys:SetStandingSpeed(self.walkspeed*spscale) 
				end
			else
				if run then 
					if graph:TrySetState("run") or updatespeed then 
						phys:SetStandingSpeed(self.runspeed*spscale) 
					end
				else  
					if graph:TrySetState("walk") or updatespeed  then 
						phys:SetStandingSpeed(self.walkspeed*spscale)  
					end
				end
			end
		end 
		if self:IsMoving() then 
			local sForward = self:Right():Normalized()
			phys:SetViewDirection(sForward)
			phys:SetMovementDirection(dir) 
		end
		
		local dfa = (math.atan2(-dir.z,dir.x)/3.1415926*180+90)
		if dfa > 180 then dfa = dfa - 360 end
		--MsgN(dfa)
		local model = self.model
		model:SetPoseParameter("move_yaw",dfa) 
		model:SetPoseParameter("move_x",dir.x*100)
		model:SetPoseParameter("move_y",dir.z*100)
	else 
		self:Stop()
	end
end
function ENT:UpdateSpeed(run)
	 
	local phys = self.phys 
	local scale = self.scale or 1
	local spmul = self.speedmul or 1
	local spscale = scale*spmul
	
	if self:IsFlying() then 
		if run then
			phys:SetAirSpeed(self.flyspeed*1000*spscale) 
		else
			phys:SetAirSpeed(self.flyspeed*10*spscale) 
		end    
	else 
		if self:Crouching() then 
			phys:SetStandingSpeed(self.walkspeed*spscale)  
		else
			if run then  
				phys:SetStandingSpeed(self.runspeed*spscale)  
			else   
				phys:SetStandingSpeed(self.walkspeed*spscale)   
			end
		end
	end 
end
function ENT:IsMoving() 
	local mv = self.phys:GetMovementDirection()
	return mv ~= Vector(0,0,0)
	
	--local cs = self.graph:CurrentState()
	--return cs =="walk" or cs == "cwalk" or cs == "run" or cs == "flight_move"
end
function ENT:Stop()
	self.lastdir = Vector(0,0,0)
	self.phys:SetMovementDirection(Vector(0,0,0)) 
	if self:IsFlying() then
		self.graph:TrySetState("flight_idle")
		self.phys:SetAirSpeed(0)
	else
		if self:Crouching() then
			if self.graph:TrySetState("cidle") then end
		else
			if self.graph:TrySetState("idle") then  end
		end
	end
	local model = self.model 
	model:SetPoseParameter("move_x",0)
	model:SetPoseParameter("move_y",0)
end
function ENT:Attack() 
	if self.graph:TrySetState("attack") then 
	end
end
function ENT:Recall() 
	if self.graph:TrySetState("recall") then 
	end
end
function ENT:StartFlight()
	if self:CanFly() then
		self.graph:SetState("flight_start")
		--self.graph:SetState("idle")
		local phys = self.phys
		phys:SetGravity(Vector(0,-0.0001,0))
		phys:SetAirSpeed(100)
		self.isflying = true
	end
end
function ENT:Land()
	self.graph:SetState("flight_end")
	local phys = self.phys
	phys:SetGravity() 
	phys:SetAirSpeed(0)
	self.isflying = false
end
function ENT:CanFly()
	local fs = self.flyspeed
	return fs and fs ~= 0
end
function ENT:IsFlying()  
	return self.isflying or false
end
function ENT:HandleDriving(driver)
	local cc = GetCurrentController()
	if cc then
		cc:HandleMovement(self)
	end
end
function ENT:RunTaskStep()
	local task = self.task
	if task then 
		if ( coroutine.status( task ) == "dead" ) then
			self.task = nil 
			return 
		end
		local ok, message = coroutine.resume(task, self )
		if ( ok == false ) then 
			ErrorNoHalt( self, " Error: ", message, "\n" ) 
			self.task = nil 
		end  
	end
end 
function ENT:Crouching()
	return self.duckmode or false
end
function ENT:SetCrouching(value)
	self.duckmode = value
end
function ENT:Duck()
	if self:IsFlying() then
		self.phys:ApplyImpulse(-self:Up()) 
	end
end
function ENT:SetSpeedMul(mul)
	self.speedmul = mul
	self.model:SetPlaybackRate(mul)
	
	local lastdir = self.lastdir
	local lastrun = self.lastrun
	
	self:UpdateSpeed(lastrun)
	
	if mul <=0 then
		self:Stop()
		self:SetUpdating(false)
	else
		if lastdir then
		end 
		self:SetUpdating(true,100)
	end
end
function ENT:GetSpeedMul()
	return self.speedmul or 1
end
function ENT:Freeze()
	self:SetSpeedMul(0)
end
function ENT:Unfreeze()
	self:SetSpeedMul(1)
end
function ENT:MoveTo(target) 
	self.target = target
	self.task = coroutine.create(function()
		while true do
			local sz = self:GetParent():GetSizepower()
			local cp = self:GetPos()
			local tp = self.target
			if tp then
				local dir = self:GetLocalCoordinates(tp)
				local dist = dir:Length()*sz
				local Up = self:Up():Normalized()
				local rad, polar,elev = self:GetHeadingElevation(-dir)
				local lastdist = self.lastdist
				local times = self.times22 or 0
				if lastdist and lastdist<=dist then
					times = times + 1
					if times > 10 then
						self:SendEvent(EVENT_ACTOR_JUMP)
						times = 0
						USE(self)
					end
				end
				self.times22 = times
				self.lastdist = dist
				local drf = polar/ 3.1415926 * 180
				--MsgN(polar)
				self:EyeLookAt(tp) 
				self:TRotateAroundAxis(Up, (-drf)/100) 
				if dist>2 then  
					--self:Stop()
					self:Move(Vector(0,0,1),true)
					local Forward = self:Right():Normalized()
					self.phys:SetViewDirection(Forward) 
					self.model:SetPoseParameter("move_yaw",  0)
				else
					self:Stop()
					break
				end
			else
				MsgN("ERROR:TARGET NOT SET")
			end
			coroutine.yield()
		end
	end)
	--self.graph:SetState("run")
	--self.phys:SetMovementDirection(Vector(0,0,1))
	--self.model:SetAnimation("run")
	--model:SetAnimation("idle")
end  
function ENT:GetHeadingElevation(dir,b) 
	if not b then
		dir = dir:Rotate(Vector(0,-180,0))
	end
	local rad = dir:Length()
	local polar = math.atan2(dir.z,dir.x)
	if dir.x < 0 then polar = polar + 3.1415926 end
	local elev = math.asin(dir.y/rad)
	return rad,polar,elev
end
function ENT:EyeLookAt(dir) 
	local sz = self:GetParent():GetSizepower()
	local Up = self:Up():Normalized()
	dir = self:GetLocalCoordinates(dir)---Up* (0.67/sz)
	
	local rad, polar,elev = self:GetHeadingElevation(dir,true)
	self.model:SetPoseParameter("head_yaw",  polar/ 3.1415926 * 180)
	self.model:SetPoseParameter("head_pitch",elev/ 3.1415926 * 180)
	
end
function ENT:EyeLookAtLerped(dir) 
	if not dir then return nil end
	local entt = dir
	dir = self:GetLocalCoordinates(entt)---Up* (0.67/sz)
	
	local sz = entt:GetParent():GetSizepower()
	local Up = entt:Up():Normalized()
	--dir = dir + Up* (0.67/sz)
	local m = self.model
	local cpp_yaw = m:GetPoseParameter("head_yaw")
	local cpp_pitch = m:GetPoseParameter("head_pitch")
	local rad, polar,elev = self:GetHeadingElevation(dir,true)
	local tpp_yaw = polar/ 3.1415926 * 180 
	local tpp_pitch = elev/ 3.1415926 * 180
	local t = 0 
	debug.DelayedTimer(0,10,15,function()
		t = t + 1/15 
		local ss_p =cpp_pitch + (tpp_pitch-cpp_pitch)*t -- Smoothstep(cpp_pitch,tpp_pitch,t)
		local ss_y =cpp_yaw + (tpp_yaw-cpp_yaw)*t -- Smoothstep(cpp_yaw,tpp_yaw,t)
		
		--MsgN(t," : ",cpp_yaw," : ",tpp_yaw," : ",ss_y)
		self:SetEyeAngles(ss_p,ss_y)
		--m:SetPoseParameter("head_yaw",  Smoothstep(cpp_yaw,tpp_yaw,t))
		--m:SetPoseParameter("head_pitch", Smoothstep(cpp_pitch,tpp_pitch,t))
	end)
	
end
function ENT:SetEyeAngles(pitch,yaw) 
	if not math.bad(pitch) then pitch = 0 end
	if not math.bad(yaw) then yaw = 0 end
	local m = self.model
	self.eyeangles = {pitch,yaw}
	m:SetPoseParameter("head_yaw",yaw)
	m:SetPoseParameter("head_pitch",pitch) 
	
	local sForward = self:Right():Normalized()
	self.phys:SetViewDirection(sForward)
end
function ENT:EyeAngles()
	local eyea = self.eyeangles or {0,0}
	return eyea[1], eyea[2]
end
function ENT:EyeLookAtTask(dir) 
	self.task = coroutine.create(function()
	while true do 
		self:EyeLookAt(dir) 
		coroutine.yield() 
		end 
	end)
end

function ENT:PickupWeapon(weap)
	----local wr = self.weapons or {}
	----self.weapons = wr
	----
	----if not wr[weap.type] then
	----	wr[weap.type] = weap
	----	weap:OnPickup(self) 
	----	self:SetActiveWeapon(weap.type)
	----else
	----	return false 
	----end
	local inv = self.inventory 
	if inv then
		inv:AddItem(self,weap)
	end
	weap:OnPickup(self) 
	self:SetActiveWeapon(weap)
end
function ENT:DropWeapon(aw)
	local em = self.model 
	if aw and self.activeweapon == aw then 
		--if aw and em then em:Detach(aw) end 
		aw:Unequip(self)
		self.activeweapon = nil   
		local inv = self.inventory 
		if inv then
			inv:RemoveItem(self,aw)
		end
		aw:OnDrop(self)
	end
end
function ENT:DropActiveWeapon()
	local aw = self.activeweapon
	if aw then self:DropWeapon(aw) end
end

function ENT:GetActiveWeapon()
	return self.activeweapon
end

function ENT:SetActiveWeapon(weap)  
	if weap then
		if weap:GetParent()==self then
			local em = self.model
			local aw = self.activeweapon
			if aw and em then  
				aw:Unequip(self)
				if self.inventory then
					self.inventory:AddItem(self,aw)
				else
					self:DropWeapon(aw)
				end 
			end 
			self.activeweapon = weap
			
			weap:Equip(self)
			
			return true 
		end
	else
		--local em = self.model
		--local aw = self.activeweapon
		--if aw and em then em:Detach(aw) end 
		--self.activeweapon = nil
		--em:StopLayeredSequence(2)
		--em:StopLayeredSequence(1)
		local em = self.model
		local aw = self.activeweapon
		if aw and em then  
			aw:Unequip(self)
			if self.inventory then
				self.inventory:AddItem(self,aw)
			else
				self:DropWeapon(aw)
			end 
		end 
		return true
	end
	return false
end

 --[[function ENT:SetActiveWeapon(type)
	if type then 
		local wr = self.weapons
		if wr then
			local weap = wr[type]
			if weap then
				local em = self.model
				local aw = self.activeweapon
				if aw and em then em:Detach(aw) end 
				self.activeweapon = weap
				em:Attach(weap,"weapon1",true,weap.attachworld or matrix.Identity())
				em:PlayLayeredSequence(1,"weapon_hold_test")
				em:PlayLayeredSequence(2,"weapon_aim")
				
				return true
			end
		end
	else
		local em = self.model
		local aw = self.activeweapon
		if aw and em then em:Detach(aw) end 
		self.activeweapon = nil
		em:StopLayeredSequence(2)
		em:StopLayeredSequence(1)
		return true
	end
	return false
end
function ENT:DropWeapon(type)
	local em = self.model
	local aw = self.activeweapon
	local wr = self.weapons or {}
	self.weapons = wr
	if aw and aw.type == type then 
		if aw and em then em:Detach(aw) end 
		self.activeweapon = nil 
		wr[type] = nil
		em:StopLayeredSequence(1)
		aw:OnDrop(self)
	end
end

function ENT:DropActiveWeapon()
	local aw = self.activeweapon
	if aw then self:DropWeapon(aw.type) end
end
function ENT:GetWeapons()
	return self.weapons
end
]]

function ENT:Cast(abname)
	local ab = self.abilities[abname]
	if ab then
		local tr = GetCameraPhysTrace()
		if tr and tr.Hit then
			--ab:Cast(self,
		end
	end
end
--BO_MoveTo(GetCamera():GetParent(),GetCamera():GetParent():GetPos()+Vector(0,0,0.01))



function ENT:GetHealth()
	return self:GetParameter(VARTYPE_HEALTH)
end
function ENT:SetHealth(val) 
	self:SendEvent(EVENT_HEALTH_CHANGED,val)
end

function ENT:GetMaxHealth()
	return self:GetParameter(VARTYPE_MAXHEALTH)
end
function ENT:SetMaxHealth(val) 
	self:SendEvent(EVENT_MAXHEALTH_CHANGED,val)
end

function ENT:GetHealthPercentage()
	return self:GetParameter(VARTYPE_HEALTH) / self:GetParameter(VARTYPE_MAXHEALTH)
end

function ENT:SetHealthPercentage(pc) 
	self:SendEvent(EVENT_HEALTH_CHANGED, pc*self:GetParameter(VARTYPE_MAXHEALTH))
end

function ENT:Hurt(amount) 
	self:SendEvent(EVENT_DAMAGE,amount)
end

function ENT:Kill() 
	if SERVER then self.graph:SetState("dead")  end
	self:SendEvent(EVENT_DEATH)
end
function ENT:Respawn() 
	if SERVER then self.graph:SetState("spawn")  end
	self:SendEvent(EVENT_SPAWN)
end

function ENT:Alive()
	return self.graph:CurrentState()~="dead"
end

function ENT:Dead()
	return self.graph:CurrentState()=="dead"
end


function ENT:Alert()
	self.graph:TrySetState("unc_transition")
end

function ENT:VelocityCheck(teleport)
	local lastvel = self.lastvel
	local vel = self.phys:GetVelocity()
	if lastvel and not teleport then 
		local veldelta = vel-lastvel
		self:VelocityHit(nil,veldelta)
	end
	self.lastvel = vel
end
function ENT:VelocityHit(hitby,velonhit)
	local avvel = velonhit:Length() -- self.phys:GetVelocity():Length()
	local scale = self.scale or 1
	--if avvel > 0 then
	if avvel > 5 then
		local vol = math.min(1,(avvel-5)/5)
		self:EmitSound(table.Random({"hit1.ogg","hit2.ogg","hit3.ogg"}),vol*0.9)
	end
	
	if avvel > 10 then
		local damage = math.pow((avvel-9)/scale,2)
		self:Hurt(damage)
		
		MsgN("CC: ",self,hitby," vel: ",avvel)
	end  
	--end
end

function ENT:Give(type)
	local tool = SpawnWeapon(type,self,Vector(0,0,0),1311314)
	self:PickupWeapon(tool)
	if SERVER then
		self:SendEvent(EVENT_GIVE_ITEM,type)
	end
end

function ENT:SetSkin(str)
	if str then
		local model = self.model
		for k,v in pairs(str:split(',')) do
			local pr = v:split(':')
			model:SetSkin(pr[1],tonumber(pr[2]))
		end
	end
end




function ENT:GetEyeTrace()
	local model = self.model
	if model then 
		--local pos = Vector(0,0,0) 
		-- 
		--if model:HasAttachment("eyes") then pos = model:GetAttachmentPos("eyes") 
		--elseif model:HasAttachment("head") then pos = model:GetAttachmentPos("head")   
		--elseif model:HasAttachment("muzzle") then pos = model:GetAttachmentPos("muzzle") end
		--
		--
		--local parentphysnode = self:GetParentWithComponent(CTYPE_PHYSSPACE)
		--if parentphysnode then
		--	local space = parentphysnode:GetComponent(CTYPE_PHYSSPACE)
		--	local lw = parentphysnode:GetLocalSpace(cam)
		--	local hit, hpos, hnorm, dist, ent = space:RayCast(lw:Position(),lw:Forward())
		--	return {Hit = hit,Position=hpos,Normal=hnorm,Distance = dist, Node = parentphysnode, Space = space,Entity = ent}
		--end
		
	end
end













