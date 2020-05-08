
SETTINGS_VALUES = {
	Categories = {
		{
			name = "Player",
			variables = {
				{ type = "string", name = "Name", var = "player/name", default = "New Player"},
				{ type = "string", name = "Character", var = "player/model", default = "vikna"},
				{ type = "string", name = "Skin IDs", var = "player/skinid", default = ""},
				{ type = "bool", name = "Hide in FP", var = "player/fpmode2", default = true},
				{ type = "bool", name = "Disable RI in FP", var = "player/fpmode2_rotintertia", default = false},
			}
		},
		{
			name = "Graphics",
			variables = {
				{type = "bool", name = "EnableShadows", var = "engine/shadowsenabled", default = true},
				{type = "bool", name = "EnableMirrors", var = "engine/mirrorsenabled", default = true},
				{type = "number", name = "ShadowSize", var = "engine/shadowssize", default = 2048, proc = function(n)
					return math.Clamp(n,128,8192) end},
				{type = "number", name = "FOV", var = "engine/fov", default = 90, proc = function(n)
					return math.Clamp(n,45,110) end},
				--{type = "separator", name = "PostProcessing"},
				{type = "bool", name = "PostProcess enabled", var = "engine/pp_enabled", default = true, 
					--apply = function(v) render.GlobalRenderParameters():SetPostprocessEnabled(v) end
					apply = function(v) render.GlobalRenderParameters():SetPostProcessEnabled(v) end
				},
				{type = "bool", name = "SSAO", var = "engine/pp_ssao", default = true,  
					--apply = function(v) render.GlobalRenderParameters():SetPostprocessSSAO(v) end
					apply = function(v) render.GlobalRenderParameters():SetPostProcessSSAO(v) end
				},
				{type = "number", name = "SSAO samples", var = "engine/pp_ssao_samples", default = 16, 
					proc = function(n) return math.Clamp(n,8,128) end, 
					--apply = function(v) render.GlobalRenderParameters():SetPostprocessSSAOSamples(v) end
					apply = function(v) render.GlobalRenderParameters():SetPostProcessSSAOSampleCount(v) end 
				},
				{type = "bool", name = "SSLR", var = "engine/pp_sslr", default = true, 
					--apply = function(v) render.GlobalRenderParameters():SetPostprocessSSLR(v) end
					apply = function(v) render.GlobalRenderParameters():SetPostProcessSSLR(v) end
				},
				{type = "bool", name = "Bloom enabled", var = "engine/pp_bloom", default = true, 
					--apply = function(v) render.GlobalRenderParameters():SetPostprocessBloom(v) end
					apply = function(v) render.GlobalRenderParameters():SetPostProcessBloom(v) end
				},
				{type = "bool", name = "Grass enabled", var = "engine/gsh_grass", default = true, 
					apply = function(v) render.GlobalRenderParameters():SetDrawGSGrass(v) end
				},
				{type = "bool", name = "Fur enabled", var = "engine/fur", default = true, 
					apply = function(v) render.GlobalRenderParameters():SetDrawGSFur(v) end
				},
				
				{type = "bool", name = "Volume clouds top", var = "engine/cheapclouds_top", default = true, 
					--apply = function(v) render.GlobalRenderParameters():SetVolumeCloudsTop(v) end
					apply = function(v) render.GlobalRenderParameters():SetDrawVolumeCloudsTop(v) end
				},
				{type = "bool", name = "Volume clouds bot", var = "engine/cheapclouds_bot", default = true, 
					--apply = function(v) render.GlobalRenderParameters():SetVolumeCloudsBot(v) end
					apply = function(v) render.GlobalRenderParameters():SetDrawVolumeCloudsBot(v) end
				},

			}
		},
		{
			name = "Controls",
			variables = {
				{type = "key", name = "Move forward", 	var = "input/move/forward", 	default = KEYS_W},
				{type = "key", name = "Move left", 		var = "input/move/left", 		default = KEYS_A},
				{type = "key", name = "Move backward", 	var = "input/move/back", 		default = KEYS_S},
				{type = "key", name = "Move right", 	var = "input/move/right", 		default = KEYS_D},
				{type = "key", name = "Move up", 		var = "input/move/up", 			default = KEYS_SPACE},
				{type = "key", name = "Move down", 		var = "input/move/down", 		default = KEYS_CONTROLKEY}, 
				
				{type = "key", name = "Inventory", 		var = "input/actor/inventory", 		default = KEYS_Q},
				{type = "key", name = "Interact",    	var = "input/actor/use", 			default = KEYS_E},
				{type = "key", name = "Pickup", 		var = "input/actor/pickup", 		default = KEYS_F},
				{type = "key", name = "Jump", 			var = "input/actor/jump", 			default = KEYS_SPACE},
				{type = "key", name = "Duck", 			var = "input/actor/duck", 			default = KEYS_CONTROLKEY}, 
				{type = "key", name = "Exit vehicle", 	var = "input/vehicle/exit", 	 	default = KEYS_V},


				{type = "key", name = "Rotate left", 	var = "input/camera/rotateleft", 		default = KEYS_Q},
				{type = "key", name = "Rotate right", 	var = "input/camera/rotateright", 		default = KEYS_E},
				{type = "key", name = "Speed regulator",var = "input/camera/speedregulator", 	default = KEYS_X},

				{type = "key", name = "Quick slot 1",var = "input/quik/slot1", 	default = KEYS_D1},
				{type = "key", name = "Quick slot 2",var = "input/quik/slot2", 	default = KEYS_D2},
				{type = "key", name = "Quick slot 3",var = "input/quik/slot3", 	default = KEYS_D3},
				{type = "key", name = "Quick slot 4",var = "input/quik/slot4", 	default = KEYS_D4},
				{type = "key", name = "Quick slot 5",var = "input/quik/slot5", 	default = KEYS_D5},
				{type = "key", name = "Quick slot 6",var = "input/quik/slot6", 	default = KEYS_D6},
				{type = "key", name = "Quick slot 7",var = "input/quik/slot7", 	default = KEYS_D7},
				{type = "key", name = "Quick slot 8",var = "input/quik/slot8", 	default = KEYS_D8},
				{type = "key", name = "Quick slot 9",var = "input/quik/slot9", 	default = KEYS_D9},
				{type = "key", name = "Quick slot 0",var = "input/quik/slot0", 	default = KEYS_D0},
			}
		},
		{
			name = "Server",
			variables = {
				{type = "string", name = "ServerName", var = "server/name", default = "Sol Server"}, 
				{type = "bool", name = "FPOnly", var = "server/firstperson", default = false}, 
				{type = "bool", name = "NoFreeCam", var = "server/nofreecam", default = true}, 
				{type = "bool", name = "NoConsole", var = "server/noconsole", default = true}, 
			}
		},
	},
	List = {},
	Index = {}
}

