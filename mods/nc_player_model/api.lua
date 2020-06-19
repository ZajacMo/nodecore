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
	lay = {x = 2, y = 2},
	walk = {x = 3, y = 27},
	walk_mine = {x = 28, y = 52},
	mine = {x = 53, y = 77},
	swim_mine = {x = 78, y = 108, speed = 0.6},
	swim_up = {x = 109, y = 133, speed = 0.6},
	swim_down = {x = 134, y = 158, speed = 0.6},
	wave = {x = 159, y = 171, speed = 0.8}
}
for k, v in pairs(nodecore.player_anim_data) do
	v.name = k
	v.speed = 30 * (v.speed or 1)
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

nodecore.player_anim = nodecore.player_anim or function(player)
	local hp = player:get_hp()
	if hp <= 0 then
		return nodecore.player_anim_data.lay
	end

	local ctl = player:get_player_control()
	local walk = (ctl.up or ctl.down) and not (ctl.up and ctl.down)
	or (ctl.right or ctl.left) and not (ctl.right and ctl.left)
	local mine = ctl.LMB or ctl.RMB
	local aux = ctl.aux1

	if not nodecore.player_swimming(player) then
		if walk and mine then return walkspeed(player, nodecore.player_anim_data.walk_mine) end
		if walk then return walkspeed(player, nodecore.player_anim_data.walk) end
		if mine then return nodecore.player_anim_data.mine end
		if aux then return nodecore.player_anim_data.wave end
		return nodecore.player_anim_data.stand
	end

	if mine then return walkspeed(player, nodecore.player_anim_data.swim_mine) end
	if not (walk or ctl.jump or ctl.sneak or (ctl.left or ctl.right)
		and not (ctl.left and ctl.right)) then
		local t = {}
		for k, v in pairs(nodecore.player_anim_data.swim_up) do
			t[k] = (k == "speed") and (0.1 * v) or v
		end
		return t
	end
	local v = player:get_player_velocity()
	if v and v.y >= -0.5 then return walkspeed(player, nodecore.player_anim_data.swim_up) end
	return walkspeed(player, nodecore.player_anim_data.swim_down)
end

nodecore.player_visuals_base = nodecore.player_visuals_base or function(player)
	local mesh = player:get_meta():get_string("custom_mesh") or ""
	return {
		visual = "mesh",
		visual_size = {x = 0.9, y = 0.9, z = 0.9},
		mesh = mesh and mesh ~= "" and mesh or modname .. ".b3d"
	}
end
