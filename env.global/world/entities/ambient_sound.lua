
ENT.randomtrack = true
ENT.list = {"ambient/170515__devlab__forest-ambient-01-loop.wav"}

function ENT:Init() 

	self:SetSpaceEnabled(false) 
end
function ENT:Spawn()
	
	self:NextTrack()
end
function ENT:Despawn()
	local snd = self.snd
	if snd then snd:Stop() snd:Dispose()  self.snd = nil end
end
 
function ENT:StartTrack(id)
	MsgN("nexttrack: ",id)
	local list = self.list
	self.trackid = id
	if list then
		local track = list[id]
		if track then 
			local ss = self.snd
			if ss then
				ss:Stop()
				ss:Dispose()
			end
		
			local snd = sound.Start(track,0.7)
			self.snd = snd
			if snd then
			
				if(#list>1)then
					debug.Delayed(snd:Duration()*1000,function()
						if IsValidEnt(self) then
							self:NextTrack()
						end
					end)
				end
			end
		end
	end
end
function ENT:NextTrack()
	local list = self.list
	if list then
		if self.randomtrack then
			local nid = math.random(1,#list)
			self:StartTrack(nid)
		else
			local nid = (self.trackid or 0) + 1
			if(nid>#list) then nid = 1 end
			self:StartTrack(nid)
		end
	end
end