-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, table, tonumber,
      vector
    = ItemStack, math, minetest, nodecore, pairs, table, tonumber,
      vector
local math_floor, math_random, table_sort
    = math.floor, math.random, table.sort
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local glyphs = {
	modname .. "_ava.png",
	modname .. "_del.png",
	modname .. "_enz.png",
	modname .. "_enz.png^[transformFX",
	modname .. "_san.png",
	modname .. "_tef.png",
	modname .. "_tef.png^[transformFX",
	modname .. "_yut.png",
	modname .. "_geq.png",
	modname .. "_geq.png^[transformFX",
	modname .. "_rex.png",
	modname .. "_rex.png^[transformFX"
}

local spinmap
do
	local rots = {}
	for i = 0, 23 do
		local f = nodecore.facedirs[i]
		local r = rots[f.t.n]
		if not r then
			r = {}
			rots[f.t.n] = r
		end
		r[f.f.n] = i
	end
	spinmap = {}
	for _, v in pairs(rots) do
		local t = {}
		for _, x in pairs(v) do t[#t + 1] = x end
		table_sort(t)
		for i = 1, #t - 1 do
			spinmap[t[i] ] = t[i + 1]
		end
		spinmap[t[#t] ] = t[1]
	end
end

local nodepref = modname .. ":glyph"
local coallump = "nc_fire:lump_coal"

for i = 1, #glyphs do
	minetest.register_node(nodepref .. i, {
			description = "Charcoal Glyph",
			tiles = {
				glyphs[i],
				modname .. "_blank.png"
			},
			drawtype = "nodebox",
			node_box = nodecore.fixedbox(
				{-0.5, -0.5, -0.5, 0.5, -7/16, 0.5}
			),
			paramtype = "light",
			paramtype2 = "facedir",
			sunlight_propagates = true,
			walkable = false,
			buildable_to = true,
			pointable = false,
			groups = {
				alpha_glyph = 1,
				snappy = 1
			},
			drop = coallump,
			floodable = true
		})
end

local function writable(pos, node)
	node = node or minetest.get_node_or_nil(pos)
	if not node then return end
	local def = minetest.registered_nodes[node.name]
	return not nodecore.toolspeed(ItemStack(""), def.groups)
end

local oldcsff = minetest.check_single_for_falling
function minetest.check_single_for_falling(pos, ...)
	local node = minetest.get_node_or_nil(pos)
	if not node then return oldcsff(pos, ...) end
	if minetest.get_item_group(node.name, "alpha_glyph") ~= 0 then
		local dp = vector.add(pos, nodecore.facedirs[node.param2].b)
		if not writable(dp) then
			minetest.remove_node(pos)
			return true
		end
	end
	return oldcsff(pos, ...)
end

local function glyphspin(pos, node)
	node = node or minetest.get_node(pos)
	if node.name:sub(1, #nodepref) ~= nodepref then return end
	local np2 = spinmap[node.param2] or 0
	if np2 < node.param2 then
		local g = tonumber(node.name:sub(#nodepref + 1))
		if not g then return end
		g = g + 1
		if g > #glyphs then g = 1 end
		node.name = nodepref .. g
	end
	node.param2 = np2
	minetest.swap_node(pos, node)
	local def = minetest.registered_items[node.name] or {}
	if def.on_spin then def.on_spin(pos, node) end
end

minetest.register_on_punchnode(function(pos, node, puncher, pointed)
		if (not puncher) or (not puncher:is_player()) then return end

		local wield = puncher:get_wielded_item()
		if wield:get_name() ~= coallump then return end

		if not writable(pos, node) then return end

		local above = pointed.above
		local anode = minetest.get_node_or_nil(above)
		if not anode then return end

		if minetest.get_item_group(anode.name, "alpha_glyph") ~= 0 then
			return glyphspin(above, anode)
		end
	end)

nodecore.register_craft({
		label = "charcoal writing",
		action = "pummel",
		pumparticles = {
			minsize = 1,
			maxsize = 5,
			forcetexture = "nc_fire_coal_4.png^[mask:[combine\\:16x16\\:"
			.. math_floor(math_random() * 12) .. ","
			.. math_floor(math_random() * 12) .. "=nc_api_pummel.png"
		},
		duration = 2,
		wield = {name = "nc_fire:lump_coal", count = false},
		consumewield = 1,
		check = function(pos, data)
			return writable(pos) and minetest.get_node(data.pointed.above).name == "air"
		end,
		nodes = { { match = {walkable = true} } },
		after = function(pos, data)
			local dir = vector.subtract(pos, data.pointed.above)
			for i = 1, #nodecore.facedirs do
				if vector.equals(nodecore.facedirs[i].b, dir) then
					return minetest.set_node(data.pointed.above, {
							name = nodepref .. 1,
							param2 = i
						})
				end
			end
		end
	})
