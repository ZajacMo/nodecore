-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, table, tonumber,
      vector
    = ItemStack, math, minetest, nodecore, pairs, table, tonumber,
      vector
local math_floor, math_random, table_sort
    = math.floor, math.random, table.sort
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

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

local glyphnames = {
	"Cav",
	"Odo",
	"Niz",
	"Zin",
	"Mew",
	"Fot",
	"Tof",
	"Yit",
	"Geq",
	"Qeg",
	"Prx",
	"Xrp"
}

local glyph_next = {}
local glyph_alts = {}
for i = 2, #glyphs do
	glyph_next[i - 1] = i
	if #glyphs[i] > #glyphs[1] then
		glyph_next[i - 1] = (i < #glyphs) and i + 1 or 1
		glyph_alts[i] = i - 1
		glyph_alts[i - 1] = i
	end
	glyph_next[#glyphs] = 1
end

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
			spinmap[t[i]] = t[i + 1]
		end
		spinmap[t[#t]] = t[1]
	end
end

local nodepref = modname .. ":glyph"
local coallump = "nc_fire:lump_coal"

for i = 1, #glyphs do
	minetest.register_node(nodepref .. i, {
			description = glyphnames[i] .. " Charcoal Glyph",
			tiles = {
				glyphs[i],
				"[combine:1x1"
			},
			drawtype = "nodebox",
			node_box = nodecore.fixedbox(
				{-0.5, -15/32, -0.5, 0.5, -14/32, 0.5}
			),
			paramtype = "light",
			paramtype2 = "facedir",
			sunlight_propagates = true,
			walkable = false,
			buildable_to = true,
			pointable = false,
			groups = {
				flammable = 1,
				alpha_glyph = 1
			},
			drop = coallump,
			floodable = true
		})
end

local function writable(pos, node)
	node = node or minetest.get_node_or_nil(pos)
	if not node then return end
	local def = minetest.registered_nodes[node.name]
	return def.walkable and def.paramtype ~= "light"
	and not nodecore.tool_digs(ItemStack(""), def.groups)
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

nodecore.register_on_punchnode("charcoal writing check", function(pos, node, puncher, pointed)
		if (not puncher) or (not puncher:is_player()) then return end

		local wield = puncher:get_wielded_item()
		if wield:get_name() ~= coallump then return end

		if not writable(pos, node) then return end

		local above = pointed.above
		local anode = minetest.get_node_or_nil(above)
		if not anode then return end

		if minetest.get_item_group(anode.name, "alpha_glyph") ~= 0 then
			if anode.name:sub(1, #nodepref) ~= nodepref then return end
			local g = tonumber(anode.name:sub(#nodepref + 1))
			if g and glyph_next[g] then
				anode.name = nodepref .. glyph_next[g]
			end
			minetest.swap_node(above, anode)
			local def = minetest.registered_items[anode.name] or {}
			if def.on_spin then def.on_spin(above, anode) end
		end
	end)

local old_place = minetest.item_place
function minetest.item_place(itemstack, placer, pointed_thing, param2, ...)
	if not nodecore.interact(placer) or (itemstack:get_name() ~= "nc_fire:lump_coal") then
		return old_place(itemstack, placer, pointed_thing, param2, ...)
	end

	local above = pointed_thing.above
	local anode = minetest.get_node_or_nil(above)
	if (not anode) or (minetest.get_item_group(anode.name, "alpha_glyph") <= 0)
	or (not vector.equals(nodecore.facedirs[anode.param2].t,
			vector.subtract(pointed_thing.above, pointed_thing.under))) then
		return old_place(itemstack, placer, pointed_thing, param2, ...)
	end

	if anode.name:sub(1, #nodepref) ~= nodepref then return end
	local np2 = spinmap[anode.param2] or 0
	if np2 < anode.param2 then
		local g = tonumber(anode.name:sub(#nodepref + 1))
		if g and glyph_alts[g] then
			anode.name = nodepref .. glyph_alts[g]
		end
	end
	anode.param2 = np2
	minetest.swap_node(above, anode)
	local def = minetest.registered_items[anode.name] or {}
	if def.on_spin then def.on_spin(above, anode) end
end

nodecore.register_craft({
		label = "charcoal writing",
		action = "pummel",
		pumparticles = {
			minsize = 1,
			maxsize = 5,
			forcetexture = "nc_fire_coal_4.png^[resize:16x16^[mask:[combine\\:16x16\\:"
			.. math_floor(math_random() * 12) .. ","
			.. math_floor(math_random() * 12) .. "=nc_api_pummel.png"
		},
		duration = 2,
		wield = {name = "nc_fire:lump_coal", count = false},
		consumewield = 1,
		check = function(pos, data)
			return writable(pos) and minetest.get_node(data.pointed.above).name == "air"
		end,
		nodes = {{match = {walkable = true}}},
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
