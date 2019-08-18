
local VEC_FORWARD = Vector(0,0,-1)
local VEC_RIGHT = Vector(1,0,0)
local VEC_UP = Vector(0,1,0)

OBJ.mouse_lastpos = {0,0}
OBJ.speed = 0.01
 

OBJ.mouseWheelValue = 0
OBJ.mouseWheelDelta = 0

OBJ.sounds = {
	wind = "ambient/wind.wav"
}
 


function OBJ:Init() 
	local cam = GetCamera()
	cam:SetUpdateSpace(true)
	self.mouseWheelValue = input.MouseWheel()  
end
function OBJ:UnInit() 
	local cam = GetCamera()
	cam:SetUpdateSpace(false)
	if self.lms_active then
		input.SetCursorHidden(false)
		self.lms_active = false
	end
end

function OBJ:MouseWheel()
	local mWVal = input.MouseWheel() 
	if not input.GetKeyboardBusy() then
		if (input.KeyPressed(KEYS_X)) then 
			self.mouseWheelDelta = self.mouseWheelDelta + (mWVal - self.mouseWheelValue)
			self.speed = math.pow(2, self.mouseWheelDelta / 100) * 0.01
		end
	end
	self.mouseWheelValue = mWVal 
end
function OBJ:MouseDown()
	if self.mouseactive then
		if(input.leftMouseButton()) then
			self:SelectNode(function(n)
				if n and n:HasTag(TAG_USEABLE) then
					USE(GetCamera(),n)
				end	
				--MsgN("nod:",n)
			end)
		end
	end
end

function OBJ:SelectNode(callback)

	local vsz = GetViewportSize()
	local vmp = input.getInterfaceMousePos()
	local vsr = (vmp/vsz)*Point(0.5,-0.5)+Point(0.5,0.5)

	render.DCISetEnabled(true)
	render.DCIRequestRedraw()
	debug.Delayed(50,function()
		local drw = render.DCIGetDrawable(vsr)  
		render.DCISetEnabled(false)
		if drw then
			callback(drw:GetNode())
		end 
	end)
end
function OBJ:KeyDown(key)  
	if input.GetKeyboardBusy() then return nil end
	if input.KeyPressed(KEYS_D1) then
		SetController("actor")
	end
	if input.KeyPressed(KEYS_C) then
		self:ToggleMouse()
	end
		if (input.KeyPressed(KEYS_R)) then 
			self.mouseWheelDelta = self.mouseWheelDelta + 100
			self.speed = math.pow(2, self.mouseWheelDelta / 100) * 0.01 
		end
		if (input.KeyPressed(KEYS_F)) then 
			self.mouseWheelDelta = self.mouseWheelDelta - 100
			self.speed = math.pow(2, self.mouseWheelDelta / 100) * 0.01
		end
end

