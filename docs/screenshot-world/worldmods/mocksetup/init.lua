-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, vector
    = ItemStack, math, minetest, nodecore, pairs, vector
local math_abs, math_pi
    = math.abs, math.pi
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname();

local setinv = {
	{"nc_stonework:tool_pick", 1, 0.7},
	{"nc_stonework:tool_spade", 1, 0.8},
	{"nc_stonework:tool_hatchet", 1, 0.4},
	{"nc_stonework:tool_mallet", 1, 0.2},
	{"nc_stonework:chip", 54},
	{"air", 1, nil, "[combine:1x1"},
	{"nc_terrain:sand_loose", 14},
	{"nc_terrain:dirt_loose", 47}
}

for _, v in pairs(setinv) do
	local n = modname .. ":" .. v[1]:gsub(":", "_")
	if not minetest.registered_items[n] then
		local def = minetest.registered_items[v[1]]
		minetest.register_item(n, {
				["type"] = def["type"],
				tiles = def.tiles,
				inventory_image = v[4] or def.inventory_image,
				wield_image = v[4] or def.wield_image,
				on_drop = function() return ItemStack("") end,
				on_place = function() end,
				on_use = function() end
			})
	end
	v[1] = n
end

local startpos = {x = -112.4, y = 4.55, z = -91.8}

nodecore.register_on_joinplayer(function(player)
		return player:set_pos(startpos)
	end)

local function enable_setup(player, ppos)
	local n = player:get_player_name()

	local r = minetest.get_player_privs(n)
	r.fly = true
	r.fast = true
	r.noclip = true
	r.debug = true
	r.basic_debug = true
	r.give = true
	r.pulverize = true
	r.interact = true
	r.keepinv = true
	r.ncdqd = true
	r.teleport = true
	minetest.set_player_privs(n, r)

	if math_abs(ppos.x - startpos.x) >= 0.001
	or math_abs(ppos.z - startpos.z) >= 0.001 then
		player:set_pos(startpos)
	end
	player:set_look_horizontal(163.8 * math_pi / 180)
	player:set_look_vertical(9 * math_pi / 180)

	nodecore.hud_set(player, {label = "crosshair", ttl = 0})
	player:set_fov(60)

	local inv = player:get_inventory()
	for i, v in pairs(setinv) do
		if v then
			local s = ItemStack(v[1])
			s:set_count(v[2])
			if v[3] then s:set_wear(65535 * v[3]) end
			inv:set_stack("main", i, s)
		end
	end
end

local function disable_setup(player)
	player:set_fov(0, false, 0.25)

	local inv = player:get_inventory()
	for i = 1, inv:get_size("main") do
		local sn = inv:get_stack("main", i):get_name()
		if sn:sub(1, #modname + 1) == modname .. ":" then
			inv:set_stack("main", i, "")
		end
	end
end

nodecore.register_playerstep({
		label = "mock hud/fov clear",
		action = function(player, data)
			data.properties.visual_size = {x = 0, y = 0}

			nodecore.hud_set(player, {label = "cheats", ttl = 0})
			nodecore.hud_set(player, {label = "hintcomplete", ttl = 0})

			local ppos = player:get_pos()
			if vector.distance(ppos, startpos) <= 1
			and player:get_player_control_bits() == 0 then
				enable_setup(player, ppos)
			else
				disable_setup(player)
			end
		end
	})