for k,v in pairs(SETTINGS_VALUES.Categories) do
	for k2,v2 in pairs(v.variables) do
		SETTINGS_VALUES.List[v2.var] = v2

		SETTINGS_VALUES.Index[v2.var] = v2
		SETTINGS_VALUES.Index[string.Replace(v2.var,'/','.')] = v2
	end
end


settings = settings or {}

function settings.GetBool(name,default)  
	name = string.Replace(name,'%.','/')
	local p = SETTINGS_VALUES.Index[name]
	if p then
		return profile.GetBool(name,p.default)
	else 
		return profile.GetBool(name,default)
	end
end
function settings.SetBool(name,value) 
	name = string.Replace(name,'%.','/')
	profile.SetBool(name,value)
end
function settings.GetNumber(name,default)
	name = string.Replace(name,'%.','/')
	local p = SETTINGS_VALUES.Index[name]
	if p then
		return profile.GetNumber(name,p.default)
	else 
		return profile.GetNumber(name,default)
	end
end
function settings.SetNumber(name,value) 
	name = string.Replace(name,'%.','/')
	profile.SetNumber(name,value)
end
function settings.GetString(name,default) 
	name = string.Replace(name,'%.','/')
	local p = SETTINGS_VALUES.Index[name]
	if p then
		return profile.GetString(name,p.default)
	else 
		return profile.GetString(name,default)
	end
end
function settings.SetString(name,value) 
	name = string.Replace(name,'%.','/')
	profile.SetString(name,value)
end
function settings.GetData(name,default)
	name = string.Replace(name,'%.','/')
	local p = SETTINGS_VALUES.Index[name]
	if p then
		return profile.GetValue(name,p.default)
	else 
		return profile.GetValue(name,default)
	end
end
function settings.SetData(name,value) 
	name = string.Replace(name,'%.','/')
	profile.SetValue(name,value)
end
function settings.Save() 
	profile.Save()
end

function  settings_error(e)
	MsgN("settings apply error:", e) 
	MsgN(debug.traceback())
end
  
function settings.Apply() 
	for k2,v2 in pairs(SETTINGS_VALUES.List) do
		if v2.apply then
			local val = nil 
			if v2.type == "bool" then
				val = settings.GetBool(v2.var,v2.default) 
			elseif v2.type =="number" then
				val = settings.GetNumber(v2.var,v2.default) 
			end
			if val ~= nil then 
				local success, result = xpcall(v2.apply,settings_error,val) 
				if success then
					Msg("s_apply ",v2.name," to ",val) 
				end
			end 
		end
	end 
end