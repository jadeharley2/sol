ENT.name = "Flat grass"


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

function ENT:Init()

	self:SetSizepower(10000)
	self:SetSeed(9900001)
	self:SetGlobalName("u1_room") 

end
function ENT:Spawn()

	-- all worlds must have minimum 1 subspace 
	-- 
	local space = ents.Create()
	space:SetLoadMode(1)
	space:SetSeed(9900002)
	space:SetParent(self) 
	space:SetSizepower(1000)
	space:SetGlobalName("u1_room.space")
	space:Spawn()  
	local sspace = space:AddComponent(CTYPE_PHYSSPACE)  
	sspace:SetGravity(Vector(0,-4,0))
	space.space = sspace

	SpawnSO("map/01/01.json",space,Vector(0,0,0),0.75) 
	--def:190000000
	--local light = self:CreateStaticLight(Vector(-1.3,1.2,-2.5)/2*10,Vector(140,161,178)/255,190000000)
	local light = self:CreateStaticLight(Vector(-1.3,1.2,-2.5)/2*10,Vector(200,200,200)/255,190000000 * 100)
	 
	self.space = space
	
	
	
	-- apparel dispenser
	local dpos = Vector(0.007491949, 0.000883143, -0.006987628)
	local current_itemv = false
	local dfunc = function(button,user) 
		if CLIENT and user == LocalPlayer() then
			if current_itemv then
				current_itemv:Close()
				current_itemv=false
				SHOWINV = false
			else
				current_itemv = panel.Create("window_itemviewer") 
				local givefunc = function(LP,itemname)
					--LP:Give(itemname) 
					LP:SendEvent(EVENT_GIVE_ITEM,itemname)
					--local app = SpawnIA(itemname,LP:GetParent(),LP:GetPos()) 
					--if app then 
					--	app:SendEvent(EVENT_PICKUP,LP)
					--	LP.inventory:AddItem(LP, app)
					--end
				end
				current_itemv:Setup("forms/apparel/","json",givefunc)
				current_itemv.OnClose = function()
					current_itemv=false
					SHOWINV = false
				end
				current_itemv:Show()
				SHOWINV = true
			end
		end
	end
	local app_b = SpawnButton(space,"primitives/sphere.json",dpos,nil,dfunc,32542389,0.8)
	app_b.usetype = "apparel spawner"
	------
	 
	-- tool dispenser
	local dpos = Vector(0.007491949, 0.000883143, -0.004687628)
	local current_wepv = false
	local dfunc = function(button,user) 
		if CLIENT and user == LocalPlayer() then
			if current_wepv then
				current_wepv:Close()
				current_wepv=false
				SHOWINV = false
			else
				current_wepv = panel.Create("window_itemviewer") 
				local givefunc = function(LP,itemname)
					LP:Give(itemname) 
				end
				current_wepv:Setup("lua/env.global/world/tools/","lua",givefunc)
				current_wepv.OnClose = function()
					current_wepv=false
					SHOWINV = false
				end
				current_wepv:Show()
				SHOWINV = true
			end
		end
	end
	local wep_b = SpawnButton(space,"primitives/sphere.json",dpos,nil,dfunc,231632412,0.8)
	wep_b.usetype = "weapon spawner"
	------
	
	-- character changer
	local dpos = Vector(0.007491949, 0.000883143, -0.002687628)
	local current_charv = false
	local dfunc = function(button,user) 
		if CLIENT and user == LocalPlayer() then
			if current_charv then
				current_charv:Close()
				current_charv=false
				SHOWINV = false
			else
				current_charv = panel.Create("window_itemviewer") 
				local givefunc = function(LP,itemname)
					LP:SendEvent(EVENT_CHANGE_CHARACTER,itemname) 
					current_charv:Close()
					current_charv=false
					SHOWINV = false
				end
				current_charv:Setup("forms/characters/","json",givefunc)
				current_charv.OnClose = function()
					current_charv=false
					SHOWINV = false
				end
				current_charv:Show()
				SHOWINV = true
			end
		end
	end
	local char_b = SpawnButton(space,"primitives/sphere.json",dpos,nil,dfunc,23521234,0.8)
	char_b.usetype = "character morpher"
	------
	
	local ambient = ents.Create("ambient_sound")
	ambient:SetParent(space)
	ambient:Spawn()
	self.ambient = ambient
	
	SpawnMirror(space,Vector(0.0005589276, 0.001217313, -0.01491671))
end

function ENT:GetSpawn() 
	local space = self.space

	local space2 = ents.Create()
	space2:SetLoadMode(1)
	space2:SetSeed(9900033)
	space2:SetPos(Vector(0.05, 0.008043702, -1.207809e-09))
	space2:SetParent(space) 
	space2:SetSizepower(5)
	space2:SetGlobalName("u1_room.space2")
	space2:SetScale(Vector(0.001, 0.1, 0.1))
	space2:SetSpaceEnabled(false)
	space2:Spawn()  
	local sspace = space2:AddComponent(CTYPE_PHYSSPACE)  
	sspace:SetGravity(Vector(0,-4,0))
	space2.space = sspace
	self.space2 = space2
	
	SpawnSO("test/r_room.json",space2,Vector(0,0,0),0.75) 
	

	space2:AddEventListener(EVENT_USE,"use_event",function(user)
		if user:GetParent()==space2 then
			user:SetParent(space2:GetParent())
			user:SetPos(space2:GetPos())
		else
			user:SetParent(space2)
			user:SetPos(Vector(0,0,0))
		end
	end)
	space2:AddFlag(FLAG_USEABLE) 

	return self.space, Vector(0,0.01,0)
end