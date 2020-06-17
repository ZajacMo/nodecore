-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, table
    = math, minetest, nodecore, pairs, table
local math_floor, table_concat
    = math.floor, table.concat
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.player_skin = nodecore.player_skin or function(player)
	local skin = player:get_meta():get_string("custom_skin") or ""
	if skin ~= "" then return skin end

	local layers = {modname .. "_base.png"}

	local privs = minetest.get_player_privs(player:get_player_name())
	if not privs.interact then
		layers[#layers + 1] = modname .. "_no_interact.png"
		layers[#layers + 1] = "[makealpha:254,0,253"
	end
	if not privs.shout then
		layers[#layers + 1] = modname .. "_no_shout.png"
	end

	return table_concat(layers, "^"), layers
end

nodecore.player_anim_data = nodecore.player_anim_data or {
	stand = {x = 0, y = 0},
	sit = {x = 1, y = 1},
	walk = {x = 2, y = 42},
	mine = {x = 43, y = 57, speed = 0.85},
	lay = {x = 58, y = 58},
	walk_mine = {x = 59, y = 103},
	swim_up = {x = 105, y = 161, speed = 0.4},
	swim_down = {x = 162, y = 223, speed = 0.4},
	swim_mine = {x = 224, y = 280, speed = 0.4},
	wave = {x = 281, y = 295, speed = 0.4}
}
for k, v in pairs(nodecore.player_anim_data) do
	v.name = k
	v.speed = 60 * (v.speed or 1)
end

local function walkspeed(player, anim)
	if not anim.speed then return anim end
	local phys = player:get_physics_override()
	local speed = math_floor(phys.speed * 10) / 10
	if speed == 1 then return anim end
	local t = {}
	for k, v in pairs(anim) do
		t[k] = (k == "speed") and (speed * v) or v
	end
	return t
end

local eye_stand = 1.625
local eye_swim = 0.5
local eye_lay = 0.5

nodecore.player_anim = nodecore.player_anim or function(player)
	local hp = player:get_hp()
	if hp <= 0 then
		return nodecore.player_anim_data.lay, eye_lay
	end

	local ctl = player:get_player_control()
	local walk = (ctl.up or ctl.down) and not (ctl.up and ctl.down)
	or (ctl.right or ctl.left) and not (ctl.right and ctl.left)
	local mine = ctl.LMB or ctl.RMB
	local aux = ctl.aux1

	if not nodecore.player_swimming(player) then
		if walk and mine then return walkspeed(player, nodecore.player_anim_data.walk_mine), eye_stand end
		if walk then return walkspeed(player, nodecore.player_anim_data.walk), eye_stand end
		if mine then return nodecore.player_anim_data.mine, eye_stand end
		if aux then return nodecore.player_anim_data.wave, eye_stand end
		return nodecore.player_anim_data.stand, eye_stand
	end

	if mine then return walkspeed(player, nodecore.player_anim_data.swim_mine), eye_swim end
	local v = player:get_player_velocity()
	if v and v.y >= -0.5 then return walkspeed(player, nodecore.player_anim_data.swim_up), eye_swim end
	return walkspeed(player, nodecore.player_anim_data.swim_down), eye_swim
end

nodecore.player_visuals_base = nodecore.player_visuals_base or function(player)
	local mesh = player:get_meta():get_string("custom_mesh") or ""
	return {
		visual = "mesh",
		visual_size = {x = 0.9, y = 0.9, z = 0.9},
		mesh = mesh and mesh ~= "" and mesh or modname .. ".b3d"
	}
end
