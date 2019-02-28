-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, minetest, nodecore, pairs, type
    = ItemStack, ipairs, minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function meta(pos)
	local node = minetest.get_node(pos)

	return node, meta
end

local function totedug(pos, node, meta, digger)
	local dump
	for dx = -1, 1 do
		for dz = -1, 1 do
			local p = {x = pos.x + dx, y = pos.y, z = pos.z + dz}
			local n = minetest.get_node(p)
			local d = minetest.registered_items[n.name] or {}
			if d and d.groups and d.groups.totable then
				local m = minetest.get_meta(p):to_table()
				for k1, v1 in pairs(m.inventory or {}) do
					for k2, v2 in pairs(v1) do
						if type(v2) == "userdata" then
							v1[k2] = v2:to_string()
						end
					end
				end
				dump = dump or {}
				dump[#dump + 1] = {
					x = dx,
					z = dz,
					n = n,
					m = m
				}
				minetest.remove_node(p)
			end
		end
	end
	local drop = ItemStack(modname .. ":handle")
	drop:get_meta():set_string("inv", dump and minetest.serialize(dump))
	minetest.handle_node_drops(pos, {drop}, digger)
end

local function toteplace(stack, placer, pointed)
	local pos = nodecore.buildable_to(pointed.under) and pointed.under
	or nodecore.buildable_to(pointed.above) and pointed.above
	if not pos then return stack end

	stack = ItemStack(stack)
	local inv = stack:get_meta():get_string("inv")
	inv = inv and (inv ~= "") and minetest.deserialize(inv)
	if not inv then
		minetest.set_node(pos, {name = stack:get_name()})
		stack:set_count(stack:get_count() - 1)
		return stack
	end

	local commit = {{pos, {name = stack:get_name()}, {}}}
	for _, v in ipairs(inv) do
		if commit then
			local p = {x = pos.x + v.x, y = pos.y, z = pos.z + v.z}
			if not nodecore.buildable_to(p) then
				commit = nil
			else
				commit[#commit + 1] = {p, v.n, v.m}
			end
		end
	end
	if commit then
		for _, v in ipairs(commit) do
			minetest.set_node(v[1], v[2])
			minetest.get_meta(v[1]):from_table(v[3])
		end
		stack:set_count(stack:get_count() - 1)
	end
	return stack
end

minetest.register_node(modname .. ":handle", {
		description = "Tote Handle",
		tiles = { "nc_woodwork_plank.png" },
		groups = {
			choppy = 1,
			flammable = 2,
			fire_fuel = 5
		},
		after_dig_node = totedug,
		on_place = toteplace,
		drop = ""
	})
