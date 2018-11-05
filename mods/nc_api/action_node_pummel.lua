-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
= minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local pummeling = {}

local function particlefx(pname, pointed)
	local a = pointed.above
	local b = pointed.under
	local vel = vector.subtract(a, b)
	local mid = vector.multiply(vector.add(a, b), 0.5)
	local p1 = {x = vel.y, y = vel.z, z = vel.x}
	local p2 = {x = vel.z, y = vel.x, z = vel.y}
	local s1 = vector.add(vector.add(mid, vector.multiply(p1, 0.5)), vector.multiply(p2, 0.5))
	local s2 = vector.add(vector.add(mid, vector.multiply(p1, -0.5)), vector.multiply(p2, -0.5))
	vel = vector.multiply(vel, 0.5)
	return minetest.add_particlespawner({
			amount = 5,
			time = 1.5,
			minpos = s1,
			maxpos = s2,
			minvel = vel,
			maxvel = vel,
			minexptime = 0.4,
			maxexptime = 0.9,
			scale = 0.05,
			texture = "nc_api_pummel.png",
			playername = pname
		})
end

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

		if def.can_pummel then
			pum.check = def.can_pummel(pos, node, pum)
			if not pum.check then
				pummeling[pname] = nil
				return
			end
		end

		if pum.count > 1 then
			if pum.particles then minetest.delete_particlespawner(pum.particles) end
			pum.particles = particlefx(pname, pointed)
		end

		if def.on_pummel(pos, node, pum) then
			if pum.particles then minetest.delete_particlespawner(pum.particles) end
			nodecore.player_knowledge_add(puncher, "pummel:" .. node.name)
			pummeling[pname] = nil
		end
	end)
