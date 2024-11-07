-- LUALOCALS < ---------------------------------------------------------
local core, math, nc, tonumber, vector
    = core, math, nc, tonumber, vector
local math_floor, math_random
    = math.floor, math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local nodepref = modname .. ":glyph"
local coallump = "nc_fire:lump_coal"

local skip = {}

nc.register_on_punchnode(function(pos, node, puncher, pointed)
		if skip[core.hash_node_position(pos)] == nc.gametime then return end
		if (not puncher) or (not puncher:is_player()) then return end

		local wield = puncher:get_wielded_item()
		if wield:get_name() ~= coallump then return end

		if not nc.writing_writable(pos, node) then return end

		local above = pointed.above
		local anode = core.get_node_or_nil(above)
		if not anode then return end
		if anode.name:sub(1, #nodepref) ~= nodepref then return end
		local g = tonumber(anode.name:sub(#nodepref + 1))
		if g and nc.writing_glyph_next[g] then
			anode.name = nodepref .. nc.writing_glyph_next[g]
		end
		core.swap_node(above, anode)
		nc.node_sound(above, "place", {node = anode})
		if core.get_item_group(anode.name, "alpha_glyph") ~= 0 then
			local def = core.registered_items[anode.name] or {}
			if def.on_spin then def.on_spin(above, anode) end
		end
		nc.player_discover(puncher, "place:" .. anode.name)
	end)

local old_place = core.item_place
function core.item_place(itemstack, placer, pointed_thing, param2, ...)
	if not nc.interact(placer) or (itemstack:get_name() ~= "nc_fire:lump_coal") then
		return old_place(itemstack, placer, pointed_thing, param2, ...)
	end

	local above = pointed_thing.above
	local anode = core.get_node_or_nil(above)
	if (not anode) or (core.get_item_group(anode.name, "alpha_glyph") <= 0)
	or (not vector.equals(nc.facedirs[anode.param2].t,
			vector.subtract(pointed_thing.above, pointed_thing.under))) then
		return old_place(itemstack, placer, pointed_thing, param2, ...)
	end

	if anode.name:sub(1, #nodepref) ~= nodepref then return end
	local np2 = nc.writing_spinmap[anode.param2] or 0
	if np2 < anode.param2 then
		local g = tonumber(anode.name:sub(#nodepref + 1))
		if g and nc.writing_glyph_alts[g] then
			anode.name = nodepref .. nc.writing_glyph_alts[g]
		end
	end
	anode.param2 = np2
	core.swap_node(above, anode)
	nc.node_sound(above, "place", {node = anode})
	local def = core.registered_items[anode.name] or {}
	if def.on_spin then def.on_spin(above, anode) end
	nc.player_discover(placer, "charcoal writing rotate")
end

local function setglyphdir(pos, dir)
	for i = 0, #nc.facedirs do
		if vector.equals(nc.facedirs[i].b, dir)
		and nc.facedirs[i].k.y > 0 then
			return nc.set_loud(pos, {
					name = nodepref .. 1,
					param2 = i
				})
		end
	end
end

nc.register_craft({
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
			return nc.writing_writable(pos)
			and core.get_node(data.pointed.above).name == "air"
		end,
		nodes = {{match = {walkable = true}}},
		after = function(pos, data)
			skip[core.hash_node_position(pos)] = nc.gametime

			local dir = vector.subtract(pos, data.pointed.above)
			if dir.y == 0 then return setglyphdir(data.pointed.above, dir) end

			local look = data.crafter and data.crafter:get_look_dir()
			if not look then return setglyphdir(data.pointed.above, dir) end

			local bestface = 0
			local bestdot = 2
			for i = 0, #nc.facedirs do
				local face = nc.facedirs[i]
				if vector.equals(face.b, dir) then
					local dot = vector.dot(look, face.k) * dir.y
					if dot < bestdot then
						bestdot = dot
						bestface = i
					end
				end
			end
			return nc.set_loud(data.pointed.above, {
					name = nodepref .. 1,
					param2 = bestface
				})
		end
	})
