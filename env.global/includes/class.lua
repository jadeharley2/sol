local reg = debug.getregistry()
local _USERCLASS = reg._USERCLASS
if not _USERCLASS then _USERCLASS = {} reg._USERCLASS = _USERCLASS end
local _CLASS_META = reg.Userclass
if not _CLASS_META then _CLASS_META = {} reg.Userclass = _CLASS_META end 

function _CLASS_META:ReloadType(type)
	local cname = string.lower(file.GetFileNameWE(type))
	self:AddType(cname)
end 

_CLASS_META_INDEX = function(t,k)
	local v = rawget(t,k)
	if v then 
		return v 
	else
		local base = rawget(t,"_base")
		while base do 
			local v = base[k]
			if v then return v end
			base = rawget(base,"_base")
		end
	end
end 
function _CLASS_META:ScanDirectory()  
	local flist = file.GetFiles(self.dir,"lua")
	for k,v in pairs(flist) do
		local cname = string.lower( file.GetFileNameWE(v))
		MsgN(self.name ..": "..cname) 
		self:AddType(cname) 
	end
	
	local dlist = file.GetDirectories(self.dir)
	for k,v in pairs(dlist) do
		local cname = string.lower( file.GetFileNameWE(v))
		MsgN(self.name ..": "..cname) 
		self:AddType(cname) 
	end
end
function _CLASS_META:AddType(type)  
	local oldc = _G[self.varn]
	local newtype = self:GetType(type) or {}
	--newtype.__index = nil
	_G[self.varn] = newtype
	
	local sfile = self.dir .. type .. ".lua"
	if file.Exists(sfile) then
		include(sfile,self.ReloadType) 
	else
		local sfile2 = self.dir .. type .. "/init.lua"
		if file.Exists(sfile2) then
			include(sfile2,self.ReloadType) 
		end 
	end
	
	local result = _G[self.varn]
	if result.base then
		local base = self.GetType(result.base) or {}
		result._base = newbase 
	else
		result._base = self.meta
	end 
	result._name = type
	_G[self.varn] = oldc or {}
	self.types[type] = result
	return result
end
function _CLASS_META:GetType(type) 
	return self.types[type] 
end
function _CLASS_META:GetTypeList() 
	return self.types
end
function _CLASS_META:GetTypeNameList() 
	local names = {}
	for k,v in pairs(self.types) do
		names[#names+1] = k
	end
	return names
end

function _CLASS_META:Create(type) 
	local m = {}
	if type then
		local b = self:GetType(type) 
		if b then
			m._base = b 
			setmetatable(m,self.meta)  
		else
			MsgN( self.name .." "..type.." not found!\n" )
			return nil
		end 
	else  
		setmetatable(m,self.meta) 
	end   
	return m 
end
function _CLASS_META:IsBelongs(obj)
	return getmetatable(obj) == self.meta 
end

_CLASS_META.__index = _CLASS_META

function DefineClass(Name,Varname,Directory,Metatable)
	local nc = _USERCLASS[Name] or {} 
	nc.name = Name 
	nc.varn = Varname
	nc.dir = Directory
	nc.meta = Metatable
	nc.types = nc.types or {} 
	setmetatable(nc,_CLASS_META)
	_USERCLASS[Name] = nc
	if Metatable then
		Metatable.__index = _CLASS_META_INDEX
	end
	nc:ScanDirectory()
	
	local luabasedDir = string.sub(Directory,5)
	hook.Add("script.reload","class."..Name, function(filename)
		MsgN("check ","class."..Name," : ",filename,luabasedDir,string.starts(filename,luabasedDir))
		if string.starts(filename,luabasedDir) then 
			local type = string.lower( file.GetFileNameWE(filename))
			nc:AddType(type)
			return true
		end
	end)
	return nc
end 
