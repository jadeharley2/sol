
function _ScriptReload(filename)
	if string.starts(filename,"lua/") then
		filename = string.sub(filename,5)
		if not hook.Call("script.reload",filename) then
			MsgN("script reload ", filename)
			include(filename)
		end
	end
end 

   