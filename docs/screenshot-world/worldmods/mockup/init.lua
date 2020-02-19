-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, pairs
    = ItemStack, math, minetest, pairs
local math_pi
    = math.pi
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname();

minetest.settings:set("time_speed", 0)
minetest.after(0, function() minetest.set_timeofday(0.5) end)

local setinv = {
	{"nc_stonework:tool_pick", 1, 0.7},
	{"nc_stonework:tool_spade", 1, 0.8},
	{"nc_stonework:tool_hatchet", 1, 0.4},
	{"nc_stonework:tool_mallet", 1, 0.2},
	{"nc_stonework:chip", 54},
	false,
	{"nc_terrain:sand_loose", 14},
	{"nc_terrain:dirt_loose", 47}
}

for _, v in pairs(setinv) do
	if v then
		local n = modname .. ":" .. v[1]:gsub(":", "_")
		if not minetest.registered_items[n] then
			print(v[1])
			local def = minetest.registered_items[v[1]]
			minetest.register_item(n, {
					["type"] = def["type"],
					tiles = def.tiles,
					inventory_image = def.inventory_image,
					wield_image = def.wield_image,
					on_drop = function() return ItemStack("") end,
					on_place = function() end,
					on_use = function() end
				})
		end
		v[1] = n
	end
end

local function setup(p)
	local n = p:get_player_name()

	local r = minetest.get_player_privs(n)
	r.fly = true
	r.fast = true
	r.give = true
	r.interact = true
	r.nc_reative = true
	minetest.set_player_privs(n, r)

	p:set_pos({x = -112.6, y = 5, z = -92.6})
	p:set_look_horizontal(163.8 * math_pi / 180)
	p:set_look_vertical(9 * math_pi / 180)

	p:hud_set_flags({crosshair = false})

	local inv = p:get_inventory()
	for i, v in pairs(setinv) do
		if v then
			local s = ItemStack(v[1])
			s:set_count(v[2])
			if v[3] then s:set_wear(65535 * v[3]) end
			inv:set_stack("main", i, s)
		end
	end
end
minetest.register_on_joinplayer(setup)
minetest.register_on_respawnplayer(setup)
