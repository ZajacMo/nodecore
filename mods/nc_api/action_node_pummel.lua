-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

local pummeling = {}

minetest.register_on_punchnode(function(pos, node, puncher, pointed)
		if not puncher:is_player() then return end
		local pname = puncher:get_player_name()

		node = node or minetest.get_node(pos)
		local def = minetest.registered_nodes[node.name]
		if not def.on_pummel then return end

		local now = minetest.get_us_time() / 1000000
		local pum = {
			puncher = puncher,
			pname = pname,
			pos = pos,
			pointed = pointed,
			node = node,
			start = now,
			count = 0
		}

		local old = pummeling[pname]
		local hash = minetest.hash_node_position
		if old and hash(old.pos) == hash(pum.pos)
		and hash(old.pointed.above) == hash(pum.pointed.above)
		and hash(old.pointed.under) == hash(pum.pointed.under)
		and old.last >= (now - 2)
		then pum = old end

		pum.count = pum.count + 1
		pum.last = now
		pum.duration = now - pum.start
		pummeling[pname] = pum

		if def.on_pummel(pos, node, pum) then
			pummeling[pname] = nil
		end
	end)
