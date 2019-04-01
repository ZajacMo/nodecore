-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, table, tonumber, vector
    = minetest, nodecore, pairs, table, tonumber, vector
local table_sort
    = table.sort
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
	for k, v in pairs(rots) do
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

local function sticks(node)
	if not node then return true end
	local def = minetest.registered_items[node.name]
	return def and def.groups and (not def.groups.silica)
	and (def.groups.cracky or def.groups.choppy)
end

local oldcsff = minetest.check_single_for_falling
function minetest.check_single_for_falling(pos, ...)
	local node = minetest.get_node_or_nil(pos)
	if not node then return oldcsff(pos, ...) end
	if minetest.get_item_group(node.name, "alpha_glyph") ~= 0 then
		local dp = vector.add(pos, nodecore.facedirs[node.param2].b)
		if not sticks(minetest.get_node_or_nil(dp)) then
			minetest.remove_node(pos)
			return true
		end
	end
	return oldcsff(pos, ...)
end

local function glyphspin(pos, node)
	node = node or minetest.get_node(pos)
	if node.name:sub(1, #nodepref) ~= nodepref then return itemstack end
	local np2 = spinmap[node.param2] or 0
	if np2 < node.param2 then
		local g = tonumber(node.name:sub(#nodepref + 1))
		if not g then return itemstack end
		g = g + 1
		if g > #glyphs then g = 1 end
		node.name = nodepref .. g
	end
	node.param2 = np2
	minetest.swap_node(pos, node)
	local def = minetest.registered_items[node.name] or {}
	if def.on_spin then def.on_spin(pos, node) end
end

local lasthits = {}
local no = minetest.log
minetest.register_on_punchnode(function(pos, node, puncher, pointed)
		if (not puncher) or (not puncher:is_player()) then return end

		local wield = puncher:get_wielded_item()
		if wield:get_name() ~= coallump then return no("lump") end

		if not sticks(node) then return no("stick") end

		local above = pointed.above
		local anode = minetest.get_node_or_nil(above)
		if not anode then return end

		if minetest.get_item_group(anode.name, "alpha_glyph") ~= 0 then
			return glyphspin(above, anode)
		end

		local pname = puncher:get_player_name()
		local now = minetest.get_us_time() / 1000000
		local last = lasthits[pname]
		if (not last) or (last.time < now - 2)
		or (not vector.equals(last.above, pointed.above))
		or (not vector.equals(last.under, pointed.under)) then
			lasthits[pname] = {
				time = now,
				above = pointed.above,
				under = pointed.under
			}
			return
		end
		lasthits[pname] = nil

		local dir = vector.subtract(pos, above)
		for i = 1, #nodecore.facedirs do
			if vector.equals(nodecore.facedirs[i].b, dir) then
				wield:take_item(1)
				puncher:set_wielded_item(wield)
				return minetest.set_node(above, {
						name = nodepref .. 1,
						param2 = i
					})
			end
		end
	end)