function OBJ:Update() 
	self:UpdateSounds()
	if input.GetKeyboardBusy() then return nil end
		
	--if not input.KeyPressed(KEYS_C) then
		local dt = 1
		
		local cam = GetCamera()
		local fov = cam:GetFOV()
		local cam_parent = cam:GetParent()
		local parent_sz = cam_parent:GetSizepower()
		local Forward = cam:Forward():Normalized()
		local Right = cam:Right():Normalized()
		local Up = cam:Up():Normalized() 
		
		local result = Vector(0,0,0)
		if input.KeyPressed(KEYS_W) then result = result - Forward end
		if input.KeyPressed(KEYS_S) then result = result + Forward end
		if input.KeyPressed(KEYS_D) then result = result - Right end
		if input.KeyPressed(KEYS_A) then result = result + Right end
		if worldeditor and worldeditor.Enabled then
			if worldeditor.Enabled() then
				if input.KeyPressed(KEYS_R) then result = result - Up end
				if input.KeyPressed(KEYS_F) then result = result + Up end
			else
				if input.KeyPressed(KEYS_SPACE) then result = result - Up end
				if input.KeyPressed(KEYS_CONTROLKEY) then result = result + Up end
			end
		end
 
		if result ~= Vector(0,0,0) then 
			result = result:Normalized()
		end
		
		if input.KeyPressed(KEYS_Q) or input.KeyPressed(KEYS_Y) then 
			cam:RotateAroundAxis(VEC_FORWARD, -0.01)
		end
		if input.KeyPressed(KEYS_E) or input.KeyPressed(KEYS_I) then 
			cam:RotateAroundAxis(VEC_FORWARD, 0.01)
		end
		
		
		if input.KeyPressed(KEYS_NUMPAD1) then 
			cam:SetFOV(fov*0.99)
		end
		if input.KeyPressed(KEYS_NUMPAD2) then 
			cam:SetFOV(fov*1.01)
		end
		if input.KeyPressed(KEYS_NUMPAD3) then 
			cam:SetFOV(80)
		end
		
		local mhag = input.MouseIsHoveringAboveGui()
		local rmb = input.rightMouseButton()

		local shx = 0
		local shy = 0
		if input.KeyPressed(KEYS_H) then shx = shx - 10 end
		if input.KeyPressed(KEYS_K) then shx = shx + 10 end
		if input.KeyPressed(KEYS_U) then shy = shy - 10 end
		if input.KeyPressed(KEYS_J) then shy = shy + 10 end

		if (self:MouseLocked() and not mhag) or (shx~=0 or shy~=0) then--not mhag and rmb then
			local size = GetViewportSize() 
			local center = size / 2
			center = Point(math.floor( center.x),math.floor(center.y))
			self:UpdateCamRotation(size,center,shx,shy)
		end 
		if self.firstp and not self:MouseLocked() and (shx==0 and shy==0) then
			self.firstp = false
		end
		if self.lms_active and (not rmb or mhag) then
			input.SetCursorHidden(false)
			self.lms_active = false
		end
		
		local cphys = cam.phys
		if cphys then
			cphys:ApplyImpulse( -result * self.speed / parent_sz * dt)
			cphys:ApplyRotation()
		else
			cam:SetPos( cam:GetPos() - result * self.speed / parent_sz * dt)
		--cam:SetVelocity( result * self.speed / parent_sz * dt)
		end
		
		
		--if CAMTESTPR then
			--if not CAMTESTPR_FIRST then
			--	CAMTESTPR:SetUpdating(false)
			--	CAMTESTPR:SetParent(cam:GetParent())
			--	CAMTESTPR_FIRST = true
			--	CAMTESTPR:SetSpaceEnabled(false)  
			--end
			--[[
			local mousePos = input.getInterfaceMousePos()
			local lp = cam:Unproject(mousePos )--:Normalized()
			local cpp = (cam:GetPos() + lp*30)--
			local hit,hd,hp,he = cam:Trace(lp)--,{CAMTESTPR})
			if hit and hd < 30 then
				cpp = hp
				if input.leftMouseButton() then
					if TESTSELECTOR then
						if TESTSELECTOR:GetParent() ~= he then
							TESTSELECTOR:SetParent(he)
						end
					end
				end
			end 
			]]
			--CAMTESTPR:SetPos(cpp)
		
		--end
	--end
end
function OBJ:UpdateCamRotation(size,center,shx,shy)
	local cam = GetCamera()
	local fov = cam:GetFOV()

	if not self.lms_active then
		input.SetCursorHidden(true)
		self.lms_active = true
	end

	local mousePos = input.getMousePosition()
	local offset = mousePos - center
	self.mouse_lastpos = mousePos
	input.setMousePosition(center)


	offset = offset + Point(shx,shy)
	if self.firstp then
		cam:RotateAroundAxis(VEC_RIGHT, (offset.y / -1000 )*fov/80)
		cam:RotateAroundAxis(VEC_UP, (offset.x / -1000)*fov/80)
	end
	self.firstp = true
end

global_atmosphere_sound = global_atmosphere_sound or false

lastcampos = false
function OBJ:UpdateSounds()
	
	local dt = 60 --60 Hz
	
	local atmPressure = env.AtmPressure()
	local windSpeed = 1
	if atmPressure then
		
		
		
		local cam = GetCamera()
		local cp = cam:GetParent()
		local cpz  = cp:GetSizepower()
		local cpos = cam:GetPos()
		if lastcampos then
			local cspd = (cpos-lastcampos):Length()*cpz
			local camSpeed = cspd*dt/4
			--MsgN(camSpeed)
			windSpeed = camSpeed/dt-- +0.01
			if camSpeed>331 then
				windSpeed =1
			end
		end
		lastcampos = cpos
		
		if atmPressure <0 then
			windSpeed=0.2
			atmPressure=1
		end
	
	end
		if atmPressure and atmPressure > 0.01 and windSpeed>0.01 then
			if not global_atmosphere_sound then
				global_atmosphere_sound = sound.Start(self.sounds.wind,0.9)
			end
			local volume = atmPressure*math.min(1,windSpeed)
			global_atmosphere_sound:SetVolume(volume)
			global_atmosphere_sound:SetSpeed(atmPressure*atmPressure*windSpeed)
		else
			if global_atmosphere_sound then
				global_atmosphere_sound:Stop()
				global_atmosphere_sound = false
			end 
		end
end

function OBJ:ToggleMouse()
	if self.mouseactive then
		input.SetCursorHidden(false)
		self.mouseactive = false
	else 
		input.SetCursorHidden(true)
		self.mouseactive = true 
	end
	
end
function OBJ:MouseLocked()
	if input.WindowActive() and not BLOCK_MOUSE then
		if SHOWINV then return false end
		 
		if self.mouseactive then
			if MAIN_MENU and MAIN_MENU:GetVisible() then
				return false
			else
				return true 
			end
		else 
			
			local mhag = input.MouseIsHoveringAboveGui()
			if not mghag then
				return	 input.rightMouseButton()
			else
				return false
			end
		end
	end
	return false
end
