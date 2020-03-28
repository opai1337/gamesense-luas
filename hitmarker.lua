-- 1337 hitmarker by opai1337 (also used in my friend's hack)

local SetEventCallback = client.set_event_callback
local impact_info = {}
local hitmarker_info = {}

local vars =  {
	hitmarker = ui.new_checkbox("VISUALS", "Player ESP", "World Hitmarker"),
	hitmarker_clr = ui.new_color_picker("VISUALS", "Player ESP", "Hitmarker Color", 255, 255, 255, 255),
	hitmarker_size = ui.new_slider("VISUALS", "Player ESP", "World Hitmarker Size", 10, 20),
    hitmarker_type = ui.new_combobox("VISUALS", "Player ESP", "Animation", {"Fade out", "Sector out"}),
}

local function DistTo(x1,y1,z1,x2,y2,z2)
	return math.sqrt(math.pow(x1 - x2, 2) + math.pow( y1 - y2, 2) + math.pow( z1 - z2 , 2) )
end

local function OnBulletImpact(ctx)
	if ui.get(vars.hitmarker) then
		local Attacker = ctx.userid
		local Entity = client.userid_to_entindex(Attacker)

		if Entity == entity.get_local_player() then
			local originX = ctx.x
			local originY = ctx.y
			local originZ = ctx.z
			table.insert(impact_info, {originX, originY, originZ , globals.realtime()})
		end
	end
end

local function OnPlayerHurt(ctx)
	if ui.get(vars.hitmarker) then
		local Attacker = ctx.attacker
		local UserId = ctx.userid
		local Best, ImpactDist = -1, -1
		local BestX, BestY, BestZ = 0, 0, 0
		local Time = globals.realtime()
		local Entity = client.userid_to_entindex(Attacker)
		if Entity == entity.get_local_player() then
			local Posx, Posy, Posz = entity.get_prop(client.userid_to_entindex(UserId), "m_vecOrigin")
			for i = 1, #impact_info, 1 do
				if Time < impact_info[i][4] + 1 then
					local originX = impact_info[i][1]
					local originY = impact_info[i][2]
					local originZ = impact_info[i][3]

					local Dist = DistTo(Posx, Posy, Posz, originX, originY, originZ)
					if Dist < ImpactDist or ImpactDist == -1 then
						ImpactDist = Dist
						Best = i
						BestX = originX
						BestY = originY
						BestZ = originZ
					end
				end
			end
			for i = 1, #impact_info, 1 do 
				impact_info[i] = { 0 , 0 , 0 , 0 }
			end
			if ImpactDist == -1 then
				return
			end
			table.insert(hitmarker_info, {BestX, BestY, BestZ, 255})
		end
	end
end

local function OnRoundStart(ctx)
	for i = 1, #hitmarker_info, 1 do 
		hitmarker_info[i] = { 0 , 0 , 0 , 0 }
	end
	for i = 1, #impact_info, 1 do 
		impact_info[i] = { 0 , 0 , 0 , 0 }
	end
end

local function OnPreRoundStart(ctx)
	for i = 1, #hitmarker_info, 1 do 
		hitmarker_info[i] = { 0, 0 , 0 , 0 }
	end
	for i = 1, #impact_info, 1 do 
		impact_info[i] = { 0 , 0 , 0 , 0 }
	end
end

local function OnPlayerSpawned(ctx)
	local userid = ctx.userid
	local entid = client.userid_to_entindex(userid)
	if entid == entity.get_local_player() then
		for i = 1,#bullet_impact,1 do 
			bullet_impact[i] = { 0 , 0 , 0 , 0 }
		end
		for i = 1,#hitmarker_queue,1 do 
			hitmarker_queue[i] = { 0 , 0 , 0 , 0 }
		end
	end
end

local function OnPaint(ctx)
	if ui.get(vars.hitmarker) then
		local time = globals.realtime()
		local r, g, b, a = ui.get(vars.hitmarker_clr)
		local size = ui.get(vars.hitmarker_size)
		local type = ui.get(vars.hitmarker_type)
		
		for i = 1, #hitmarker_info, 1 do 
			a = hitmarker_info[i][4]
			local expired = true
			if expired then
				hitmarker_info[i][4] = hitmarker_info[i][4] - 2
			end
			if expired and hitmarker_info[i][4] <= 0 then
				hitmarker_info[i] = { 0, 0, 0, 0 }
			end
			local Posx, Posy, Posz = hitmarker_info[i][1], hitmarker_info[i][2], hitmarker_info[i][3]
			local X, Y = client.world_to_screen(ctx, Posx, Posy, Posz)
			if X ~= nil and Y ~= nil then
				if type == "Fade out" then
					local radius = (255 - a) / (30 - size)
					renderer.circle(X, Y, r, g, b, a, radius, 0, 1)
				elseif type == "Sector out" then
					renderer.circle(X, Y, r, g, b, a, size, 25, a / 255)
				end
			end
		end
	end
end

SetEventCallback("paint", OnPaint)
SetEventCallback("bullet_impact", OnBulletImpact)
SetEventCallback("player_hurt", OnPlayerHurt)
SetEventCallback("round_start", OnRoundStart)
SetEventCallback("round_prestart", OnPreRoundStart)
SetEventCallback("player_spawned", OnPlayerSpawned)