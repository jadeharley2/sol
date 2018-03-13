
hook = hook or {}

local lua_hooks = lua_hooks or {}

function hook.Add(type, id, func)
	local case = lua_hooks[type] or {}
	case.functions = case.functions or {}
	if not case.functions[id] then
		case.count = (case.count or 0) + 1
	end
	case.functions[id] = func 
	lua_hooks[type] = case
end
function hook.Remove(type, id)
	local case = lua_hooks[type]
	if case then
		if case.functions[id] then
			case.functions[id] = nil
			case.count = case.count - 1
		end
		if(case._count == 0) then
			lua_hooks[type] = nil
		end
	end
end
function hook.GetTable()
	return table.Copy(lua_hooks)
end

function hook.Call(eventid,...)
	--if eventid ~= "main.update" then MsgN("hook call: "..tostring(eventid)) MsgN(...) end
	local case = lua_hooks[eventid]
	if case then
		for k,v in pairs(case.functions) do
			local result = v(...)
			if result then
				return result
			end
		end
	end
end

_SetNativeCallFunc(hook.Call)