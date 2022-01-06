-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, vector
    = minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

local function pummelparticles(_, data)
	local pointed = data.pointed
	local nodedef = data.nodedef
	local pname = data.pname

	local stack = nodecore.stack_get(data.node)
	if stack and not stack:is_empty() then
		nodedef = minetest.registered_items[stack:get_name()] or nodedef
	end

	local a = pointed.above
	local b = pointed.under
	local vel = vector.subtract(a, b)
	local mid = vector.multiply(vector.add(a, b), 0.5)
	local p1 = {x = vel.y, y = vel.z, z = vel.x}
	local p2 = {x = vel.z, y = vel.x, z = vel.y}
	local s1 = vector.add(vector.add(mid, vector.multiply(p1, 0.5)), vector.multiply(p2, 0.5))
	local s2 = vector.add(vector.add(mid, vector.multiply(p1, -0.5)), vector.multiply(p2, -0.5))
	vel = vector.multiply(vel, 0.5)

	data.clearfx = nodecore.digparticles(nodedef, nodecore.underride(
			nodecore.underride({}, data.recipe.pumparticles or {}),
			{
				amount = 8,
				time = 1.5,
				minpos = s1,
				maxpos = s2,
				minvel = vel,
				maxvel = vel,
				minexptime = 0.4,
				maxexptime = 0.9,
				minsize = 1,
				maxsize = 5,
				playername = pname
			})
	)
end

local pummeling = {}

nodecore.register_on_dignode("dig pummel reset", function(_, _, digger)
		if not (digger and digger:is_player()) then return end
		pummeling[digger:get_player_name()] = nil
	end)

nodecore.register_on_punchnode("pummel check", function(pos, node, puncher, pointed)
		if (not puncher:is_player()) or puncher:get_player_control().sneak then return end
		local pname = puncher:get_player_name()
		if not nodecore.interact(pname) then return end

		node = node or minetest.get_node(pos)
		local def = minetest.registered_items[node.name] or {}
		if not def.pointable then return end

		local now = minetest.get_us_time() / 1000000
		local pum = {
			action = "pummel",
			crafter = puncher,
			pname = pname,
			pos = pos,
			pointed = pointed,
			node = node,
			nodedef = def,
			start = now,
			wield = puncher:get_wielded_item():to_string(),
			count = 0,
			inprogress = pummelparticles
		}

		local old = pummeling[pname]
		if old and old.clearfx then old.clearfx() end

		local hash = minetest.hash_node_position
		if old and hash(old.pos) == hash(pum.pos)
		and hash(old.pointed.above) == hash(pum.pointed.above)
		and hash(old.pointed.under) == hash(pum.pointed.under)
		and pum.wield == old.wield
		and old.last >= (now - 3)
		then pum = old end

		pum.count = pum.count + 1
		pum.last = now
		pum.duration = now - pum.start - 1
		pummeling[pname] = pum

		if pum.count < 2 then return end

		if nodecore.protection_test(pos, pname) then
			pummeling[pname] = nil
			return
		end

		if nodecore.craft_check(pos, node, nodecore.underride({}, pum)) then
			pummeling[pname] = nil
			return
		end
	end)
