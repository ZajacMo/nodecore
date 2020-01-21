-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, table
    = minetest, nodecore, pairs, table
local table_concat
    = table.concat
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local liquids = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_items) do
			if v.liquidtype and v.liquidtype ~= "none" then
				liquids[k] = true
			end
		end
	end)
function nodecore.player_swimming(player)
	local pos = player:get_pos()
	local r = 0.6
	for dz = -r, r, r do
		for dx = -r, r, r do
			local p = {
				x = pos.x + dx,
				y = pos.y,
				z = pos.z + dz
			}
			local node = minetest.get_node(p)
			if (node.name == "air" or liquids[node.name]) then
				p.y = p.y - 0.35
				node = minetest.get_node(p)
			end
			if not liquids[node.name] then return end
		end
	end
	return true
end

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

local anim_data = {
	stand = {x = 0, y = 0},
	sit = {x = 1, y = 1},
	walk = {x = 2, y = 42},
	mine = {x = 43, y = 57, speed = 0.85},
	lay = {x = 58, y = 58},
	walk_mine = {x = 59, y = 103},
	swim_up = {x = 105, y = 162, speed = 0.4},
	swim_down = {x = 163, y = 223, speed = 0.4},
	swim_mine = {x = 224, y = 281, speed = 0.5}
}
for k, v in pairs(anim_data) do
	v.name = k
	v.speed = 72 * (v.speed or 1)
end

nodecore.player_anim = nodecore.player_anim or function(player)
	local hp = player:get_hp()
	if hp <= 0 then
		return anim_data.lay
	end

	local ctl = player:get_player_control()
	local walk = ctl.up or ctl.down or ctl.right or ctl.left
	local mine = ctl.LMB or ctl.RMB

	if not nodecore.player_swimming(player) then
		if walk and mine then return anim_data.walk_mine end
		if walk then return anim_data.walk end
		if mine then return anim_data.mine end
		return anim_data.stand
	end

	if mine then return anim_data.swim_mine end
	local v = player:get_player_velocity()
	if v and v.y >= -0.5 then return anim_data.swim_up end
	return anim_data.swim_down
end

nodecore.player_visuals_base = nodecore.player_visuals_base or function(player)
	local mesh = player:get_meta():get_string("custom_mesh") or ""
	return {
		visual = "mesh",
		visual_size = {x = 0.9, y = 0.9, z = 0.9},
		mesh = mesh and mesh ~= "" and mesh or modname .. ".b3d"
	}
end
