-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs, vector
    = ItemStack, minetest, nodecore, pairs, vector
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

local startpos = {}
local function setup(p)
	local inv = p:get_inventory()
	for i, v in pairs(setinv) do
		if v then
			local s = ItemStack(v[1])
			s:set_count(v[2])
			if v[3] then s:set_wear(65535 * v[3]) end
			inv:set_stack("main", i, s)
		end
	end
	local pname = p:get_player_name()
	minetest.after(0, function()
			p = minetest.get_player_by_name(pname)
			if not p then return end
			startpos[pname] = p:get_pos()
		end)
end
nodecore.register_on_joinplayer(setup)
nodecore.register_on_respawnplayer(setup)

nodecore.register_playerstep({
		label = "mock inv clear",
		action = function(p)
			local pname = p:get_player_name()
			local pos = p:get_pos()
			local spos = startpos[pname]
			if not spos or vector.distance(pos, spos) < 1 then return end
			startpos[pname] = nil
			local inv = p:get_inventory()
			for i = 1, inv:get_size("main") do
				local sn = inv:get_stack("main", i):get_name()
				if sn:sub(1, #modname + 1) == modname .. ":" then
					inv:set_stack("main", i, "")
				end
			end
		end
	})
