---function LoadWorld(id)
---	U = ents.Create()
---	U:SetSizepower(math.pow(2,88))
---	U:SetSeed(1000001)
---	U:SetGlobalName("u1")
---	U:Spawn() 
---
---	space = ents.Create("spaceCluster") 
---	space:SetSeed(1000002)
---	space:SetParent(U) 
---	space:SetSizepower(math.pow(2,86))
---	space:SetGlobalName("u1.mc")
---	space:Spawn() 
---	
---	--AddOrigin(cam)
---	cam:SetUpdateSpace(true)
---	
---	if ISSAVEDGAME then 
---		LoadSave() 
---	else
---		SendTo(cam,"@u1.mc;-0.002718567,0.0005680526,0.004285494;0.3089897,0.02846826,0.06682603;s1065632697;s2008649333;s2397131")--ship
---	--SendTo(cam,"@u1.mc;-0.002718567,0.0005680526,0.004285494;0.3089897,0.02846826,0.06682603;s1065632697;s2008649333;s2008650333;0.803679,0.07456001,-0.4183209")--planet surface
---	end
---	--local targetpos = Vector(0.003537618,0.01925059,0.2446546)
---	--cam:SetPos(targetpos)
---	cam:SetGlobalName("player_cam")
---	hook.Call("engine.location.loaded", cam,"local")
---end